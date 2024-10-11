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

module idle_wheel_gear(
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
            cylinder(r = screw_radius, h = width + axle_protrusion, $fn = 10);
        }
    }
    for(a = [0 : 12 : 360])
        rotate([0, 0, a])
            translate([0, wheel_radius - 1, 0]) grip();
}

idle_wheel_gear(axle_protrusion = 0);