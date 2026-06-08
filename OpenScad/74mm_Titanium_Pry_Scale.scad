// ============================================================================
// 74mm SAK Solid Titanium Pry Scale (SLIM 2.5mm Edition)
// ============================================================================
// An ultra-minimalist, high-strength 74mm SAK scale with an integrated pry bar.
// Completely solid with no accessory slots to maximize structural strength.
//
// Uses the organic hull-taper design to blend the pry wedge smoothly
// with the natural contours of the scale body.
// Designed specifically for SLS Titanium 3D printing.
// ============================================================================

$fn = 60;

// --- LIBRARY IMPORTS ---
// We import the mathematical solid body and profile from the Dual Slot engine.
use <74mm_Dual_Slot_Scale.scad>

// --- CONFIGURATION ---
// Standard SAK 74mm scales are 2.5mm thick.
target_thickness = 2.5; 

// --- TAPERED TIP CONFIGURATION ---
slice_at_y = -31.0;     // Y-coordinate to cut the scale and start the taper
y_target   = slice_at_y - 7;     // Y-coordinate of the chisel tip (length of tool)
z_target   = 0;       // Z-coordinate of the chisel tip (height of bevel)
tip_width  = 6.0;       // Width of the chisel tip in X
y_tip_cut  = y_target + 1.5; // Y-coordinate to cut off the tip (set to less than y_target to disable)

// --- MODULES ---

module cross_section_slice(y, thickness=0.05) {
    // Generates a very thin 3D slice of the scale body at Y = y
    intersection() {
        sak_74mm_solid_body();
        translate([0, y, 0])
            cube([100, thickness, 100], center=true);
    }
}

module tapered_extension(y, y_target, z_target, tip_width) {
    // Linearly tapers the cross section slice at Y = y to a target line segment
    hull() {
        cross_section_slice(y);
        
        // Target line segment along the X-axis
        hull() {
            translate([-tip_width/2, y_target, z_target]) sphere(r=0.001, $fn=8);
            translate([ tip_width/2, y_target, z_target]) sphere(r=0.001, $fn=8);
        }
    }
}

module solid_scale_with_pry() {
    union() {
        // 1. Keep the scale body only for Y > slice_at_y
        difference() {
            sak_74mm_solid_body();
            // Remove everything below slice_at_y (Y < slice_at_y)
            translate([0, slice_at_y - 50, 0])
                cube([100, 100, 100], center=true);
        }
        
        // 2. Add the tapered tip extending from slice_at_y to the target line,
        // and optionally cut off the tip at y_tip_cut
        difference() {
            tapered_extension(slice_at_y, y_target, z_target, tip_width);
            
            // Remove everything below y_tip_cut (Y < y_tip_cut)
            translate([0, y_tip_cut - 50, 0])
                cube([100, 100, 100], center=true);
        }
    }
}

// --- FINAL ASSEMBLY ---
difference() {
    // A. Solid 2.5mm thin body with the integrated pry bar
    color("Silver")
        solid_scale_with_pry();

    // B. Drill clean rivet holes to the exact depth
    #new_rivet_holes();
}
