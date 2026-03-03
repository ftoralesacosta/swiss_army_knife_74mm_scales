// --- File Setup ---
file_58mm = "58mm_source_files/sak58mmscales-pen.stl";
file_74mm = "sak74mm_blank.stl";

$fn = 60; // Smoothness


// --- Global Transformations ---
stretch = [4.0, 17.0];   // [x, y1] -> 16.5 stretch at Y = -23.5
stretch_y2 = 18.5-stretch.y;        // y2      -> 2.0 stretch at Y = 40
split_pos = [3, -23.5, 40];

// --- Rivet Fill (Original Holes) ---
rivet_anchor = [-3.5, -23, -2.4]; // [x, y, z]
rivet_spacing = [7.0, 46];       // [x, y]
rivet_dim = [4.0, 3.65];         // [diam, height]

// --- New Mounting Holes ---
hole_dist = [9.5 / 2, 60.5 / 2]; // [half-x, half-y]
hole_dim = [3.75, 5.0];           // [diam, height]
hole_nudge = [1.75, 9.35, -1.5];  // [x, y, z]
hole_z_offset = 0.1;             // 2.0 - 1.5 --> 0.5 without shear

// --- Patch Rectangles (X, Y, Z positions and sizes) ---
rects = [
    [[-3.5, 33.5, -0.4],    [4.5, 9, 3.3]], // Patch 1
    [[8., 16, -0.4],     [4.4, 50, 3.3]], // Patch 2
    [[-0.3, -23.5, -0.5], [4.4, 1, 3.5]]  // Patch 3
];

// --- Centering & Debug ---
left_edge = -6.8;
right_edge = 9.8;
scale_center = (left_edge + right_edge) / 2;

show_target_ghost = false; 
show_cut_planes   = false; 
show_debug_rivets = false;
show_center_lines = true;

// --- Cylinder for Pen ---
y_cyl_params = [0.0, 38, -0.5, 20]; 
y_cyl_diam = 2.5;
y_rect_height = 2.0;


// --- MAIN RENDER ---

// 1. Reference Ghost + Center Lines
if (show_target_ghost) {
    %color("Grey", 1.0) translate([1, 9, 4.]) import(file_74mm);
}
if (show_center_lines) {
    translate([scale_center, 0, 3])
    %color("Black") cube([0.1, 100, 0.5], center=true);
    translate([scale_center, -22.5, 3])
     %color("Black") cube([100, 0.1, 0.5], center=true);
}

// 2. Final Object
difference() {
    // START WITH THE SOLID BODY
    difference() {
        union() {
            // Step A: Stretch and Orient the base 58mm scale
            color("Red") 
                stretch_y_axis() 
                    stretch_x_axis() 
                        oriented_58mm();
            
            // Step B: Add patches (Processed BEFORE trim to match curvature)
            patch_rectangles();
        }

        // Step C: Trim the combined mess into the final 74mm shape
        //trim_excess_material(); 
        trim_excess_material_rounded(2.5);
    }

    // Step D: Drill the new holes (The "Subtract" phase)
    translate(hole_nudge) 
        new_mounting_holes();
    
    // Step E: Remove the Y-axis cylinder
    #y_pen_hole_subtractions();
    
    // Step F: Shear bottom of scale for tighter pen action
    translate([-100, -100, 0.75])  //1.25 levels with scale
        cube([200, 200, 3]);
    
}

// --- MODULES ---

module oriented_58mm() {
    union() {
        rotate([-90, 0, 90]) import(file_58mm, convexity=3);
        rivet_fills(); 
    }
}

module rivet_fills() {
    color("Red")
    for (x = [0, 1], y = [0, 1]) {
        translate([
            rivet_anchor.x + (x * rivet_spacing.x), 
            rivet_anchor.y + (y * rivet_spacing.y), 
            rivet_anchor.z
        ])
        cylinder(d=rivet_dim[0], h=rivet_dim[1], $fn=30);
    }
}

module patch_rectangles() {
    for (r = rects) {
        translate(r[0]) #cube(r[1], center=true);
    }
}

module new_mounting_holes() {
    for(x = [-1, 1], y = [-1, 1]) {
        translate([x * hole_dist.x, y * hole_dist.y, hole_z_offset]) 
            #cylinder(h=hole_dim[1], d=hole_dim[0], $fn=30);
    }
}

module stretch_x_axis() {
    union() {
        intersection() { // Left Side
            children();
            translate([-50, -50, -50]) cube([50 + split_pos.x, 100, 100]);
        }
        translate([stretch.x, 0, 0]) intersection() { // Right Side
            children();
            translate([split_pos.x, -50, -50]) cube([50, 100, 100]);
        }
        hull() { // Bridge
            intersection() {
                children();
                translate([split_pos.x - 0.05, -50, -50]) cube([0.05, 100, 100]);
            }
            translate([stretch.x, 0, 0]) intersection() {
                children();
                translate([split_pos.x, -50, -50]) cube([0.05, 100, 100]);
            }
        }
    }
}


module stretch_y_axis() {
    // Apply 2.0mm stretch at the top point (Y=40)
    stretch_at_y(split_pos[2], stretch_y2) 
        // Apply 16.5mm stretch at the bottom point (Y=-23.5)
        stretch_at_y(split_pos[1], stretch.y) 
            children();
}

module stretch_at_y(pos, amount) {
    union() {
        intersection() { // Part below the cut
            children();
            translate([-100, -500, -50]) cube([200, 500 + pos, 100]);
        }
        translate([0, amount, 0]) intersection() { // Part above the cut
            children();
            translate([-100, pos, -50]) cube([200, 500, 100]);
        }
        hull() { // The "Bridge" connecting the two halves
            intersection() {
                children();
                translate([-100, pos - 0.01, -50]) cube([200, 0.01, 100]);
            }
            translate([0, amount, 0]) intersection() {
                children();
                translate([-100, pos, -50]) cube([200, 0.01, 100]);
            }
        }
    }
}

module trim_excess_material_rounded(nudge_z = 0) {
    // This creates a "Negative Mold" of your new rounded shape.
    difference() {
        // 1. The Giant Block
        cube([200, 200, 200], center=true);
        
        // 2. The Shape to Keep (Shifted by nudge_z)
        translate([0, 0, nudge_z])
            sak_scale_rounded(thickness=10.0, edge_radius=2.1); 
    }
}

// 1. Define the 2D Outline
module sak_profile_2d() {
    t_len = 75; t_wid = 17.0; rad = 7.5; elong = 0.9;
    hull() {
        for (x = [-1, 1], y = [-1, 1]) 
            translate([x * (t_wid/2 - rad)+1.71, y * (t_len/2 - (rad * elong))+9.35])
            scale([1, elong]) circle(r=rad);
    }
}

// 2. Create the Rounded Volume (Positive)
module sak_scale_rounded(thickness=5, edge_radius=1.5) {
    minkowski() {
        // Core shape (shrunken so the sphere doesn't make it oversized)
        linear_extrude(height = thickness - 2*edge_radius, center=true)
            offset(r = -edge_radius)
            sak_profile_2d();
            
        // The sphere that adds the curve to Top AND Bottom
        sphere(r = edge_radius);
    }
}

module y_axis_cylinder_cutout() {
    translate([y_cyl_params[0], y_cyl_params[1], y_cyl_params[2]])
        rotate([-90, 0, 0]) // Rotate to align with Y-axis
            cylinder(d=y_cyl_diam, h=y_cyl_params[3], center=true, $fn=30);
}

module y_pen_hole_subtractions() {
translate([y_cyl_params[0], y_cyl_params[1], y_cyl_params[2]]) {
        // 1. The Cylinder (Stays centered)
        rotate([-90, 0, 0]) 
            cylinder(d=y_cyl_diam, h=y_cyl_params[3], center=true, $fn=30);
        
        // 2. The Rectangle (Shifted UP so bottom face bisects cylinder)
        translate([0, 0, y_rect_height / 2]) 
            cube([y_cyl_diam, y_cyl_params[3], y_rect_height], center=true);
    }
}
