# Freewood-Design

**Deutsch & English · German & English.** Autor · Author: Lacustat. Version 0.2.1 · Interface 16001 (World of Warcraft: Forever).

## Inhalt · Contents
- [Deutsch](#deutsch)
  - [Wofür](#wofür)
  - [Inhalt des Addons](#inhalt-des-addons)
  - [Probefenster Pinky](#probefenster-pinky)
  - [Benutzung im Code](#benutzung-im-code)
  - [Grafiken umwandeln](#grafiken-umwandeln)
  - [Stand](#stand)
- [English](#english)
  - [What for](#what-for)
  - [Contents of the addon](#contents-of-the-addon)
  - [Pinky probe window](#pinky-probe-window)
  - [Use in code](#use-in-code)
  - [Converting graphics](#converting-graphics)
  - [Status](#status)
- [Lizenz · License](#lizenz--license)

## Deutsch

### Wofür
Grafiken für die Freewood-Designs. Das erste ist **„Pinky Freewood“**, ein zweites Design neben dem Standard-Freewood (Steampunk/Goblin: Leder, Messing, Rohre, Zahnräder) für alles Spielrelevante; Dev-Sachen bleiben im Standarddesign. Das Addon enthält die Texturen, eine kleine Pfadtabelle und seit 0.2.0 das Probefenster `/fwpinky`. Spätere Designs kommen als weitere Ordner unter `Media\` dazu.

### Inhalt des Addons
| Ordner | Inhalt |
|---|---|
| `Media\Pinky\ui` | Hauptrahmen (1024 x 512), Slideout-Rahmen, Ausklapp-Knopf, Schließen-Knopf, Roster-Schilder (normal, hover, ausgewählt), Schienen hinter den Schildern, Lampen, Scroll-Pfeile, Listenansicht-Hebel, Detailkarte (ohne Notizfeld), Knöpfe, Haken, Eingabe- und Auswahlfeld, Trennrohre, Scrollleiste, Tooltip-Rand, Zahnrad-Knopf, Wimpel, Rohr unten, Logo, Porträtring, Leuchten |
| `Media\Pinky\class` | Klassen-Icons (256 x 256) nach Klassenkürzel: `pf_class_druid` … `pf_class_warrior`, dazu `pf_class_pet` (Jäger-Begleiter) |
| `Media\Pinky\craft` | Berufs-Icons (256 x 256): Alchemie, Schmiedekunst, Kochen, Verzauberkunst, Ingenieurskunst, Erste Hilfe, Angeln, Kräuterkunde, Inschriftenkunde, Juwelierskunst, Lederverarbeitung, Bergbau, Kürschnerei, Überleben, Schneiderei |
| `Media\Pinky\later` | für später (Stammbaum) |

Beschlossen mit Lacustat: Notizfelder der Detailkarte, Kopfzeile und Hervorhebungen der Listenansicht zeichnet das Spiel selbst (dynamischer); Hover/gedrückt/gesperrt der Scroll-Pfeile über die Helligkeit. Der Ausklapp-Knopf sitzt am Hauptrahmen und verschwindet beim Klick, weil das Slideout denselben Knopf trägt (wirkt verschmolzen). Die Schienen liegen hinter den Roster-Schildern, die darauf hoch und runter fahren.

### Probefenster Pinky
`/fwpinky` öffnet das Gildenfenster im Pinky-Design (seit 0.2.0, im Spiel ungeprüft):
- **Roster:** Messingschilder auf zwei Schienen (3 sichtbar), links das Klassen-Icon (grau bei offline), Name in der Mitte (grün online, grau offline), rechts die zwei Hauptberufe aus dem Gilden-Modul (geteilte Profile; ohne Daten bleiben die Plätze leer), daneben die Lampe (grün/rot). Reihenfolge: online zuerst, dann Rang, dann Name. Blättern mit den Pfeilen (Helligkeit für hover/gedrückt/gesperrt) oder dem Mausrad.
- **Listenansicht:** Der Hebel unten links schaltet auf eine gezeichnete Liste (Name, Stufe, Klasse, Rang, Gebiet; Zähler „online / alle“); wird gemerkt.
- **Detailkarte:** Name (mit Umbruch, zentriert), Stufe groß, Gildenrang, Gebiet (oder „offline“), öffentliche Notiz und – nur wer Offiziersnotizen sehen darf – die Offiziersnotiz in gezeichneten Feldern, unten die zwei Berufe. Klick auf ein Schild oder eine Zeile wählt das Mitglied.
- **Slideout:** Der Knopf am rechten Rand verschwindet beim Klick; das Slideout fährt mit demselben Knopf hinter dem Rahmen heraus (0,35 s, weich auslaufend) und mit dem Knopf am Slideout wieder hinein. Inhalt folgt (Symbole).
- Schließen: rotes X, Escape. Fenster ziehbar, Position und Größe werden gemerkt (`FreewoodDesignDB`).
- Befehle: `/fwpinky groesse 50-150` (Standard 90), `/fwpinky reset` (Position), `/fwpinky hilfe`.
- Test: `texlua tests/pinky_test.lua` (45 Prüfungen mit Attrappen; Aussehen nur im Spiel prüfbar).

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
Version 0.2.1: lange Namen auf den Schildern umbrechen (2 Zeilen) statt „…“, Berufs-Icons weiter innen, Schrift nicht kleiner als bei 90 % (Rahmen wird trotzdem kleiner), Slideout weiter hinter dem Rahmen (keine Lücke), Notizfeld schmaler und mittig, Schließen-X mittig im Loch. Version 0.2.0: Probefenster `/fwpinky` (Gildenansicht, Liste, Detailkarte, Slideout). Version 0.1.0: Grafiken für das Gildenfenster und das Slideout. Alles im Spiel ungeprüft (ob alle TGAs laden, Lage der Teile). Größe zusammen etwa 20 MB. Slideout-Symbole folgen.

## English

### What for
Graphics for the Freewood designs. The first one is **"Pinky Freewood"**, a second design next to standard Freewood (steampunk/goblin: leather, brass, pipes, gears) for everything relevant to playing; dev tools stay in the standard design. The addon holds the textures, a small path table and, since 0.2.0, the probe window `/fwpinky`. Later designs are added as further folders under `Media\`.

### Contents of the addon
| Folder | Contents |
|---|---|
| `Media\Pinky\ui` | main frame (1024 x 512), slide-out frame, slide-out button, close button, roster plates (normal, hover, selected), rails behind the plates, lamps, scroll arrows, list-mode lever, detail card (without note field), buttons, check box, edit and dropdown fields, separator pipes, scroll bar, tooltip border, gear button, pennant, bottom pipe, logo, portrait ring, glows |
| `Media\Pinky\class` | class icons (256 x 256) by class token: `pf_class_druid` … `pf_class_warrior`, plus `pf_class_pet` (hunter pet) |
| `Media\Pinky\craft` | profession icons (256 x 256): alchemy, blacksmithing, cooking, enchanting, engineering, first aid, fishing, herbalism, inscription, jewelcrafting, leatherworking, mining, skinning, survival, tailoring |
| `Media\Pinky\later` | for later (family tree) |

Decided with Lacustat: the detail card's note fields, the list view's header and highlights are drawn by the game (more flexible); hover/pushed/disabled of the scroll arrows via brightness. The slide-out button sits on the main frame and disappears on click, because the slide-out carries the same button (looks merged). The rails lie behind the roster plates, which travel up and down on them.

### Pinky probe window
`/fwpinky` opens the guild window in the Pinky design (since 0.2.0, unverified in game): roster of brass plates on two rails (3 visible) with class icon, name, two main professions (from the guild module's shared profiles) and status lamp; scroll arrows (brightness states) and mouse wheel; the lever bottom left switches to a drawn list (name, level, class, rank, zone); detail card with name (wrapped, centred), level, guild rank, zone, public note and – only for those allowed – the officer note in drawn fields, professions at the bottom; the slide-out button on the right edge disappears on click and the slide-out travels out from behind the frame carrying the same button, and back. Close with the red X or Escape; draggable; position and size are remembered. Commands: `/fwpinky groesse 50-150`, `/fwpinky reset`, `/fwpinky hilfe`. Test: `texlua tests/pinky_test.lua`.

### Use in code
See the Lua block above: `FreewoodDesign.Tex(name)`, `ClassTex(token)`, `CraftTex(key)`, `CraftBySkill(id)`, `Box(name)` (used area for `SetTexCoord`).

### Converting graphics
Lacustat's sources (PNG, some 1254 x 1254) stay on his PC and are not in the repo. `tools/convert_pinky.py` turns them into TGAs: power-of-two target size, downscaling with premultiplied alpha (no dark fringes), alpha from 250 fully opaque, colour under transparent pixels black, 32-bit uncompressed TGA, consistent names. Test: `texlua tests/media_test.lua`.

### Status
Version 0.2.1: long names on the plates wrap (2 lines) instead of "...", profession icons further in, text never smaller than at 90 % (the frame still shrinks), slide-out further behind the frame (no gap), note field narrower and centred, close X centred in the hole. Version 0.2.0: probe window `/fwpinky` (guild view, list, detail card, slide-out). Version 0.1.0: graphics for the guild window and the slide-out. All unverified in game. About 20 MB in total. Slide-out symbols will follow.

## Lizenz · License
GPL-3.0-or-later, siehe · see `LICENSE`.
