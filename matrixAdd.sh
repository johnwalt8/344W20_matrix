# matrixAdd.sh
#!/bin/bash

# take two MxN matrices and add them together element-wise to produce and MxN matrix.
# should return and error of the matrices do not have the same dimensions

function dims(){
    rows=0
    total=0
    columns=0
    decColumns=0
    intColumns=0
    rows=`wc -l < $1`
    total=`wc -w < $1`
    columns=`expr $total / $rows`
    decColumns=$(bc <<< "scale=2;$total / $rows")
    intColumns=$(bc <<< "scale=2;$columns / 1")

    if [[ $intColumns != $decColumns ]]
    then
            echo "invalid matrix: not all rows are the same length" >&2
            exit 13
    fi
}
dims $1

leftRows=$rows
leftColumns=$columns

dims $2

if [[ $leftRows -ne $rows || $leftColumns -ne $columns ]]
then
    echo "invalid matrices: adding matrices requires that the two matrices be the same dimensions"
    exit 13
fi

for (( i=1; i<=$rows; i=i+1))
do
    lRow=$( cat $1 | tail -n+$i | head -n1 )
    rRow=$( cat $2 | tail -n+$i | head -n1 )
    for (( j=1; j<=$columns; j=j+1))
    do
        lField=$( echo $lRow | cut -d' ' -f$j )
        rField=$( echo $rRow | cut -d' ' -f$j )
        printf "%d" "$(( $lField + $rField ))"
        if [ $j -ne $columns ]
        then
            printf "\t"
        fi
    done
    printf "\n"
done

# for (( i=1; i<=$columns; i=i+1))
# do
#     field=$( echo $row | cut -d' ' -f$i )
#     echo "i: $i, field: $field"
# done