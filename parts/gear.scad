difference() {
    linear_extrude(height = 5) import("gear.svg");
    cylinder(r = 1.3, h = 6, $fn = 20);
}