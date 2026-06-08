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
slice_at_y = -33.0;     // Y-coordinate to cut the scale and start the taper
y_target   = slice_at_y - 10;     // Y-coordinate of the chisel tip (length of tool)
z_target   = 0;       // Z-coordinate of the chisel tip (height of bevel)
tip_width  = 3.0;       // Width of the chisel tip in X
y_tip_cut  = y_target + 1.2; // Y-coordinate to cut off the tip (set to less than y_target to disable)

enable_curved_taper = false; // Set to true for a smooth parabolic transition, false for a sharp linear taper
taper_slices = 12;      // Number of slices for the curved taper (higher = smoother, 10-15 is plenty)
scale_width_at_slice = 13.5; // Estimated width of the scale at slice_at_y (used for smooth X-taper)

// --- STRAIGHT TWEEZER SLOT CONFIGURATION ---
enable_straight_tweezer_slot = false; // Set to true to add the straight tweezers slot
tweezer_pos = [3.0, -8,1.15];  // XYZ starting position (entrance) of the tweezers slot
tweezer_width = 3.15;              // Width of the slot (X-size)
tweezer_length = 46.0;             // Length of the slot (Y-size, goes inwards)
tweezer_height = 1.3;              // Height of the slot (Z-size)

// --- MODULES ---

module cross_section_slice(y, thickness=0.05) {
    // Generates a very thin 3D slice of the scale body at Y = y
    intersection() {
        sak_74mm_solid_body();
        translate([0, y, 0])
            cube([100, thickness, 100], center=true);
    }
}

module tapered_extension(y, y_target, z_target, tip_width, N=taper_slices) {
    if (enable_curved_taper) {
        // Generates a mathematically smooth quadratic (parabolic) taper
        // from the scale cross-section at Y = y to the target chisel edge.
        // By using a quadratic curve (t^2), the tangent at the start of the taper
        // is perfectly flat (slope = 0), matching the scale body with no sharp crease.
        y_start = y;
        y_end = y_target;
        z_start = target_thickness;
        z_end = z_target;
        width_start = scale_width_at_slice;
        width_end = tip_width;
        
        for (i = [0 : N-1]) {
            t0 = i / N;
            t1 = (i + 1) / N;
            
            // Quadratic curve: flat at start (t=0), accelerating to a wedge at end (t=1)
            curve0 = t0 * t0;
            curve1 = t1 * t1;
            
            // Y positions for the segment
            y0 = y_start - t0 * (y_start - y_end);
            y1 = y_start - t1 * (y_start - y_end);
            
            // Z scaling (max 0.001 to prevent degenerate 2D faces in CGAL)
            sz0 = max(0.001, 1.0 - curve0 * (1.0 - z_end/z_start));
            sz1 = max(0.001, 1.0 - curve1 * (1.0 - z_end/z_start));
            
            // X scaling (max 0.001 to prevent degenerate 2D faces in CGAL)
            sx0 = max(0.001, 1.0 - curve0 * (1.0 - width_end/width_start));
            sx1 = max(0.001, 1.0 - curve1 * (1.0 - width_end/width_start));
            
            hull() {
                // Start of segment: scale the base slice at Y=0, then place at y0
                translate([0, y0, 0])
                    scale([sx0, 1.0, sz0])
                    translate([0, -y_start, 0])
                    cross_section_slice(y_start);
                    
                // End of segment: scale the base slice at Y=0, then place at y1
                translate([0, y1, 0])
                    scale([sx1, 1.0, sz1])
                    translate([0, -y_start, 0])
                    cross_section_slice(y_start);
            }
        }
    } else {
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
}

module straight_tweezer_slot() {
    t_x = tweezer_pos[0];
    t_y = tweezer_pos[1];
    t_z = tweezer_pos[2];
    
    notch_length = 4.5;
    notch_height = 4.5;
    notch_z = t_z + 1.6; // Centered slightly above tweezer Z to cut through the top of the scale
    
    y_start = t_y;
    y_end = t_y + tweezer_length;
    
    // Auto-detect entrance: the end furthest from Y=0 is the entrance!
    is_bottom_entrance = abs(y_start) > abs(y_end);
    
    // Calculate Y centers and lengths based on entrance direction
    channel_y = is_bottom_entrance ? (t_y + tweezer_length/2 - 3.75) : (t_y + tweezer_length/2 + 3.75);
    channel_len = tweezer_length + 7.5; // Extended by 7.5mm to ensure a clean cut through the outer edge
    
    notch_y = is_bottom_entrance ? (t_y + notch_length/2 - 3.75) : (y_end - notch_length/2 + 3.75);
    notch_len = notch_length + 7.5;
    
    // 1. The Straight Tweezers Channel
    translate([t_x, channel_y, t_z])
        cube([tweezer_width, channel_len, tweezer_height], center=true);
        
    // 2. The Pull Notch
    translate([t_x, notch_y, notch_z])
        cube([tweezer_width, notch_len, notch_height], center=true);
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

    // C. Drill the straight tweezers slot if enabled
    if (enable_straight_tweezer_slot) {
        straight_tweezer_slot();
    }
}
