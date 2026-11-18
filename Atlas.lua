-- Freewood-Design: Atlas-Tabelle (erzeugt von tools/make_atlas.py, nicht von Hand aendern)
-- SPDX-License-Identifier: GPL-3.0-or-later
-- name = { Atlasdatei, x, y, Atlasbreite, Atlashoehe }: Zelle des Zustands im Atlas (Pixel). Der genutzte Bereich
-- innerhalb der Zelle steht wie bisher in FreewoodDesign.Pinky.box[name].
local D = _G.FreewoodDesign
if not D then return end
D.Pinky.atlas = {
    pf_row_normal = { "pf_atlas_row", 0, 0, 512, 1024 },
    pf_row_hover = { "pf_atlas_row", 0, 256, 512, 1024 },
    pf_row_selected = { "pf_atlas_row", 0, 512, 512, 1024 },
    pf_close_normal = { "pf_atlas_close", 0, 0, 256, 64 },
    pf_close_hover = { "pf_atlas_close", 64, 0, 256, 64 },
    pf_close_pushed = { "pf_atlas_close", 128, 0, 256, 64 },
    pf_slide_btn_normal = { "pf_atlas_slide_btn", 0, 0, 256, 512 },
    pf_slide_btn_hover = { "pf_atlas_slide_btn", 64, 0, 256, 512 },
    pf_slide_btn_pushed = { "pf_atlas_slide_btn", 128, 0, 256, 512 },
    pf_listmode_off = { "pf_atlas_listmode", 0, 0, 512, 128 },
    pf_listmode_off_hover = { "pf_atlas_listmode", 128, 0, 512, 128 },
    pf_listmode_on = { "pf_atlas_listmode", 256, 0, 512, 128 },
    pf_listmode_on_hover = { "pf_atlas_listmode", 384, 0, 512, 128 },
    pf_lamp_on = { "pf_atlas_lamp", 0, 0, 256, 128 },
    pf_lamp_off = { "pf_atlas_lamp", 128, 0, 256, 128 },
    pf_scroll_up = { "pf_atlas_scroll", 0, 0, 128, 64 },
    pf_scroll_down = { "pf_atlas_scroll", 0, 32, 128, 64 },
    pf_gear_normal = { "pf_atlas_gear", 0, 0, 512, 128 },
    pf_gear_hover = { "pf_atlas_gear", 128, 0, 512, 128 },
    pf_gear_pushed = { "pf_atlas_gear", 256, 0, 512, 128 },
    pf_button_normal = { "pf_atlas_button", 0, 0, 256, 256 },
    pf_button_hover = { "pf_atlas_button", 0, 64, 256, 256 },
    pf_button_pushed = { "pf_atlas_button", 0, 128, 256, 256 },
}
