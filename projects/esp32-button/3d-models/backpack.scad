// ESP32 Pomodoro Button - Simple Backpack Enclosure
// Atom Lite on top, expansion board on bottom, connected by M2 screw + GROVE

// === Parameters ===
$fn = 50;

// Atom Lite dimensions
atom_size = 24;
atom_height = 9.5;

// PCB dimensions (same as Atom Lite)
pcb_size = 24;
pcb_thickness = 1.6;

// Component height on PCB
component_height = 4;  // TP4056, USB-C, etc.

// M2 mounting
m2_hole = 2.2;
m2_head_dia = 4;
m2_nut_dia = 4.5;
m2_screw_length = 10;  // M2x10mm

// GROVE connector grove_height = 4;
// Battery dimensions
battery_width = 30;
battery_length = 40;
battery_height = 5;

// === Simple Backpack Case ===
// Just the bottom part that holds the extension board and battery
module backpack() {
    // Base plate with walls
    base_thickness = 1.5;
    wall_height = component_height + battery_height + 2;
    
    union() {
        // Main shell with cutouts
        difference() {
            // Outer shell
            linear_extrude(height = wall_height)
                rounded_square(pcb_size + 2, pcb_size + 2, 2);
            
            // Hollow interior
            translate([1, 1, base_thickness])
                linear_extrude(height = wall_height)
                    rounded_square(pcb_size, pcb_size, 1);
            
            // USB-C opening (side)
            translate([(pcb_size + 2 - 12)/2, -0.5, wall_height - 8])
                cube([12, 2, 6]);
            
            // Switch opening (side)
            translate([pcb_size + 2 - 1.5, 6, wall_height - 8])
                cube([2, 10, 4]);
        }
        
        // PCB mounting posts (4 corners, match Atom Lite hole pattern)
        // Actually Atom Lite only has ONE center M2 hole
        // So we use the center hole for mounting
        
        // Center M2 post (main mounting point)
        post_height = wall_height - 1;
        difference() {
            translate([(pcb_size + 2)/2, (pcb_size + 2)/2, 0])
                cylinder(d=8, h=post_height);
            translate([(pcb_size + 2)/2, (pcb_size + 2)/2, -0.5])
                cylinder(d=m2_hole, h=post_height + 1);
            // Nut trap at bottom
            translate([(pcb_size + 2)/2, (pcb_size + 2)/2, -0.5])
                cylinder(d=m2_nut_dia, h=3, $fn=6);
        }
        
        // Small alignment pins (optional, for stability)
        pin_positions = [
            [3, 3],
            [pcb_size + 2 - 3, 3],
            [3, pcb_size + 2 - 3],
            [pcb_size + 2 - 3, pcb_size + 2 - 3]
        ];
        
        for (pos = pin_positions) {
            translate([pos[0], pos[1], wall_height - 3])
                cylinder(d=2, h=3);
        }
        
        // Battery retention clips
        translate([1, 4, base_thickness + 2])
            cube([1.5, 6, battery_height - 2]);
        translate([1, pcb_size + 2 - 10, base_thickness + 2])
            cube([1.5, 6, battery_height - 2]);
        translate([pcb_size + 2 - 2.5, 4, base_thickness + 2])
            cube([1.5, 6, battery_height - 2]);
        translate([pcb_size + 2 - 2.5, pcb_size + 2 - 10, base_thickness + 2])
            cube([1.5, 6, battery_height - 2]);
    }
}

// === Helper: Rounded Square ===
module rounded_square(w, h, r) {
    if (r > 0) {
        offset(r = r) offset(r = -r)
            square([w, h]);
    } else {
        square([w, h]);
    }
}

// === Assembly Preview ===
module assembly() {
    // Backpack (bottom)
    color("gray", 0.7)
        backpack();
    
    // Extension PCB (visual)
    translate([1, 1, 6])
        color("green", 0.8)
        cube([24, 24, 1.6]);
    
    // Battery (visual)
    translate([3, 3, 1.5])
        color("blue", 0.5)
        cube([30, 40, 5]);
    
    // M2 screw (visual)
    translate([(pcb_size + 2)/2, (pcb_size + 2)/2, 0])
        color("silver")
        cylinder(d=2, h=20);
    
    // Atom Lite (visual, on top)
    translate([1, 1, 15])
        color("darkgray")
        cube([24, 24, 9.5]);
    
    // GROVE cable (visual)
    color("black", 0.5) {
        translate([12, 25, 8])
            cube([6, 4, 2]);
        translate([12, 25, 16])
            cube([6, 4, 2]);
    }
}

// === Export ===
// Export the backpack:
backpack();

// Or preview assembly:
// assembly();
