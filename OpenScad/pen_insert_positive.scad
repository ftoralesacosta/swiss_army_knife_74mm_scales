// ============================================================================
// Pen Cavity Positive Impression Extractor
// ============================================================================
// This script extracts the positive shape of the pen insert cavity from a 
// Victorinox scale STL file so that you can subtract it from other designs.
//
// It provides adjustable parameters to size and position a "capturing box"
// (the selector volume) to isolate the pen cavity perfectly.
// ============================================================================

// --- 1. FILE PATHS & STL IMPORT STYLING ---
// The path to the original STL file (relative to this file, or absolute)
stl_file = "sak58mmscales-pen.stl";

// Level of detail / smoothness for circular features
$fn = 60; 

// --- 2. STL ORIENTATION PARAMETERS ---
// Use these to orient and position the STL if it's not in your desired default orientation.
// By default, this matches the orientation used in the 74mm scale BASE script.
stl_rotation    = [-90, 0, 90];
stl_translation = [0, 0, 0];


// --- 3. CAPTURING VOLUME CONFIGURATION ---
// Choose the shape of the selector volume used to isolate the cavity:
// "shaped_plug" (Recommended): A custom combination of boxes designed to capture
//   both the pen slot and slider slot perfectly without touching the scale's
//   curved boundaries. This eliminates all outer edge artifacts.
// "shrunken_glove": Automatically generates a 3D volume matching the exact curvature 
//   of the scale, offset inwards.
// "oval": An elliptical cylinder, useful for matching circular scale ends.
// "cube": A standard rectangular block.
box_shape = "shaped_plug"; // ["shaped_plug", "shrunken_glove", "oval", "cube"]

// Size of the capturing block [width (X), length (Y), height (Z)]
// (Used as the dimensions for the cube/oval, and the bounding/height values for the glove)
box_size = [15.0, 75.0, 4.0];

// Position of the capturing block relative to the STL origin
// Z is automatically offset so that the top surface of the box is perfectly flush with the Z = 1.25 flat face.
box_translation = [0, 0.0, 1.25 - box_size[2]/2];

// Optional rotation of the capturing block
box_rotation = [0, 0, 0];


// --- 4. SHRUNKEN GLOVE PARAMETERS ---
// (Only used if box_shape = "shrunken_glove")
// How many millimeters to shrink the outer edge contour inwards. 
// 0.8mm - 1.2mm is usually perfect to cut off the filleted edge artifacts.
glove_offset_inwards = 1.0;

// Length cutoff parameters to chop off the extreme rounded tips at +Y and -Y ends.
// This completely eliminates the thin 2D speckled webbing artifacts at the ends.
glove_y_length = 50.0;  // Safely inside the scale tips to avoid dome edge artifacts
glove_y_center = 3.0;   // Centered to preserve the main pen channel structure


// --- 5. EXTRACTION METHOD ---
// "hull_intersection" (Recommended): Subtracts the STL from its convex hull, 
//   then intersects with the capturing box. This guarantees the top surface 
//   of the positive impression perfectly matches the flat face of the scale.
// "direct_difference": Subtracts the STL directly from the capturing box.
//   Use this if you want the capturing box to act as a flat cap/backplane.
extraction_method = "hull_intersection"; // ["hull_intersection", "direct_difference"]


// --- 6. OTHER FEATURES CONFIG ---
// Fill the original rivet holes so they don't get captured as "cavities"
fill_rivet_holes = true;


// --- 7. NARROW CHANNEL EXTENSION ---
// The final length of the narrow channel that houses the tip of the pen (in mm).
// Originally, the STL's narrow channel had a length of 21.0mm (Y from 8 to 29).
// We shorten the STL bounding box to 16.0mm (ending at Y=24), and manually
// extend it with a perfectly aligned cylinder-on-box channel to this final length.
pen_tip_length = 21.0;


// ============================================================================
// INTERNAL IMPLEMENTATION
// ============================================================================

// Module that imports and positions the original STL with filled rivets
module oriented_stl() {
    union() {
        translate(stl_translation) {
            rotate(stl_rotation) {
                import(stl_file, convexity=5);
            }
        }
        
        if (fill_rivet_holes) {
            // Rivet hole locations are already in the world orientation (aligned along Z)
            // So we apply translation, but do not rotate them.
            translate(stl_translation) {
                rivet_fills_58mm();
            }
        }
    }
}

// Helper to fill rivet holes so they are not treated as cavities
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

// Automated 3D volume matching the exact 2D contour of the scale, offset inwards
module shrunken_glove(offset_dist, height) {
    // Project the STL slightly inside its solid body (Z = 1.00) to get a robust 2D profile,
    // wrap in hull() to fill all internal cavity holes, shrink it inwards,
    // and extrude it as a 3D volume centered around Z.
    translate(stl_translation) {
        linear_extrude(height=height, center=true) {
            offset(r = -offset_dist) {
                hull() {
                    projection(cut = true) {
                        translate([0, 0, -1.00]) {
                            rotate(stl_rotation) {
                                import(stl_file, convexity=5);
                            }
                        }
                    }
                }
            }
        }
    }
}

// The capturing block module (can be moved / resized via parameters)
module capturing_volume() {
    translate(box_translation) {
        rotate(box_rotation) {
            if (box_shape == "shrunken_glove") {
                // We intersect the shrunken glove with a length-limiting box to chop off the dome ends.
                intersection() {
                    shrunken_glove(glove_offset_inwards, box_size[2]);
                    translate([0, glove_y_center, 0]) {
                        cube([50, glove_y_length, box_size[2]], center=true);
                    }
                }
            } else if (box_shape == "shaped_plug") {
                // A custom combination of narrow/wide boxes that isolates the pen cavity and 
                // slider slot while keeping clear of the scale's curved borders.
                union() {
                    // Box 1: Most narrow channel for the pen tip (Y from 8 to 24)
                    translate([0, 16.0, 0])
                        cube([2.5, 16.0, box_size[2]], center=true);

                    // Box 2: Medium pen holder channel (Y from -25 to 8)
                    translate([0, -8.5, 0])
                        cube([4.5, 33.0, box_size[2]], center=true);
                        
                    // Box 3: Wider channel for the slider slot (Y from -20 to 7)
                    translate([-4.0, -6.5, 0])
                        cube([5.0, 27.0, box_size[2]], center=true);
                }
            } else {
                if (box_shape == "cube") {
                    cube(box_size, center=true);
                } else if (box_shape == "oval") {
                    // Scale a cylinder to make a perfect ellipse matching the rounded ends
                    scale([1, box_size[1]/box_size[0], 1]) {
                        cylinder(d=box_size[0], h=box_size[2], center=true);
                    }
                }
            }
        }
    }
}

// Helper module to create a channel of a given length, consisting of a cylinder of radius 1.25
// (centered at X=0, Z=0) and a box of width 2.5 (from X=-1.25 to 1.25) extending from Z=0 to Z=1.25.
module aligned_channel(length) {
    union() {
        // Cylinder along Y-axis, centered at X=0, Z=0
        rotate([-90, 0, 0])
            cylinder(r=1.25, h=length, $fn=60);
        
        // Box atop the cylinder (from Z=0 to Z=1.25)
        translate([-1.25, 0, 0])
            cube([2.5, length, 1.25]);
    }
}

// The generated positive impression of the cavity
module pen_cavity_impression() {
    union() {
        if (extraction_method == "hull_intersection") {
            // Method A (Recommended):
            // 1. Get all concave cavities by subtracting STL from its convex hull
            // 2. Intersect with the capturing box to isolate ONLY the pen slot
            intersection() {
                difference() {
                    hull() oriented_stl();
                    oriented_stl();
                }
                capturing_volume();
            }
        } else if (extraction_method == "direct_difference") {
            // Method B:
            // Subtract the STL directly from the capturing box.
            difference() {
                capturing_volume();
                oriented_stl();
            }
        }
        
        // Add the manually extended aligned channel starting at Y = 24
        if (pen_tip_length > 16.0) {
            translate([0, 24.0, 0])
                aligned_channel(pen_tip_length - 16.0);
        }
    }
}


// ============================================================================
// VISUALIZATION & OUTPUT
// ============================================================================

// Color codes for visual inspection in OpenSCAD:
// Green: The extracted pen cavity positive impression
// Semi-transparent Red: The capturing block bounds (to help you adjust parameters)
// Semi-transparent Blue: The original STL scale (for alignment reference)

show_positive_impression = true;
show_capturing_box_bounds = false;
show_original_reference = false;

if (show_positive_impression) {
    color("Green") {
        pen_cavity_impression();
    }
}

if (show_capturing_box_bounds) {
    // Render capturing box as transparent red bounds
    color([1, 0, 0, 0.25]) {
        capturing_volume();
    }
}

if (show_original_reference) {
    // Render original scale as transparent blue reference
    color([0, 0, 1, 0.25]) {
        oriented_stl();
    }
}