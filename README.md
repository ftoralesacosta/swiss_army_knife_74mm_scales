# Swiss Army Knife Custom 74mm Scales

This is a collection of OpenSCAD scripts for modifying and stretching Swiss Army Knife (SAK) scales to fit the 74mm models. I've been looking for a 74mm pen scale for a while. There was a version I never got the chance to download that took generic pen refills, but that has been lost since Shapeways went bankrupt.

![74mm Blue Pen Scale](74mm_blue_pen_scale.png)
![74mm Red Dual Slot Scale](74mm_red_dual_slot_scale.png)

---

### 📜 Credits & Sources
The base 58mm geometries are derived from **Emil’s SAK Scales** on Thingiverse:
[Thing 5216489 - Victorinox 58mm Scales](https://www.thingiverse.com/thing:5216489/files)

---

### 🛠️ Hardware Requirements
These scripts are optimized for a flush, high-tension fit. Standard 3.0mm inserts are too long for this profile and will bottom out.

* **Pocket Clip:** Compatible with **Civivi Deep Carry** clips (4.6mm hole spacing).
* **Threaded Inserts:** Designed for **M2 Heat-Set Threaded Inserts**.
    * **Height Constraint:** You **must** use **2.0mm tall** inserts. 
* **Hole Specs:** 3.2mm diameter bore for the insert; 2.2mm clearance for the screw.

---

### 📦 Components

#### 1. 58mm → 74mm: Dual Accessory Scale
Converts a 58mm source into a 74mm scale with dual-tool support.
* **Twin Slots:** Mirrored internal geometry for both Toothpick and Tweezers.
* **Geometry Preservation:** Uses `hull()` operations to stretch the length. This ensures the ergonomic curves of the 58mm tips remain intact rather than being linearly distorted.
* **Rivet Management:** Automatically plugs old rivet holes and generates new 3.8mm mounting points for the 74mm frame.

#### 2. 58mm → 74mm: Pen Scale
A more sophisticated conversion for the 58mm Pen Scale that prioritizes a factory-style finish.
* **OEM Drop-in:** Creates a scale that uses the original pen insert from the 58mm SAK with zero modifications needed.
* **Minkowski Rounding & Non-Linear Stretching:** Uses a sphere primitive to generate rounded edges that match the OEM feel, combined with independent X/Y axis stretching so the pen slot remains functional and aligned despite the size increase.
* **The "Snap":** Includes specific Y-axis cylinder subtractions and a shear-bottom cut to ensure the pen deploys with the correct mechanical tension.

#### 3. 74mm Executive: Pocket Clip & M2 Insert Mod
Adds mounting points to an existing 74mm STL.
* **Tension Fit:** Uses "bowed" pin channels to ensure a tight interference fit on the original brass pins.
* **Threaded Inserts:** Modeled specifically for **2.0mm tall M2 heat-set threaded inserts**. *(Note: Be careful here. Most standard M2 inserts are 3.0mm tall and will punch right through the bottom of the scale.)*
* **Clip Spacing:** Holes are spaced exactly **4.6mm** apart to drop in standard [CIVIVI deep carry pocket clips](https://www.civivi.com/collections/accessories/products/civivi-2pcs-deep-carry-pocket-clip-ca-05d).
