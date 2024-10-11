use <yellow_motor.scad>
use <hexnut.scad>
side_thickness = 2;
screw_radius = 2.5 / 2;

module bot_side(side_depth = 30, side_length = 90, side_thickness = 3, side_holes = [40.5, 81]) {
    module side_shape(h = side_thickness) {
        translate([-side_depth / 2, 0, 0])
            cube([side_depth, side_length, h]);
    }
        
    module cutouts(h = side_thickness) {
        intersection() {
            linear_extrude(height = h) projection() yellow_motor();
            union() {
                translate([0, 0, side_thickness])
                    yellow_motor();
            }
        }
        for(hole = side_holes) {
            translate([0, hole, 0]) {
                cylinder(r = screw_radius, h = h, $fn = 30);
                if(h >= side_thickness) {
                    translate([0, 0, 3]) hexnut(flats = 5, depth = h - 1);
                }
            }
        }
    }
    
    module cutout_walls(h = 2){
        mink_h = 0.09;
        minkowski() {
            cutouts(h = h - mink_h);
            cylinder(r = 3, h = 0.09, $fn = 30);
        }
    }
    
    difference() {
        union() {
            hull() {
                cutout_walls(h = 3);
                translate([-13, 0, 0]) cube([2, 90, 20]);
            }
            cutout_walls(h = side_thickness);
            translate([-1, 0, 0]) cube([2, side_holes[1], 2]);
        }
        union() {
            minkowski() {
                cutouts(h = 20);
                cylinder(r = 0.1, h = 0.1, $fn = 10);
            }
            cylinder(r = 7 / 2, h = 10, $fn = 100);
        }
    }
}
//mirror([1, 0, 0])
bot_side();
