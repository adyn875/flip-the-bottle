# Flip the Bottle

This repository contains a small Roblox prototype game inspired by the classic bottle-flip challenge.

## What this includes
- A basic arena and bottle object
- Player controls to flip the bottle with `F` or left click
- Score tracking and landing detection
- Rojo project structure for syncing into Roblox Studio

## Open in Roblox Studio
1. Install Rojo: https://rojo.space/
2. In the repo root, run:
   ```bash
   rojo serve
   ```
3. Connect Roblox Studio to the Rojo server and sync the project.
4. Press Play in Studio.

## Controls
- Press `F` or left-click to flip the bottle.
- If the bottle lands upright within the tolerance window, you score points.

## Files
- `default.project.json` — Rojo project file
- `src/ServerScriptService/FlipBottleService.server.lua` — game logic
- `src/StarterPlayer/StarterPlayerScripts/FlipBottleClient.client.lua` — input and HUD
- `src/ReplicatedStorage/Shared/BottleFlipConfig.lua` — tuning values
