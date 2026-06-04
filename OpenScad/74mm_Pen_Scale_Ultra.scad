// ============================================================================
// 74mm SAK Pen Scale ULTRA
// ============================================================================
// Adds a straight tweezers slot to the side of the pen cavity.
// Starts from 74mm_Pen_Scale_BASE.stl.
// ============================================================================

$fn = 60;

// Path to the base pen scale STL (centered at origin, flat bottom face at Z = 0)
file_base = "../74mm_Pen_Scale_BASE.stl";

// --- Tweezers Channel Config ---
// Centered at X = 4.75 (directly aligned with the rivet holes)
tweezer_x = 4.75;
tweezer_length = 46.0;
tweezer_width = 3.15;
tweezer_height = 1.3;

// Notch Config (the thumb pull opening at the entrance)
notch_length = 4.5;
notch_height = 4.5;

difference() {
    // A. The Base Scale Part
    color("Green")
        import(file_base);

    // B. The Straight Tweezers Channel
    // Starts at Y = -37.5 (the bottom end) and goes inwards for tweezer_length
    translate([tweezer_x, -37.5 + tweezer_length/2, 2.15])
        cube([tweezer_width, tweezer_length, tweezer_height], center=true);

    // C. The Pull Notch
    // At the entrance (Y = -37.5), cutting through the top of the scale (Z > 0)
    translate([tweezer_x, -37.5 + notch_length/2, 3.75])
        cube([tweezer_width, notch_length, notch_height], center=true);
}
