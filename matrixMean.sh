# matixMean.sh
#!/bin/bash

# take and MxN matrix and return an 1xN row vector,
# where the first element is the mean of column one,
# the second element is the mean of column two, and so on
temp="tempfile"

function dims(){
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


for (( i=1; i<=$columns; i=i+1))
do
    rowSum=0
    column=$(cut -f"$i" $1 | paste -s)
    for j in $column
    do
        rowSum=`expr $rowSum + $j`
    done
    mean=$((($rowSum + ($columns/2)*( ($rowSum>0)*2-1 )) / $columns))
    printf "%d" $mean
    if [ $i -ne $columns ]
    then
        printf "\t"
    fi
done
    printf "\n"