use <gear_outer.scad>

segment_length = 15.3;
guide_width = 3;
guide_depth = 2;
guide_thickness = [3,1];
track_width = 14;
$fn = 100;

gear_outer(
        segment_length = segment_length,
        guide_width = guide_width,
        guide_depth = guide_depth,
        guide_thickness = guide_thickness,
        segments = 12,
        track_width = track_width,
    );