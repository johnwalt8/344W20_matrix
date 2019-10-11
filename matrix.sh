#!/bin/bash

# matrix
# Walter Johnson: johnwalt@oregonstate.edu
# CS344 OPERATING SYSTEMS I
# Fall 2019

# calculates basic matrix operations: dimensions, transpose, mean vector, add, multiply
#   input: matrix - whole number values separated by tabs into a rectangular matrix
# accepts the following operations:
#   dims - print the dimensions of the matrix as the number of rows, followed by a space, then the number of columns
#       arguments: single file path or stdin
#   transpose - reflect the elements of the matrix along the main diagonal. Thus, an MxN matrix will become an NxM matrix and the values along the main diagonal will remain unchanged
#       arguments: single file path or stdin
#   mean - take an MxN matrix and return an 1xN row vector, where the first element is the mean of column one, the second element is the mean of column two, and so on.
#       arguments: single file path or stdin
#   add - take two MxN matrices and add them together element-wise to produce an MxN matrix. add should return an error if the matrices do not have the same dimensions.
#       arguments: two file paths
#   multiply - take an MxN and NxP matrix and produce an MxP matrix.
#       arguments: two file paths
TMP="tempfile$$"

trap "rm -f $TMP" EXIT
trap "echo ' SIGNAL received: deleting temp file then exiting'; rm -f $TMP; exit 13" INT HUP TERM

function dims(){
    rows=0
    total=0
    columns=0
    columnsRoundedUp=0
    rows=`wc -l < $1`
    if [[ $rows == 0 ]]
    then
        echo "file is empty" >&2
        exit 13
    fi
    total=`wc -w < $1`
    columns=`expr $total / $rows` # bash integer math rounds down
    columnsRoundedUp=$(( ($total + ($rows-1)) / $rows ))

    if [[ $columns != $columnsRoundedUp ]]
    then
            echo "invalid matrix: not all rows the same length" >&2
            exit 13
    fi
}

function transpose(){
    dims $1
    for (( i=1; i<=$columns; i=i+1))
    do
        cut -f"$i" $1 | paste -s
    done
}

function mean(){
    dims $1
    for (( i=1; i<=$columns; i=i+1))
    do
        columnSum=0
        column=$(cut -f"$i" $1 | paste -s)
        for j in $column
        do
            columnSum=`expr $columnSum + $j`
        done
        mean=$(( ($columnSum + ($rows/2)*( ($columnSum>0)*2-1 )) / $rows ))
        printf "%d" $mean
        if [ $i -ne $columns ]
        then
            printf "\t"
        fi
    done
    printf "\n"
}

function add(){
    dims $1

    leftRows=$rows
    leftColumns=$columns

    dims $2

    if [[ $leftRows -ne $rows || $leftColumns -ne $columns ]]
    then
        echo "invalid matrices: adding matrices requires that the two matrices be the same dimensions" >&2
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
}

function multiply(){
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
}

if [[ $# -gt 3 || $# -lt 1 ]]
then
    echo "invalid number of arguments" >&2
    exit 13
fi

case $1 in
    dims|transpose|mean)
        case $# in
            1)  echo "enter a tab-delimited matrix, then hit CTRL+D:"
                cat > $TMP
                subjectFile=$TMP
                ;;
            2)  if [[ -r $2 ]]
                then
                    subjectFile=$2
                else
                    echo "file is not readable" >&2
                    exit 13
                fi
                ;;
            *)  echo "invalid number of arugments for this operation" >&2
                exit 13
                ;;
        esac
        case $1 in
            dims)       dims $subjectFile
                        echo "$rows $columns"
                        ;;
            transpose)  transpose $subjectFile
                        ;;
            mean)       mean $subjectFile
                        ;;
            *)          echo "something, somewhere, went just a little bit wrong: A" >&2
                        ;;
        esac
        ;;
    add|multiply)
        if [[ $# -ne 3 ]]
        then
            echo "this operation requires matrices as the second and third arguments" >&2
            exit 13
        fi
        if [[ -r $2 && -r $3 ]]
        then
            case $# in
                3)  case $1 in
                        add)        add $2 $3
                                    ;;
                        multiply)   multiply $2 $3
                                    ;;
                        *)          echo "something, somewhere, went just a little bit wrong: B" >&2
                                    ;;
                    esac
                    ;;
                *)  echo "invalid number of arguments for this operation" >&2
                    exit 13
                    ;;
            esac
        else
            echo "at least one of these files is not readable" >&2
            exit 13
        fi
        ;;
    *)
        echo "invalid operation" >&2
        exit 13
        ;;
esac