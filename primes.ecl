int n read n
int cp cp := 2
do
    check n > 0
    int found found := 0
    int cf1 cf1 := 2
    int cf1s cf1s := cf1 * cf1
    do
        check cf1s <= cp
        int cf2 cf2 := 2
        int pr pr := cf1 * cf2
        do
            check pr <= cp
            if pr == cp then
                found := 1
            fi
            cf2 := cf2 + 1
            pr := cf1 * cf2
        od
        cf1 := cf1 + 1
        cf1s := cf1 * cf1
    od
    if found == 0 then
        write cp
        n := n - 1
    fi
    cp := cp + 1
od
