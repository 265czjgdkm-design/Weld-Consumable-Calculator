# Weld Calculator Web + 3D Direction Report

## Current conclusion

This product should **not** jump directly into a heavy CAD-style browser viewer.

The best path is:

1. Keep the main product in **Flutter Web** for the calculator, forms, presets, PDF, and fast mobile-friendly UX.
2. Keep the technical drawing area as **2D section-first** because weld users need clarity before realism.
3. Add a **small web 3D layer only for selected joints**, starting with branch/nozzle visuals.
4. Use a **hybrid approach**:
   - 2D section = primary engineering explanation
   - 3D preview = secondary orientation aid

## Best stack choice

### Best near-term product stack

- **Frontend shell:** Flutter Web
- **Primary detail visualization:** CustomPainter 2D sections
- **3D preview for the website:** `<model-viewer>` or a dedicated web route with Three.js
- **3D model authoring:** Blender first, Fusion/Onshape only if true parametric engineering authoring is needed

### Why this is the best practical choice

- Flutter Web is already working in this repo.
- The calculator and reporting flow are already product-shaped.
- A fully procedural 3D CAD-like weld engine in Flutter is too expensive for the current stage.
- Users need quick understanding, not a general-purpose CAD workspace.
- A lightweight model viewer with hotspots is much faster to ship and easier to explain.

## Tool decision

### Option A: `<model-viewer>`  
Best for fastest professional result.

Use when:
- you want a polished 3D model viewer on the website fast
- you want orbit / zoom / touch controls with low engineering cost
- you want hotspot annotations like `Weld`, `Gap`, `Repad`, `Branch neck`
- you want optional AR later

Pros:
- easiest path to a production-looking web 3D viewer
- hotspot / annotation support is already built around web use
- good for mobile websites
- ideal for prebuilt GLB assets

Cons:
- not ideal for deep procedural geometry generation
- less flexible than a full 3D engine for custom live geometry

### Option B: Three.js  
Best for custom interactive weld scenes.

Use when:
- you want parametric geometry driven from inputs
- you want custom overlays, clipping, exploded views, section cuts
- you want full control over render style

Pros:
- industry-standard web 3D library
- strongest flexibility for a custom weld product
- good long-term foundation if the app becomes a premium engineering tool

Cons:
- more engineering effort
- more UI/annotation work must be built by hand

### Option C: Babylon.js  
Best if the product becomes a more scene-heavy 3D app.

Use when:
- you expect a more engine-like 3D product with richer scene systems
- you want a stronger built-in application framework feel

Pros:
- very capable engine
- good if the app moves toward richer 3D workflows

Cons:
- overkill for the current product stage
- not the shortest path to a clean branch-connection viewer

## Recommendation

### Phase 1 recommendation

Ship this:

- Flutter Web main app
- improved 2D section detail
- a separate **3D Preview** card using `<model-viewer>`
- manually created GLB assets for:
  - set-on nozzle
  - set-in nozzle
  - weldolet
- hotspot labels for:
  - branch neck
  - fillet weld
  - gap/opening
  - repad
  - base metal

This is the highest-quality low-risk path.

### Phase 2 recommendation

If users respond well, move selected views to **Three.js parametric geometry**:

- branch OD changes
- run OD changes
- wall thickness changes
- repad on/off
- set-on vs set-in vs weldolet variation

## 3D authoring tools

### Blender
Best default choice.

Use for:
- fast GLB creation
- simple branch connection assets
- stylized technical materials
- lightweight web export

Why:
- free
- flexible
- good enough for this product stage

### Onshape
Best if you want browser-based cloud CAD collaboration.

Use for:
- precise engineering geometry
- collaborative modeling in the browser
- versioned cloud-native CAD workflow

Why:
- very good if multiple people will build geometry
- strong long-term product design workflow

### Autodesk Fusion
Best if you need true engineering-grade parametric authoring and downstream detail logic.

Use for:
- mechanical precision
- assemblies
- engineering-quality authoring
- more serious future product assets

Why:
- strongest professional engineering authoring option in this list
- better than Blender when model correctness matters more than speed

## Website architecture recommendation

### Best product architecture

1. Keep the calculator as the main page in Flutter Web.
2. Make technical drawings a modular area:
   - `2D Section`
   - `Weld Detail`
   - `3D Preview`
3. Load 3D only when the user opens the 3D panel.
4. Keep 3D optional on mobile to protect performance.
5. Build the public marketing site separately if needed later.

### Best deployment model

- Public website:
  - landing page
  - product explanation
  - screenshots
  - pricing / premium later
- App route:
  - the actual calculator

If needed later:
- `site.com/` = marketing
- `site.com/app` = calculator

## What to build next

### Immediate next step

Build one clean branch/nozzle web visual system:

1. Finalize the 2D section detail style
2. Create one GLB for `Set-on Nozzle`
3. Show it inside a `3D Preview` card
4. Add 4-5 hotspots only
5. Compare user understanding against the current 2D-only approach

### After that

Build:

1. `Set-in Nozzle`
2. `Weldolet`
3. optional section cut overlay in 3D
4. premium PDF report with 2D detail + 3D preview snapshot

## Final product judgment

If this becomes a website, the strongest product identity is:

- **engineering calculator first**
- **technical visual explainer second**
- **3D orientation tool third**

Not:

- a full CAD app

That distinction matters.  
The easiest way to make this look premium is **not** to overbuild 3D.  
It is to make the 2D explanation excellent and use 3D only where it improves comprehension.

## Sources

- [Flutter Web docs](https://docs.flutter.dev/platform-integration/web)
- [Three.js manual](https://threejs.org/manual/)
- [`<model-viewer>` docs](https://modelviewer.dev/docs/)
- [`<model-viewer>` annotations example](https://modelviewer.dev/examples/annotations/)
- [Babylon.js viewer docs](https://doc.babylonjs.com/features/featuresDeepDive/babylonViewer/)
- [Blender manual](https://docs.blender.org/manual/en/latest/index.html)
- [Onshape platform](https://www.onshape.com/en/platform)
- [Autodesk Fusion overview](https://www.autodesk.com/products/fusion-360/overview)
- [RedLineIPS reinforcement pads](https://redlineips.com/metallic-piping-accessories/reinforcement-pads/)
- [Wermac weldolet overview](https://www.wermac.org/fittings/weldolet.html)
- [Wermac pad vs olet](https://www.wermac.org/fittings/pad_olet.html)
