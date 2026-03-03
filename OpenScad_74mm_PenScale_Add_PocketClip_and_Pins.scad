// --- 1. File Configuration ---
file_74mm = "OpenScad_74mm_PenScale.stl";
$fn = 60; // Smoothness

// --- Centering & Debug ---
left_edge = -5.7;
right_edge = 10.6;
scale_center = (left_edge + right_edge) / 2;
show_center_lines = false;
if (show_center_lines) {
    translate([scale_center, 0, 6])
    %color("Black") cube([0.1, 100, 0.5], center=true);
    translate([0.0, -12.5, 6])
    %color("Black") cube([100, 0.1, 0.5], center=true);
}

// --- 2. Hole Configuration ---

// A. Insert Settings (The wide part for the brass nut)
hole_diameter = 3.2; 
hole_height   = 2.0;

// B. Screw Clearance Settings (The narrow part for the screw to pass through)
screw_diameter = 2.2;  // 2.2mm allows an M2 screw to slide through easily
screw_depth    = 6.0;  // How deep the screw hole goes (should be > hole_height)

// C. Clip Settings
// Civivi Deep Carry clips are usually 4.5mm spacing.
clip_hole_spacing = 4.5; 

// --- 3. Position the Holes ---
// CHANGE THESE NUMBERS to move the holes to the right spot
// Note: These coordinates are relative to the world, not the STL's local origin
pos_x = scale_center+0.3;  
pos_y = -7.2; 
pos_z = 4.8;  // Entry point (Surface height)

rot_x = 0;
rot_y = 180;
rot_z = 90;   // Rotate this if the clip needs to be angled

// --- 4. Pin Channel Settings ---
pin_width = 1.3;         
pin_length = 35.0;       
pin_pos_x = -5.0;         
pin_pos_y = -2.7;
pin_pos_z = 1.5;
pin_angle = 91.0;    


// --- 5. The Geometry ---
difference() {
    // A. The Part (Imported & Moved as you requested)
    color("yellow", 1.0) 
    translate([1, 9, 4.]) 
    import(file_74mm);

    // B. The Holes to Cut
    // The '#' sign makes the holes appear red/transparent so you can see them!
    #translate([pos_x, pos_y, pos_z])
    rotate([rot_x, rot_y, rot_z])
    civivi_holes();
}

// --- Modules ---

module civivi_holes() {
    union() {
        // Hole 1 Stack
        make_hole_stack();
        
        // Hole 2 Stack (offset by 4.5mm)
        translate([clip_hole_spacing, 0, 0])
        make_hole_stack();
        
        // B. Pin Channel
        translate([pin_pos_x, pin_pos_y, pin_pos_z])
        rotate([0, 0, pin_angle]) // Only rotate on Z to align with the pen body
        curved_pin_channel(pin_length, pin_width, 0.5);
        
        // C. Second Pin Channel
        translate([pin_pos_x-41, pin_pos_y, pin_pos_z])
        rotate([0, 0, pin_angle]) // Only rotate on Z to align with the pen body
        curved_pin_channel(pin_length, pin_width, 0.5);
        }
    }

module make_hole_stack() {
    union() {
        // 1. The Insert Hole (Wide, Shallow)
        cylinder(h = hole_height, d = hole_diameter);
        
        // 2. The Screw Hole (Narrow, Deep)
        // We start this at 0 too, so it goes all the way through the insert area
        // down into the plastic.
        cylinder(h = screw_depth, d = screw_diameter);
    }
}

module curved_pin_channel(length, diameter, x_offset) {
    steps = 4; 
    render() 
    for (i = [0 : steps - 1]) {
        // progress along the length (Y-axis)
        y_pos1 = (i / steps) * length;
        y_pos2 = ((i + 1) / steps) * length;
        
        // Offset amount (X-axis) creating the bow
        x_off1 = sin((i / steps) * 180) * x_offset;
        x_off2 = sin(((i + 1) / steps) * 180) * x_offset;

        hull() {
            // Keep Z at 0 to ensure no vertical curve
            translate([x_off1, y_pos1 - length/2, 0])
                sphere(d = diameter, $fn=12); // Using spheres for cleaner hulls at angles
            translate([x_off2, y_pos2 - length/2, 0])
                sphere(d = diameter, $fn=12);
        }
    }
}