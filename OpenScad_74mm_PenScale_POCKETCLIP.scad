// --- 1. File Configuration ---
file_74mm = "OpenScad_74mm_PenScale.stl";
$fn = 120; // Smoothness

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
screw_diameter = 2.2;  
screw_depth    = 6.0;  

// C. Clip Settings
clip_hole_spacing = 4.5; 

// D. Indent Settings (CA-05A profile)
indent_depth = 1.1;
scale_thickness_at_clip = 4.5; 

// Indent widths (including 0.1mm shrinkage allowance)
width_inner = 5.5 + 0.1; // Inner hole (5.6mm total)
width_outer = 6.8 + 0.1; // Edge fold (6.9mm total)

// *** EDITABLE LENGTH PARAMETERS ***

// 1. Flat Edge (Towards the OUTSIDE end of the scale)
extension_towards_edge = 5.2; 
flat_corner_radius = 2.9; // Adjusts how round the corners of the flat edge are

// 2. Rounded Tip (Towards the INSIDE middle of the scale)
extension_towards_middle = 0.0; 

// --- 3. Position the Holes ---
pos_x = scale_center+0.3;  
pos_y = -7.2; 
pos_z = 4.96;  // Entry point (Surface height for INSIDE face)

rot_x = 0;
rot_y = 180;
rot_z = 90;   

// --- 4. Pin Channel Settings ---
pin_width = 1.3;         
pin_length = 35.0;       
pin_pos_x = -5.0;         
pin_pos_y = -2.7;
pin_pos_z = 1.5;
pin_angle = 91.0;    

// --- 5. The Geometry ---
difference() {
    // A. The Part (Imported)
    color("yellow", 1.0) 
    translate([1, 9, 4.]) 
    import(file_74mm);

    // B. The Holes & Indent to Cut
    #translate([pos_x, pos_y, pos_z])
    rotate([rot_x, rot_y, rot_z])
    civivi_holes();
}

// --- Modules ---

module civivi_holes() {
    union() {
        // --- A. The Flush Clip Indent ---
        //clip_indent();

        // --- B. The Screw Holes ---
        // Hole 1 Stack
        make_hole_stack();
        
        // Hole 2 Stack (offset by 4.5mm)
        translate([clip_hole_spacing, 0, 0])
        make_hole_stack();
        
        // --- C. Pin Channel 1 (Original) ---
        translate([pin_pos_x-2.0, pin_pos_y, pin_pos_z])
        rotate([0, 0, pin_angle]) 
        curved_pin_channel(pin_length+4, pin_width, 0.9);

        // --- D. Pin Channel 2 (Opposite Y) ---
        translate([pin_pos_x-41, pin_pos_y, pin_pos_z])
        rotate([0, 0, 180 - pin_angle]) 
        curved_pin_channel(pin_length, pin_width-0.4, 0.9);
    }
}

module clip_indent() {
    total_length_outer = clip_hole_spacing + extension_towards_edge;
    
    // Pushed through to the OUTSIDE face
    translate([0, 0, scale_thickness_at_clip - indent_depth])
    hull() {
        // 1. Inner tip (Middle of scale) - Reverted to the "perfect" state
        translate([-extension_towards_middle, 0, 0])
        cylinder(h = indent_depth + 5.0, d = width_inner);

        // 2. Outer flat end (Towards edge of scale) - Extended by 4mm
        translate([total_length_outer - flat_corner_radius, (width_outer / 2) - flat_corner_radius, 0])
        cylinder(h = indent_depth + 5.0, r = flat_corner_radius);
        
        translate([total_length_outer - flat_corner_radius, -(width_outer / 2) + flat_corner_radius, 0])
        cylinder(h = indent_depth + 5.0, r = flat_corner_radius);
    }
}

module make_hole_stack() {
    union() {
        // 1. The Insert Hole (Wide, Shallow - INSIDE face)
        cylinder(h = hole_height, d = hole_diameter);
        
        // 2. The Screw Hole (Narrow, Deep)
        cylinder(h = screw_depth, d = screw_diameter);
    }
}

module curved_pin_channel(length, diameter, x_offset) {
    steps = 4; 
    render() 
    for (i = [0 : steps - 1]) {
        y_pos1 = (i / steps) * length;
        y_pos2 = ((i + 1) / steps) * length;
        
        x_off1 = sin((i / steps) * 180) * x_offset;
        x_off2 = sin(((i + 1) / steps) * 180) * x_offset;

        hull() {
            translate([x_off1, y_pos1 - length/2, 0])
                sphere(d = diameter, $fn=12); 
            translate([x_off2, y_pos2 - length/2, 0])
                sphere(d = diameter, $fn=12);
        }
    }
}