$fn = 100;

track_circumference = 367;
mould_screw_radius = 1.5;

function circumference_from_segments(segment_length = 18, number_of_segments = 10) =
    segment_length * number_of_segments;

module track_shape(
    track_thickness = 1,
    track_radius = 100,
    track_width = 20,
    segments = 100,
    tooth_width = 2,
    tooth_height = 2,
    guide_thickness = [3,1],
    guide_width = 3,
    guide_depth = 2,
    ) {
    difference() {
        difference() {
            // track outer
            cylinder(r = track_radius + (track_thickness / 2), h = track_width);
            // track inner
            cylinder(r = track_radius - (track_thickness / 2), h = track_width);
        }
        for(a = [0: 360 / segments: 360]) {
            if(tooth_width != 0 && tooth_height != 0 ) {
                rotate([0, 0, a]) translate([- tooth_width / 2, track_radius - (track_thickness), 0]) {
                    cube([tooth_width, track_thickness * 2, tooth_height]);
                    translate([0, 0, track_width - tooth_height]) cube([tooth_width, track_thickness * 2, tooth_height]);
                }
            }
        }
    }
    for(a = [360 / segments / 2: 360 / segments: 360]) {
        /*rotate([0, 0, a]) translate([- guide_width / 2, track_radius - track_thickness / 2 - guide_depth, (track_width - guide_thickness) / 2]) {
            cube([guide_width, guide_depth + (track_thickness / 2), guide_thickness]);
        }*/
        rotate([0, 0, a]) translate([- guide_width / 2, track_radius - track_thickness / 2, (track_width) / 2]) {
            rotate([90,0,0]) hull() {
                cylinder(r1 = guide_thickness[0], r2 = guide_thickness[1], h = guide_depth, $fn = 10);
                translate([guide_width, 0, 0])
                    cylinder(r1 = guide_thickness[0], r2 = guide_thickness[1], h = guide_depth, $fn = 10);
            }
        }
    }
}

module track_mould_outer(
    mould_thickness = 2,
    track_thickness = 1,
    track_radius = 100,
    track_width = 20,
    segments = 100,
    guide_thickness = 1,
    guide_width = 3,
    guide_depth = 2,
    ) {
    difference() {
        cylinder(
            r = track_radius + mould_thickness + track_thickness / 2,
            h = track_width + mould_thickness + mould_thickness
        );
        union() {
            translate([0, 0, mould_thickness])
                cylinder(
                    r = track_radius + track_thickness / 2,
                    h = track_width + mould_thickness
                );
            translate([0, 0, mould_thickness + track_width])
                cylinder(
                    r1 = track_radius + track_thickness / 2,
                    r2 = track_radius + track_thickness / 2 + mould_thickness,
                    h = mould_thickness
                );
            cylinder(r = track_radius - guide_depth - mould_thickness - track_thickness / 2, h = track_width);
            for(a = [0 : 5 : 360])
                rotate([0, 0, a])
                    translate([0, track_radius + track_thickness / 2, mould_thickness])
                        cylinder(r = 0.5, h = track_width, $fn = 6);
            for(a = [0 : 90 : 360])
                rotate([0, 0, a])
                    translate([0, track_radius - guide_depth - mould_thickness / 2 - track_thickness / 2, 0])
                        cylinder(r = mould_screw_radius, h = track_width);
        }
    }
}

module track_mould_inner(
    mould_thickness = 2,
    track_thickness = 1,
    track_radius = 100,
    track_width = 20,
    segments = 100,
    tooth_width = 2,
    tooth_height = 2,
    guide_thickness = 1,
    guide_width = 3,
    guide_depth = 2,
    ) {
    difference() {
        cylinder(
            r = track_radius + (track_thickness / 2) - 0.05,
            h = track_width
            );
        union() {
            cylinder(
                r = track_radius - guide_depth - mould_thickness - track_thickness / 2,
                h = track_width
                );
            track_shape(
                track_radius = track_radius,
                track_width = track_width,
                segments = segments,
                tooth_width = tooth_width,
                tooth_height = tooth_height,
                );
            for(a = [0 : 90 : 360])
                rotate([0, 0, a])
                    translate([0, track_radius - guide_depth - mould_thickness / 2 - track_thickness / 2, 0])
                        cylinder(r = mould_screw_radius, h = track_width);
        }
    }
}

module top_ring(
    mould_thickness = 2,
    track_thickness = 1,
    track_radius = 100,
    track_width = 20,
    segments = 100,
    guide_thickness = 1,
    guide_width = 3,
    guide_depth = 2,
    ) {
    difference() {
        cylinder(
            r1 = track_radius,
            r2 = track_radius - mould_thickness,
            h = mould_thickness
            );
        union() {
            cylinder(
                r = track_radius - guide_depth - mould_thickness - track_thickness / 2,
                h = track_width
                );
            for(a = [0 : 90 : 360])
                rotate([0, 0, a])
                    translate([0, track_radius - guide_depth - mould_thickness / 2 - track_thickness / 2, 0])
                        cylinder(r = mould_screw_radius, h = track_width);
        }
    }
}

base_track_r = track_circumference / (PI * 2);

mould_thickness = 5;
/*
track_mould_outer(
        track_radius = base_track_r,
        track_width = 14,
        segments = 66,
        mould_thickness = mould_thickness,
    );
*/
// translate([0, 0, 3 + 14])
top_ring(
        track_radius = base_track_r,
        track_width = 14,
        segments = 66,
        mould_thickness = mould_thickness,
    );

/*
translate([0, 0, 3])
    track_mould_inner(
        track_radius = base_track_r,
        track_width = 14,
        segments = 24,
        tooth_width = 0,
        tooth_height = 0,
        mould_thickness = mould_thickness,
        );
 */