int a read a
int b read b
do
    if a > b then
        a := a - b
    elsif b > a then
        b := b - a
    else
        write a
        check 0
    fi
od
