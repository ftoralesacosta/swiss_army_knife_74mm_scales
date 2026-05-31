// --- File Setup & Core Dimensions ---
target_len     = 75;
target_width   = 17.0; // Carefully dialed-in width for 74mm scale
target_thick   = 2.5;
$fn = 60; // Global smoothness

// --- Minkowski Configuration ---
mask_offset_x = 0; // Perfectly centered
mask_offset_y = 0; // Perfectly centered
mask_edge_radius = 2.1;

// --- Accessory Channels (Tweezers/Toothpick Slots) ---
enable_accessory_channels = true;
channel_width = 3.15; 
channel_length = 46; 
channel_height = 1.3; 

// Position relative to flat bottom face at Z = 0
channel_pos_x = -3.2;         
channel_pos_y = 8.6;          
channel_angle = 185.0;        
channel_pos_z = channel_height / 2; // Starts exactly at Z = 0

// Notch Settings (The opening for the tool head)
notch_length = 4.5;           
notch_start_pos = 42;
notch_depth_offset = 2.25;    
notch_height = 6.0;

// --- Pin Channel Settings (Optional) ---
enable_pin_slot = false;
pin_width = 1.0; 
pin_length = 45.0;        
pin_pos_x = 4.3;          
pin_pos_y = 14.5;
pin_pos_z = 1.0;
pin_angle = 186.0; 

// --- New Rivet Holes ---
hole_dist_y   = 60.5 / 2; 
hole_dist_x   = 9.5 / 2; 
hole_dia      = 3.8;
hole_height   = 2.1; // Height 1.6 + 0.5 clearance
hole_z_offset = -0.5; // Starts below Z = 0 for a clean cut
hole_nudge_x  = 0; // Perfectly centered
hole_nudge_y  = 0; // Perfectly centered

// --- Debug Config ---
show_center_lines = false;


// --- Mathematical Geometry Modules ---

module sak_profile_2d() {
    rad = 7.5; elong = 0.9;
    hull() {
        for (x = [-1, 1], y = [-1, 1]) 
            translate([x * (target_width/2 - rad) + mask_offset_x, y * (target_len/2 - (rad * elong)) + mask_offset_y])
            scale([1, elong]) circle(r=rad);
    }
}

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

module sak_74mm_solid_body() {
    difference() {
        // 1. Generate double-thickness rounded scale centered at Z = 0
        sak_scale_rounded(thickness = target_thick * 2, edge_radius = mask_edge_radius);
        
        // 2. Cut off the bottom half to leave a perfectly flat bottom face at Z = 0
        translate([-100, -100, -200])
            cube([200, 200, 200]);
    }
}

module new_rivet_holes() {
    for(x = [-1, 1], y = [-1, 1]) {
        translate([x * hole_dist_x + hole_nudge_x, y * hole_dist_y + hole_nudge_y, hole_z_offset]) 
            cylinder(h=hole_height, d=hole_dia, $fn=30);
    }
}

module accessory_slots() {
    if (enable_accessory_channels){
        // A & B: Main Channel and Notch
        translate([channel_pos_x, channel_pos_y, channel_pos_z])
        rotate([0, 0, channel_angle])
        union() {
            // A. The Main Channel
            translate([0, channel_length/2, 0])
            cube([channel_width, channel_length, channel_height], center=true);

            // B. The Notch
            translate([0, notch_start_pos + notch_length/2, notch_depth_offset]) 
            cube([channel_width, notch_length, notch_height], center=true);
        }
    }
    
    // C. Pin Channel (With Tension Curve)
    if (enable_pin_slot) {
        translate([pin_pos_x, pin_pos_y, pin_pos_z])
        rotate([0, 0, pin_angle])
        translate([0, pin_length/2, 0])
        union() {
            bend_amount = 0.4;
            steps = 20;
            for (i = [0 : steps]) {
                progress = (i / steps) - 0.5; 
                offset = bend_amount * (1 - pow(progress * 2, 2));
                translate([offset, progress * pin_length, 0])
                rotate([90, 0, 0])
                cylinder(d = pin_width, h = pin_length/steps + 0.1, center=true, $fn=15);
            }
        }
    }
}


// --- Final Assembly & Rendering ---

// 1. Visual Verification Centerlines (Optional)
if (show_center_lines) {
    translate([0, 0, 3])
        %color("Black") cube([0.1, 100, 0.5], center=true);
    translate([0, 0, 3])
        %color("Black") cube([100, 0.1, 0.5], center=true);
}

// 2. Final Subtracted Shape
difference() {
    // Perfectly flat-bottomed, rounded-top mathematical solid body
    sak_74mm_solid_body();

    // Rivet Holes (cuts from Z = -0.5 to 1.6)
    #new_rivet_holes();

    // Accessory Slots (cuts from Z = 0 to 1.3)
    if (enable_accessory_channels) {
        #accessory_slots();
        
        // Reflected slot
        rotate([0, 0, 180])
            #accessory_slots();
    }
}