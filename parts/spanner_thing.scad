use<hexnut.scad>

difference() {
    translate([-40, -10, 0]) cube([69.8, 20, 4]);
    translate([27, 0, 0]) hexnut(flats = 10, depth = 5);
}