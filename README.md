# Garage Vehicle Armor

A Cyberpunk 2077 mod that sells armor plating for your vehicles through [Garage](https://www.nexusmods.com/cyberpunk2077/mods/30297) by CyanideX. An "Armor" service appears in the garage hub for cars you own.

| Tier | Damage reduction | Acceleration loss | Price | Refit fee |
|---|---|---|---|---|
| Light | 15% | 10% | 20,000 | 2,000 |
| Medium | 30% | 15% | 45,000 | 4,500 |
| Heavy | 50% | 20% | 90,000 | 9,000 |

- **Damage reduction** applies to everything that hurts the vehicle: gunfire, collisions and explosions. While V is inside an armored car, damage to V is cut by the same amount.
- **Acceleration loss** is the armor's weight. An armored car gains speed more slowly under throttle.
- A vehicle carries one tier at a time. Fitting a tier replaces the one it had.
- Removing armor is free. The refit fee applies when putting back a tier that vehicle has already bought.
- Armor is bought per vehicle and saved with the game. What you pay goes into that garage's cash pool.

## Installation

The `r6` and `bin` folders are laid out from the game root, so they can be copied into the game directory or zipped together for a mod manager.

Requires:
- [Garage](https://www.nexusmods.com/cyberpunk2077/mods/30297) (GarageCore)
- [RED4ext](https://github.com/WopsS/RED4ext)
- [redscript](https://github.com/jac3km4/redscript)
- [Codeware](https://github.com/psiberx/cp2077-codeware)
- [Cyber Engine Tweaks](https://github.com/maximegmd/CyberEngineTweaks)

Optional:
- [Mod Settings](https://github.com/jackhumbert/mod_settings) - adds an in-game options page (see below). Without it the defaults apply.

The mod will not compile without Garage installed.

## Options

With Mod Settings installed, under **Garage Vehicle Armor**:

| Section | Option | Default |
|---|---|---|
| Damage reduction | Light armor (%) | 15 |
| Damage reduction | Medium armor (%) | 30 |
| Damage reduction | Heavy armor (%) | 50 |
| Occupants | Armor protects V | On |
| Weight | Light armor acceleration loss (%) | 10 |
| Weight | Medium armor acceleration loss (%) | 15 |
| Weight | Heavy armor acceleration loss (%) | 20 |

Setting an acceleration loss to 0 turns the weight penalty off for that tier. Prices are fixed.

## Translating

The text the mod shows in game goes through Codeware's localization system, so it can be translated without touching the rest of the code. It is all in `r6/scripts/GarageVehicleArmor/ArmorLocalization.reds`.

The file starts with instructions: copy the English class, translate the second string on each line, and return the new class for your language. English is used for any language without a translation. The Mod Settings page is in English only. Translations are welcome as pull requests.

## Notes

- Armor is for cars. Motorcycles cannot be armored, and the Armor service does not appear for them.
- Three purpose-built military vehicles from other mods are heavily protected as they come, so the Armor service does not appear for them either: the Solvind TOR, the CINO RAM and the BA-06X Avalanche. None of them needs to be installed.
- The weight is not written into the vehicle's physics record. Each frame the car gains speed under throttle, part of that gain is pushed back out of it. This leaves the record alone for mods that manage it, such as NCGT, but it only affects forward acceleration: braking, cornering and reversing are unchanged.
- NCGT's own mechanical wear from crashes is worked out from the impact, not from the damage the armor reduces, so armor does not lessen it.
- Built and tested on game version 2.3x, alongside NCGT and Vehicle Systems Simulation.

## Credits

- **CyanideX** for [Garage](https://www.nexusmods.com/cyberpunk2077/mods/30297) and its service API and wiki, which this mod is built on.

The code in this repository was written with Claude, an AI assistant.

## License

[MIT](LICENSE)
