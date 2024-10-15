module battery_sling(dimensions, wall = 1) {
    difference() {
        translate([-wall, -wall, 0]) cube([dimensions.x + 2 * wall, dimensions.y + 2 * wall, dimensions.z]);
        cube([dimensions.x, dimensions.y, dimensions.z]);
    }
}

battery_sling([24, 25, 10]);