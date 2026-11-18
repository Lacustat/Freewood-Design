#!/usr/bin/env python3
# Freewood-Design: Zustaende eines Knopfs in eine gemeinsame Datei legen (Atlas), seit 0.2.14
# SPDX-License-Identifier: GPL-3.0-or-later
# Aufruf nach convert_pinky.py: python3 tools/make_atlas.py Media/Pinky/ui Atlas.lua
#   - je Satz eine TGA (Zweierpotenz), Zellen gleich gross, nebeneinander oder untereinander
#   - die Einzeldateien des Satzes werden geloescht (sind dann im Atlas)
#   - schreibt Atlas.lua: FreewoodDesign.Pinky.atlas[name] = { datei, x, y, breite, hoehe } (Zelle und Atlasgroesse)
# Warum: Das Spiel laedt eine Datei erst, wenn sie zum ersten Mal gezeichnet wird. Liegt der Hover-Zustand in
# derselben Datei wie der normale (schon sichtbare), gibt es beim ersten Ueberfahren kein Blinken.
import os, sys
from PIL import Image

UI, OUT = sys.argv[1], sys.argv[2]
SETS = [  # Name des Atlas, Zustaende, Richtung (h = nebeneinander, v = untereinander)
    ("pf_atlas_row", ["pf_row_normal", "pf_row_hover", "pf_row_selected"], "v"),
    ("pf_atlas_close", ["pf_close_normal", "pf_close_hover", "pf_close_pushed"], "h"),
    ("pf_atlas_slide_btn", ["pf_slide_btn_normal", "pf_slide_btn_hover", "pf_slide_btn_pushed"], "h"),
    ("pf_atlas_listmode", ["pf_listmode_off", "pf_listmode_off_hover", "pf_listmode_on", "pf_listmode_on_hover"], "h"),
    ("pf_atlas_lamp", ["pf_lamp_on", "pf_lamp_off"], "h"),
    ("pf_atlas_scroll", ["pf_scroll_up", "pf_scroll_down"], "v"),
    ("pf_atlas_gear", ["pf_gear_normal", "pf_gear_hover", "pf_gear_pushed"], "h"),
    ("pf_atlas_button", ["pf_button_normal", "pf_button_hover", "pf_button_pushed"], "v"),
]

def p2(n):
    x = 1
    while x < n: x *= 2
    return x

lines = []
for atlas, names, d in SETS:
    ims = [Image.open(os.path.join(UI, n + ".tga")).convert("RGBA") for n in names]
    w, h = ims[0].size
    assert all(im.size == (w, h) for im in ims), atlas
    k = len(ims)
    aw, ah = (p2(w * k), h) if d == "h" else (w, p2(h * k))
    A = Image.new("RGBA", (aw, ah), (0, 0, 0, 0))
    for i, (n, im) in enumerate(zip(names, ims)):
        x, y = (i * w, 0) if d == "h" else (0, i * h)
        A.paste(im, (x, y))
        lines.append(f'    {n} = {{ "{atlas}", {x}, {y}, {aw}, {ah} }},')
    A.save(os.path.join(UI, atlas + ".tga"), format="TGA", compression=None)
    for n in names: os.remove(os.path.join(UI, n + ".tga"))
    print(f"{atlas:22} {aw}x{ah}  ({', '.join(names)})")

with open(OUT, "w", encoding="utf-8") as fh:
    fh.write('''-- Freewood-Design: Atlas-Tabelle (erzeugt von tools/make_atlas.py, nicht von Hand aendern)
-- SPDX-License-Identifier: GPL-3.0-or-later
-- name = { Atlasdatei, x, y, Atlasbreite, Atlashoehe }: Zelle des Zustands im Atlas (Pixel). Der genutzte Bereich
-- innerhalb der Zelle steht wie bisher in FreewoodDesign.Pinky.box[name].
local D = _G.FreewoodDesign
if not D then return end
D.Pinky.atlas = {
''' + "\n".join(lines) + "\n}\n")
