-- Freewood-Design: Texturen der Freewood-Designs (seit 0.1.0)
-- SPDX-License-Identifier: GPL-3.0-or-later
--
-- Inhalt
--   1. Pfade (FreewoodDesign.Path, FreewoodDesign.Tex)
--   2. Liste der Pinky-Texturen (FreewoodDesign.Pinky.files)
--   3. Klassen und Berufe (FreewoodDesign.ClassTex, FreewoodDesign.CraftTex, FreewoodDesign.CraftBySkill)
--   Genutzter Bereich je Textur: FreewoodDesign.Box(name)
--
-- Nur Grafiken; das Fenster baut der Core bzw. das jeweilige Modul. Quellen (PNG) liegen bei Lacustat, umgewandelt mit
-- tools/convert_pinky.py (Zweierpotenz, TGA 32 Bit, fast deckende Pixel voll deckend).

local D = _G.FreewoodDesign or {}
_G.FreewoodDesign = D

D.VERSION = "0.2.0"
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

-- Genutzter Bereich je Textur (gemessen am Alphakanal): { links, oben, rechts, unten, Breite, Hoehe } in Pixeln
D.Pinky.box = {
    pf_class_druid = { 0, 0, 255, 254, 256, 256 },
    pf_class_hunter = { 0, 0, 254, 254, 256, 256 },
    pf_class_mage = { 0, 0, 255, 254, 256, 256 },
    pf_class_paladin = { 0, 0, 255, 255, 256, 256 },
    pf_class_pet = { 0, 0, 255, 255, 256, 256 },
    pf_class_priest = { 0, 0, 255, 254, 256, 256 },
    pf_class_rogue = { 0, 0, 255, 254, 256, 256 },
    pf_class_shaman = { 0, 0, 255, 254, 256, 256 },
    pf_class_warlock = { 0, 0, 255, 254, 256, 256 },
    pf_class_warrior = { 0, 0, 255, 255, 256, 256 },
    pf_craft_alchemy = { 1, 0, 255, 254, 256, 256 },
    pf_craft_blacksmithing = { 0, 0, 255, 255, 256, 256 },
    pf_craft_cooking = { 0, 0, 254, 254, 256, 256 },
    pf_craft_enchanting = { 1, 0, 255, 254, 256, 256 },
    pf_craft_engineering = { 1, 0, 254, 254, 256, 256 },
    pf_craft_firstaid = { 0, 0, 255, 255, 256, 256 },
    pf_craft_fishing = { 1, 0, 255, 254, 256, 256 },
    pf_craft_herbalism = { 1, 0, 255, 254, 256, 256 },
    pf_craft_inscription = { 0, 0, 255, 254, 256, 256 },
    pf_craft_jewelcrafting = { 0, 0, 254, 254, 256, 256 },
    pf_craft_leatherworking = { 0, 0, 255, 255, 256, 256 },
    pf_craft_mining = { 1, 0, 255, 254, 256, 256 },
    pf_craft_skinning = { 1, 0, 254, 254, 256, 256 },
    pf_craft_survival = { 0, 0, 254, 254, 256, 256 },
    pf_craft_tailoring = { 0, 0, 255, 254, 256, 256 },
    pf_panel_family_tree = { 0, 0, 1024, 512, 1024, 512 },
    pf_button_hover = { 17, 0, 239, 63, 256, 64 },
    pf_button_normal = { 17, 0, 239, 63, 256, 64 },
    pf_button_pushed = { 20, 0, 236, 63, 256, 64 },
    pf_card = { 8, 116, 248, 396, 256, 512 },
    pf_check_off = { 5, 3, 121, 125, 128, 128 },
    pf_check_on = { 4, 3, 122, 125, 128, 128 },
    pf_class_glow = { 0, 0, 255, 254, 256, 256 },
    pf_close_hover = { 0, 0, 64, 64, 64, 64 },
    pf_close_normal = { 0, 0, 64, 64, 64, 64 },
    pf_close_pushed = { 0, 0, 64, 64, 64, 64 },
    pf_craft_glow = { 0, 0, 255, 254, 256, 256 },
    pf_divider = { 0, 7, 512, 57, 512, 64 },
    pf_dropdown = { 0, 19, 512, 109, 512, 128 },
    pf_edit = { 0, 16, 512, 113, 512, 128 },
    pf_frame_main = { 76, 19, 947, 492, 1024, 512 },
    pf_frame_slide = { 26, 116, 486, 396, 512, 512 },
    pf_gear_hover = { 0, 0, 128, 128, 128, 128 },
    pf_gear_normal = { 0, 0, 128, 128, 128, 128 },
    pf_gear_pushed = { 0, 0, 128, 128, 128, 128 },
    pf_lamp_off = { 0, 18, 96, 111, 128, 128 },
    pf_lamp_on = { 0, 18, 95, 111, 128, 128 },
    pf_listmode_off = { 10, 2, 118, 125, 128, 128 },
    pf_listmode_off_hover = { 10, 1, 118, 126, 128, 128 },
    pf_listmode_on = { 10, 2, 118, 126, 128, 128 },
    pf_listmode_on_hover = { 10, 2, 118, 126, 128, 128 },
    pf_logo_gear = { 0, 0, 128, 128, 128, 128 },
    pf_panel = { 0, 0, 512, 512, 512, 512 },
    pf_pennant = { 0, 0, 55, 82, 64, 128 },
    pf_pipe_bottom = { 238, 0, 512, 78, 512, 128 },
    pf_portrait_frame = { 0, 0, 507, 507, 512, 512 },
    pf_portrait_glow_red = { 0, 0, 255, 254, 256, 256 },
    pf_portrait_glow_yellow = { 0, 0, 255, 254, 256, 256 },
    pf_rail_left = { 2, 106, 30, 407, 32, 512 },
    pf_rail_right = { 2, 106, 30, 407, 32, 512 },
    pf_row_hover = { 77, 77, 434, 178, 512, 256 },
    pf_row_normal = { 77, 77, 434, 178, 512, 256 },
    pf_row_selected = { 77, 77, 434, 178, 512, 256 },
    pf_scroll_down = { 22, 0, 106, 28, 128, 32 },
    pf_scroll_up = { 22, 0, 107, 28, 128, 32 },
    pf_scrollbar_thumb_hover = { 0, 0, 64, 32, 64, 32 },
    pf_scrollbar_thumb_normal = { 0, 0, 64, 32, 64, 32 },
    pf_scrollbar_track = { 0, 0, 32, 512, 32, 512 },
    pf_separator_h = { 90, 0, 422, 32, 512, 32 },
    pf_separator_v = { 0, 90, 32, 422, 32, 512 },
    pf_slide_btn_hover = { 0, 116, 52, 396, 64, 512 },
    pf_slide_btn_normal = { 0, 116, 52, 396, 64, 512 },
    pf_slide_btn_pushed = { 0, 116, 52, 396, 64, 512 },
    pf_tooltip_border = { 49, 71, 462, 441, 512, 512 },
}
-- Texturkoordinaten fuer den genutzten Bereich: links, rechts, oben, unten (fuer SetTexCoord) und Groesse in Pixeln
function D.Box(name)
    local b = D.Pinky.box[name]
    if not b then return 0, 1, 0, 1, 0, 0 end
    return b[1] / b[5], b[3] / b[5], b[2] / b[6], b[4] / b[6], b[3] - b[1], b[4] - b[2]
end

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

-- Berufs-Kennungen (Skill-Line) -> Schluessel
D.SKILL_CRAFT = { [171] = "alchemy", [164] = "blacksmithing", [333] = "enchanting", [202] = "engineering",
    [165] = "leatherworking", [197] = "tailoring", [182] = "herbalism", [186] = "mining", [393] = "skinning",
    [185] = "cooking", [129] = "firstaid", [356] = "fishing", [755] = "jewelcrafting", [773] = "inscription" }
function D.CraftBySkill(id)
    local k = D.SKILL_CRAFT[tonumber(id) or 0]
    return k and D.CraftTex(k) or nil
end
