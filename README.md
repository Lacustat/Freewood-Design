# Freewood-Design

**Deutsch & English · German & English.** Autor · Author: Lacustat. Version 0.1.0 · Interface 16001 (World of Warcraft: Forever).

## Inhalt · Contents
- [Deutsch](#deutsch)
  - [Wofür](#wofür)
  - [Inhalt des Addons](#inhalt-des-addons)
  - [Benutzung im Code](#benutzung-im-code)
  - [Grafiken umwandeln](#grafiken-umwandeln)
  - [Stand](#stand)
- [English](#english)
  - [What for](#what-for)
  - [Contents of the addon](#contents-of-the-addon)
  - [Use in code](#use-in-code)
  - [Converting graphics](#converting-graphics)
  - [Status](#status)
- [Lizenz · License](#lizenz--license)

## Deutsch

### Wofür
Grafiken für die Freewood-Designs. Das erste ist **„Pinky Freewood“**, ein zweites Design neben dem Standard-Freewood (Steampunk/Goblin: Leder, Messing, Rohre, Zahnräder) für alles Spielrelevante; Dev-Sachen bleiben im Standarddesign. Das Addon enthält nur Texturen und eine kleine Pfadtabelle, keine Fenster. Spätere Designs kommen als weitere Ordner unter `Media\` dazu.

### Inhalt des Addons
| Ordner | Inhalt |
|---|---|
| `Media\Pinky\ui` | Hauptrahmen (1024 x 512), Slideout-Rahmen, Ausklapp-Knopf, Schließen-Knopf, Roster-Schilder (normal, hover, ausgewählt), Schienen hinter den Schildern, Lampen, Scroll-Pfeile, Listenansicht-Hebel, Detailkarte (ohne Notizfeld), Knöpfe, Haken, Eingabe- und Auswahlfeld, Trennrohre, Scrollleiste, Tooltip-Rand, Zahnrad-Knopf, Wimpel, Rohr unten, Logo, Porträtring, Leuchten |
| `Media\Pinky\class` | Klassen-Icons (256 x 256) nach Klassenkürzel: `pf_class_druid` … `pf_class_warrior`, dazu `pf_class_pet` (Jäger-Begleiter) |
| `Media\Pinky\craft` | Berufs-Icons (256 x 256): Alchemie, Schmiedekunst, Kochen, Verzauberkunst, Ingenieurskunst, Erste Hilfe, Angeln, Kräuterkunde, Inschriftenkunde, Juwelierskunst, Lederverarbeitung, Bergbau, Kürschnerei, Überleben, Schneiderei |
| `Media\Pinky\later` | für später (Stammbaum) |

Beschlossen mit Lacustat: Notizfelder der Detailkarte, Kopfzeile und Hervorhebungen der Listenansicht zeichnet das Spiel selbst (dynamischer); Hover/gedrückt/gesperrt der Scroll-Pfeile über die Helligkeit. Der Ausklapp-Knopf sitzt am Hauptrahmen und verschwindet beim Klick, weil das Slideout denselben Knopf trägt (wirkt verschmolzen). Die Schienen liegen hinter den Roster-Schildern, die darauf hoch und runter fahren.

### Benutzung im Code
```lua
local D = FreewoodDesign
tex:SetTexture(D.Tex("pf_frame_main"))      -- voller Pfad oder nil
icon:SetTexture(D.ClassTex("ROGUE"))        -- Klassenkürzel des Spiels, "PET" für Begleiter
icon:SetTexture(D.CraftTex("leatherworking"))
```

### Grafiken umwandeln
Lacustats Vorlagen (PNG, teils 1254 x 1254) bleiben auf seinem PC (`Documents\Freewood Addon\Freewood Design`) und kommen nicht ins Repo. `tools/convert_pinky.py` macht daraus die TGAs: Zielgröße in Zweierpotenz, Verkleinern mit vormultipliziertem Alpha (keine dunklen Säume), Alpha ab 250 voll deckend, Farbe unter durchsichtigen Pixeln schwarz, TGA 32 Bit unkomprimiert, einheitliche Namen. Aufruf: `python3 tools/convert_pinky.py "<Freewood Design>" Media/Pinky`. Test: `texlua tests/media_test.lua` (jede Datei vorhanden, Zweierpotenz, 32 Bit).

### Stand
Version 0.1.0: Grafiken für das Gildenfenster und das Slideout. Im Spiel ungeprüft (ob alle TGAs laden). Größe zusammen etwa 20 MB. Slideout-Symbole folgen.

## English

### What for
Graphics for the Freewood designs. The first one is **"Pinky Freewood"**, a second design next to standard Freewood (steampunk/goblin: leather, brass, pipes, gears) for everything relevant to playing; dev tools stay in the standard design. The addon holds textures and a small path table only, no windows. Later designs are added as further folders under `Media\`.

### Contents of the addon
| Folder | Contents |
|---|---|
| `Media\Pinky\ui` | main frame (1024 x 512), slide-out frame, slide-out button, close button, roster plates (normal, hover, selected), rails behind the plates, lamps, scroll arrows, list-mode lever, detail card (without note field), buttons, check box, edit and dropdown fields, separator pipes, scroll bar, tooltip border, gear button, pennant, bottom pipe, logo, portrait ring, glows |
| `Media\Pinky\class` | class icons (256 x 256) by class token: `pf_class_druid` … `pf_class_warrior`, plus `pf_class_pet` (hunter pet) |
| `Media\Pinky\craft` | profession icons (256 x 256): alchemy, blacksmithing, cooking, enchanting, engineering, first aid, fishing, herbalism, inscription, jewelcrafting, leatherworking, mining, skinning, survival, tailoring |
| `Media\Pinky\later` | for later (family tree) |

Decided with Lacustat: the detail card's note fields, the list view's header and highlights are drawn by the game (more flexible); hover/pushed/disabled of the scroll arrows via brightness. The slide-out button sits on the main frame and disappears on click, because the slide-out carries the same button (looks merged). The rails lie behind the roster plates, which travel up and down on them.

### Use in code
See the Lua block above: `FreewoodDesign.Tex(name)`, `ClassTex(token)`, `CraftTex(key)`.

### Converting graphics
Lacustat's sources (PNG, some 1254 x 1254) stay on his PC and are not in the repo. `tools/convert_pinky.py` turns them into TGAs: power-of-two target size, downscaling with premultiplied alpha (no dark fringes), alpha from 250 fully opaque, colour under transparent pixels black, 32-bit uncompressed TGA, consistent names. Test: `texlua tests/media_test.lua`.

### Status
Version 0.1.0: graphics for the guild window and the slide-out. Unverified in game (whether all TGAs load). About 20 MB in total. Slide-out symbols will follow.

## Lizenz · License
GPL-3.0-or-later, siehe · see `LICENSE`.
