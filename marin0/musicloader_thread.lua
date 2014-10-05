local args = {...}
this = {}
this.musiclist = args[1]
this.trackname = args[2]
this.tracksource = args[3]
this.demandtrack = args[4]

require("love.filesystem")
require("love.sound")
require("love.audio")
require("love.timer")

love.filesystem.setIdentity("Marin0")

local musicpath = "sounds/%s.ogg"

local musiclist = {}
local musictoload = {} -- waiting to be loaded into memory

local function getmusiclist()
	-- the music string should have names separated by the ";" character
	-- music will be loaded in in the same order as they appear in the string
	local musicliststr = this.musiclist:pop()
	if musicliststr then
		for musicname in musicliststr:gmatch("[^;]+") do
			if not musiclist[musicname] then
				musiclist[musicname] = true
				table.insert(musictoload, musicname)
			end
		end
	end
end

local function getfilename(name)
	local filename = name:match("%.[mo][pg][3g]$") and name or musicpath:format(name) -- mp3 or ogg
	if love.filesystem.exists(filename) and love.filesystem.isFile(filename) then
		return filename
	else
		print(string.format("thread can't load \"%s\": not a file!", filename))
	end
end

local function loadmusic()
	local demandtrack = this.demandtrack:pop()
	if #musictoload > 0 or demandtrack then
		local name
		if demandtrack then
			name=demandtrack
		else
			name=table.remove(musictoload, 1)
		end
		--@DEV: We could probably optimize ^this^ by using "or" but I don't want to chance a lua quirk.
		local filename = getfilename(name)
		if filename then
			local source = love.audio.newSource(love.sound.newDecoder(filename, 512 * 1024), "static")
			--print("thread loaded music", name)
			this.trackname:push(name)
			this.tracksource:push(source)
		end
	end
end

while true do
	getmusiclist()
	loadmusic()
	love.timer.sleep(1/60)
end
