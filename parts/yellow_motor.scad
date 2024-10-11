

module yellow_motor(screw_protrusion = 10) {
    motor_width = 18.9;
    motor_depth = 22.5;
    shaft_radius = 5.5 / 2;
    shaft_length = 36.5;
    shaft_protrusion_radius = 7 / 2;
    shaft_to_knob = 11;
    knob_radius = 4 / 2;
    knob_height = 2;
    shaft_to_screw_holes = [8.5, 20];
    screw_hole_radius = 3 / 2;
    shaft_to_clip = 30;
    clip_radius = 7 / 2;
    clip_height = 1;
    across_clips = 22.5;
    shaft_to_back_edge = 11.5;
    shaft_to_front_edge = 25.5;
    round_body_flats = 17.5;
    round_body_radius = 22.5/2;
    total_body_length = 65.25;
    
    // motor body
    translate([0, -shaft_to_back_edge, 0]) {
        // body bit
        translate([-motor_depth / 2, 0, 0]) cube([motor_depth, shaft_to_back_edge + shaft_to_front_edge, motor_width]);
        // round bit and clips
        translate([0, 0, motor_width - round_body_flats]) {
            // clips
            translate([0, shaft_to_back_edge + shaft_to_clip, -1 * (across_clips - round_body_flats) / 2]) cylinder(r = clip_radius, h = across_clips, $fn = 10);
            // round body
            intersection() {
                translate([-round_body_radius, 0, 0]) cube([round_body_radius*2, total_body_length, round_body_flats]);
                translate([0, 0, round_body_flats / 2])
                    rotate([270, 0, 0])
                        cylinder(r = round_body_radius, h = total_body_length, $fn = 100);
            }
        }
    }
    // knob
    translate([0, shaft_to_knob, -knob_height]) cylinder(r = knob_radius, h = knob_height, $fn = 30);
    
    // motor shaft
    translate([0, 0, motor_width / 2]) cylinder(r = shaft_radius, h = shaft_length, center = true, $fn = 30);
    
    // screw holes
    for(m = [0,1]) {
        mirror([m, 0, 0]) translate([shaft_to_screw_holes[0], shaft_to_screw_holes[1], -screw_protrusion]) cylinder(r = screw_hole_radius, h = screw_protrusion * 2 + motor_width, $fn = 30);
    }
}

yellow_motor();