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
//tweezer_x = 4.75;
tweezer_x=3.0;
tweezer_length = 46.0;
tweezer_width = 3.15;
tweezer_height = 1.3;
tweezer_z = 2.15; // Z center of the tweezer channel

// Notch Config (the thumb pull opening at the entrance)
notch_length = 4.5;
notch_height = 4.5;

// --- Hollowed Box Config (Under Tweezers Channel) ---
// Adjust the location and size of the hollowed box in XY:
hollow_box_width = 3.15;                  // Width (X size)
hollow_box_length = 52.0;                // Length (Y size)
hollow_box_x = tweezer_x;                // Center X coordinate (aligns with tweezer channel by default)
hollow_box_y = 0 ; // Center Y coordinate (aligns with tweezer channel by default)

// Z parameters are automatically calculated:
// - Top of the hollowed box is the bottom of the tweezer channel: tweezer_z - tweezer_height/2 (1.5mm)
// - Bottom of the hollowed box is the bottom of the SAK scale: Z = 0
hollow_box_z_top = tweezer_z - tweezer_height/2;
hollow_box_z_bottom = 0;
hollow_box_height = hollow_box_z_top - hollow_box_z_bottom;
hollow_box_z_center = hollow_box_z_bottom + hollow_box_height / 2;

difference() {
    // A. The Base Scale Part
    color("Green")
        import(file_base);

    // B. The Straight Tweezers Channel
    // Starts at Y = -37.5 (the bottom end) and goes inwards for tweezer_length
    translate([tweezer_x, -37.5 + tweezer_length/2, tweezer_z])
        cube([tweezer_width, tweezer_length, tweezer_height], center=true);

    // C. The Pull Notch
    // At the entrance (Y = -37.5), cutting through the top of the scale (Z > 0)
    translate([tweezer_x, -37.5 + notch_length/2, 3.75])
        cube([tweezer_width, notch_length, notch_height], center=true);

    // D. The Hollowed Box under the Tweezers Channel
    // Extends from the bottom of the tweezer channel (Z = 1.5) to the bottom of the SAK scale (Z = 0)
    color("Red")
    translate([hollow_box_x, hollow_box_y, hollow_box_z_center])
        cube([hollow_box_width, hollow_box_length, hollow_box_height], center=true);
}