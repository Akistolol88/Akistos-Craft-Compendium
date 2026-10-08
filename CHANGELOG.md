## Changelog

### 1.4.2
- Rich Thorium Vein and Ooze Covered Rich Thorium Vein use GatherMate2's Rich Thorium node icon in the Mining list while GatherMate2 is loaded
- Trainers can now be marked like recipe vendors: click a light blue trainer name in a recipe's "Taught by" list to get the world map marker, minimap icon, arrow and "Target" button for that trainer (203 trainers). The mark is removed when you open that trainer's training window
- Added missing drop chances for Enchant Cloak - Greater Resistance, Frostguard, Runn Tum Tuber Surprise and Wizardweave Leggings

#### Gather Timers
- Black Lotus timers are now listed next to the world map's "Zoom Out" button instead of under the herb's icon, so they no longer cover Rich Thorium subzone names. Every running Black Lotus timer is listed there with its zone, one per row, whichever map is open
- Rich Thorium subzones are labelled with a Rich Thorium Vein icon instead of "RTV" (GatherMate2's node icon when GatherMate2 is loaded)
- Timer countdowns on the map are slightly larger, and subzone names are yellow
- Timer colours on the map: the time left is red, "may be up" is green and "up" is epic purple; the "Black Lotus" name is shown in green
- Rich Thorium Vein maximum respawn raised from 20 to 25 minutes
- Mining a Truesilver Deposit on a Rich Thorium Vein spawn point now starts that subzone's timer, as the two share spawns

### 1.4.0
- Recipe vendors are now shown as pins on the world map (206 vendors). Hover a pin to see the recipes that vendor sells with prices; recipes you already know are greyed out. Toggle with the "Recipe vendors" checkbox on the map or `/acc vendors`
- Vendor pins that would overlap are spread apart so each one can be hovered
- Mark a vendor to go to: click a light blue vendor name in a recipe's "Sold by" list, or click a vendor pin on the world map. The marked vendor gets a gold marker on the world map and an icon on the minimap
- An arrow points to the marked vendor once you are within 100 yards, with the distance shown
- "Target" button for the marked vendor: targets them and marks them with the Square raid marker. Targeting the vendor yourself also applies the Square
- The vendor mark is removed when you open that vendor's shop, by right-clicking the arrow, by clicking the map marker, or with `/acc unmark`
- Creature tooltips now list the recipes that creature can drop, with drop chance (never shown in combat). Toggle with `/acc drops`
- Fixed the Enchanting search filter selecting and highlighting the wrong enchant while a search was active
- Fixed vendors and creatures in Alterac Mountains being listed under "Deadmines"
- Fixed Kalldan Felmoon being listed in Darnassus instead of The Barrens, and Namdo Bizzfizzle in Stranglethorn Vale instead of Dun Morogh
- Removed Carrie Hearthfire, a Season of Discovery vendor, from Smoked Sagefish and Sagefish Delight

#### Gather Timers 0.2.0 beta (new sub-addon, included in the download)
- Respawn timers for Black Lotus (per zone, 5-45 minutes) and Rich Thorium Veins, including Ooze Covered (per subzone, 5-20 minutes), started automatically when you gather one
- Timers are shared by all your characters on the same realm and keep counting while you are logged out
- The world map circles every Rich Thorium subzone in dark green with its name; a running timer is shown in red inside the subzone it belongs to
- Chat messages when a timer starts, when the node can respawn, and when it should be up; running timers are listed at login
- `/accgt` lists timers, `/accgt clear` removes them
- Can be disabled separately in the addon list