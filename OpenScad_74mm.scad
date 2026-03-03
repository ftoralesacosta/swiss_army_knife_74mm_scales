// --- File Setup ---
filename = "58mm_source_files/victorinox-scale-58mm.stl";

// --- Dimensions Configuration (Scale) ---
original_len   = 58;
original_width = 18;  
original_thick = 3.2; 

target_len     = 75;
target_width   = 21;
target_thick   = 2.5;

plug_thickness = 1.8;
$fn = 60; // Global smoothness

// --- Dimensions Configuration (Slots - Borrowed) ---

// 1. Channel Dimensions (Tweezers/Toothpick)
enable_accessory_channels=true;
channel_width = 3.15; 
channel_length = 46; 
channel_height = 1.3; 

// 2. Position (ADJUST THESE TO MOVE THE SLOT)
channel_pos_x = -3.2;          
channel_pos_y = 8.6;          
channel_angle = 185.0;        
channel_pos_z = 1.31; 

// 3. Notch Settings (The opening for the tool head)
notch_length = 4.5;           
notch_start_pos = 42;
notch_depth_offset = -2.25;    
notch_height = 6.0;

// 4. Pin Channel Settings
enable_pin_slot = false;
pin_width = 1.0; 
pin_length = 45.0;        
pin_pos_x = 4.3;          
pin_pos_y = 14.5;
pin_pos_z = 1.0;
pin_angle = 186.0; 

// --- Calculations ---
stretch  = target_len - original_len;
offset   = stretch / 2;
scale_y  = target_width / original_width;
scale_z  = target_thick / original_thick;

// --- New Rivet Holes ---
hole_dist_y   = 60.5 / 2; 
hole_dist_x   = 9.5 / 2; 
hole_dia      = 3.8;
hole_height   = 1.6; 
hole_z_offset = 2.0-1.5; 


// --- Geometry Modules ---

module oriented_knife_geom() {
    rotate([0, 0, -90]) import(filename, convexity=3);
}

module rivet_plugs() {
    translate([-4.2, 31.2, 0.15]) cylinder(h=plug_thickness, d=4.5);
    translate([4.0, 31.2, 0.15])  cylinder(h=plug_thickness, d=4.8);
    translate([-4.2, -31.2, 0.15]) cylinder(h=plug_thickness, d=4.5);
    translate([4.0, -31.2, 0.15])  cylinder(h=plug_thickness, d=4.8);
}

module stretched_body() {
    rotate([0, 0, 90]) 
    scale([1, scale_y, scale_z]) 
    union() {
        // Right Half
        translate([offset, 0, 0]) 
            intersection() {
                oriented_knife_geom();
                translate([0, -50, -50]) cube([100, 100, 100]); 
            }
        // Left Half
        translate([-offset, 0, 0]) 
            intersection() {
                oriented_knife_geom();
                translate([-100, -50, -50]) cube([100, 100, 100]); 
            }
        // Center Fill Bridge
        hull() {
            translate([offset, 0, 0]) 
                intersection() {
                    oriented_knife_geom();
                    translate([0, -50, -50]) cube([0.1, 100, 100]);
                }
            translate([-offset, 0, 0]) 
                intersection() {
                    oriented_knife_geom();
                    translate([-0.1, -50, -50]) cube([0.1, 100, 100]); 
                }
        }
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
            // Tension Curve Parameters
            bend_amount = 0.4; // How much the middle bows out (in mm)
            steps = 20;        // Smoothness of the curve
            
            for (i = [0 : steps]) {
                // Calculate progress along the pin (from -0.5 to 0.5)
                progress = (i / steps) - 0.5; 
                
                // Parabolic curve formula: y = 1 - 4x^2
                // This makes the offset 0 at the ends and 'bend_amount' in the middle
                offset = bend_amount * (1 - pow(progress * 2, 2));
                
                translate([offset, progress * pin_length, 0])
                rotate([90, 0, 0])
                cylinder(d = pin_width, h = pin_length/steps + 0.1, center=true, $fn=15);
            }
        }
    }
}

// --- Final Assembly ---

difference() {
    // 1. Positive Volume
    union() {
        stretched_body();
        rivet_plugs();
    }

    // 2. Negative Volume (Holes & Slots)
    union() {
        // Rivet Holes
        for(x = [-1, 1], y = [-1, 1]) {
            #translate([x * hole_dist_x, y * hole_dist_y, hole_z_offset]) 
                cylinder(h=hole_height, d=hole_dia);
        }

        // --- Accessory Slots ---
        
        
        //Comment Both Slots out if you want a 'blank' scale
        // Slot 1: The Original
        #accessory_slots();

        // Slot 2: Reflected across the X-axis (Top to Bottom)
        // Rotating 180 degrees keeps the angle parallel to the first
        rotate([0, 0, 180])
        #accessory_slots();
    }
}