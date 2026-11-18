-- Test: jede Textur in Design.lua liegt als TGA vor, Zweierpotenz, 32 Bit   texlua tests/media_test.lua
local fails, n = 0, 0
local function ok(c, m) n = n + 1 if not c then fails = fails + 1 print("FEHLER " .. m) end end
assert(loadfile("Design.lua"))()
local D = FreewoodDesign
local function u16(s, i) return s:byte(i) + 256 * s:byte(i + 1) end
local function p2(v) local x = 1 while x < v do x = x * 2 end return x == v end
local count = 0
for group, list in pairs(D.Pinky.files) do
    for _, name in ipairs(list) do
        count = count + 1
        local f = io.open("Media/Pinky/" .. group .. "/" .. name .. ".tga", "rb")
        ok(f ~= nil, "Datei fehlt: " .. name)
        if f then
            local h = f:read(18) f:close()
            local w, hgt = u16(h, 13), u16(h, 15)
            ok(h:byte(3) == 2, name .. ": TGA unkomprimiert (Typ 2)")
            ok(h:byte(17) == 32, name .. ": 32 Bit")
            ok(p2(w) and p2(hgt) and w <= 2048 and hgt <= 2048, name .. ": Zweierpotenz " .. w .. "x" .. hgt)
        end
    end
end
ok(count >= 70, "alle Texturen gelistet: " .. count)
ok(D.Tex("pf_frame_main") == "Interface\\AddOns\\Freewood-Design\\Media\\Pinky\\ui\\pf_frame_main", "Pfad Hauptrahmen")
ok(D.ClassTex("ROGUE") ~= nil and D.ClassTex("SHAMAN") ~= nil and D.ClassTex("PET") ~= nil, "Klassen nach Kuerzel")
for _, c in ipairs({ "DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR" }) do
    ok(D.ClassTex(c) ~= nil, "Klasse " .. c)
end
for _, c in ipairs(D.CRAFTS) do ok(D.CraftTex(c) ~= nil, "Beruf " .. c) end
ok(D.CraftTex("First Aid") ~= nil, "Beruf mit Leerzeichen")
ok(D.Tex("gibtsnicht") == nil, "unbekannt -> nil")
print(string.format("%d Pruefungen, %d Fehler", n, fails))
os.exit(fails == 0 and 0 or 1)
