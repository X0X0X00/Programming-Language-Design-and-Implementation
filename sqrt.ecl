real d read d
real l l := d / 2.0
do
    check l * l > d
    l := l / 2.0
od
real h h := 2.0 * l
real err err := d - (l * l)
if err < 0.0 then err := 0.0 - err fi
do
    check err > 1.e-8
    real a a := (l + h) / 2.0
    if (a * a) < d then
        l := a
    else
        h := a
    fi
    err := d - (l * l)
    if err < 0.0 then err := 0.0 - err fi
od
write l
