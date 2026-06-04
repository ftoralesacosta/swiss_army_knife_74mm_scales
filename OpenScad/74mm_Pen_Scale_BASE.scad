// ============================================================================
// 74mm SAK Pen Scale BASE
// ============================================================================
// Integrates the pen cavity insert into the 74mm Swiss Army Knife scale.
// Resolves coordinates so that the flat bottom face of the scale is perfectly flush
// with the flat face of the pen insert.
// ============================================================================

$fn = 60; // Smoothness

// --- CONFIGURATION ---

// Choose base geometry source:
// true  = Use mathematical model from 74mm_Dual_Slot_Scale.scad (cleaner, parametric)
// false = Import pre-rendered "74mm_BLANK Scale.stl" from parent directory
use_mathematical_geometry = true;

// Choose pen insert source:
// true  = Generate live using pen_cavity_impression() module from pen_insert_positive.scad
// false = Import pre-rendered "pen_insert_positive.stl"
use_live_pen_impression = false;

// Set to true to preview the pen insert plug in red (ghost overlay in preview mode)
preview_pen_insert = true;

// --- THICKNESS CONFIGURATION ---
// Standard SAK 74mm scales are 2.5mm thick.
// SAK Pen scales need to be thicker (e.g. 3.45mm) to house the pen cavity.
target_thickness = 3.45;
extra_thickness = target_thickness - 2.5;

// --- RIVET HOLE CONFIGURATION ---
// Depth of the rivet holes into the flat face of the scale (standard is 1.6mm)
rivet_hole_depth = 1.6;

// --- PEN CAVITY POSITIONING & FRICTION TUNING ---
pen_offset_x = -2.0; // Left/right shift
pen_offset_y = 7.0; // Up/down shift
pen_offset_z = -0.30; 
// Offset Z is important. More negative values make for a tighter fit. This may
// need adjusting. Works for 0.4mm PETG and PLA. If the insert rattles in the scale
// make pen_offset_z more negative. If it's too difficult to actuate the pen, make less negative

// --- LIBRARY IMPORTS ---
use <74mm_Dual_Slot_Scale.scad>
use <pen_insert_positive.scad>

// --- GEOMETRY GENERATORS ---

module blank_scale_base() {
    if (use_mathematical_geometry) {
        sak_74mm_solid_body();
    } else {
        import("../74mm_BLANK Scale.stl");
    }
}

module pen_insert_plug() {
    if (use_live_pen_impression) {
        pen_cavity_impression();
    } else {
        import("pen_insert_positive.stl");
    }
}

// Solid cylinders that match the position and height of pre-existing rivet holes 
// in the imported STL. Used to completely fill them so we can drill them to a uniform depth.
module rivet_fillers(extra_thick) {
    h_dist_y   = 60.5 / 2; 
    h_dist_x   = 9.5 / 2; 
    h_dia      = 3.8 + 0.1; // Slightly larger diameter to ensure a clean union/merge
    h_height   = 2.1; 
    h_z_offset = extra_thick - 0.5; // Offset starts exactly where the translated STL's holes are
    
    for(x = [-1, 1], y = [-1, 1]) {
        translate([x * h_dist_x, y * h_dist_y, h_z_offset]) 
            cylinder(h=h_height, d=h_dia, $fn=30);
    }
}

// Clean rivet holes subtraction with custom depth
module rivet_holes_subtraction(depth) {
    h_dist_y   = 60.5 / 2; 
    h_dist_x   = 9.5 / 2; 
    h_dia      = 3.8;
    h_height   = depth + 0.5; // Include 0.5mm starting depth below Z = 0
    h_z_offset = -0.5; 
    
    for(x = [-1, 1], y = [-1, 1]) {
        translate([x * h_dist_x, y * h_dist_y, h_z_offset]) 
            cylinder(h=h_height, d=h_dia, $fn=30);
    }
}

module base_scale_solid() {
    if (use_mathematical_geometry) {
        union() {
            // Flat extension at the bottom
            linear_extrude(height = extra_thickness)
                sak_profile_2d();
                
            // Original rounded scale shifted up
            translate([0, 0, extra_thickness])
                sak_74mm_solid_body();
        }
    } else {
        union() {
            // Flat extension at the bottom
            linear_extrude(height = extra_thickness)
                sak_profile_2d();
                
            // Original rounded scale shifted up
            translate([0, 0, extra_thickness])
                import("../74mm_BLANK Scale.stl");
                
            // Fill the rivet holes of the imported STL
            rivet_fillers(extra_thickness);
        }
    }
}

// --- FINAL ASSEMBLY ---

// Optional preview overlay
if (preview_pen_insert) {
    %color("Red")
    translate([pen_offset_x, pen_offset_y, pen_offset_z])
    translate([0, 0, 1.25])
    mirror([0, 0, 1])
    pen_insert_plug();
}

difference() {
    base_scale_solid();
    
    // Drill clean rivet holes to the exact custom depth
    rivet_holes_subtraction(rivet_hole_depth);
    
    // Position and subtract the pen insert:
    // - Flat face of pen_insert_plug() is at Z = 1.25.
    // - Mirror Z flips the cavity upwards so it cuts into the scale body (Z > 0).
    // - Translate by [0, 0, 1.25] places its flat face at Z = 0.
    // - pen_offset_z can be adjusted to tune the cavity depth/fit tightness.
    translate([pen_offset_x, pen_offset_y, pen_offset_z])
    translate([0, 0, 1.25])
    mirror([0, 0, 1])
    pen_insert_plug();
}
