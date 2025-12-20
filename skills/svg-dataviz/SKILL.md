---
name: svg-dataviz
description: Create data visualizations as SVG with iterative render-and-check workflow. Use when asked to create charts, diagrams, or visual explanations of data. Produces PNG output via rsvg-convert or sips.
---

# SVG Data Visualization

Create data visualizations as SVG, render to PNG, and iterate until the output is correct.

## When to Use

- Creating charts (line, bar, area, etc.)
- Visualizing concepts or relationships
- Any request for a visual/diagram that should be rendered

## Workflow

### 1. Understand the Content

Before writing SVG, clarify WHAT the chart shows:
- What data/concepts are being visualized?
- What's the key message or insight?
- What are the axes, labels, categories?

Write a brief content spec (mental or explicit) that captures the semantics. This stays fixed while styling evolves.

### 2. Apply a Design System

If a brand skill exists, read its brand-guide.md for:
- Color palette
- Typography specs
- Visual principles

If no brand specified, use sensible defaults:
- Dark background (#1a1a2e or similar)
- Clear visual hierarchy
- Direct labeling (labels next to what they describe)

### 3. Create SVG

Canvas: 1280×720 (16:9) is a good default for presentations.

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1280 720" width="1280" height="720">
  <rect x="0" y="0" width="1280" height="720" fill="#BACKGROUND"/>
  <style>
    text { font-family: 'Public Sans', system-ui, sans-serif; }
  </style>
  <!-- Content -->
</svg>
```

### 4. Render to PNG

**Primary (supports arrows/markers):**
```bash
rsvg-convert -w 1280 -h 720 input.svg -o /tmp/chart.png
```

**Fast alternative (no marker support):**
```bash
sips -s format png -z 720 1280 input.svg --out /tmp/chart.png
```

### 5. View and Iterate

Read the PNG to see the result. Check:
- [ ] All text visible and not truncated
- [ ] Curves/lines smooth (no random dips)
- [ ] Labels align with what they describe
- [ ] Space is filled (no large empty areas)
- [ ] Visual hierarchy is clear

If issues, modify SVG and re-render. Iterate until satisfied.

### 6. Show to User

Open in browser for user to see:
```bash
open -a "Google Chrome" /tmp/chart.png
```

## Key Principles

### Fill the Space
- Maximum 10% empty space
- Chart area ~60% width, labels ~35% width
- If there's empty space, something is undersized

### Readable at Presentation Scale
- Title: 40-48px
- Labels: 16-20px
- Axis text: 14-16px
- All text needs 15-20px margin from edges (prevents truncation)

### Direct Labeling
- Labels next to what they describe
- Color dots connect labels to data
- Avoid separate legend boxes when direct labeling works

### Curves Need Weight
- Stroke width: 4-5px
- Round linecaps
- Smooth curves (one inflection point, no random wobbles)

### Distinguish Speculative from Actual
- Solid lines = real/current
- Dashed lines = potential/speculative (18px dash, 10px gap)

## Architecture & System Diagrams

When creating system diagrams, data flow diagrams, or architecture visuals (databases, arrows, boxes), apply stricter layout discipline than charts.

### Grid-First Layout

**Define the grid before drawing anything:**
- Divide canvas into columns (e.g., 5 columns for: inputs | arrows | central system | arrows | outputs)
- Columns should be symmetric where content is symmetric (if left input box is 200px, right output box is 200px)
- All elements snap to column boundaries - no orphan edges floating between grid lines
- Sketch the grid mentally or on paper first, then code to it

**Example 1280px grid for a data flow diagram:**
```
Col 1 (Inputs):      x=40-220   (180px)
Col 2 (Arrows in):   x=220-340  (120px)
Col 3 (Central):     x=340-760  (420px)
Col 4 (Arrows out):  x=760-880  (120px)
Col 5 (Outputs):     x=880-1060 (180px)
Col 6 (Legend):      x=1080-1240 (160px)
```

### Consistent Element Styling

**Arrows representing similar concepts should look identical:**
- All "inflow" arrows: same shape (block arrow), same size, same style
- All "outflow" arrows: same shape, same size, same style
- Don't mix thin lines with block arrows for the same semantic role

**Database cylinders:**
- Use proper cylinder shape: ellipse top + rectangle body + ellipse bottom
- All databases in a stack should have identical width
- Vertical spacing between stacked databases should be consistent
- Label centered in the rectangle portion

**Bounding boxes (like "permissions" containers):**
- Dashed stroke to indicate logical grouping without visual dominance
- Consistent padding from contained elements to edge
- Label at top, centered or left-aligned consistently

### Visual Balance

**Symmetric content = symmetric layout:**
- If you have "inputs" on left and "outputs" on right, they should mirror each other
- Same box width, same text styling, same vertical position

**Breathing room inside containers:**
- Elements inside a bounding box need consistent margins
- Don't cram - if it feels tight, the container is too small or has too much content

### Labels and Callouts

**Arrows carrying meaning need labels:**
- Block arrows with text inside (e.g., "TAG/SDK", "CAPI")
- Or adjacent label boxes (e.g., "5 REALTIME FEED" next to a flow arrow)
- Labels should explain what flows through, not just that something flows

**Substantive descriptions:**
- Bottom-level outputs (like model boxes) need real descriptions
- Not "Model 1" but "Large-scale outcome models across large and small advertisers"
- The description should answer "what does this actually do?"

### Pre-Flight Checklist for Architecture Diagrams

Before rendering, verify:
- [ ] Grid defined with explicit column boundaries
- [ ] Symmetric elements have identical dimensions
- [ ] All arrows of same type use same shape/size
- [ ] Database cylinders are consistent width and properly stacked
- [ ] Bounding boxes have consistent internal padding
- [ ] Every arrow/flow has a label explaining what it carries
- [ ] Output boxes have substantive descriptions, not placeholders
- [ ] No element edges floating between grid lines

## Implementation Tips

### Preventing Text Truncation
```
Right-side labels: position at x=850, text-anchor="start"
This leaves ~430px for text before the edge
```

### Smooth Curves (SVG path)
```xml
<!-- Plateau curve -->
<path d="M 0 460 Q 200 400, 400 350 Q 600 320, 770 310" />

<!-- Rising curve that continues beyond chart -->
<path d="M 0 450 Q 300 350, 550 180 Q 700 60, 770 25" />
```

### Arrow Markers
```xml
<defs>
  <marker id="arrow" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
    <polygon points="0 0, 10 3.5, 0 7" fill="#COLOR"/>
  </marker>
</defs>
<path d="..." marker-end="url(#arrow)"/>
```

Note: `sips` doesn't render markers. Use `rsvg-convert` if you need arrows.

## Composing with Brand Skills

When a brand skill exists:
1. Read its brand-guide.md for colors, fonts, principles
2. Apply those specs to your SVG
3. Check its examples/ folder for reference
