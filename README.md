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

* **Accessory Slots:**
  * Tweezers for 58mm models
  * Toothpick for 58mm models
  * *Note: Should test with Tortoise Gear ferro rod*
* **Pen Insert:**
  * Small pressurized pen
  * Grey pen holder insert
* **Pocket Clip & Hardware:**
  * [CIVIVI Deep Carry Pocket Clip](https://www.civivi.com/collections/accessories/products/civivi-2pcs-deep-carry-pocket-clip-ca-05d) (I used the shorter clip). Alternatively, any clip with a 4.5mm hole spacing and M2 screws will work.
  * 2.0mm tall threaded heat inserts for M2 screws *(Note: Most standard M2 inserts are 3.0mm tall, which is too long).*
* **Pins:**
  * Stainless steel pins from Victorinox.
  * The pin-holes are 35mm long and have a modeled diameter of 1.5mm (but will accept slightly smaller pins to account for 3D printing imperfections).

---

### 📦 Components

#### 1. 58mm → 74mm: Dual Accessory Scale
Converts a 58mm source into a 74mm scale with dual-tool support.
* **Twin Slots:** Mirrored internal geometry for both Toothpick and Tweezers.
* **Geometry Preservation:** Uses `hull()` operations to stretch the length. This ensures the ergonomic curves of the 58mm tips remain intact rather than being linearly distorted.
* **Rivet Management:** Automatically plugs old rivet holes and generates new 3.8mm mounting points for the 74mm frame.

#### 2. 58mm → 74mm: Pen Scale
Converts the 58mm Pen Scale, prioritizing a factory-style finish.
* **OEM Drop-in:** Creates a scale that uses the original pen insert from the 58mm SAK with zero modifications needed.
* **Minkowski Rounding & Non-Linear Stretching:** Uses a sphere primitive to generate rounded edges that match the original scale shape, combined with independent X/Y axis stretching so the pen slot remains functional and aligned despite the size increase.
* **The "Snap":** Includes specific Y-axis cylinder subtractions and a shear-bottom cut to ensure the pen deploys with the right amount of tension.

#### 3. Adding Pocket Clip & Pins
Adds mounting points to an existing 74mm STL.
* **Threaded Inserts:** Modeled specifically for **2.0mm tall M2 heat-set threaded inserts**. *(Warning: Standard 3.0mm M2 inserts will punch right through the bottom of the scale.)*
* **Clip Spacing Specs:** * Holes are modeled exactly **4.6mm** apart. This is deliberately slightly wider than the physical 4.5mm CIVIVI clip spacing to account for print shrinkage.
  * 3.2mm diameter bore for the heat insert.
  * 2.2mm clearance for the screw.
* **Tension Fit Pins:** Uses "bowed" pin channels to ensure a tight interference fit on the original brass pins.

---

### 📝 ToDo's
* Apply Minkowski rounding to the dual slot scale instead of the current split/stretch method.
* Utilize the side of the pen scale (e.g., a pull-out tray or side door of some kind).
* Figure out how to install the Leatherman micro bit driver.
* Indent the mounting area so the pocket clip sits flush with the scale (pending scale thickness checks).
* Fit another accessory slot for the pen scale that does not have a pocket clip.
