-- Test: Pinky-Probefenster mit Attrappen (Gildenliste, Roster, Liste, Karte, Slideout)   texlua tests/pinky_test.lua
local fails, n = 0, 0
local function eq(a, b, m) n = n + 1 if a ~= b then fails = fails + 1 print("FEHLER " .. m, tostring(a), tostring(b)) end end

-- Rahmen-Attrappe: merkt Sichtbarkeit, Texte, Texturen, Skripte, Punkte; andere Methoden tun nichts
local function Mock(kind)
    local o = { shown = true, scripts = {}, points = {}, level = 1, enabled = true, kind = kind }
    return setmetatable(o, { __index = function(t, k)
        local m = {
            Show = function(s) s.shown = true end, Hide = function(s) s.shown = false end,
            IsShown = function(s) return s.shown end, IsVisible = function(s) return s.shown end,
            SetText = function(s, v) s.text = v end, GetText = function(s) return s.text end,
            SetTexture = function(s, v) s.tex = v end,
            SetScript = function(s, e, f) s.scripts[e] = f end, GetScript = function(s, e) return s.scripts[e] end,
            SetPoint = function(s, ...) s.points[#s.points + 1] = { ... } end,
            ClearAllPoints = function(s) s.points = {} end,
            SetFrameLevel = function(s, v) s.level = v end, GetFrameLevel = function(s) return s.level end,
            Enable = function(s) s.enabled = true end, Disable = function(s) s.enabled = false end,
            IsEnabled = function(s) return s.enabled end,
            CreateTexture = function() return Mock("tex") end, CreateFontString = function() return Mock("fs") end,
            GetStringHeight = function() return 12 end,
            GetPoint = function(s) local p = s.points[1] or {} return p[1], p[2], p[3], p[4], p[5] end,
        }
        if m[k] then return m[k] end
        if type(k) == "string" and k:find("^%u") then return function() return nil end end
        return nil
    end })
end
_G.UIParent = Mock("frame")
_G.UISpecialFrames = {}
_G.CreateFrame = function(kind) return Mock(kind) end
_G.GetLocale = function() return "deDE" end
_G.GetTime = function() return 100 end
local timers = {}
_G.C_Timer = { After = function(_, fn) timers[#timers + 1] = fn end }
local chat = {}
_G.DEFAULT_CHAT_FRAME = { AddMessage = function(_, t) chat[#chat + 1] = t end }

-- Gilde: Vor- und Nachname, Realm-Endung, offline/online, Offiziersnotiz
local roster = {
    { "Pinky Freewood-Realm", "Ober-Affe", 0, 60, "Schurke", "Orgrimmar", "Chef", "geheim", true, 0, "ROGUE" },
    { "Dr Freewood-Realm", "Affe", 2, 45, "Druide", "Mulgore", "", "", false, 0, "DRUID" },
    { "Aroki Silberrücken", "Affe", 2, 33, "Jäger", "Brachland", "Bogen", "", true, 0, "HUNTER" },
    { "Zed Zack", "Neuling", 3, 12, "Magier", "Durotar", "", "", true, 0, "MAGE" },
    { "Anna Bell-Lang", "Neuling", 3, 8, "Priester", "Tirisfal", "", "", false, 0, "PRIEST" },
}
local officer = false
_G.IsInGuild = function() return true end
_G.GetNumGuildMembers = function() return #roster end
_G.GetGuildRosterInfo = function(i) return unpack(roster[i]) end
local requested = 0
_G.C_GuildInfo = { GuildRoster = function() requested = requested + 1 end, CanViewOfficerNote = function() return officer end }
-- Gilden-Modul mit geteilten Berufen
_G.Freewood = { Guild = {
    Shared = function(name) if name == "Pinky Freewood-Realm" then return { skills = { [165] = {}, [393] = {} } } end end,
    MainProfs = function(sk) local a = {} for id in pairs(sk or {}) do a[#a + 1] = id end table.sort(a) return a[1], a[2] end,
} }
_G.SlashCmdList = {}

assert(loadfile("Design.lua"))()
assert(loadfile("Pinky.lua"))("Freewood-Design")
local P = FreewoodPinky
eq(type(P), "table", "Pinky geladen")

-- 1. Gildenliste
local rows = P.ReadRoster()
eq(#rows, 5, "fuenf Mitglieder")
eq(rows[1].name, "Pinky Freewood", "online und Rang zuerst, Realm weg")
eq(rows[2].name, "Aroki Silberrücken", "zweiter online")
eq(rows[3].name, "Zed Zack", "dritter online")
eq(rows[4].online, false, "offline danach")
eq(P.Display("Anna Bell-Lang"), "Anna Bell", "Realm-Endung ohne Leerzeichen wird abgeschnitten (bekannte Grenze)")
eq(P.Display("Zed Zack"), "Zed Zack", "ohne Realm bleibt")
eq(rows[1].prof1, 165, "Beruf 1 aus dem Gilden-Modul")
eq(rows[1].prof2, 393, "Beruf 2")
eq(FreewoodDesign.CraftBySkill(165) ~= nil, true, "Berufstextur Lederverarbeitung")

-- 2. Fenster
SlashCmdList.FWPINKY("")
local f = P.frame
assert(f, "Fenster gebaut")
f.scripts.OnShow(f)
eq(requested, 1, "Gildenliste angefragt")
eq(f:IsShown(), true, "Fenster offen")
local visible = P.RowCount()
eq(visible >= 3, true, "mindestens drei Schilder: " .. visible)
eq(f.roster:IsShown(), true, "Roster sichtbar")
eq(f.list:IsShown(), false, "Liste aus")
eq(f.up.enabled, false, "oben: hoch gesperrt")
eq(f.down.enabled, #rows > visible, "runter nur, wenn mehr Mitglieder")

-- 3. Karte: erstes Mitglied, Offiziersnotiz nur fuer Offiziere
eq(P.selected, "Pinky Freewood-Realm", "erstes Mitglied gewaehlt")
eq(f.card.name.text, "Pinky Freewood", "Name auf der Karte")
eq(f.card.rank.text, "Ober-Affe", "Rangname")
eq(f.card.note.txt.text, "Chef", "oeffentliche Notiz")
eq(f.card.onote.box.shown, false, "Offiziersnotiz versteckt")
officer = true
P.Refresh()
eq(f.card.onote.box.shown, true, "Offiziersnotiz fuer Offiziere")
eq(f.card.onote.txt.text, "geheim", "Offiziersnotiz Text")
P.Select("Dr Freewood-Realm")
eq(f.card.zone.text, P.L.offline, "offline statt Gebiet")
eq(f.card.note.txt.text, "-", "leere Notiz")

-- 4. Scrollen
P.Scroll(1)
eq(P.offset, math.min(1, #rows - visible), "eine Zeile weiter")
P.Scroll(-5)
eq(P.offset, 0, "nicht ueber den Anfang")

-- 5. Listenansicht per Hebel
f.lever.scripts.OnClick(f.lever)
eq(FreewoodDesignDB.pinky.listMode, true, "Listenansicht gemerkt")
eq(f.list:IsShown(), true, "Liste an")
eq(f.roster:IsShown(), false, "Schilder und Schienen weg")
eq(f.list.count.text, "3 / 5 online", "Zaehler")
-- Sortieren per Klick auf die Spaltenueberschrift
local heads = f.list.heads
eq(#heads, 5, "fuenf Spalten")
heads[2].scripts.OnClick(heads[2])   -- Stufe
eq(FreewoodDesignDB.pinky.sortKey, "level", "nach Stufe")
eq(P.rows[1].level, 8, "aufsteigend: kleinste Stufe zuerst")
eq(heads[2].arrow.shown, true, "Pfeil an der Spalte")
heads[2].scripts.OnClick(heads[2])
eq(P.rows[1].level, 60, "zweiter Klick: absteigend")
heads[1].scripts.OnClick(heads[1])   -- Name
eq(P.rows[1].name, "Anna Bell", "nach Name aufsteigend")
eq(heads[2].arrow.shown, false, "Pfeil gewechselt")
heads[4].scripts.OnClick(heads[4])   -- Rang
eq(P.rows[1].rankIndex, 0, "nach Rang: Ober-Affe zuerst")
f.lever.scripts.OnClick(f.lever)
eq(f.roster:IsShown(), true, "zurueck zum Roster")
eq(P.rows[1].name, "Pinky Freewood", "Roster bleibt: online, Rang, Name")

-- 6. Slideout: Knopf am Rahmen verschwindet, Fenster faehrt heraus, zurueck
local slide = P.slide
eq(slide:IsShown(), false, "Slideout zu")
f.slideBtn.scripts.OnClick(f.slideBtn)
eq(f.slideBtn:IsShown(), false, "Rahmen-Knopf weg (verschmolzen)")
eq(slide:IsShown(), true, "Slideout sichtbar")
for _ = 1, 10 do slide.scripts.OnUpdate(slide, 0.05) end
eq(slide.x, 880, "ganz offen")
slide.btn.scripts.OnClick(slide.btn)
slide.scripts.OnUpdate(slide, 0.1)
eq(slide.x > 440 and slide.x < 880, true, "faehrt zurueck: " .. tostring(slide.x))
for _ = 1, 10 do slide.scripts.OnUpdate(slide, 0.05) end
eq(slide:IsShown(), false, "zu")
eq(f.slideBtn:IsShown(), true, "Rahmen-Knopf wieder da")
-- Fenster schliessen klappt das Slideout sofort ein
P.SetSlide(true)
f.scripts.OnHide(f)
eq(slide:IsShown(), false, "mit dem Fenster zu")

-- Berufs-Symbole: Standard eigene Bilder (nur auf der Karte), umschaltbar
eq(P.CraftStyle(), "pinky", "Standard eigene Bilder")
P.Select("Pinky Freewood-Realm")
eq(f.card.prof1.tex, FreewoodDesign.CraftTex("leatherworking"), "eigenes Bild auf der Karte")
eq(f.card.class.tex, FreewoodDesign.ClassTex("ROGUE"), "Klassen-Icon auf der Karte")
SlashCmdList.FWPINKY("symbole blizzard")
eq(f.card.prof1.tex, "Interface\\Icons\\INV_Misc_ArmorKit_17", "Spiel-Icon zum Vergleich")
SlashCmdList.FWPINKY("symbole pinky")
eq(P.CraftStyle(), "pinky", "zurueck")

-- Roster: Stufen-Knopf in Klassenfarbe, Name in Klassenfarbe, Tooltip
P.Refresh()
local pl
for _, child in ipairs({}) do end
local r1, g1, b1 = P.ClassColor("ROGUE", true)
eq(r1 == 1 and g1 > 0.9, true, "Schurke gelb")
local r2 = P.ClassColor("ROGUE", false)
eq(r2, 0.5, "offline abgedunkelt")
local tipLines = {}
_G.GameTooltip = { SetOwner = function() end, SetText = function(_, t) tipLines[1] = t end,
    AddLine = function(_, t) tipLines[#tipLines + 1] = t end, Show = function() end, Hide = function() end }
P.ShowTip(f, P.rows[1])
eq(tipLines[1], P.rows[1].name, "Tooltip: Name")
eq(tipLines[2]:find("60", 1, true) ~= nil, true, "Tooltip: Stufe")
eq(tipLines[#tipLines]:find("165", 1, true) ~= nil or tipLines[#tipLines]:find("leather", 1, true) ~= nil, true, "Tooltip: Berufe")

-- 7. Befehle
SlashCmdList.FWPINKY("groesse 80")
eq(FreewoodDesignDB.pinky.scale, nil, "Groesse nicht aenderbar")
eq(P.SCALE, 1.5, "fest 150 %")
SlashCmdList.FWPINKY("reset")
eq(FreewoodDesignDB.pinky.pos, nil, "Position zurueck")

-- Mindestgroesse der Schrift
eq(P.FontFactor(1.5), 1, "gross: Schrift normal")
eq(P.FontFactor(0.9), 1, "90 %: normal")
eq(math.abs(P.FontFactor(0.5) - 1.8) < 1e-9, true, "50 %: Schrift ausgeglichen")
eq(f.slideBtn ~= nil, true, "Knopf da")
eq(f.sep ~= nil, true, "Trenner zwischen Roster und Karte")

-- 8. Ohne Gilde
_G.IsInGuild = function() return false end
f:Show()
P.Refresh()
eq(f.status.text, P.L.noGuild, "Hinweis ohne Gilde")

print(string.format("%d Pruefungen, %d Fehler", n, fails))
os.exit(fails == 0 and 0 or 1)
