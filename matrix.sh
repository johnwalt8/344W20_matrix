#!/bin/bash

# matrix
# Walter Johnson: johnwalt@oregonstate.edu
# CS344 OPERATING SYSTEMS I
# Winter 2020 

# Based on code written by Walter for CS344 Fall 2019 with permission from Bram Lewis.  

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

trap "rm -f $TMP" EXIT # removes temporary file at any exit
trap "echo ' SIGNAL received: deleting temp file then exiting'; rm -f $TMP; exit 13" INT HUP TERM

# matrixDimensions - determines number of rows and columns in a rectangular matrix, 
#   saves values in variables "rows" and "columns"
# USE: matrixDimensions [MATRIX_FILE_PATH]
function matrixDimensions(){
    numberOfRows=0          # global variable used throughout "matrix"
    totalNumElements=0      # total number of elements (integers) in matrix
    numberOfColumns=0       # global variable used throughout "matrix"
    columnsRoundedUp=0      # must be the same as "columns" for a valid matrix

    numberOfRows=$( wc -l < $1 )    # number of rows in file
    if [[ $numberOfRows == 0 ]]
    then
        echo "file is empty" >&2
        exit 13
    fi
    totalNumElements=$( wc -w < $1 )   # number of "words" in file (number of elements in matrix)
    numberOfColumns=$(( $totalNumElements / $numberOfRows )) # bash integer math rounds down
    columnsRoundedUp=$(( ($totalNumElements + ($numberOfRows-1)) / $numberOfRows ))

    if [[ $numberOfColumns != $columnsRoundedUp ]]
    then
            echo "invalid matrix: not all rows the same length" >&2
            exit 13
    fi
}

# transposeMatrix - reflects the elements of the matrix along the main diagonal, 
#   that is, first row becomes first column, second row becomes second column, and so on
# USE: transposeMatrix [MATRIX_FILE_PATH]
function transposeMatrix(){
    matrixDimensions $1  # global "numberOfColumns" variable is used in following for loop

    for (( i=1; i<=$numberOfColumns; i=i+1))
    do
        cut -f"$i" $1 | paste -s        # takes "i"th field (element) of EVERY line,
    done                                #   writes as TAB (default) deliminated line
}

# matrixMean - prints mean of each column of a matrix in a single row such that the first element
#   of the row is mean of the first column of the matrix, and so on
# USE: matrixMean [MATRIX_FILE_PATH]
function matrixMean(){
    matrixDimensions $1  # global "numberOfColumns" variable is used in following for loop

    for (( i=1; i<=$numberOfColumns; i=i+1))
    do
        columnElementsSum=0
        column=$(cut -f"$i" $1 | paste -s)  # elements of column "i" as a TAB delimited line

        for element in $column
        do
            columnElementsSum=$(( $columnElementsSum + $element ))
        done

        mean=$(( ($columnElementsSum + ($numberOfRows/2)*( ($columnElementsSum>0)*2-1 )) / $numberOfRows )) # ***.5 values rounded away from zero as bash integer math rounds down
        printf "%d" $mean

        if [ $i -ne $numberOfColumns ] # if it is not the last element
        then
            printf "\t"
        fi
    done
    printf "\n" # after the last element
}

# addMatrices - takes two matrices of the same dimensions and adds corresponding elements
#   to create a matrix of the same dimensions
# USE: addMatrices [FIRST_MATRIX_FILE_PATH] [SECOND_MATRIX_FILE_PATH]
function addMatrices(){
    matrixDimensions $1 # determines number of rows and columns of first matrix for comparison

    firstMatrixRows=$numberOfRows
    firstMatrixColumns=$numberOfColumns

    matrixDimensions $2

    # matrices must have the same dimensions for matrix addition
    if [[ $firstMatrixRows -ne $numberOfRows || $firstMatrixColumns -ne $numberOfColumns ]]
    then
        echo "invalid matrices: adding matrices requires that the two matrices be the same dimensions" >&2
        exit 13
    fi

    # matrix addition - add corresponding elements
    for (( i=1; i<=$numberOfRows; i=i+1)) # for each row
    do
        rowFirstMatrix=$( cat $1 | tail -n+$i | head -n1 ) # "i"th row
        rowSecondMatrix=$( cat $2 | tail -n+$i | head -n1 )

        for (( j=1; j<=$numberOfColumns; j=j+1)) # for each element of the row
        do
            elementFirstMatrix=$( echo $rowFirstMatrix | cut -d' ' -f$j ) # "j"th element
            elementSecondMatrix=$( echo $rowSecondMatrix | cut -d' ' -f$j )

            printf "%d" "$(( $elementFirstMatrix + $elementSecondMatrix ))"

            if [ $j -ne $numberOfColumns ] # if not the last element
            then
                printf "\t"
            fi
        done
        printf "\n" # after the last element of reach row
    done
}

# multiplyMatrices - takes MxN and NxP matrices and produces MxP matrix with matrix multiplication
# USE: multiplyMatrices [FIRST_MATRIX_FILE_PATH] [SECOND_MATRIX_FILE_PATH]
function multiplyMatrices(){
    matrixDimensions $1 # determines number of rows and columns of first matrix for comparison

    firstMatrixRows=$numberOfRows
    firstMatrixColumns=$numberOfColumns

    matrixDimensions $2

    # number of columns of first matrix must equal number of rows of second matrix
    if [[ $firstMatrixColumns -ne $numberOfRows ]]
    then
        echo "invalid matrices: multipying matrices requires that number of columns in the first matrix is equal to the number of rows in the second matrix" >&2
        exit 13
    fi

    # matrix multiplication - dot product of corresponding row from first matrix and column from second matrix
    for (( i=1; i<=$firstMatrixRows; i=i+1)) # for each row of the first matrix
    do
        rowFirstMatrix=$( cat $1 | tail -n+$i | head -n1 )

        for (( j=1; j<=$numberOfColumns; j=j+1)) # for each column of the second matrix
        do
            dotProduct=0
            columnSecondMatrix=$(cut -f"$j" $2 | paste -s)

            for (( k=1; k<=$firstMatrixColumns; k=k+1)) # for each element of the row of the first matrix
            do
                elementFirstMatrix=$( echo $rowFirstMatrix | cut -d' ' -f$k ) # "k"th element
                elementSecondMatrix=$( echo $columnSecondMatrix | cut -d' ' -f$k )
                dotProduct=$(( $dotProduct+($elementFirstMatrix*$elementSecondMatrix) ))
            done
            printf "%d" "$dotProduct"

            if [ $j -ne $numberOfColumns ] # if not the last element of the row
            then
                printf "\t"
            fi
        done
        printf "\n" # after the last element of the row
    done
}

if [[ $# -gt 3 || $# -lt 1 ]] # must be 1, 2, or 3 arguments
then
    echo "invalid number of arguments" >&2
    exit 13
fi

case $1 in # first argument should be the operation
    dims|transpose|mean)
        case $# in # for these operations, there should be 0 or 1 matrices
            1)  # zero matrices provided, look to stdin
                cat > $TMP
                subjectFile=$TMP
                ;;
            2)  # one matrix file provided, make sure it is readable
                if [[ -r $2 ]]
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
        case $1 in # use the proper function for the operation specified
            dims)       matrixDimensions $subjectFile
                        echo "$numberOfRows $numberOfColumns"
                        ;;
            transpose)  transposeMatrix $subjectFile
                        ;;
            mean)       matrixMean $subjectFile
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
        if [[ -r $2 && -r $3 ]] # check that both files are readable
        then
            case $# in
                3)  case $1 in # use the proper function for the operation specified
                        add)        addMatrices $2 $3
                                    ;;
                        multiply)   multiplyMatrices $2 $3
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
    *) # first argument is not one of the five valid operations
        echo "invalid operation" >&2 
        exit 13
        ;;
esac
