# matrixTranspose.sh
#!/bin/bash

# reflect the elements of the matrix along the main diagonal.
# An MxN matrix will become and NxM matrix and the values
# along the main diagonal will remain unchanged

# rows=0
# columns=0

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
    cut -f"$i" $1 | paste -s
done