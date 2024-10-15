use<hexnut.scad>

$fn = 30;

module washer(inner_radius = 1.3, outer_radius = 5, thickness = 4, nut = [5,2]) {
    difference() {
        cylinder(r = outer_radius, h = thickness);
        // hexnut(flats = 2 * outer_radius, depth = thickness);
        union() {
            cylinder(r = inner_radius, h = thickness);
            if(0 != nut[0] && 0 != nut[1]) {
                translate([0, 0, thickness - 2]) hexnut(flats = 5, depth=2);
            }
        }
    }
}

//washer(thickness = 3, inner_radius = 5.5 / 2, nut = [0, 0]);

washer();