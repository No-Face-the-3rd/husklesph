

local rootFolder = (GM or GAMEMODE).Folder:sub(11) .. "/gamemode/"

Taunts = {}
TauntCategories = {}
AllowedTauntSounds = {}

local function addTaunt(name, snd, pteam, sex, cats)
	if type(snd) != "table" then snd = {snd} end
	if #snd == 0 then error("No sounds for " .. name) return end

	local t = {}
	t.sound = snd
	t.categories = cats
	if type(pteam) == "string" then
		pteam = pteam:lower()
		if pteam == "prop" || pteam == "props" then
			t.team = 3
		elseif pteam == "hunter" || pteam == "hunters" then
			t.team = 2
		end
	else
		t.team = tonumber(pteam)
	end
	if sex && #sex > 0 then
		t.sex = sex
	end
	t.name = name

	local dur, count = 0, 0
	for k, v in pairs(snd) do
		AllowedTauntSounds[v] = t
		dur = dur + SoundDuration(v)
		count = count + 1
	end

	t.soundDuration = dur / count

	table.insert(Taunts, t)
	for k, cat in pairs(cats) do
		if !TauntCategories[cat] then TauntCategories[cat] = {} end
		table.insert(TauntCategories[cat], t)
	end
end

function GM:LoadTaunts()
	local tempG = {}
	tempG.addTaunt = addTaunt
	local meta = {}
	meta.__index = _G
	setmetatable(tempG, meta)

	local files, dirs = file.Find(rootFolder .. "taunts/*", "LUA")
	for k, v in pairs(files) do
		AddCSLuaFile(rootFolder .. "taunts/" .. v)

		local name = v:sub(1, -5)
		local f = CompileFile(rootFolder .. "taunts/" .. v)
		if !f then
			return
		end
		setfenv(f, tempG)
		local b, err = pcall(f)

		if !b then
			MsgC(Color(255, 50, 50), "Loading taunts failed " .. name .. ".lua\nError: " .. err .. "\n")
		end
	end
end

GM:LoadTaunts()