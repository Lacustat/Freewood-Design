#!/usr/bin/env python3
# Freewood-Design: PNG-Vorlagen von Lacustat in TGA fuer das Spiel umwandeln (Pinky Freewood)
# SPDX-License-Identifier: GPL-3.0-or-later
# Aufruf: python3 tools/convert_pinky.py <Ordner "Freewood Design"> <Ausgabe Media/Pinky>
#   - Zielgroesse je Datei (Zweierpotenz), Verkleinern mit vormultipliziertem Alpha (keine dunklen Saeume)
#   - fast deckende Pixel (Alpha >= 250) werden voll deckend, Farbe unter Alpha 0 wird schwarz
#   - TGA 32 Bit, unkomprimiert; Dateinamen vereinheitlicht (Tabelle MAP)
import os, sys
from PIL import Image

SRC, DST = sys.argv[1], sys.argv[2]
IC = 256  # Klassen-/Berufs-Icons
MAP = {
    # Klassen (Namen nach dem Klassenkuerzel des Spiels, klein)
    "pf_class_icons/pf_class_icon_druid.png": ("class/pf_class_druid", IC),
    "pf_class_icons/pf_class_icon_hunter.png": ("class/pf_class_hunter", IC),
    "pf_class_icons/pf_class_icon_mage.png": ("class/pf_class_mage", IC),
    "pf_class_icons/pf_class_icon_paladin.png": ("class/pf_class_paladin", IC),
    "pf_class_icons/pf_class_icon_priest.png": ("class/pf_class_priest", IC),
    "pf_class_icons/pf_class_icon_rouge.png": ("class/pf_class_rogue", IC),
    "pf_class_icons/pf_class_icon_shamane.png": ("class/pf_class_shaman", IC),
    "pf_class_icons/pf_class_icon_warlock.png": ("class/pf_class_warlock", IC),
    "pf_class_icons/pf_class_icon_warrior.png": ("class/pf_class_warrior", IC),
    "pf_class_icons/pf_class_icon_pet.png": ("class/pf_class_pet", IC),
    # Berufe (seit 0.2.18: klarere Icons fuer die Detailkarte aus pf_crafting_icons_detail_view)
    "pf_crafting_icons_detail_view/pf_crafting_icon_detail_alchemy.png": ("craft/pf_craft_alchemy", IC, "center"),
    "pf_crafting_icons_detail_view/pf_crafting_icon_detail_blacksmith.png": ("craft/pf_craft_blacksmithing", IC, "center"),
    "pf_crafting_icons_detail_view/pf_crafting_icon_detail_cooking.png": ("craft/pf_craft_cooking", IC, "center"),
    "pf_crafting_icons_detail_view/pf_crafting_icon_detail_enchanting.png": ("craft/pf_craft_enchanting", IC, "center"),
    "pf_crafting_icons_detail_view/pf_crafting_icon_detail_firstaid.png": ("craft/pf_craft_firstaid", IC, "center"),
    "pf_crafting_icons_detail_view/pf_crafting_icon_detail_fishing.png": ("craft/pf_craft_fishing", IC, "center"),
    "pf_crafting_icons_detail_view/pf_crafting_icon_detail_herbalism.png": ("craft/pf_craft_herbalism", IC, "center"),
    "pf_crafting_icons_detail_view/pf_crafting_icon_detail_ingenieure.png": ("craft/pf_craft_engineering", IC, "center"),
    "pf_crafting_icons_detail_view/pf_crafting_icon_detail_inscription.png": ("craft/pf_craft_inscription", IC, "center"),
    "pf_crafting_icons_detail_view/pf_crafting_icon_detail_juwe.png": ("craft/pf_craft_jewelcrafting", IC, "center"),
    "pf_crafting_icons_detail_view/pf_crafting_icon_detail_leatherworking.png": ("craft/pf_craft_leatherworking", IC, "center"),
    "pf_crafting_icons_detail_view/pf_crafting_icon_detail_mining.png": ("craft/pf_craft_mining", IC, "center"),
    "pf_crafting_icons_detail_view/pf_crafting_icon_detail_skinning.png": ("craft/pf_craft_skinning", IC, "center"),
    "pf_crafting_icons_detail_view/pf_crafting_icon_detail_survival.png": ("craft/pf_craft_survival", IC, "center"),
    "pf_crafting_icons_detail_view/pf_crafting_icon_detail_tailor.png": ("craft/pf_craft_tailoring", IC, "center"),
    # Logo
    "pf_logos/pf_logo_gear.png": ("ui/pf_logo_gear", None),
    # Oberflaeche (Groesse bleibt, ausser angegeben)
    "pf_ui_elements/pf_btn_normal.png": ("ui/pf_close_normal", None),
    "pf_ui_elements/pf_btn_mouseOver.png": ("ui/pf_close_hover", None),
    "pf_ui_elements/pf_btn_pushed.png": ("ui/pf_close_pushed", None),
    "pf_ui_elements/pf_btn_std_normal.png": ("ui/pf_button_normal", None),
    "pf_ui_elements/pf_btn_std_hover.png": ("ui/pf_button_hover", None),
    "pf_ui_elements/pf_btn_std_pushed.png": ("ui/pf_button_pushed", None),
    "pf_ui_elements/pf_card.png": ("ui/pf_card", None),
    "pf_ui_elements/pf_check_off.png": ("ui/pf_check_off", None),
    "pf_ui_elements/pf_check_on.png": ("ui/pf_check_on", None),
    "pf_ui_elements/pf_class_icon_glow.png": ("ui/pf_class_glow", (256, 256)),
    "pf_ui_elements/pf_craft_icon_glow.png": ("ui/pf_craft_glow", (256, 256)),
    "pf_ui_elements/pf_divider.png": ("ui/pf_divider", None),
    "pf_ui_elements/pf_dropdown.png": ("ui/pf_dropdown", None),
    "pf_ui_elements/pf_edit.png": ("ui/pf_edit", None),
    "pf_ui_elements/pf_frame_main.png": ("ui/pf_frame_main", None),
    "pf_ui_elements/pf_frame_slide.png": ("ui/pf_frame_slide", None),
    "pf_ui_elements/pf_lamp_on.png": ("ui/pf_lamp_on", (128, 128)),
    "pf_ui_elements/pf_lamp_off.png": ("ui/pf_lamp_off", (128, 128)),
    "pf_ui_elements/pf_listmode_off.png": ("ui/pf_listmode_off", (128, 128)),
    "pf_ui_elements/pf_listmode_off_mouseover.png": ("ui/pf_listmode_off_hover", (128, 128)),
    "pf_ui_elements/pf_listmode_on.png": ("ui/pf_listmode_on", (128, 128)),
    "pf_ui_elements/pf_listmode_on_mouseover.png": ("ui/pf_listmode_on_hover", (128, 128)),
    "pf_ui_elements/pf_panel.png": ("ui/pf_panel", None),
    "pf_ui_elements/pf_panel_root_family_tree.png": ("later/pf_panel_family_tree", (1024, 512)),
    "pf_ui_elements/pf_pennant.png": ("ui/pf_pennant", None),
    "pf_ui_elements/pf_pipe_bottom (1).png": ("ui/pf_pipe_bottom", None),
    "pf_ui_elements/pf_portrai_frame.png": ("ui/pf_portrait_frame", (512, 512)),
    "pf_ui_elements/pf_portrai_glow_red.png": ("ui/pf_portrait_glow_red", (256, 256)),
    "pf_ui_elements/pf_protrai_glow_yellow.png": ("ui/pf_portrait_glow_yellow", (256, 256)),
    "pf_ui_elements/pf_rail_backround_left.png": ("ui/pf_rail_left", None),
    "pf_ui_elements/pf_rail_backround_right.png": ("ui/pf_rail_right", None),
    "pf_ui_elements/pf_roster_plate_normal.png": ("ui/pf_row_normal", None),
    "pf_ui_elements/pf_roster_plate_mouseover.png": ("ui/pf_row_hover", None),
    "pf_ui_elements/pf_roster_plate_select.png": ("ui/pf_row_selected", None),
    "pf_ui_elements/pf_scroll_up.png": ("ui/pf_scroll_up", None),
    "pf_ui_elements/pf_scroll_down.png": ("ui/pf_scroll_down", None),
    "pf_ui_elements/pf_scrollbar_track.png": ("ui/pf_scrollbar_track", None),
    "pf_ui_elements/pf_scrollbar_thumb_normal.png": ("ui/pf_scrollbar_thumb_normal", None),
    "pf_ui_elements/pf_scrollbar_thumb_hover.png": ("ui/pf_scrollbar_thumb_hover", None),
    "pf_ui_elements/pf_seperator_pipe_horizontal.png": ("ui/pf_separator_h", None),
    "pf_ui_elements/pf_seperator_pipe_vertical.png": ("ui/pf_separator_v", None),
    "pf_ui_elements/pf_settings_gear_normal.png": ("ui/pf_gear_normal", None),
    "pf_ui_elements/pf_settings_gear_hover.png": ("ui/pf_gear_hover", None),
    "pf_ui_elements/pf_settings_gear_pushed.png": ("ui/pf_gear_pushed", None),
    "pf_ui_elements/pf_slider_btn_normal.png": ("ui/pf_slide_btn_normal", None),
    "pf_ui_elements/pf_slider_btn_hover.png": ("ui/pf_slide_btn_hover", None),
    "pf_ui_elements/pf_slider_btn_pushed.png": ("ui/pf_slide_btn_pushed", None),
    "pf_ui_elements/pf_tooltip_border.png": ("ui/pf_tooltip_border", None),
    "pf_ui_elements/pf_card_one_note.png": None,   # nicht noetig: Notizfelder zeichnet das Spiel
}

def p2(n): return n > 0 and n & (n - 1) == 0

def convert(src, dst, size, center=False):
    im = Image.open(src).convert("RGBA")
    if center:
        # Motiv mittig: auf den genutzten Bereich zuschneiden und quadratisch mittig einsetzen (seit 0.2.19)
        bb = im.getchannel("A").getbbox()
        if bb:
            im = im.crop(bb)
            side = max(im.size)
            sq = Image.new("RGBA", (side, side), (0, 0, 0, 0))
            sq.paste(im, ((side - im.size[0]) // 2, (side - im.size[1]) // 2))
            im = sq
    if isinstance(size, int): size = (size, size)
    if size and im.size != size:
        im = im.convert("RGBa").resize(size, Image.LANCZOS).convert("RGBA")
    r, g, b, a = im.split()
    a = a.point(lambda v: 255 if v >= 250 else v)
    im = Image.merge("RGBA", (r, g, b, a))
    black = Image.new("RGBA", im.size, (0, 0, 0, 0))
    im = Image.composite(im, black, a.point(lambda v: 255 if v > 0 else 0))
    assert p2(im.size[0]) and p2(im.size[1]), (src, im.size)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    im.save(dst, format="TGA", compression=None)
    return im.size

total, done, missing = 0, [], []
for rel, spec in MAP.items():
    p = os.path.join(SRC, rel)
    if spec is None: continue
    if not os.path.exists(p): missing.append(rel); continue
    name, size = spec[0], spec[1]
    out = os.path.join(DST, name + ".tga")
    s = convert(p, out, size, len(spec) > 2 and spec[2] == "center")
    total += os.path.getsize(out)
    done.append((name, s))
for n, s in done: print(f"{n:36} {s[0]}x{s[1]}")
print(f"{len(done)} Dateien, {total/1048576:.1f} MB", "fehlt:", missing)
