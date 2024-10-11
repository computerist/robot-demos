screw_radius = 1.3;

function make_grip_profile(height, depth) =
    [
        [0, 0],
        [depth/2, 0],
        [depth, height / 3],
        [depth, 2 * height / 3],
        [depth / 2, height],
        [0, height]
    ];
    
module grip(height = 5, depth = 2, thickness =1) {
    rotate([90, 0, 90])
    translate([0, 0, -thickness / 2]) linear_extrude(height = thickness) polygon(make_grip_profile(height, depth));
}

module driven_wheel_gear(
        wheel_radius = 30,
        shaft_radius = 5.5 / 2,
        shaft_flats = 4,
        width = 10,
        axle_protrusion = 1,
        hub_thickness = 5,
    ) {
    difference() {
        union () {
            linear_extrude(height = width) translate([-0.13,0.1,0]) import("wheel_gear_2.svg");
            cylinder(r = wheel_radius, h = width / 2, $fn = 100);
            cylinder(r = shaft_radius + hub_thickness, h = width + axle_protrusion);
        }
        union() {
            cylinder(r = 1.3, h = 12, $fn = 10);
            translate([0, 0, 5]) cylinder(r = shaft_radius, h = width + axle_protrusion);
            cylinder(r = screw_radius, h = width + axle_protrusion);
        }
    }
    for(m = [0, 1]) {
        mirror([0, m, 0])
            translate([- shaft_radius, shaft_flats / 2, 0])
                cube([shaft_radius * 2, hub_thickness, width + axle_protrusion]);
    }
    for(a = [0 : 12 : 360])
        rotate([0, 0, a])
            translate([0, wheel_radius - 1, 0]) grip();
}

driven_wheel_gear();