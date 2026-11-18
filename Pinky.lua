-- Freewood-Design: Probefenster "Pinky Freewood" (Gildenansicht mit Slideout), seit 0.2.0
-- SPDX-License-Identifier: GPL-3.0-or-later
--
-- Inhalt
--   1. Grundlagen (Speicher, Helfer, Texturen mit genutztem Bereich)
--   2. Gildenliste lesen (Pinky.ReadRoster): Name, Rang, Stufe, Klasse, Gebiet, Notizen, online, Berufe
--   3. Hauptfenster (Rahmen, Schliessen, Deko, Ziehen, Groesse)
--   4. Roster: Schienen, Messingschilder, Lampen, Scroll-Pfeile, Mausrad
--   5. Listenansicht (Hebel): gezeichnete Kopfzeile und Zeilen
--   6. Detailkarte: Name (Umbruch, zentriert), Stufe, Gildenrang, Notizen (Offiziersnotiz nur fuer Offiziere), Berufe
--   7. Slideout: Ausklapp-Knopf am Rahmen, Fenster faehrt hinter dem Rahmen heraus
--   8. Ereignisse und /fwpinky
--
-- Berufe kommen aus dem Gilden-Modul (Freewood-Guild, geteilte Profile), sonst bleiben die Plaetze leer.
-- Masse in Einheiten des Rahmenbildes (1024 x 512). Im Spiel ungeprueft.

local ADDON = ...
local G = _G
local D = G.FreewoodDesign
if not D then return end

local Pinky = {}
D.Pinky.UI = Pinky
G.FreewoodPinky = Pinky

local FONT = "Fonts\\FRIZQT__.TTF"
local W, H = 1024, 512
-- Innenflaeche des Rahmens (gemessen): x 165..855, y 105..415
local IN_L, IN_T, IN_R, IN_B = 165, 105, 855, 415
local ROSTER_L, ROSTER_R = 178, 590
local SEP_X = 584                       -- senkrechter Trenner zwischen Roster und Detailkarte (Mitte)
local CARD_X, CARD_Y = 604, 4          -- linke obere Ecke der Kartentextur (256 x 512)
local SLIDE_BTN_X = 936                 -- Ausklapp-Knopf (64 x 512) am rechten Rand
local SLIDE_OPEN_X, SLIDE_CLOSED_X = 880, 440
local SLIDE_SECS = 0.35
Pinky.ROW_SCALE = 0.74
Pinky.ROW_GAP = 6
Pinky.LIST_ROW_H = 18
Pinky.CARD_PROF, Pinky.CARD_PROF_SMALL = 62, 40   -- Berufs-Icons auf der Karte (ohne / mit Offiziersnotiz)
-- Groesse fest im Design, unabhaengig von der UI-Skalierung des Spiels (seit 0.2.13): Lacustats Wahl war 150 % bei
-- UI-Skalierung 65 % -> wirksamer Massstab 0,975. Das Fenster bekommt Pinky.SCALE_EFF / Skalierung des UIParent,
-- wird also kleiner, wenn jemand die UI-Skalierung hochdreht, und groesser, wenn er sie senkt.
Pinky.SCALE_EFF = 1.5 * 0.65
Pinky.DISC_SIZE = 0.42        -- Stufen-Scheibe auf dem Schild: Anteil der Schildhoehe
Pinky.PROF_SIZE = 0.36       -- Berufs-Icons auf dem Schild: Anteil der Schildhoehe
Pinky.PROF_INSET = 30       -- Berufs-Icons: Abstand vom rechten Rand des Schildes (vor der Zierleiste)
Pinky.FONT_MIN_SCALE = 0    -- aus: die Groesse auf dem Bildschirm ist fest (seit 0.2.13), Schrift braucht keinen Ausgleich

local L = {
    title = "Pinky Freewood",
    noGuild = "Du bist in keiner Gilde.",
    loading = "Gildenliste wird geladen ...",
    level = "Stufe",
    note = "Notiz",
    onote = "Offiziersnotiz",
    online = "online",
    offline = "offline",
    listmode = "Listenansicht an/aus",
    colName = "Name", colLevel = "Stufe", colClass = "Klasse", colRank = "Rang", colZone = "Gebiet",
    slideSoon = "Hier kommen die Bereiche hin.",
    reset = "Pinky: Position zurueckgesetzt.",
    help = "/fwpinky (Fenster), /fwpinky symbole blizzard|kasten|pinky, /fwpinky reset",
    iconsSet = "Pinky: Berufs-Symbole %s",
}
if G.GetLocale and G.GetLocale() ~= "deDE" then
    L.noGuild = "You are not in a guild."
    L.loading = "Loading guild roster ..."
    L.level, L.note, L.onote, L.listmode = "Level", "Note", "Officer note", "List view on/off"
    L.colName, L.colLevel, L.colClass, L.colRank, L.colZone = "Name", "Level", "Class", "Rank", "Zone"
    L.slideSoon = "The sections go here."
    L.reset = "Pinky: position reset."
    L.help = "/fwpinky (window), /fwpinky symbole blizzard|kasten|pinky, /fwpinky reset"
    L.iconsSet = "Pinky: profession icons %s"
end
Pinky.L = L

------------------------------------------------------------------------
-- 1. Grundlagen
------------------------------------------------------------------------

local function DB()
    G.FreewoodDesignDB = G.FreewoodDesignDB or {}
    local db = G.FreewoodDesignDB
    db.pinky = db.pinky or {}
    return db.pinky
end
Pinky.DB = DB

local function Say(t)
    local FW = G.Freewood
    if FW and FW.Print then FW:Print(t) elseif G.DEFAULT_CHAT_FRAME then G.DEFAULT_CHAT_FRAME:AddMessage("|cffc89b3cFreewood|r " .. t) end
end

local function Secret(v)
    local FW = G.Freewood
    return FW and FW.Util and FW.Util.IsSecret and FW.Util.IsSecret(v) or false
end

-- Textur nur mit dem genutzten Bereich; scale: Einheiten je Bildpixel
local function Tex(parent, name, layer, scale, sub)
    local t = parent:CreateTexture(nil, layer or "ARTWORK", nil, sub)
    t:SetTexture(D.Tex(name))
    local l, r, top, b, w, h = D.Box(name)
    t:SetTexCoord(l, r, top, b)
    scale = scale or 1
    t:SetSize(math.max(1, w * scale), math.max(1, h * scale))
    t.pfName = name
    return t
end
-- Textur wechseln (gleiche Groesse, gleicher Bereich, z. B. normal -> hover)
local function Swap(t, name)
    if t.pfStates then t:Set(name) return end
    if t.pfName == name then return end
    t:SetTexture(D.Tex(name))
    local l, r, top, b = D.Box(name)
    t:SetTexCoord(l, r, top, b)
    t.pfName = name
end
-- Nur die vier Texturkoordinaten des genutzten Bereichs setzen
local function TC(t, name)
    local l, r, top, b = D.Box(name)
    t:SetTexCoord(l, r, top, b)
end
-- Mehrere Zustaende als eigene Texturen, alle beim Aufbau geladen; Wechsel nur ueber Zeigen/Verbergen.
-- So muss beim ersten Ueberfahren nichts nachgeladen werden (kein kurzes Blinken, seit 0.2.11).
local function States(parent, names, layer, sub)
    local o = { tex = {}, cur = nil, pfStates = true }
    for _, n in ipairs(names) do
        local t = parent:CreateTexture(nil, layer or "ARTWORK", nil, sub)
        t:SetTexture(D.Tex(n))
        TC(t, n)
        t:SetAllPoints(parent)
        t:Hide()
        o.tex[n] = t
    end
    function o:Set(n)
        if self.cur == n or not self.tex[n] then return end
        for k, t in pairs(self.tex) do if k == n then t:Show() else t:Hide() end end
        self.cur = n
    end
    o:Set(names[1])
    return o
end
Pinky.States = States
-- Ecke oben links des genutzten Bereichs einer Textur, deren volles Bild bei (x, y) laege
local function At(t, parent, name, x, y, scale)
    local b = D.Pinky.box[name]
    scale = scale or 1
    t:SetPoint("TOPLEFT", parent, "TOPLEFT", x + b[1] * scale, -(y + b[2] * scale))
end

local fonts = {}   -- alle Schriften mit ihrer Grundgroesse (fuer die Mindestgroesse)
local fontScale = 1
local function Font(parent, size, r, g, b, justify, flags)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(FONT, size * fontScale, flags or "")
    fonts[#fonts + 1] = { fs, size, flags or "" }
    fs:SetTextColor(r or 1, g or 1, b or 1)
    fs:SetJustifyH(justify or "CENTER")
    if fs.SetShadowOffset then fs:SetShadowOffset(1, -1) fs:SetShadowColor(0, 0, 0, 0.8) end
    return fs
end

-- Knopf-Helligkeit (Scroll-Pfeile haben nur ein Bild)
local BRIGHT = { normal = 0.85, hover = 1, pushed = 0.6, disabled = 0.35 }
local function Bright(t, state)
    local v = BRIGHT[state] or 1
    t:SetVertexColor(v, v, v)
    if t.SetDesaturated then t:SetDesaturated(state == "disabled") end
end

------------------------------------------------------------------------
-- 2. Gildenliste
------------------------------------------------------------------------

Pinky.rows = {}

local function Display(name)
    local FWG = G.Freewood and G.Freewood.Guild
    if FWG and FWG.Display then
        local ok, d = pcall(FWG.Display, name)
        if ok and type(d) == "string" then return d end
    end
    -- "Vorname Nachname-Realm" -> ohne Realm (nur wenn der Teil nach dem letzten - kein Leerzeichen hat)
    local base, realm = name:match("^(.*)%-([^%-%s]+)$")
    if base and realm then return base end
    return name
end
Pinky.Display = Display

local function Profs(full)
    local FWG = G.Freewood and G.Freewood.Guild
    if not (FWG and FWG.Shared and FWG.MainProfs) then return nil, nil end
    local ok, sh = pcall(FWG.Shared, full)
    if not ok or type(sh) ~= "table" then return nil, nil end
    local ok2, p1, p2 = pcall(FWG.MainProfs, sh.skills)
    if not ok2 then return nil, nil end
    return p1, p2
end

function Pinky.CanOfficerNote()
    local gi = G.C_GuildInfo
    if gi and gi.CanViewOfficerNote then
        local ok, v = pcall(gi.CanViewOfficerNote)
        if ok then return v and true or false end
    end
    if type(G.CanViewOfficerNote) == "function" then
        local ok, v = pcall(G.CanViewOfficerNote)
        if ok then return v and true or false end
    end
    return false
end

function Pinky.ReadRoster()
    local rows = {}
    if not (G.IsInGuild and G.IsInGuild()) or not G.GetNumGuildMembers or not G.GetGuildRosterInfo then
        Pinky.rows = rows
        return rows
    end
    local n = G.GetNumGuildMembers() or 0
    for i = 1, n do
        local ok, name, rank, rankIndex, level, className, zone, note, onote, online, _, classFile =
            pcall(G.GetGuildRosterInfo, i)
        if ok and type(name) == "string" and not Secret(name) then
            local p1, p2 = Profs(name)
            rows[#rows + 1] = {
                full = name, name = Display(name),
                rank = type(rank) == "string" and rank or "", rankIndex = tonumber(rankIndex) or 99,
                level = tonumber(level) or 0, className = type(className) == "string" and className or "",
                class = type(classFile) == "string" and classFile or nil,
                zone = type(zone) == "string" and zone or "",
                note = type(note) == "string" and not Secret(note) and note or "",
                onote = type(onote) == "string" and not Secret(onote) and onote or "",
                online = online and true or false, prof1 = p1, prof2 = p2,
            }
        end
    end
    Pinky.SortRows(rows, DB().listMode and DB().sortKey or nil, DB().sortAsc ~= false)
    Pinky.rows = rows
    return rows
end

-- Sortieren: ohne Schluessel online zuerst, dann Rang, dann Name; mit Schluessel (Listenansicht, Klick auf die
-- Spaltenueberschrift) nach dieser Spalte auf- oder absteigend, bei Gleichstand nach Name
local SORT_VAL = {
    name = function(e) return e.name:lower() end,
    level = function(e) return e.level end,
    className = function(e) return e.className:lower() end,
    rank = function(e) return e.rankIndex end,
    zone = function(e) return e.zone:lower() end,
}
function Pinky.SortRows(rows, key, asc)
    local get = key and SORT_VAL[key]
    table.sort(rows, function(a, b)
        if get then
            local va, vb = get(a), get(b)
            if va ~= vb then
                if asc then return va < vb end
                return va > vb
            end
            return a.name < b.name
        end
        if a.online ~= b.online then return a.online end
        if a.rankIndex ~= b.rankIndex then return a.rankIndex < b.rankIndex end
        return a.name < b.name
    end)
    return rows
end

-- Klick auf eine Spaltenueberschrift: gleiche Spalte dreht die Richtung, neue Spalte beginnt aufsteigend
function Pinky.SetSort(key)
    local db = DB()
    if db.sortKey == key then db.sortAsc = not (db.sortAsc ~= false) else db.sortKey, db.sortAsc = key, true end
    Pinky.offset = 0
    Pinky.Refresh()
end

-- Berufs-Symbole: "blizzard" (Spiel-Icons, eckig, besser erkennbar bei kleiner Groesse) oder "pinky"
-- (eigene Bilder aus Freewood-Design). Einstellung DB().craftIcons, Standard "blizzard" (Test seit 0.2.6).
Pinky.BLIZZ_CRAFT = {
    [171] = "Interface\\Icons\\Trade_Alchemy", [164] = "Interface\\Icons\\Trade_BlackSmithing",
    [333] = "Interface\\Icons\\Trade_Engraving", [202] = "Interface\\Icons\\Trade_Engineering",
    [165] = "Interface\\Icons\\INV_Misc_ArmorKit_17", [197] = "Interface\\Icons\\Trade_Tailoring",
    [182] = "Interface\\Icons\\Spell_Nature_NatureTouchGrow", [186] = "Interface\\Icons\\Trade_Mining",
    [393] = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01", [185] = "Interface\\Icons\\INV_Misc_Food_15",
    [129] = "Interface\\Icons\\Spell_Holy_SealOfSacrifice", [356] = "Interface\\Icons\\Trade_Fishing",
    [755] = "Interface\\Icons\\INV_Misc_Gem_01", [773] = "Interface\\Icons\\INV_Inscription_Tradeskill01",
}

function Pinky.CraftStyle()
    return DB().craftIcons == "blizzard" and "blizzard" or "pinky"   -- seit 0.2.9 wieder eigene Bilder als Standard
end

-- Klassenfarben (Spiel-Tabelle, sonst die bekannten Werte); offline abgedunkelt
local CLASS_RGB = {
    WARRIOR = { 0.78, 0.61, 0.43 }, PALADIN = { 0.96, 0.55, 0.73 }, HUNTER = { 0.67, 0.83, 0.45 },
    ROGUE = { 1, 0.96, 0.41 }, PRIEST = { 1, 1, 1 }, SHAMAN = { 0, 0.44, 0.87 }, MAGE = { 0.25, 0.78, 0.92 },
    WARLOCK = { 0.53, 0.53, 0.93 }, DRUID = { 1, 0.49, 0.04 },
}
function Pinky.ClassColor(token, online)
    local r, g, b = 0.8, 0.8, 0.8
    local c = G.RAID_CLASS_COLORS and token and G.RAID_CLASS_COLORS[token]
    if type(c) == "table" and c.r then r, g, b = c.r, c.g, c.b
    elseif token and CLASS_RGB[token] then r, g, b = CLASS_RGB[token][1], CLASS_RGB[token][2], CLASS_RGB[token][3] end
    if online == false then r, g, b = r * 0.5, g * 0.5, b * 0.5 end
    return r, g, b
end

-- Berufsname fuer den Tooltip
function Pinky.ProfName(id)
    local FWG = G.Freewood and G.Freewood.Guild
    if FWG and FWG.ProfName then
        local ok, n = pcall(FWG.ProfName, id)
        if ok and type(n) == "string" then return n end
    end
    return D.SKILL_CRAFT[tonumber(id) or 0] or tostring(id)
end
-- Schwarzer Hintergrund der Spiel-Icons: "add" (Schwarz wird durchsichtig, Farben leuchten leicht) oder "box"
function Pinky.CraftBlend()
    return DB().craftBlend == "box" and "box" or "add"
end

-- Berufs-Symbol in eine Textur setzen; Rueckgabe true, wenn es eines gibt
function Pinky.SetCraft(t, id)
    local path
    if Pinky.CraftStyle() == "blizzard" then path = Pinky.BLIZZ_CRAFT[tonumber(id) or 0] end
    local blizz = path ~= nil
    path = path or D.CraftBySkill(id)
    t:SetTexture(path)
    -- Spiel-Icons eckig mit beschnittenem Rand (runde Maske verzerrte sie in Forever, 0.2.6)
    if blizz then t:SetTexCoord(0.07, 0.93, 0.07, 0.93) else t:SetTexCoord(0, 1, 0, 1) end
    -- additives Mischen: Schwarz verschwindet, das Motiv bleibt (nur bei Spiel-Icons)
    if t.SetBlendMode then t:SetBlendMode((blizz and Pinky.CraftBlend() == "add") and "ADD" or "BLEND") end
    if path then t:Show() else t:Hide() end
    return path ~= nil
end

local lastReq = -100
function Pinky.RequestRoster()
    local now = G.GetTime and G.GetTime() or 0
    if now - lastReq < 10 then return end
    lastReq = now
    local gi = G.C_GuildInfo
    if gi and gi.GuildRoster then pcall(gi.GuildRoster) elseif G.GuildRoster then pcall(G.GuildRoster) end
end

------------------------------------------------------------------------
-- 3. Hauptfenster
------------------------------------------------------------------------

local f   -- Hauptfenster
local slide

local function Build()
    f = G.CreateFrame("Frame", "FreewoodPinkyFrame", G.UIParent)
    f:SetSize(W, H)
    f:SetFrameStrata("HIGH")
    f:SetFrameLevel(20)
    f:SetClampedToScreen(true)
    -- nur der gemalte Rahmen nimmt Maus an (nicht der durchsichtige Rand)
    local box = D.Pinky.box.pf_frame_main
    if f.SetHitRectInsets then f:SetHitRectInsets(box[1], W - box[3], box[2], H - box[4]) end
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, rp, x, y = self:GetPoint(1)
        DB().pos = { p, rp, x, y }
    end)
    f:Hide()

    local frame = f:CreateTexture(nil, "BACKGROUND")
    frame:SetTexture(D.Tex("pf_frame_main"))
    frame:SetAllPoints(f)

    -- Deko ausserhalb des Rahmens
    local pen = Tex(f, "pf_pennant", "ARTWORK")
    At(pen, f, "pf_pennant", 941, 44)   -- Stange stoesst an den rechten Rahmen, Wimpel haengt aussen
    local pipe = Tex(f, "pf_pipe_bottom", "BACKGROUND", 1, -1)
    At(pipe, f, "pf_pipe_bottom", 300, 480)
    local logo = Tex(f, "pf_logo_gear", "OVERLAY", 0.95)
    At(logo, f, "pf_logo_gear", 860, 410, 0.95)

    -- Titel auf der Platte oben links
    f.title = Font(f, 14, 0.95, 0.82, 0.45)
    f.title:SetPoint("CENTER", f, "TOPLEFT", 265, -44)
    f.title:SetText(L.title)

    -- Schliessen im Loch oben rechts (Mitte etwa 925, 52)
    local close = G.CreateFrame("Button", nil, f)
    close:SetSize(46, 46)
    close:SetPoint("CENTER", f, "TOPLEFT", 921, -51)   -- Mitte des Lochs (gemessen)
    local ct = States(close, { "pf_close_normal", "pf_close_hover", "pf_close_pushed" })
    close:SetScript("OnEnter", function() ct:Set("pf_close_hover") end)
    close:SetScript("OnLeave", function() ct:Set("pf_close_normal") end)
    close:SetScript("OnMouseDown", function() ct:Set("pf_close_pushed") end)
    close:SetScript("OnMouseUp", function() ct:Set("pf_close_hover") end)
    close:SetScript("OnClick", function() f:Hide() end)
    f.close = close

    -- Klassen- und Berufsbilder einmal vorladen (unsichtbar), damit die Detailkarte beim Wechsel nicht blinkt
    local pre = G.CreateFrame("Frame", nil, f)
    pre:SetSize(1, 1)
    pre:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    pre:SetAlpha(0.01)   -- fast unsichtbar, aber gezeichnet: nur so laedt das Spiel die Dateien wirklich (0.2.14)
    for _, group in ipairs({ "class", "craft" }) do
        for _, n in ipairs(D.Pinky.files[group] or {}) do
            local t = pre:CreateTexture(nil, "BACKGROUND")
            t:SetTexture(D.Tex(n))
            t:SetSize(1, 1)
            t:SetPoint("TOPLEFT", pre, "TOPLEFT", 0, 0)
        end
    end
    f.preload = pre

    Pinky.BuildRoster()
    Pinky.BuildList()
    Pinky.BuildCard()
    -- Trenner (Rohr) zwischen Roster und Detailkarte
    local sep = Tex(f, "pf_separator_v", "ARTWORK")
    local _, _, _, _, sw = D.Box("pf_separator_v")
    sep:SetSize(sw * 0.6, IN_B - IN_T + 8)
    sep:SetPoint("TOP", f, "TOPLEFT", SEP_X, -(IN_T - 4))
    f.sep = sep
    Pinky.BuildSlide()

    f:SetScript("OnShow", function()
        Pinky.ApplyScale()
        Pinky.RequestRoster()
        Pinky.Refresh()
    end)
    f:SetScript("OnHide", function()
        if slide then Pinky.SetSlide(false, true) end
    end)
    if G.UISpecialFrames then table.insert(G.UISpecialFrames, "FreewoodPinkyFrame") end
    Pinky.ApplyScale()
    Pinky.ApplyPos()
    Pinky.frame = f
end

-- Faktor fuer die Schrift: unter 90 % gleicht er die Verkleinerung aus, damit der Text lesbar bleibt
function Pinky.FontFactor(s)
    if s >= Pinky.FONT_MIN_SCALE then return 1 end
    return Pinky.FONT_MIN_SCALE / s
end

function Pinky.FrameScale()
    local eff = G.UIParent and G.UIParent.GetEffectiveScale and G.UIParent:GetEffectiveScale() or 1
    if not eff or eff <= 0 then eff = 1 end
    return math.max(0.4, math.min(4, Pinky.SCALE_EFF / eff))
end

function Pinky.ApplyScale()
    local s = Pinky.FrameScale()
    if f then f:SetScale(s) end
    if slide then slide:SetScale(s) end
    fontScale = Pinky.FontFactor(s)
    for _, e in ipairs(fonts) do e[1]:SetFont(FONT, e[2] * fontScale, e[3]) end
    if f and f:IsShown() then Pinky.Refresh() end
end

function Pinky.ApplyPos()
    f:ClearAllPoints()
    local p = DB().pos
    if type(p) == "table" and p[1] then
        f:SetPoint(p[1], G.UIParent, p[2], p[3], p[4])
    else
        f:SetPoint("CENTER", G.UIParent, "CENTER", 0, 40)
    end
end

------------------------------------------------------------------------
-- 4. Roster
------------------------------------------------------------------------

local plates = {}
Pinky.offset = 0
Pinky.selected = nil

local function RowCount()
    local _, _, _, _, _, h = D.Box("pf_row_normal")
    local rowH = h * Pinky.ROW_SCALE + Pinky.ROW_GAP
    return math.max(1, math.floor((IN_B - IN_T - 40) / rowH)), rowH
end
Pinky.RowCount = RowCount

local function Plate(i)
    local p = plates[i]
    if p then return p end
    local s = Pinky.ROW_SCALE
    local _, _, _, _, pw, ph = D.Box("pf_row_normal")
    local _, rowH = RowCount()
    p = G.CreateFrame("Button", nil, f.roster)
    p:SetSize(pw * s, ph * s)
    local x = ROSTER_L + ((ROSTER_R - ROSTER_L) - 30 - pw * s) / 2
    p:SetPoint("TOPLEFT", f, "TOPLEFT", x, -(IN_T + 8 + (i - 1) * rowH))
    p.bg = States(p, { "pf_row_normal", "pf_row_hover", "pf_row_selected" }, "ARTWORK", -1)
    -- Stufen-Knopf links: Porträtring mit Glasscheibe in Klassenfarbe und der Stufe (seit 0.2.9)
    local ks = ph * s * 0.92
    -- Glasscheibe ohne Ring, ganz im Schild (seit 0.2.10)
    local ds = ph * s * Pinky.DISC_SIZE
    p.disc = Tex(p, "pf_disc", "ARTWORK", 1, 1)
    p.disc:SetSize(ds, ds)
    p.disc:SetPoint("LEFT", p, "LEFT", ph * s * 0.16, 0)
    p.lvl = Font(p, 14, 1, 1, 1, nil, "OUTLINE")   -- Umriss: lesbar auch auf hellem Glas (Schurke, Priester)
    p.lvl:SetPoint("CENTER", p.disc, "CENTER", 0, 0)
    p.name = Font(p, 15, 0.45, 0.9, 0.3)
    p.name:SetPoint("LEFT", p.disc, "RIGHT", 6, 0)
    p.name:SetPoint("RIGHT", p, "RIGHT", -Pinky.PROF_INSET, 0)
    p.name:SetHeight(ph * s * 0.8)
    p.name:SetWordWrap(true)                 -- lange Namen in zwei Zeilen statt "..."
    if p.name.SetMaxLines then p.name:SetMaxLines(2) end
    -- Lampe rechts neben dem Schild
    local _, _, _, _, lw, lh = D.Box("pf_lamp_on")
    p.lamp = G.CreateFrame("Frame", nil, f.roster)
    p.lamp:SetSize(lw * 0.3, lh * 0.3)
    p.lamp:SetPoint("LEFT", p, "RIGHT", -3, 0)   -- haengt am Schild (Leuchte)
    p.lamp.st = States(p.lamp, { "pf_lamp_on", "pf_lamp_off" })
    p:SetScript("OnEnter", function(self)
        if self.e and Pinky.selected ~= self.e.full then Swap(self.bg, "pf_row_hover") end
        if self.e then Pinky.ShowTip(self, self.e) end
    end)
    p:SetScript("OnLeave", function(self)
        if self.e and Pinky.selected ~= self.e.full then Swap(self.bg, "pf_row_normal") end
        if G.GameTooltip then G.GameTooltip:Hide() end
    end)
    p:SetScript("OnClick", function(self)
        if self.e then Pinky.Select(self.e.full) end
    end)
    plates[i] = p
    return p
end

function Pinky.BuildRoster()
    f.roster = G.CreateFrame("Frame", nil, f)
    f.roster:SetAllPoints(f)
    f.roster:SetFrameLevel(f:GetFrameLevel() + 2)
    -- Schienen hinter den Schildern
    local _, _, _, _, rw, rh = D.Box("pf_rail_left")
    -- Schienen: von der inneren Rahmenkante oben bis an die Scroll-Knoepfe unten
    local _, _, _, _, _, arrowH = D.Box("pf_scroll_down")
    local railTop = IN_T - 4
    local railH = (IN_B - 4 - arrowH + 4) - railTop
    local rs = railH / rh
    local _, _, _, _, pw = D.Box("pf_row_normal")
    local plateW = pw * Pinky.ROW_SCALE
    local plateX = ROSTER_L + ((ROSTER_R - ROSTER_L) - 30 - plateW) / 2
    for k, name in ipairs({ "pf_rail_left", "pf_rail_right" }) do
        local t = Tex(f.roster, name, "BACKGROUND", rs)
        t:SetWidth(rw * 0.9)
        local x = plateX + plateW * (k == 1 and 0.3 or 0.7) - rw * 0.45
        t:SetPoint("TOPLEFT", f, "TOPLEFT", x, -railTop)
        t:SetHeight(railH)
        f.roster["rail" .. k] = t
    end
    -- Scroll-Pfeile unten (runter links, hoch rechts wie im Entwurf)
    local function Arrow(name, dx, step)
        local b = G.CreateFrame("Button", nil, f)
        b:SetFrameLevel(f:GetFrameLevel() + 6)
        local _, _, _, _, aw, ah = D.Box(name)
        b:SetSize(aw, ah)
        b:SetPoint("BOTTOM", f, "TOPLEFT", plateX + plateW / 2 + dx, -(IN_B - 4))
        b.t = b:CreateTexture(nil, "ARTWORK")
        b.t:SetAllPoints(b)
        b.t:SetTexture(D.Tex(name))
        TC(b.t, name)
        Bright(b.t, "normal")
        b:SetScript("OnEnter", function(self) if self:IsEnabled() then Bright(self.t, "hover") end end)
        b:SetScript("OnLeave", function(self) Bright(self.t, self:IsEnabled() and "normal" or "disabled") end)
        b:SetScript("OnMouseDown", function(self) if self:IsEnabled() then Bright(self.t, "pushed") end end)
        b:SetScript("OnMouseUp", function(self) if self:IsEnabled() then Bright(self.t, "hover") end end)
        b:SetScript("OnClick", function() Pinky.Scroll(step) end)
        return b
    end
    f.down = Arrow("pf_scroll_down", -50, 1)
    f.up = Arrow("pf_scroll_up", 50, -1)
    -- Listenansicht-Hebel unten links
    local lv = G.CreateFrame("Button", nil, f)
    lv:SetSize(44, 50)
    lv:SetPoint("BOTTOMLEFT", f, "TOPLEFT", IN_L + 88, -(IN_B + 50))   -- im unteren Rahmen, links vom Handrad
    lv:SetFrameLevel(f:GetFrameLevel() + 6)
    lv.t = States(lv, { "pf_listmode_off", "pf_listmode_off_hover", "pf_listmode_on", "pf_listmode_on_hover" })
    local function LeverTex(hover)
        lv.t:Set("pf_listmode_" .. (DB().listMode and "on" or "off") .. (hover and "_hover" or ""))
    end
    lv.Update = LeverTex
    lv:SetScript("OnEnter", function(self)
        LeverTex(true)
        if G.GameTooltip then
            G.GameTooltip:SetOwner(self, "ANCHOR_TOP")
            G.GameTooltip:SetText(L.listmode)
            G.GameTooltip:Show()
        end
    end)
    lv:SetScript("OnLeave", function() LeverTex(false) if G.GameTooltip then G.GameTooltip:Hide() end end)
    lv:SetScript("OnClick", function()
        DB().listMode = not DB().listMode
        LeverTex(true)
        Pinky.offset = 0
        Pinky.Refresh()
    end)
    LeverTex(false)
    f.lever = lv
    -- Mausrad ueber dem Roster-Bereich
    local wheel = G.CreateFrame("Frame", nil, f)
    wheel:SetPoint("TOPLEFT", f, "TOPLEFT", ROSTER_L - 10, -IN_T)
    wheel:SetPoint("BOTTOMRIGHT", f, "TOPLEFT", ROSTER_R, -IN_B)
    wheel:SetFrameLevel(f:GetFrameLevel() + 1)
    wheel:EnableMouseWheel(true)
    wheel:SetScript("OnMouseWheel", function(_, delta) Pinky.Scroll(delta > 0 and -1 or 1) end)
    f.status = Font(f, 13, 0.85, 0.8, 0.7)
    f.status:SetPoint("CENTER", f, "TOPLEFT", (ROSTER_L + ROSTER_R) / 2, -((IN_T + IN_B) / 2))
end

function Pinky.Visible()
    if DB().listMode then return Pinky.ListCount() end
    return (RowCount())
end

function Pinky.Scroll(step)
    local maxOff = math.max(0, #Pinky.rows - Pinky.Visible())
    local o = math.max(0, math.min(maxOff, Pinky.offset + step))
    if o ~= Pinky.offset then
        Pinky.offset = o
        Pinky.Refresh()
    end
end

-- Tooltip eines Schilds: Name in Klassenfarbe, Stufe und Klasse, Rang, Gebiet oder offline, Berufe
function Pinky.ShowTip(owner, e)
    local tt = G.GameTooltip
    if not tt then return end
    tt:SetOwner(owner, "ANCHOR_RIGHT")
    tt:SetText(e.name, Pinky.ClassColor(e.class, true))
    tt:AddLine(string.format("%s %d %s", L.level, e.level or 0, e.className or ""), 1, 1, 1)
    if e.rank ~= "" then tt:AddLine(e.rank, 0.45, 0.9, 0.3) end
    tt:AddLine(e.online and e.zone or L.offline, 0.8, 0.8, 0.8)
    local profs = {}
    if e.prof1 then profs[#profs + 1] = Pinky.ProfName(e.prof1) end
    if e.prof2 then profs[#profs + 1] = Pinky.ProfName(e.prof2) end
    if #profs > 0 then tt:AddLine(table.concat(profs, ", "), 1, 0.82, 0.4) end
    tt:Show()
end

local function SetArrow(b, on)
    if on then b:Enable() Bright(b.t, "normal") else b:Disable() Bright(b.t, "disabled") end
end

function Pinky.RefreshRoster()
    local show = not DB().listMode
    if show then f.roster:Show() else f.roster:Hide() end
    local n = RowCount()
    for i = 1, math.max(n, #plates) do
        local p = Plate(i)
        local e = show and i <= n and Pinky.rows[Pinky.offset + i] or nil
        p.e = e
        if e then
            p.name:SetText(e.name)
            p.name:SetTextColor(Pinky.ClassColor(e.class, e.online))
            local r, g, b = Pinky.ClassColor(e.class, e.online)
            p.disc:SetVertexColor(r, g, b)
            p.lvl:SetText(e.level > 0 and e.level or "?")
            if e.online then p.lvl:SetTextColor(1, 1, 1) else p.lvl:SetTextColor(0.75, 0.75, 0.75) end
            p.lamp.st:Set(e.online and "pf_lamp_on" or "pf_lamp_off")
            Swap(p.bg, Pinky.selected == e.full and "pf_row_selected" or "pf_row_normal")
            p:Show()
            p.lamp:Show()
        else
            p:Hide()
            p.lamp:Hide()
        end
    end
end

------------------------------------------------------------------------
-- 5. Listenansicht
------------------------------------------------------------------------

local lines = {}
local COLS = { { "name", 0.36, "LEFT", "colName" }, { "level", 0.1, "CENTER", "colLevel" },
    { "className", 0.18, "LEFT", "colClass" }, { "rank", 0.18, "LEFT", "colRank" }, { "zone", 0.18, "LEFT", "colZone" } }
local LIST_L, LIST_R = ROSTER_L - 6, ROSTER_R - 8
local LIST_T = IN_T + 22   -- Kopfzeile unterhalb der inneren Rahmenkante

function Pinky.ListCount()
    return math.max(1, math.floor((IN_B - LIST_T - 24 - 40) / Pinky.LIST_ROW_H))
end

local function Rect(parent, layer, r, g, b, a)
    local t = parent:CreateTexture(nil, layer or "BACKGROUND")
    t:SetColorTexture(r, g, b, a)
    return t
end

function Pinky.BuildList()
    local lf = G.CreateFrame("Frame", nil, f)
    lf:SetAllPoints(f)
    lf:SetFrameLevel(f:GetFrameLevel() + 2)
    lf:Hide()
    f.list = lf
    local width = LIST_R - LIST_L
    -- Kopfzeile: Messingleiste
    local head = Rect(lf, "ARTWORK", 0.55, 0.38, 0.16, 0.9)
    head:SetPoint("TOPLEFT", f, "TOPLEFT", LIST_L, -LIST_T)
    head:SetSize(width, 22)
    local line = Rect(lf, "ARTWORK", 0.85, 0.66, 0.3, 1)
    line:SetPoint("TOPLEFT", head, "BOTTOMLEFT", 0, 0)
    line:SetSize(width, 1)
    local x = 6
    lf.heads = {}
    for _, c in ipairs(COLS) do
        local hb = G.CreateFrame("Button", nil, lf)
        hb:SetSize(width * c[2], 22)
        hb:SetPoint("TOPLEFT", f, "TOPLEFT", LIST_L + x - 6, -LIST_T)
        local fs = Font(hb, 12, 1, 0.9, 0.65, c[3])
        fs:SetPoint("LEFT", hb, "LEFT", 6, 0)
        fs:SetWidth(width * c[2] - 18)
        fs:SetText(L[c[4]])
        hb.fs = fs
        -- Richtungspfeil aus den Scroll-Pfeilen (klein)
        hb.arrow = G.CreateFrame("Frame", nil, hb)
        hb.arrow:SetSize(14, 6)
        hb.arrow:SetPoint("RIGHT", hb, "RIGHT", -2, 0)
        hb.arrow.st = States(hb.arrow, { "pf_scroll_up", "pf_scroll_down" }, "OVERLAY")
        hb.arrow:Hide()
        hb.key = c[1]
        hb:SetScript("OnEnter", function(self) self.fs:SetTextColor(1, 1, 1) end)
        hb:SetScript("OnLeave", function(self) Pinky.UpdateHeads() end)
        hb:SetScript("OnClick", function(self) Pinky.SetSort(self.key) end)
        lf.heads[#lf.heads + 1] = hb
        x = x + width * c[2]
    end
    lf.head = head
    -- Bildlauf mit Mausrad und den Pfeilen (die Pfeile bleiben im Roster-Bereich, Kopien hier)
    lf:EnableMouseWheel(true)
    lf:SetScript("OnMouseWheel", function(_, delta) Pinky.Scroll(delta > 0 and -3 or 3) end)
    lf.count = Font(lf, 11, 0.8, 0.75, 0.65, "RIGHT")
    lf.count:SetPoint("BOTTOMRIGHT", f, "TOPLEFT", LIST_R, -(IN_B - 6))
end

local function Line(i)
    local r = lines[i]
    if r then return r end
    local lf = f.list
    local width = LIST_R - LIST_L
    r = G.CreateFrame("Button", nil, lf)
    r:SetSize(width, Pinky.LIST_ROW_H)
    r:SetPoint("TOPLEFT", f, "TOPLEFT", LIST_L, -(LIST_T + 24 + (i - 1) * Pinky.LIST_ROW_H))
    r.alt = Rect(r, "BACKGROUND", 0.45, 0.3, 0.15, i % 2 == 0 and 0.18 or 0)
    r.alt:SetAllPoints(r)
    r.hl = Rect(r, "ARTWORK", 0.85, 0.66, 0.3, 0.22)
    r.hl:SetAllPoints(r)
    r.hl:Hide()
    r.sel = Rect(r, "ARTWORK", 0.95, 0.7, 0.25, 0.38)
    r.sel:SetAllPoints(r)
    r.sel:Hide()
    r.dot = Rect(r, "OVERLAY", 0.4, 0.9, 0.3, 1)
    r.dot:SetSize(6, 6)
    r.dot:SetPoint("LEFT", r, "LEFT", 2, 0)
    r.cells = {}
    local x = 12
    for k, c in ipairs(COLS) do
        local fs = Font(r, 12, 0.92, 0.88, 0.8, c[3])
        fs:SetPoint("LEFT", r, "LEFT", x, 0)
        fs:SetWidth(width * c[2] - (k == 1 and 12 or 6))
        fs:SetWordWrap(false)
        r.cells[k] = fs
        x = x + width * c[2] - (k == 1 and 6 or 0)
    end
    r:SetScript("OnEnter", function(self) self.hl:Show() end)
    r:SetScript("OnLeave", function(self) self.hl:Hide() end)
    r:SetScript("OnClick", function(self) if self.e then Pinky.Select(self.e.full) end end)
    lines[i] = r
    return r
end

function Pinky.UpdateHeads()
    if not (f and f.list and f.list.heads) then return end
    local key, asc = DB().sortKey, DB().sortAsc ~= false
    for _, hb in ipairs(f.list.heads) do
        if hb.key == key then
            hb.arrow.st:Set(asc and "pf_scroll_up" or "pf_scroll_down")
            hb.arrow:Show()
            hb.fs:SetTextColor(1, 0.95, 0.75)
        else
            hb.arrow:Hide()
            hb.fs:SetTextColor(1, 0.9, 0.65)
        end
    end
end

function Pinky.RefreshList()
    Pinky.UpdateHeads()
    local show = DB().listMode
    if show then f.list:Show() else f.list:Hide() return end
    local n = Pinky.ListCount()
    for i = 1, math.max(n, #lines) do
        local r = Line(i)
        local e = i <= n and Pinky.rows[Pinky.offset + i] or nil
        r.e = e
        if e then
            r.cells[1]:SetText(e.name)
            r.cells[2]:SetText(e.level > 0 and e.level or "")
            r.cells[3]:SetText(e.className)
            r.cells[4]:SetText(e.rank)
            r.cells[5]:SetText(e.zone)
            local c = e.online and 0.92 or 0.55
            for k = 1, #r.cells do r.cells[k]:SetTextColor(c, c * 0.96, c * 0.87) end
            r.cells[1]:SetTextColor(Pinky.ClassColor(e.class, e.online))
            r.dot:SetColorTexture(e.online and 0.4 or 0.6, e.online and 0.9 or 0.15, e.online and 0.3 or 0.1, 1)
            if Pinky.selected == e.full then r.sel:Show() else r.sel:Hide() end
            r:Show()
        else
            r:Hide()
        end
    end
    local on = 0
    for _, e in ipairs(Pinky.rows) do if e.online then on = on + 1 end end
    f.list.count:SetText(string.format("%d / %d %s", on, #Pinky.rows, L.online))
end

------------------------------------------------------------------------
-- 6. Detailkarte
------------------------------------------------------------------------

function Pinky.BuildCard()
    local c = G.CreateFrame("Frame", nil, f)
    c:SetAllPoints(f)
    c:SetFrameLevel(f:GetFrameLevel() + 3)
    f.card = c
    local t = Tex(c, "pf_card", "BACKGROUND")
    At(t, f, "pf_card", CARD_X, CARD_Y)
    local b = D.Pinky.box.pf_card
    -- Innenflaeche der Karte (zwischen den Zierleisten): etwa x 50..206, y 120..392 des Kartenbildes
    local L0, T0, R0 = CARD_X + 58, CARD_Y + b[2] + 10, CARD_X + 198
    local w = R0 - L0
    c.name = Font(c, 14, 0.45, 0.9, 0.3)
    c.name:SetPoint("TOP", f, "TOPLEFT", L0 + w / 2, -T0)
    c.name:SetWidth(w)
    c.name:SetWordWrap(true)
    -- Klassen-Icon und Stufe nebeneinander
    c.class = c:CreateTexture(nil, "OVERLAY")
    c.class:SetSize(62, 62)
    c.class:SetPoint("TOP", c.name, "BOTTOM", 0, -3)
    c.level = Font(c, 26, 1, 1, 1)
    c.level:SetPoint("TOP", c.class, "BOTTOM", 0, -1)
    c.rank = Font(c, 11, 0.45, 0.9, 0.3)
    c.rank:SetPoint("TOP", c.level, "BOTTOM", 0, -1)
    c.rank:SetWidth(w)
    c.zone = Font(c, 10, 0.8, 0.75, 0.65)
    c.zone:SetWidth(w)
    c.zone:SetPoint("TOP", c.rank, "BOTTOM", 0, -2)
    -- Notizfelder (gezeichnet)
    local function Field(label)
        local box = Rect(c, "ARTWORK", 0.1, 0.05, 0.02, 0.85)
        box:SetSize(w, 10)
        local edge = Rect(c, "ARTWORK", 0.55, 0.38, 0.16, 0.9)
        edge:SetPoint("BOTTOMLEFT", box, "TOPLEFT", 0, 0)
        edge:SetSize(w, 1)
        local lab = Font(c, 10, 0.85, 0.72, 0.45, "LEFT")
        lab:SetPoint("TOPLEFT", box, "TOPLEFT", 4, -3)
        lab:SetText(label)
        local txt = Font(c, 11, 0.95, 0.92, 0.85, "LEFT")
        txt:SetPoint("TOPLEFT", lab, "BOTTOMLEFT", 0, -2)
        txt:SetWidth(w - 8)
        txt:SetJustifyV("TOP")
        txt:SetWordWrap(true)
        return { box = box, edge = edge, lab = lab, txt = txt }
    end
    c.note = Field(L.note .. ":")
    c.onote = Field(L.onote .. ":")
    c.note.box:SetPoint("TOP", c.zone, "BOTTOM", 0, -6)
    c.onote.box:SetPoint("TOP", c.note.box, "BOTTOM", 0, -6)
    c.prof1 = c:CreateTexture(nil, "OVERLAY")
    c.prof2 = c:CreateTexture(nil, "OVERLAY")
    c.prof1:SetSize(Pinky.CARD_PROF, Pinky.CARD_PROF)
    c.prof2:SetSize(Pinky.CARD_PROF, Pinky.CARD_PROF)
    c.prof1:SetPoint("BOTTOMRIGHT", f, "TOPLEFT", L0 + w / 2 - 4, -(CARD_Y + b[4] - 10))
    c.prof2:SetPoint("BOTTOMLEFT", f, "TOPLEFT", L0 + w / 2 + 4, -(CARD_Y + b[4] - 10))
end

local function FieldHeight(fd, text)
    fd.txt:SetText(text ~= "" and text or "-")
    local h = (fd.txt.GetStringHeight and fd.txt:GetStringHeight() or 12) + 20
    fd.box:SetHeight(math.max(28, math.min(fd.maxH or 40, h)))
end

function Pinky.Select(full)
    Pinky.selected = full
    Pinky.Refresh()
end

function Pinky.RefreshCard()
    local c = f.card
    local e
    for _, r in ipairs(Pinky.rows) do if r.full == Pinky.selected then e = r break end end
    if not e then e = Pinky.rows[1] if e then Pinky.selected = e.full end end
    local parts = { c.name, c.class, c.level, c.rank, c.zone, c.prof1, c.prof2 }
    local fields = { c.note, c.onote }
    if not e then
        for _, p in ipairs(parts) do p:Hide() end
        for _, fd in ipairs(fields) do fd.box:Hide() fd.edge:Hide() fd.lab:Hide() fd.txt:Hide() end
        return
    end
    for _, p in ipairs(parts) do p:Show() end
    c.name:SetText(e.name)
    c.name:SetTextColor(Pinky.ClassColor(e.class, e.online))
    c.class:SetTexture(D.ClassTex(e.class) or "Interface\\Icons\\INV_Misc_QuestionMark")
    c.class:SetDesaturated(not e.online)
    c.level:SetText(e.level > 0 and e.level or "?")
    c.rank:SetText(e.rank)
    c.zone:SetText(e.online and e.zone or L.offline)
    local officer = Pinky.CanOfficerNote()
    for k, fd in ipairs(fields) do
        local on = k == 1 or officer
        for _, p in ipairs({ fd.box, fd.edge, fd.lab, fd.txt }) do if on then p:Show() else p:Hide() end end
    end
    -- Mit Offiziersnotiz wird es eng: Felder flacher, Berufe etwas kleiner
    c.note.maxH = officer and 28 or 36
    c.onote.maxH = 26
    FieldHeight(c.note, e.note)
    if officer then FieldHeight(c.onote, e.onote) end
    local ps = officer and Pinky.CARD_PROF_SMALL or Pinky.CARD_PROF
    c.prof1:SetSize(ps, ps)
    c.prof2:SetSize(ps, ps)
    Pinky.SetCraft(c.prof1, e.prof1)
    Pinky.SetCraft(c.prof2, e.prof2)
end

------------------------------------------------------------------------
-- 7. Slideout
------------------------------------------------------------------------

Pinky.slideOpen = false
local anim  -- { from, to, t }

local function SlideX(x)
    slide:ClearAllPoints()
    slide:SetPoint("TOPLEFT", f, "TOPLEFT", x, 0)
    slide.x = x
end

function Pinky.BuildSlide()
    -- Eigener Rahmen unter dem Hauptfenster (gleiche Schicht, niedrigere Ebene): faehrt hinter dem Rahmen heraus
    slide = G.CreateFrame("Frame", "FreewoodPinkySlide", G.UIParent)
    slide:SetSize(512, 512)
    slide:SetFrameStrata("HIGH")
    slide:SetFrameLevel(5)
    local box = D.Pinky.box.pf_frame_slide
    if slide.SetHitRectInsets then slide:SetHitRectInsets(box[1], 512 - box[3], box[2], 512 - box[4]) end
    slide:EnableMouse(true)
    local t = slide:CreateTexture(nil, "BACKGROUND")
    t:SetTexture(D.Tex("pf_frame_slide"))
    t:SetAllPoints(slide)
    slide.soon = Font(slide, 12, 0.85, 0.78, 0.6)
    slide.soon:SetPoint("CENTER", slide, "TOPLEFT", (box[1] + 434) / 2, -256)
    slide.soon:SetText(L.slideSoon)
    slide:Hide()
    SlideX(SLIDE_CLOSED_X)
    Pinky.slide = slide

    -- Knopf am Slideout (ist im Bild; unsichtbare Flaeche darueber mit hover/gedrueckt-Bild)
    local function SlideButton(parent, x, onClick, level)
        local b = G.CreateFrame("Button", nil, parent)
        local bb = D.Pinky.box.pf_slide_btn_normal
        b:SetSize(bb[3] - bb[1], bb[4] - bb[2])
        b:SetPoint("TOPLEFT", parent, "TOPLEFT", x + bb[1], -bb[2])
        b:SetFrameLevel(level)
        b.t = States(b, { "pf_slide_btn_normal", "pf_slide_btn_hover", "pf_slide_btn_pushed" })
        b:SetScript("OnEnter", function(self) Swap(self.t, "pf_slide_btn_hover") end)
        b:SetScript("OnLeave", function(self) Swap(self.t, "pf_slide_btn_normal") end)
        b:SetScript("OnMouseDown", function(self) Swap(self.t, "pf_slide_btn_pushed") end)
        b:SetScript("OnMouseUp", function(self) Swap(self.t, "pf_slide_btn_hover") end)
        b:SetScript("OnClick", onClick)
        return b
    end
    f.slideBtn = SlideButton(f, SLIDE_BTN_X, function() Pinky.SetSlide(true) end, f:GetFrameLevel() + 8)
    slide.btn = SlideButton(slide, 434, function() Pinky.SetSlide(false) end, slide:GetFrameLevel() + 4)

    slide:SetScript("OnUpdate", function(self, elapsed)
        if not anim then return end
        anim.t = anim.t + (elapsed or 0)
        local k = math.min(1, anim.t / SLIDE_SECS)
        local e = 1 - (1 - k) * (1 - k) * (1 - k)   -- weich auslaufen
        SlideX(anim.from + (anim.to - anim.from) * e)
        if k >= 1 then
            local opened = anim.to == SLIDE_OPEN_X
            anim = nil
            if not opened then
                self:Hide()
                f.slideBtn:Show()
            end
        end
    end)
end

-- open: true/false; instant: ohne Bewegung
function Pinky.SetSlide(open, instant)
    if not slide then return end
    Pinky.slideOpen = open and true or false
    DB().slideOpen = Pinky.slideOpen
    local from = slide:IsShown() and (slide.x or SLIDE_CLOSED_X) or SLIDE_CLOSED_X
    local to = open and SLIDE_OPEN_X or SLIDE_CLOSED_X
    if open then
        f.slideBtn:Hide()     -- das Slideout traegt denselben Knopf (wirkt verschmolzen)
        slide:Show()
    end
    if instant then
        anim = nil
        SlideX(to)
        if not open then slide:Hide() f.slideBtn:Show() end
        return
    end
    anim = { from = from, to = to, t = 0 }
end

------------------------------------------------------------------------
-- Gesamt
------------------------------------------------------------------------

function Pinky.Refresh()
    if not f or not f:IsShown() then return end
    Pinky.ReadRoster()
    local maxOff = math.max(0, #Pinky.rows - Pinky.Visible())
    if Pinky.offset > maxOff then Pinky.offset = maxOff end
    if f.lever and f.lever.Update then f.lever.Update(false) end
    SetArrow(f.up, Pinky.offset > 0)
    SetArrow(f.down, Pinky.offset < maxOff)
    Pinky.RefreshRoster()
    Pinky.RefreshList()
    Pinky.RefreshCard()
    if #Pinky.rows == 0 then
        f.status:SetText((G.IsInGuild and G.IsInGuild()) and L.loading or L.noGuild)
        f.status:Show()
    else
        f.status:Hide()
    end
end

function Pinky.Toggle()
    if not f then Build() end
    if f:IsShown() then f:Hide() else f:Show() end
end

------------------------------------------------------------------------
-- 8. Ereignisse und Befehl
------------------------------------------------------------------------

local ev = G.CreateFrame("Frame")
ev:RegisterEvent("GUILD_ROSTER_UPDATE")
ev:RegisterEvent("PLAYER_GUILD_UPDATE")
ev:RegisterEvent("UI_SCALE_CHANGED")
ev:RegisterEvent("DISPLAY_SIZE_CHANGED")
local pending = false
ev:SetScript("OnEvent", function(_, event)
    if event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
        if f then Pinky.ApplyScale() end
        return
    end
    if not f or not f:IsShown() or pending then return end
    pending = true
    local function Go() pending = false Pinky.Refresh() end
    if G.C_Timer and G.C_Timer.After then G.C_Timer.After(0.5, Go) else Go() end
end)

G.SLASH_FWPINKY1 = "/fwpinky"
G.SlashCmdList = G.SlashCmdList or {}
G.SlashCmdList["FWPINKY"] = function(msg)
    msg = tostring(msg or ""):lower()
    local cmd, arg = msg:match("^%s*(%S*)%s*(.-)%s*$")
    if cmd == "icons" or cmd == "symbole" then
        if arg == "kasten" or arg == "box" then
            DB().craftIcons, DB().craftBlend = "blizzard", "box"
        elseif arg == "pinky" then
            DB().craftIcons = "pinky"
        else
            DB().craftIcons, DB().craftBlend = "blizzard", "add"
        end
        Say(string.format(L.iconsSet, DB().craftIcons .. (DB().craftIcons == "blizzard" and (" / " .. Pinky.CraftBlend()) or "")))
        if f then Pinky.Refresh() end
    elseif cmd == "reset" then
        DB().pos = nil
        if f then Pinky.ApplyPos() end
        Say(L.reset)
    elseif cmd == "help" or cmd == "hilfe" then
        Say(L.help)
    else
        Pinky.Toggle()
    end
end
