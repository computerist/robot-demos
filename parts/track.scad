$fn = 100;

track_circumference = 367;

module track_shape(
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
        difference() {
            // track outer
            cylinder(r = track_radius + (track_thickness / 2), h = track_width);
            // track inner
            cylinder(r = track_radius - (track_thickness / 2), h = track_width);
        }
        for(a = [0: 360 / segments: 360]) {
            rotate([0, 0, a]) translate([- tooth_width / 2, track_radius - (track_thickness), 0]) {
                cube([tooth_width, track_thickness * 2, tooth_height]);
                translate([0, 0, track_width - tooth_height]) cube([tooth_width, track_thickness * 2, tooth_height]);
            }
        }
    }
    for(a = [360 / segments / 2: 360 / segments: 360]) {
        rotate([0, 0, a]) translate([- guide_width / 2, track_radius - track_thickness / 2 - guide_depth, (track_width - guide_thickness) / 2]) {
            cube([guide_width, guide_depth + (track_thickness / 2), guide_thickness]);
        }
    }
}

module track_mould_outer(
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
            translate([0, track_radius - guide_depth - mould_thickness / 2 - track_thickness / 2, 0])
                cylinder(r = 1, h = track_width);
            for(a = [0 : 90 : 360])
                rotate([0, 0, a])
                    translate([0, track_radius - guide_depth - mould_thickness / 2 - track_thickness / 2, 0])
                        cylinder(r = 1, h = track_width);
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
                track_radius = base_track_r,
                track_width = 14,
                segments = 66,
                tooth_width = 1.7,
                tooth_height = 2,
                );
            for(a = [0 : 90 : 360])
                rotate([0, 0, a])
                    translate([0, track_radius - guide_depth - mould_thickness / 2 - track_thickness / 2, 0])
                        cylinder(r = 1, h = track_width);
        }
    }
}

module top_ring(
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
                        cylinder(r = 1, h = track_width);
        }
    }
}

base_track_r = track_circumference / (PI * 2);

/*track_shape(
    track_radius = base_track_r,
    track_width = 14,
    segments = 66,
    tooth_width = 1.7,
    tooth_height = 2,
    mould_thickness = 3,
    );*/
    
track_mould_outer(
        track_radius = base_track_r,
        track_width = 14,
        segments = 66,
        tooth_width = 1.7,
        tooth_height = 2,
        mould_thickness = 3,
    );
    
translate([0, 0, 3 + 14])
top_ring(
        track_radius = base_track_r,
        track_width = 14,
        segments = 66,
        tooth_width = 1.7,
        tooth_height = 2,
        mould_thickness = 3,
    );

translate([0, 0, 3])
//intersection() {
    track_mould_inner(
        track_radius = base_track_r,
        track_width = 14,
        segments = 66,
        tooth_width = 1.7,
        tooth_height = 2,
        mould_thickness = 3,
        );
//    cylinder(r = base_track_r + 5, h = 7);
//}

// track_mould();