// ============================================================================
// Pen Cavity Positive Impression Extractor
// ============================================================================
// Extracts the positive shape of the pen insert cavity from a Victorinox 58mm
// scale STL file, with an adjustable pen tip channel extension.
// ============================================================================

$fn = 60; 

// --- PARAMETERS ---
stl_file       = "sak58mmscales-pen.stl";
pen_tip_length = 23.0; // Adjustable final length of the narrow channel (default 21.0)

// STL Orientation (aligned along Z, top flat face at Z=1.25, channel runs along Y)
stl_rotation    = [-90, 0, 90];
stl_translation = [0, 0, 0];

// Capturing Volume Properties
box_z_size      = 4.0;
box_translation = [0, 0.0, 1.25 - box_z_size/2];

// --- MODULES ---

// Imports the original STL and fills rivet holes to prevent capturing them as cavities
module oriented_stl() {
    union() {
        translate(stl_translation)
            rotate(stl_rotation)
                import(stl_file, convexity=5);
        
        // Fill rivet holes (already oriented along Z)
        translate(stl_translation)
            rivet_fills_58mm();
    }
}

module rivet_fills_58mm() {
    rivet_anchor = [-3.5, -23, -2.4];
    rivet_spacing = [7.0, 46];
    rivet_dim = [4.0, 3.65]; // [Diameter, Height]
    for (x = [0, 1], y = [0, 1]) {
        translate([
            rivet_anchor.x + (x * rivet_spacing.x), 
            rivet_anchor.y + (y * rivet_spacing.y), 
            rivet_anchor.z
        ])
        cylinder(d=rivet_dim[0], h=rivet_dim[1], $fn=30);
    }
}

// Custom volume to isolate the pen cavity and slider slot
module capturing_volume() {
    translate(box_translation) {
        union() {
            // Box 1: Narrow channel for the pen tip (Y from 8 to 24)
            translate([0, 16.0, 0])
                cube([2.5, 16.0, box_z_size], center=true);

            // Box 2: Medium pen holder channel (Y from -25 to 8)
            translate([0, -8.5, 0])
                cube([4.5, 33.0, box_z_size], center=true);
                
            // Box 3: Slider slot channel (Y from -20 to 7)
            translate([-4.0, -6.5, 0])
                cube([5.0, 27.0, box_z_size], center=true);
        }
    }
}

// Creates the extension channel: cylinder of radius 1.25 topped by a 2.5 wide box
module aligned_channel(length) {
    union() {
        rotate([-90, 0, 0])
            cylinder(r=1.25, h=length, $fn=60);
        
        translate([-1.25, 0, 0])
            cube([2.5, length, 1.25]);
    }
}

// Extracted positive cavity impression with the adjustable manual extension
module pen_cavity_impression(tip_length = pen_tip_length) {
    union() {
        // Extract cavity by subtracting STL from its convex hull, limited to capturing volume
        intersection() {
            difference() {
                hull() oriented_stl();
                oriented_stl();
            }
            capturing_volume();
        }
        
        // Manual pen tip extension beyond Y = 24
        if (tip_length > 16.0) {
            translate([0, 24.0, 0])
                aligned_channel(tip_length - 16.0);
        }
    }
}

// --- OUTPUT ---
color("Green") {
    pen_cavity_impression();
}
