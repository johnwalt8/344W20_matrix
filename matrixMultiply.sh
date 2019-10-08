# matrixMultiply.sh
#!/bin/bash

# take an MxN and an NxP matrix and produce an MxP matrix.
# note that matrix multiplication is not commutative.

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

if [[ $leftColumns -ne $rows ]]
then
    echo "invalid matrices: multipying matrices requires that number of columns in the first matrix is equal to the number of rows in the second matrix" >&2
    exit 13
fi

for (( i=1; i<=$leftRows; i=i+1))
do
    lRow=$( cat $1 | tail -n+$i | head -n1 )
    for (( j=1; j<=$columns; j=j+1))
    do
        dotProduct=0
        rColumn=$(cut -f"$j" $2 | paste -s)
        for (( k=1; k<=$leftColumns; k=k+1))
        do
            lField=$( echo $lRow | cut -d' ' -f$k )
            rField=$( echo $rColumn | cut -d' ' -f$k )
            dotProduct=$(( $dotProduct+($lField*$rField) ))
        done
        printf "%d" "$dotProduct"
        if [ $j -ne $columns ]
        then
            printf "\t"
        fi
    done
    printf "\n"
done