-- Freewood-Design: Texturen der Freewood-Designs (seit 0.1.0)
-- SPDX-License-Identifier: GPL-3.0-or-later
--
-- Inhalt
--   1. Pfade (FreewoodDesign.Path, FreewoodDesign.Tex)
--   2. Liste der Pinky-Texturen (FreewoodDesign.Pinky.files)
--   3. Klassen und Berufe (FreewoodDesign.ClassTex, FreewoodDesign.CraftTex)
--
-- Nur Grafiken; das Fenster baut der Core bzw. das jeweilige Modul. Quellen (PNG) liegen bei Lacustat, umgewandelt mit
-- tools/convert_pinky.py (Zweierpotenz, TGA 32 Bit, fast deckende Pixel voll deckend).

local D = _G.FreewoodDesign or {}
_G.FreewoodDesign = D

D.VERSION = "0.1.0"
D.ROOT = "Interface\\AddOns\\Freewood-Design\\Media\\"

------------------------------------------------------------------------
-- 1. Pfade
------------------------------------------------------------------------

-- D.Path("Pinky", "ui", "pf_frame_main") -> "Interface\\AddOns\\Freewood-Design\\Media\\Pinky\\ui\\pf_frame_main"
function D.Path(design, group, name)
    return D.ROOT .. design .. "\\" .. group .. "\\" .. name
end

------------------------------------------------------------------------
-- 2. Pinky Freewood
------------------------------------------------------------------------

D.Pinky = D.Pinky or {}
D.Pinky.files = {
    ui = { "pf_button_hover", "pf_button_normal", "pf_button_pushed", "pf_card", "pf_check_off", "pf_check_on", "pf_class_glow", "pf_close_hover", "pf_close_normal", "pf_close_pushed", "pf_craft_glow", "pf_divider", "pf_dropdown", "pf_edit", "pf_frame_main", "pf_frame_slide", "pf_gear_hover", "pf_gear_normal", "pf_gear_pushed", "pf_lamp_off", "pf_lamp_on", "pf_listmode_off", "pf_listmode_off_hover", "pf_listmode_on", "pf_listmode_on_hover", "pf_logo_gear", "pf_panel", "pf_pennant", "pf_pipe_bottom", "pf_portrait_frame", "pf_portrait_glow_red", "pf_portrait_glow_yellow", "pf_rail_left", "pf_rail_right", "pf_row_hover", "pf_row_normal", "pf_row_selected", "pf_scroll_down", "pf_scroll_up", "pf_scrollbar_thumb_hover", "pf_scrollbar_thumb_normal", "pf_scrollbar_track", "pf_separator_h", "pf_separator_v", "pf_slide_btn_hover", "pf_slide_btn_normal", "pf_slide_btn_pushed", "pf_tooltip_border" },
    class = { "pf_class_druid", "pf_class_hunter", "pf_class_mage", "pf_class_paladin", "pf_class_pet", "pf_class_priest", "pf_class_rogue", "pf_class_shaman", "pf_class_warlock", "pf_class_warrior" },
    craft = { "pf_craft_alchemy", "pf_craft_blacksmithing", "pf_craft_cooking", "pf_craft_enchanting", "pf_craft_engineering", "pf_craft_firstaid", "pf_craft_fishing", "pf_craft_herbalism", "pf_craft_inscription", "pf_craft_jewelcrafting", "pf_craft_leatherworking", "pf_craft_mining", "pf_craft_skinning", "pf_craft_survival", "pf_craft_tailoring" },
    later = { "pf_panel_family_tree" },
}
local known = {}
for group, list in pairs(D.Pinky.files) do
    for _, n in ipairs(list) do known[n] = group end
end
-- D.Tex("pf_frame_main") -> voller Pfad; nil, wenn es die Textur nicht gibt
function D.Tex(name)
    local g = known[name]
    return g and D.Path("Pinky", g, name) or nil
end
D.Pinky.Tex = D.Tex

------------------------------------------------------------------------
-- 3. Klassen und Berufe
------------------------------------------------------------------------

-- Klassenkuerzel des Spiels (UnitClass, GetGuildRosterInfo) -> Textur; "PET" fuer Jaeger-Begleiter
function D.ClassTex(token)
    if type(token) ~= "string" then return nil end
    return D.Tex("pf_class_" .. token:lower())
end

-- Berufe nach englischem Namen ohne Leerzeichen ("alchemy", "blacksmithing", "firstaid" ...)
D.CRAFTS = { "alchemy", "blacksmithing", "cooking", "enchanting", "engineering", "firstaid", "fishing", "herbalism",
    "inscription", "jewelcrafting", "leatherworking", "mining", "skinning", "survival", "tailoring" }
function D.CraftTex(key)
    if type(key) ~= "string" then return nil end
    return D.Tex("pf_craft_" .. key:lower():gsub("[%s%-]", ""))
end
