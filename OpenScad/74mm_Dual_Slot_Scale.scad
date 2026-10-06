// --- File Setup & Core Dimensions ---
target_len     = 74;   // End-to-end. (Was 75: overhung the 74mm liner by ~0.5 at each end)
target_width   = 17.0; // Carefully dialed-in width for 74mm scale
target_thick   = 2.0;  // (was 2.5 - printed slightly taller than the toothpick/tweezers)
$fn = 60; // Global smoothness

// --- Minkowski Configuration ---
mask_offset_x = 0; // Perfectly centered
mask_offset_y = 0; // Perfectly centered
mask_edge_radius = 2.1; // (legacy - only used by sak_scale_rounded())

// --- Edge Profile (cross-section of the rounded edge) ---
// Measured from a photo of a genuine Victorinox small toothpick (IMG_2339):
// the head end is a single circular arc, R = 2.4 mm (+/- ~0.1), fit error < 0.03 mm.
// The arc is placed tangent to the top face so it blends smoothly (no crease):
// center at Z = target_thick - R (= -0.4 at 2.0 mm thick, so the arc starts just
// below the base and the edge meets the bottom face ~10 deg off vertical).
edge_profile_radius = 2.4;
edge_arc_center_z   = target_thick - edge_profile_radius;
edge_profile_steps  = 24;   // Number of slices used to build the arc

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

// Channel Stiffener: the channel gets shallower toward its inner end (the middle of
// the scale, where both channels overlap and the scale wants to bend). Material is
// added inside the channel only - the scale height is unchanged.
// Sized to follow the toothpick's point taper (STL: 1.32 thick until ~9.6 mm from
// the point, tapering to 0.55 at the point; point sits ~1.5 mm from the inner end).
enable_channel_taper = true;
channel_taper_length = 11;   // Distance from the inner end over which depth ramps (was 12; toothpick now seats 1 mm deeper)
channel_inner_depth  = 0.6;  // Channel depth at the very inner end (full = channel_height)

// Notch Settings (The opening for the tool head)
// The toothpick head's shoulder butts against the notch's inner wall
// (notch_start_pos), so this sets how far in the toothpick goes.
notch_length = 5.5;           // (was 4.5; +1 so the notch's outer end stays put)
notch_start_pos = 42;         // (was 43; tools overhung the liner edge by ~1 mm)
notch_depth_offset = 2.25;    
notch_height = 6.0;

// Nail Nick (ramp behind the tool head so a fingernail can lift it out)
// Starts at the top surface nail_nick_length before the notch wall and slopes
// down toward the knife (Z = 0) to nail_nick_bottom_z at the notch wall.
// Ending at the channel top (1.3) exposes the head's shoulder above the shank.
enable_nail_nick  = true;
nail_nick_length  = 1.5;
nail_nick_bottom_z = channel_height;

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
hole_height   = 1.9; // Pocket depth 1.4 + 0.5 below Z = 0. (Was 2.1 / 1.6 deep: only 0.4 mm
                     // of skin left on the 2.0 mm scale. Set back to 2.1 if pins don't seat.)
hole_z_offset = -0.5; // Starts below Z = 0 for a clean cut
hole_nudge_x  = 0; // Perfectly centered
hole_nudge_y  = 0; // Perfectly centered

// --- Debug Config ---
show_center_lines = false;


// --- Mathematical Geometry Modules ---

// Plan-view outline (same plane as the liners) - compound curve per end:
//   straight side -> corner arc (profile_corner_radius) -> flat end arc (profile_end_radius)
// All arcs are tangent. A large end radius makes the end flatten out quickly from
// the corner, like the aluminum liner, instead of bulging like a single radius.
// Defaults keep the corners where the old R7.5 ellipse put them; only the
// middle of the end comes in (0.5 mm), giving 74 mm overall.
profile_corner_radius = 6.2;
profile_end_radius    = 45;

// Derived: corner-circle center (x, y) and the end arc's tangent point.
_pc_x  = target_width/2 - profile_corner_radius;
_pe_cy = target_len/2 - profile_end_radius;                   // end-arc center y
_pc_y  = _pe_cy + sqrt(pow(profile_end_radius - profile_corner_radius, 2) - _pc_x*_pc_x);
_pt_x  = _pc_x * profile_end_radius / (profile_end_radius - profile_corner_radius);

module sak_profile_2d() {
    translate([mask_offset_x, mask_offset_y])
    hull() {
        // Four corner arcs
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * _pc_x, sy * _pc_y]) circle(r = profile_corner_radius, $fn = 120);
        // Two flat end arcs (only the part between the corner tangent points)
        for (sy = [-1, 1])
            mirror([0, sy < 0 ? 1 : 0])
            intersection() {
                translate([0, _pe_cy]) circle(r = profile_end_radius, $fn = 720);
                translate([-_pt_x, _pc_y]) square([2 * _pt_x, target_len]);
            }
    }
}

// Previous outline (hull of 4 R7.5 x 6.75 ellipses) - kept for reference.
module sak_profile_2d_legacy(rad = 7.5, elong = 0.9) {
    hull() {
        for (x = [-1, 1], y = [-1, 1]) 
            translate([x * (target_width/2 - rad) + mask_offset_x, y * (75/2 - (rad * elong)) + mask_offset_y])
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

// Horizontal inset of the edge at height z, relative to the full footprint at Z = 0.
// Arc of radius R centered at height zc; vertical wall below zc.
function _edge_w(z, R, zc) = z <= zc ? R : sqrt(max(0, R*R - pow(z - zc, 2)));
function edge_inset(z, R, zc) = _edge_w(0, R, zc) - _edge_w(z, R, zc);

module sak_74mm_solid_body(thick = target_thick, R = edge_profile_radius, zc = undef) {
    z_c = is_undef(zc) ? thick - R : zc;   // default: arc tangent to the top face
    assert(thick <= z_c + R + 1e-9, "Scale is thicker than the edge arc's top (arc center + edge_profile_radius)");
    // Profile and arc are both convex, so a hull of thin offset slices
    // reproduces the solid exactly (and much faster than minkowski).
    eps = 0.01;
    hull() {
        // Slices at Z = 0 and evenly spaced in angle around the arc
        zs = concat([0], [for (i = [0 : edge_profile_steps])
                          let(zz = z_c + R * sin(90 * i / edge_profile_steps))
                          if (zz > 0 && zz < thick) zz], [thick - eps]);
        for (z0 = zs) {
            z = min(z0, thick - eps);
            translate([0, 0, z])
                linear_extrude(height = eps)
                offset(delta = -edge_inset(z, R, z_c))
                sak_profile_2d();
        }
    }
}

// Previous body (R2.1 sphere minkowski, sliced flat at the top) - kept for reference.
module sak_74mm_solid_body_legacy(thick = target_thick) {
    difference() {
        // 1. Generate double-thickness rounded scale centered at Z = 0
        sak_scale_rounded(thickness = 2.5 * 2, edge_radius = mask_edge_radius);
        
        // 2. Cut off the bottom half to leave a perfectly flat bottom face at Z = 0
        translate([-100, -100, -200])
            cube([200, 200, 200]);
            
        // 3. Slice off the top to the desired thickness
        translate([-100, -100, thick])
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
            // A. The Main Channel (cut up from Z = 0; local z = world Z - channel_pos_z)
            if (enable_channel_taper) {
                eps = 0.01;
                // Full-depth section
                translate([0, (channel_taper_length + channel_length)/2, 0])
                cube([channel_width, channel_length - channel_taper_length, channel_height], center=true);
                // Stiffener ramp: shallow at the inner end, full depth at channel_taper_length
                hull() {
                    translate([-channel_width/2, 0, -channel_pos_z - eps])
                        cube([channel_width, eps, channel_inner_depth + eps]);
                    translate([-channel_width/2, channel_taper_length, -channel_pos_z - eps])
                        cube([channel_width, eps, channel_height + eps]);
                }
            } else {
                translate([0, channel_length/2, 0])
                cube([channel_width, channel_length, channel_height], center=true);
            }

            // B. The Notch
            translate([0, notch_start_pos + notch_length/2, notch_depth_offset]) 
            cube([channel_width, notch_length, notch_height], center=true);

            // B2. Nail Nick: sloped ramp in front of the notch wall
            //     (local z = world Z - channel_pos_z)
            if (enable_nail_nick) {
                eps = 0.01;
                z_top = notch_depth_offset + notch_height/2;   // well above the scale
                hull() {
                    // At the notch wall: open from nail_nick_bottom_z upward
                    translate([-channel_width/2, notch_start_pos - eps, nail_nick_bottom_z - channel_pos_z])
                        cube([channel_width, 2*eps, z_top - (nail_nick_bottom_z - channel_pos_z)]);
                    // nail_nick_length further in: starts at the top surface
                    translate([-channel_width/2, notch_start_pos - nail_nick_length - eps, target_thick - channel_pos_z])
                        cube([channel_width, 2*eps, z_top - (target_thick - channel_pos_z)]);
                }
            }
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

    // Rivet Holes (cuts from Z = -0.5 to 1.4)
    #new_rivet_holes();

    // Accessory Slots (cuts from Z = 0 to 1.3)
    if (enable_accessory_channels) {
        #accessory_slots();
        
        // Reflected slot
        rotate([0, 0, 180])
            #accessory_slots();
    }
}