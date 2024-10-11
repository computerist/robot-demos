module gear_outer(
        segment_length,
        guide_width,
        guide_depth,
        guide_thickness,
        segments,
        track_width,
    ) {
    circumference = segment_length * segments;
    outer_radius = circumference / (PI * 2);
    echo("circumference", circumference)
    echo("outer radius", outer_radius)
    echo("min track length", circumference + 4 * outer_radius);
    difference() {
        cylinder(r = outer_radius, h = track_width);
        for(a = [0 : 360 / segments : 360]) {
            rotate([0, 0, a]) {
                hull() {
                    translate([0, outer_radius, track_width / 2])
                        rotate([90, 0, 0])
                            cylinder(r1 = guide_thickness[0], r2 = guide_thickness[2], h = guide_depth, $fn = 10);
                    rotate([0, 0, (360 / circumference) * guide_width])        
                        translate([0, outer_radius, track_width / 2])
                            rotate([90, 0, 0])
                                cylinder(r1 = guide_thickness[0], r2 = guide_thickness[2], h = guide_depth, $fn = 10);
                 }
            }
        }
    }
}