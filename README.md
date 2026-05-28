# Akistos Craft Compendium

A World of Warcraft Classic Era addon for browsing every crafting and gathering recipe in the game — where to learn it, what it costs to make, and which of your characters already knows it.

## Features

- **All professions** — Alchemy, Blacksmithing, Cooking, Enchanting, Engineering, Fishing, First Aid, Herbalism, Leatherworking, Mining, Skinning, Tailoring
- **Recipe sources** — trainer name and location, vendor (with reputation requirements), creature drop with drop rate, quest reward, world drop, book, or holiday event
- **Full material list** with quantities for every craftable recipe
- **Training ranks** — Apprentice through Artisan shown in every profession's Misc tab, with shift-click linking
- **Gathering info** — Mining vein locations and smelting recipes; Herbalism herb zones; Skinning skill colour bands and max mob level calculator
- **Account-wide tracking** — Known / Not Known label on every recipe; lists which alts know it
- **Tooltip integration** — hover any recipe item link in chat or inventory to see Known / Not Known status
- **Shift-click linking** — insert recipe, item, or quest links directly into chat
- **Minimap button** — drag to reposition, right-click for options, toggle with `/acc minimap`
- **Persistent state** — selected profession, category, and page remembered across sessions
- **Engineering specialization** — Gnomish and Goblin recipes flagged accordingly

## Installation

1. Download or clone this repository
2. Copy the `AkistosCraftCompendium` folder into your WoW Classic Era addons directory:
   ```
   World of Warcraft/_classic_era_/Interface/AddOns/AkistosCraftCompendium
   ```
3. Launch WoW Classic Era and log in
4. Type `/acc` in chat to open the compendium

## Commands

| Command | Description |
|---|---|
| `/acc` | Toggle the compendium window |
| `/acc minimap` | Toggle the minimap button |
| `/acc help` | Show all available commands |

## Features to Come

- **Recipe search** — filter recipes by name directly inside your Blizzard profession window
- **Missing recipe scanner** — see at a glance which recipes your current character is still missing for each profession they have trained

## Project Status

🚧 In active development — WoW Classic Era (patch 1.15)
