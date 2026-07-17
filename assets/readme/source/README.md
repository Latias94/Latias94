# README visual sources

The rendered assets in the parent directory use real outputs from the projects featured in the profile.

## Source material

- `dear-imgui-docking.webp`: cropped from `dear-imgui-rs/screenshots/game-engine-docking.png`
- `dear-imgui-node-editor.webp`: `dear-imgui-rs/screenshots/node-editor-showcase.png`
- `dear-imgui-implot3d.webp`: `dear-imgui-rs/screenshots/implot3d-basic.png`
- `merman-*.webp`: `merman/docs/assets/showcase/`
- `fret-*.webp`: `fret/screenshots/`

The optimized copies live under `../artifacts/`. The SVG files in this directory are editable composition sources; the profile embeds WebP renders so GitHub does not need to resolve nested SVG image references.

## Render

Run this command from this directory with ImageMagick and a Chromium browser installed:

```powershell
./render.ps1
```

The script renders the SVG compositions in Chromium so local WebP references behave exactly like browser images, then uses ImageMagick to encode the final profile assets.

## Preview

Create a self-contained local preview from the repository root:

```powershell
pandoc --standalone --embed-resources --metadata 'pagetitle=Frankorz / Latias94' --css assets/readme/source/preview.css README.md -o $env:TEMP/latias94-readme-preview.html
```
