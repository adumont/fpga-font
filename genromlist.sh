COLS=$(( 2**$1 - 1))
ROWS=$(( 2**$2 - 1))

echo "// ROM 2^${1}x2^${2}x8=$(( 2**$1 * 2**$2))x8 bits"
echo
for y in $( seq 0 ${ROWS} )
do
    echo "// Line $y: from $(( 2**$1 * $y )) to $(( (2**$1 * ($y+1))-1 ))"
    for x in $( seq 0 ${COLS} )
    do
        echo -n "00 ";
    done
    echo
done