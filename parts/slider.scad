use<hexnut.scad>

screw_radius = 1.25;

function make_slider_cross_section (depth, width) =
    [[-width / 2, 0], [0, -depth], [width / 2, 0]];

module slider(length = 30, depth = 10, width = 20) {
    profile = make_slider_cross_section(depth, width);
    difference() {
        rotate([270, 0, 0])
            linear_extrude(height = length) polygon(profile);
        union() {
            translate([0, length / 2, 0]) {
                translate([0, 0, depth / 2]) hexnut(flats = 4, depth = depth / 2);
                cylinder(r = screw_radius, h = depth, $fn = 10);
            }
        }
    }
}