int i i := 3
do
    check i > 0
    int j j := 2
    do
        check j > 0
        write i * j
        j := j - 1
    od
    i := i - 1
od
