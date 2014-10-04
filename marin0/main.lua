io.stdout:setvbuf("no")

--[[
	STEAL MY SHIT AND I'LL FUCK YOU UP
	PRETTY MUCH EVERYTHING BY MAURICE GUGAN AND IF SOMETHING ISN'T BY ME THEN IT SHOULD BE OBVIOUS OR NOBODY CARES

	THIS AWESOME PIECE OF CELESTIAL AMBROSIA IS RELEASED AS NON-COMMERCIAL, SHARE ALIKE, WHATEVER. YOU MAY PRINT OUT THIS CODES AND USE IT AS WALLPAPER IN YOUR BATHROOM.
	FOR SPECIFIC LICENSE (I know you linux users get a hard on when it comes to licenses) SEE http://creativecommons.org/licenses/by-nc-sa/3.0/
	NOW GO AWAY (or stay and modify shit. I don't care as long as you stick to the above license.)
	
	EXTRA ENTITIES & TWEAKS BY ALESAN99
	DAFUQ ARE YOU DOING HERE!
]]
function love.load()
	marioversion = 3
	versionstring = "version 1.6"
	shaderlist = love.filesystem.enumerate( "shaders/" )
	graphicspacklist = love.filesystem.enumerate( "graphics/" )
	
	graphicspacki = 1 --@DEV: We have no guarantee which pack this will be, so we're gonna wanna change this later.
	graphicspack = graphicspacklist[graphicspacki]
	
	dlclist = {"dlc_a_portal_tribute", "dlc_acid_trip", "dlc_escape_the_lab", "dlc_scienceandstuff", "dlc_smb2J", "dlc_the_untitled_game"}
	
	local rem
	for i, v in pairs(shaderlist) do
		if v == "init.lua" then
			rem = i
		else
			shaderlist[i] = string.sub(v, 1, string.len(v)-5)
		end
	end
	
	table.remove(shaderlist, rem)
	table.insert(shaderlist, 1, "none")
	currentshaderi1 = 1
	currentshaderi2 = 1
	
	hatcount = #love.filesystem.enumerate("graphics/SMB/hats") --@DEV: We shouldn't be changing this, but we should consider it when we add the fallback.
	
	if not pcall(loadconfig) then
		players = 1
		defaultconfig()
	end

	
	saveconfig()
	width = 25
	height = 14 --?
	fsaa = 0
	fullscreen = false
	changescale(scale, fullscreen)
	love.graphics.setCaption( "Mari0" )
	
	--version check by checking for a const that was added in 0.8.0
	if love._version_major == nil then error("You have an outdated version of Love! Get 0.8.0 or higher and retry.") end
	
	iconimg = newImageFallback("icon.gif")
	love.graphics.setIcon(iconimg)
	
	love.graphics.setDefaultImageFilter("nearest", "nearest")
	
	love.graphics.setBackgroundColor(0, 0, 0)
	
	
	fontimage = newImageFallback("font.png")
	fontimageback = newImageFallback("fontback.png")
	fontglyphs = "0123456789abcdefghijklmnopqrstuvwxyz.:/,'C-_>* !{}?"
	fontquads = {}
	for i = 1, string.len(fontglyphs) do
		fontquads[string.sub(fontglyphs, i, i)] = love.graphics.newQuad((i-1)*8, 0, 8, 8, 512, 8)
	end

	fontquadsback = {}
	for i = 1, string.len(fontglyphs) do
		fontquadsback[string.sub(fontglyphs, i, i)] = love.graphics.newQuad((i-1)*10, 0, 10, 10, fontimageback:getWidth(), fontimageback:getHeight())
	end

	require "notice"
	
	


	math.randomseed(os.time());math.random();math.random()
	
	love.graphics.clear()
	love.graphics.setColor(100, 100, 100)
	loadingtexts = {"reticulating splines..", "loading..", "booting glados..", "growing potatoes..", "voting against acta..", "rendering important stuff..",
					"baking cake..", "happy explosion day..", "raising coolness by 20 percent..", "yay facepunch..", "stabbing myself..", "sharpening knives..",
					"tanaka, thai kick..", "loading game genie..", "thanking alesan99..", "avoiding lawsuits..", "loading bugs..",
					"fixign typo..", "this message will self destruct in 3 2 1..", "preparing deadly neurotoxin.."}
	loadingtext = loadingtexts[math.random(#loadingtexts)]
	properprint(loadingtext, 25*8*scale-string.len(loadingtext)*4*scale, 108*scale)
	love.graphics.present()
	--require ALL the files!
	require "shaders"
	require "variables"
	require "class"
	require "sha1"

	
	require "intro"
	require "menu"
	require "levelscreen"
	require "game"
	require "editor"
	require "physics"
	require "quad"
	require "entity"
	require "portalwall"
	require "tile"
	require "mario"
	require "goomba"
	require "koopa"
	require "cheepcheep"
	require "mushroom"
	require "hatconfigs"
	require "bighatconfigs"
	require "flower"
	require "star"
	require "oneup"
	require "coinblockanimation"
	require "scrollingscore"
	require "platform"
	require "platformspawner"
	require "portalparticle"
	require "portalprojectile"
	require "box"
	require "emancipationgrill"
	require "door"
	require "button"
	require "groundlight"
	require "wallindicator"
	require "walltimer"
	require "lightbridge"
	require "faithplate"
	require "laser"
	require "laserdetector"
	require "gel"
	require "geldispenser"
	require "cubedispenser"
	require "pushbutton"
	require "screenboundary"
	require "bulletbill"
	require "hammerbro"
	require "fireball"
	require "gui"
	require "blockdebris"
	require "firework"
	require "plant"
	require "castlefire"
	require "fire"
	require "bowser"
	require "vine"
	require "spring"
	require "flyingfish"
	require "upfire"
	require "seesaw"
	require "seesawplatform"
	require "lakito"
	require "bubble"
	require "squid"
	require "rainboom"
	require "miniblock"
	require "notgate"
	require "musicloader"
	require "netplay"
	require "server"
	require "onlinemenu"
	require "lobby"
	require "springgreen"
	require "windleaf"
	require "poisonmush"
	require "redplant"
	require "reddownplant"
	require "downplant"
	socket = require "socket"
	
	http = require("socket.http")
	http.TIMEOUT = 1


	love.filesystem.setIdentity("Marin0")
	
	updatenotification = false
	if getupdate() then
		updatenotification = true
	end
	credited = true
	http.TIMEOUT = 4
	
	playertypei = 1
	playertype = playertypelist[playertypei] --portal, minecraft
	loadgraphics()
	
	if volume == 0 then
		soundenabled = false
	else
		soundenabled = true
	end
	love.filesystem.mkdir( "mappacks" )
	love.filesystem.mkdir( "modmappacks" )
	editormode = false
	yoffset = 0
	love.graphics.setPointSize(3*scale)
	love.graphics.setLineWidth(3*scale)
	
	uispace = math.floor(width*16*scale/4)
	guielements = {}
	
	endingtextcolor = {255, 255, 255}
	endingtext = {"congratulations!", "you have finished this mappack!"}
	endingtextcolorname = "white"
	playername = "mario"
	toadtext = {"thank you mario!", "but our princess is in", "another castle!"}
	peachtext = {"thank you mario!", "your quest is over.", "we present you a new quest.", "push button b", "to play as steve"}
	pressbtosteve = true
	hudtextcolor = {255, 255, 255}
	hudvisible = true
	loadcustomtext()
	
	--custom players
	--loadplayer()
	
	--Backgroundcolors
	backgroundcolor = {}
	backgroundcolor[1] = {92, 148, 252}
	backgroundcolor[2] = {0, 0, 0}
	backgroundcolor[3] = {32, 56, 236}
	
	--AUDIO--
	--sounds
	jumpsound = love.audio.newSource("sounds/jump.ogg", "static");love.audio.stop(jumpsound)
	jumpbigsound = love.audio.newSource("sounds/jumpbig.ogg", "static");love.audio.stop(jumpbigsound)
	jumptinysound = love.audio.newSource("sounds/jumptiny.ogg", "static");love.audio.stop(jumptinysound)
	stompsound = love.audio.newSource("sounds/stomp.ogg", "static");stompsound:setVolume(0);stompsound:play();stompsound:stop();stompsound:setVolume(1)
	shotsound = love.audio.newSource("sounds/shot.ogg", "static");shotsound:setVolume(0);shotsound:play();shotsound:stop();shotsound:setVolume(1)
	blockhitsound = love.audio.newSource("sounds/blockhit.ogg", "static");blockhitsound:setVolume(0);blockhitsound:play();blockhitsound:stop();blockhitsound:setVolume(1)
	blockbreaksound = love.audio.newSource("sounds/blockbreak.ogg", "static");blockbreaksound:setVolume(0);blockbreaksound:play();blockbreaksound:stop();blockbreaksound:setVolume(1)
	coinsound = love.audio.newSource("sounds/coin.ogg", "static");coinsound:setVolume(0);coinsound:play();coinsound:stop();coinsound:setVolume(1)
	pipesound = love.audio.newSource("sounds/pipe.ogg", "static");pipesound:setVolume(0);pipesound:play();pipesound:stop();pipesound:setVolume(1)
	boomsound = love.audio.newSource("sounds/boom.ogg", "static");boomsound:setVolume(0);boomsound:play();boomsound:stop();boomsound:setVolume(1)
	mushroomappearsound = love.audio.newSource("sounds/mushroomappear.ogg", "static");mushroomappearsound:setVolume(0);mushroomappearsound:play();mushroomappearsound:stop();mushroomappearsound:setVolume(1)
	mushroomeatsound = love.audio.newSource("sounds/mushroomeat.ogg", "static");mushroomeatsound:setVolume(0);mushroomeatsound:play();mushroomeatsound:stop();mushroomeatsound:setVolume(1)
	shrinksound = love.audio.newSource("sounds/shrink.ogg", "static");shrinksound:setVolume(0);shrinksound:play();shrinksound:stop();shrinksound:setVolume(1)
	deathsound = love.audio.newSource("sounds/death.ogg", "static");deathsound:setVolume(0);deathsound:play();deathsound:stop();deathsound:setVolume(1)
	gameoversound = love.audio.newSource("sounds/gameover.ogg", "static");gameoversound:setVolume(0);gameoversound:play();gameoversound:stop();gameoversound:setVolume(1)
	fireballsound = love.audio.newSource("sounds/fireball.ogg", "static");fireballsound:setVolume(0);fireballsound:play();fireballsound:stop();fireballsound:setVolume(1)
	oneupsound = love.audio.newSource("sounds/oneup.ogg", "static");oneupsound:setVolume(0);oneupsound:play();oneupsound:stop();oneupsound:setVolume(1)
	levelendsound = love.audio.newSource("sounds/levelend.ogg", "static");levelendsound:setVolume(0);levelendsound:play();levelendsound:stop();levelendsound:setVolume(1)
	castleendsound = love.audio.newSource("sounds/castleend.ogg", "static");castleendsound:setVolume(0);castleendsound:play();castleendsound:stop();castleendsound:setVolume(1)
	scoreringsound = love.audio.newSource("sounds/scorering.ogg", "static");scoreringsound:setVolume(0);scoreringsound:play();scoreringsound:stop();scoreringsound:setVolume(1);scoreringsound:setLooping(true)
	intermissionsound = love.audio.newSource("sounds/intermission.ogg", "static");intermissionsound:setVolume(0);intermissionsound:play();intermissionsound:stop();intermissionsound:setVolume(1)
	firesound = love.audio.newSource("sounds/fire.ogg", "static");firesound:setVolume(0);firesound:play();firesound:stop();firesound:setVolume(1)
	bridgebreaksound = love.audio.newSource("sounds/bridgebreak.ogg", "static");bridgebreaksound:setVolume(0);bridgebreaksound:play();bridgebreaksound:stop();bridgebreaksound:setVolume(1)
	bowserfallsound = love.audio.newSource("sounds/bowserfall.ogg", "static");bowserfallsound:setVolume(0);bowserfallsound:play();bowserfallsound:stop();bowserfallsound:setVolume(1)
	vinesound = love.audio.newSource("sounds/vine.ogg", "static");vinesound:setVolume(0);vinesound:play();vinesound:stop();vinesound:setVolume(1)
	swimsound = love.audio.newSource("sounds/swim.ogg", "static");swimsound:setVolume(0);swimsound:play();swimsound:stop();swimsound:setVolume(1)
	rainboomsound = love.audio.newSource("sounds/rainboom.ogg", "static");rainboomsound:setVolume(0);rainboomsound:play();rainboomsound:stop();rainboomsound:setVolume(1)
	konamisound = love.audio.newSource("sounds/konami.ogg", "static");konamisound:setVolume(0);konamisound:play();konamisound:stop();konamisound:setVolume(1)
	pausesound = love.audio.newSource("sounds/pause.ogg", "static");pausesound:setVolume(0);pausesound:play();pausesound:stop();pausesound:setVolume(1)
	bulletbillsound = love.audio.newSource("sounds/bulletbill.ogg", "static");pausesound:setVolume(0);pausesound:play();pausesound:stop();pausesound:setVolume(1)
	stabsound = love.audio.newSource("sounds/stab.ogg", "static")
	iciclesound = love.audio.newSource("sounds/icicle.ogg", "static");iciclesound:setVolume(0);iciclesound:play();iciclesound:stop();iciclesound:setVolume(1)
	thwompsound = love.audio.newSource("sounds/thwomp.ogg", "static");thwompsound:setVolume(0);thwompsound:play();thwompsound:stop();thwompsound:setVolume(1)
	boomerangsound = love.audio.newSource("sounds/boomerang.ogg", "static");boomerangsound:setVolume(0);boomerangsound:play();boomerangsound:stop();boomerangsound:setVolume(1)
	raccoonswingsound = love.audio.newSource("sounds/raccoonswing.ogg", "static");raccoonswingsound:setVolume(0);raccoonswingsound:play();raccoonswingsound:stop();raccoonswingsound:setVolume(1)
	raccoonplanesound = love.audio.newSource("sounds/raccoonplane.ogg", "static");raccoonplanesound:setVolume(0);raccoonplanesound:play();raccoonplanesound:stop();raccoonplanesound:setVolume(1);raccoonplanesound:setLooping(true)
	skidsound = love.audio.newSource("sounds/skid.ogg", "static");skidsound:setVolume(0);skidsound:play();skidsound:stop();skidsound:setVolume(1)
	turretshotsound = love.audio.newSource("sounds/turretshot.ogg", "static");turretshotsound:setVolume(0);turretshotsound:play();turretshotsound:stop();turretshotsound:setVolume(1)
	bossmusic = love.audio.newSource("sounds/boss.ogg", "static");bossmusic:setVolume(0);bossmusic:play();bossmusic:stop();bossmusic:setVolume(1);bossmusic:setLooping(true)
	
	glados1sound = love.audio.newSource("sounds/glados/glados1.ogg", "static");glados1sound:setVolume(0);glados1sound:play();glados1sound:stop();glados1sound:setVolume(1)
	glados2sound = love.audio.newSource("sounds/glados/glados2.ogg", "static");glados2sound:setVolume(0);glados2sound:play();glados2sound:stop();glados2sound:setVolume(1)
	
	portal1opensound = love.audio.newSource("sounds/portal1open.ogg", "static");portal1opensound:setVolume(0);portal1opensound:play();portal1opensound:stop();portal1opensound:setVolume(0.3)
	portal2opensound = love.audio.newSource("sounds/portal2open.ogg", "static");portal2opensound:setVolume(0);portal2opensound:play();portal2opensound:stop();portal2opensound:setVolume(0.3)
	portalentersound = love.audio.newSource("sounds/portalenter.ogg", "static");portalentersound:setVolume(0);portalentersound:play();portalentersound:stop();portalentersound:setVolume(0.3)
	portalfizzlesound = love.audio.newSource("sounds/portalfizzle.ogg", "static");portalfizzlesound:setVolume(0);portalfizzlesound:play();portalfizzlesound:stop();portalfizzlesound:setVolume(0.3)
	
	lowtime = love.audio.newSource("sounds/lowtime.ogg", "static");rainboomsound:setVolume(0);rainboomsound:play();rainboomsound:stop();rainboomsound:setVolume(1)
	
	--music
	--[[
	overworldmusic = love.audio.newSource("sounds/overworld.ogg", "stream");overworldmusic:setLooping(true)
	undergroundmusic = love.audio.newSource("sounds/underground.ogg", "stream");undergroundmusic:setLooping(true)
	castlemusic = love.audio.newSource("sounds/castle.ogg", "stream");castlemusic:setLooping(true)
	underwatermusic = love.audio.newSource("sounds/underwater.ogg", "stream");underwatermusic:setLooping(true)
	starmusic = love.audio.newSource("sounds/starmusic.ogg", "stream");starmusic:setLooping(true)
	princessmusic = love.audio.newSource("sounds/princessmusic.ogg", "stream");princessmusic:setLooping(true)
	
	overworldmusicfast = love.audio.newSource("sounds/overworld-fast.ogg", "stream");overworldmusicfast:setLooping(true)
	undergroundmusicfast = love.audio.newSource("sounds/underground-fast.ogg", "stream");undergroundmusicfast:setLooping(true)
	castlemusicfast = love.audio.newSource("sounds/castle-fast.ogg", "stream");castlemusicfast:setLooping(true)
	underwatermusicfast = love.audio.newSource("sounds/underwater-fast.ogg", "stream");underwatermusicfast:setLooping(true)
	starmusicfast = love.audio.newSource("sounds/starmusic-fast.ogg", "stream");starmusicfast:setLooping(true)
	]]
	
	soundlist = {jumpsound, jumpbigsound, stompsound, shotsound, blockhitsound, blockbreaksound, coinsound, pipesound, boomsound, mushroomappearsound, mushroomeatsound, shrinksound, deathsound, gameoversound,
				turretshotsound, fireballsound, oneupsound, levelendsound, castleendsound, bossmusic, scoreringsound, intermissionsound, firesound, bridgebreaksound, bowserfallsound, vinesound, swimsound, rainboomsoud, 
				portal1opensound, portal2opensound, portalentersound, portalfizzlesound, lowtime, konamisound, pausesound, stabsound, bulletbillsound, iciclesound, thwompsound, boomerangsound, raccoonswingsound,
				raccoonplanesound, skidsound, turretshotsound, bossmusic, jumptiny}
	
	-- musiclist = {overworldmusic, undergroundmusic, castlemusic, underwatermusic, starmusic}
	-- musiclistfast = {overworldmusicfast, undergroundmusicfast, castlemusicfast, underwatermusicfast, starmusicfast}
	
	musici = 2
	
	shaders:init()
	shaders:set(1, shaderlist[currentshaderi1])
	shaders:set(2, shaderlist[currentshaderi2])
	
	for i, v in pairs(dlclist) do
		delete_mappack(v)
	end

	chatlogfont = newFontFallback("chatfont.ttf", 7*scale)
	bigchatlogfont = newFontFallback("chatfont.ttf", 14*scale)
	
	intro_load()

	magicdns_session_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	magicdns_session = ""
	for i = 1, 8 do
		rand = math.random(string.len(magicdns_session_chars))
		magicdns_session = magicdns_session .. string.sub(magicdns_session_chars, rand, rand)
	end
	--use love.filesystem.getIdentity() when it works
	magicdns_identity = love.filesystem.getSaveDirectory():split("/")
	magicdns_identity = string.upper(magicdns_identity[#magicdns_identity])

	--GETS MARI0, CAUSE WE WANT IT TO BE THE MAGICDNS FOR MARI0
	--I WANTED IT TO BE QCODEONLINEMOD, BUT WHATEVER
	--NOT NOT TETRIS
	--EVEN THOUGH NOT TETRIS DOESN'T HAVE ONLINE MP
	--WHATEVER
	--QCODE'S NEXT SECRET PROJECT CONFIRMED

end

function love.update(dt)
	if music then
		music:update()
	end
	dt = math.min(0.01666667, dt)
	
	--speed
	if speed ~= speedtarget then
		if speed > speedtarget then
			speed = math.max(speedtarget, speed+(speedtarget-speed)*dt*5)
		elseif speed < speedtarget then
			speed = math.min(speedtarget, speed+(speedtarget-speed)*dt*5)
		end
		
		if math.abs(speed-speedtarget) < 0.02 then
			speed = speedtarget
		end
		
		if speed > 0 then
			for i, v in pairs(soundlist) do
				v:setPitch( speed )
			end
			music.pitch = speed
			love.audio.setVolume(volume)
		else
			love.audio.setVolume(0)
		end
	end
--	dt = dt * speed
	gdt = dt
	
	if frameadvance == 1 then
		return
	elseif frameadvance == 2 then
		frameadvance = 1
	end

	if skipupdate then
		skipupdate = false
		return
	end
	
	--netplay_update(dt)
	keyprompt_update()
	
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "options" or gamestate == "onlinemenu" or gamestate == "lobby" then
		menu_update(dt)
	elseif gamestate == "levelscreen" or gamestate == "gameover" or gamestate == "sublevelscreen" or gamestate == "mappackfinished" then
		levelscreen_update(dt)
	elseif gamestate == "game" then
		game_update(dt)	
	elseif gamestate == "intro" then
		intro_update(dt)	
	end

	if onlinemp then
		if clientisnetworkhost then
			server_update(dt)
		end
		network_update(dt)
	end
	
	for i, v in pairs(guielements) do
		v:update(dt)
	end


	notice.update(dt)
end

function love.draw()
	shaders:predraw()
	
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "options" or gamestate == "onlinemenu" or gamestate == "lobby" then
		menu_draw()
	elseif gamestate == "levelscreen" or gamestate == "gameover" or gamestate == "mappackfinished" then
		levelscreen_draw()
	elseif gamestate == "game" then
		game_draw()
	elseif gamestate == "intro" then
		intro_draw()
	end
	notice.draw()
	
	shaders:postdraw()
	
	love.graphics.setColor(255, 255,255)
	if gamestate == "menu" then
		gamestate = "options"
		gamestate = "menu"
	end
end

function saveconfig()
	local s = ""
	for i = 1, #controls do
		s = s .. "playercontrols:" .. i .. ":"
		local count = 0
		for j, k in pairs(controls[i]) do
			local c = ""
			for l = 1, #controls[i][j] do
				c = c .. controls[i][j][l]
				if l ~= #controls[i][j] then
					c = c ..  "-"
				end
			end
			s = s .. j .. "-" .. c
			count = count + 1
			if count == 12 then
				s = s .. ";"
			else
				s = s .. ","
			end
		end
	end	
	
	for i = 1, #mariocolors do
		s = s .. "playercolors:" .. i .. ":"
		for j = 1, 3 do
			for k = 1, 3 do
				s = s .. mariocolors[i][j][k]
				if j == 3 and k == 3 then
					s = s .. ";"
				else
					s = s .. ","
				end
			end
		end
	end
	
	for i = 1, #portalhues do
		s = s .. "portalhues:" .. i .. ":"
		s = s .. round(portalhues[i][1], 4) .. "," .. round(portalhues[i][2], 4) .. ";"
	end
	
	for i = 1, #mariohats do
		s = s .. "mariohats:" .. i
		if #mariohats[i] > 0 then
			s = s .. ":"
		end
		for j = 1, #mariohats[i] do
			s = s .. mariohats[i][j]
			if j == #mariohats[i] then
				s = s .. ";"
			else
				s = s .. ","
			end
		end
		
		if #mariohats[i] == 0 then
			s = s .. ";"
		end
	end
	
	s = s .. "scale:" .. scale .. ";"
	
	s = s .. "graphicspack:" .. graphicspacklist[graphicspacki] .. ";"
	
	s = s .. "shader1:" .. shaderlist[currentshaderi1] .. ";"
	s = s .. "shader2:" .. shaderlist[currentshaderi2] .. ";"
	
	s = s .. "volume:" .. volume .. ";"
	s = s .. "mouseowner:" .. mouseowner .. ";"
	
	s = s .. "mappack:" .. mappack .. ";"
	
	if vsync then
		s = s .. "vsync;"
	end
	
	if gamefinished then
		s = s .. "gamefinished;"
	end
	
	--reached worlds
	for i, v in pairs(reachedworlds) do
		s = s .. "reachedworlds:" .. i .. ":"
		for j = 1, 8 do
			if v[j] then
				s = s .. 1
			else
				s = s .. 0
			end
			
			if j == 8 then
				s = s .. ";"
			else
				s = s .. ","
			end
		end
	end
	
	if mappackfolder == "modmappacks" then
		s = s .. "modmappacks;"
	end
	
	love.filesystem.write("options.txt", s)
end

function loadconfig()
	players = 1
	defaultconfig()
	
	if not love.filesystem.exists("options.txt") then
		return
	end
	
	local s = love.filesystem.read("options.txt")
	s1 = s:split(";")
	for i = 1, #s1-1 do
		s2 = s1[i]:split(":")
		
		if s2[1] == "playercontrols" then
			if controls[tonumber(s2[2])] == nil then
				controls[tonumber(s2[2])] = {}
			end
			
			s3 = s2[3]:split(",")
			for j = 1, #s3 do
				s4 = s3[j]:split("-")
				controls[tonumber(s2[2])][s4[1]] = {}
				for k = 2, #s4 do
					if tonumber(s4[k]) ~= nil then
						controls[tonumber(s2[2])][s4[1]][k-1] = tonumber(s4[k])
					else
						controls[tonumber(s2[2])][s4[1]][k-1] = s4[k]
					end
				end
			end
			players = math.max(players, tonumber(s2[2]))
			
		elseif s2[1] == "playercolors" then
			if mariocolors[tonumber(s2[2])] == nil then
				mariocolors[tonumber(s2[2])] = {}
			end
			s3 = s2[3]:split(",")
			mariocolors[tonumber(s2[2])] = {{tonumber(s3[1]), tonumber(s3[2]), tonumber(s3[3])}, {tonumber(s3[4]), tonumber(s3[5]), tonumber(s3[6])}, {tonumber(s3[7]), tonumber(s3[8]), tonumber(s3[9])}}
			
		elseif s2[1] == "portalhues" then
			if portalhues[tonumber(s2[2])] == nil then
				portalhues[tonumber(s2[2])] = {}
			end
			s3 = s2[3]:split(",")
			portalhues[tonumber(s2[2])] = {tonumber(s3[1]), tonumber(s3[2])}
		
		elseif s2[1] == "mariohats" then
			local playerno = tonumber(s2[2])
			mariohats[playerno] = {}
			
			if s2[3] == "mariohats" then --SAVING WENT WRONG OMG
			
			elseif s2[3] then
				s3 = s2[3]:split(",")
				for i = 1, #s3 do
					local hatno = tonumber(s3[i])
					if hatno > hatcount then
						hatno = hatcount
					end
					mariohats[playerno][i] = hatno
				end
			end
			
		elseif s2[1] == "scale" then
			scale = tonumber(s2[2])
		elseif s2[1] == "graphicspack" then
			print("debug: graphicspack iter")
			for i = 1, #graphicspacklist do
				print("gp: "..graphicspacklist[i].."; s2: "..s2[2])
				if graphicspacklist[i] == s2[2] then
					graphicspack = s2[2]
					graphicspacki = i
					break
				end
			end
		elseif s2[1] == "shader1" then
			for i = 1, #shaderlist do
				if shaderlist[i] == s2[2] then
					currentshaderi1 = i
					break
				end
			end
		elseif s2[1] == "shader2" then
			for i = 1, #shaderlist do
				if shaderlist[i] == s2[2] then
					currentshaderi2 = i
					break
				end
			end
		elseif s2[1] == "volume" then
			volume = tonumber(s2[2])
			love.audio.setVolume( volume )
		elseif s2[1] == "mouseowner" then
			mouseowner = tonumber(s2[2])
		elseif s2[1] == "mappack" then
			if love.filesystem.exists(mappackfolder .. "/" .. s2[2] .. "/") then
				mappack = s2[2]
			end
		elseif s2[1] == "gamefinished" then
			gamefinished = true
		elseif s2[1] == "vsync" then
			vsync = true
		elseif s2[1] == "reachedworlds" then
			reachedworlds[s2[2]] = {}
			local s3 = s2[3]:split(",")
			for i = 1, #s3 do
				if tonumber(s3[i]) == 1 then
					reachedworlds[s2[2]][i] = true
				end
			end
		elseif s2[1] == "modmappacks" then
			mappackfolder = "modmappacks"
		end
	end
	
	for i = 1, math.max(4, players) do
		portalcolor[i] = {getrainbowcolor(portalhues[i][1]), getrainbowcolor(portalhues[i][2])}
	end
	players = 1
end

function loadcustomtext()
	if love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/endingmusic.ogg") then
		endingmusic = love.audio.newSource(mappackfolder .. "/" .. mappack .. "/endingmusic.ogg");endingmusic:play();endingmusic:stop()
	elseif love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/endingmusic.mp3") then
		endingmusic = love.audio.newSource(mappackfolder .. "/" .. mappack .. "/endingmusic.mp3");endingmusic:play();endingmusic:stop()
	else
		endingmusic = konamisound
	end
	if love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/text.txt") then
		local s = love.filesystem.read(mappackfolder .. "/" .. mappack .. "/text.txt")
		--read .txt
		local lines
		if string.find(s, "\r\n") then
			lines = s:split("\r\n")
		else
			lines = s:split("\n")
		end
		
		for i = 1, #lines do
			local s2 = lines[i]:split("=")
			local s3
			if string.find(s2[1], ":") then
				s3 = s2[1]:split(":")
			else
				s3 = {s2[1]}
			end
			if s3[1] == "endingtextcolor" then
				local s4 = s2[2]:split(",")
				
				for j = 1, 3 do
					endingtextcolor[j] = tonumber(s4[j])
				end
			elseif s3[1] == "endingtext" then
				local s4 = s2[2]:split(",")
				
				for j = 1, #s4 do
					endingtext[j] = s4[j]
				end
			elseif s3[1] == "endingcolorname" then
				endingtextcolorname = s2[2]
			elseif s3[1] == "playername" then
				playername = s2[2]
			elseif s3[1] == "hudtextcolor" then
				local s4 = s2[2]:split(",")
				
				for j = 1, 3 do
					hudtextcolor[j] = tonumber(s4[j])
				end
			elseif s3[1] == "hudcolorname" then
				hudtextcolorname = s2[2]
			elseif s3[1] == "hudvisible" then
				hudvisible = (s2[2] == "true")
			elseif s3[1] == "toadtext" then
				local s4 = s2[2]:split(",")
				
				for j = 1, 3 do
					toadtext[j] = s4[j]
				end
			elseif s3[1] == "peachtext" then
				local s4 = s2[2]:split(",")
				
				for j = 1, 5 do
					peachtext[j] = s4[j]
				end
			elseif s3[1] == "steve" then
				pressbtosteve = (s2[2] == "true")
			end
		end
	else
		endingtextcolor = {255, 255, 255}
		endingtextcolorname = "white"
		endingtext = {"congratulations!", "you have finished this mappack!"}
		toadtext = {"thank you mario!", "but our princess is in", "another castle!"}
		peachtext = {"thank you mario!", "your quest is over.", "we present you a new quest.", "push button b", "to play as steve"}
		pressbtosteve = true
		playername = "mario"
		hudtextcolor = {255, 255, 255}
		hudtextcolorname = "white"
		hudvisible = true
	end
end

function savecustomtext()
	local s = ""
	if textcolorl == "red" then
		s = s .. "endingtextcolor=255,0,0"
	elseif textcolorl == "blue" then
		s = s .. "endingtextcolor=0,0,255"
	elseif textcolorl == "yellow" then
		s = s .. "endingtextcolor=255,255,0"
	elseif textcolorl == "green" then
		s = s .. "endingtextcolor=0,255,0"
	elseif textcolorl == "orange" then
		s = s .. "endingtextcolor=255,106,0"
	elseif textcolorl == "pink" then
		s = s .. "endingtextcolor=255,128,255"
	elseif textcolorl == "purple" then
		s = s .. "endingtextcolor=113,0,174"
	else
		s = s .. "endingtextcolor=255,255,255"
	end
	s = s .. "\r\nendingcolorname=" .. textcolorl
	s = s .. "\r\nendingtext=" .. guielements["editendingtext1"].value .. "," .. guielements["editendingtext2"].value
	s = s .. "\r\nplayername=" .. guielements["editplayername"].value
	s = s .. "\r\n"
	if textcolorp == "red" then
		s = s .. "hudtextcolor=255,0,0"
	elseif textcolorp == "blue" then
		s = s .. "hudtextcolor=0,0,255"
	elseif textcolorp == "yellow" then
		s = s .. "hudtextcolor=255,255,0"
	elseif textcolorp == "green" then
		s = s .. "hudtextcolor=0,255,0"
	elseif textcolorp == "orange" then
		s = s .. "hudtextcolor=255,106,0"
	elseif textcolorp == "pink" then
		s = s .. "hudtextcolor=255,128,255"
	elseif textcolorp == "purple" then
		s = s .. "hudtextcolor=113,0,174"
	elseif textcolorp == "black" then
		s = s .. "hudtextcolor=0,0,0"
	else
		s = s .. "hudtextcolor=255,255,255"
	end
	s = s .. "\r\nhudcolorname=" .. textcolorp
	s = s .. "\r\nhudvisible=" .. tostring(hudvisible)
	s = s .. "\r\ntoadtext=" .. guielements["edittoadtext1"].value .. "," .. guielements["edittoadtext2"].value .. "," .. guielements["edittoadtext3"].value
	s = s .. "\r\npeachtext=" .. guielements["editpeachtext1"].value .. "," .. guielements["editpeachtext2"].value .. "," .. guielements["editpeachtext3"].value .. "," .. guielements["editpeachtext4"].value .. "," .. guielements["editpeachtext5"].value
	s = s .. "\r\nsteve=" .. tostring(pressbtosteve)
	
	love.filesystem.write(mappackfolder .. "/" .. mappack .. "/text.txt", s)
	loadcustomtext()
end

function defaultconfig()
	local oldplayers = players
	players = 99
	--------------
	-- CONTORLS --
	--------------
	
	-- Joystick stuff:
	-- joy, #, hat, #, direction (r, u, ru, etc)
	-- joy, #, axe, #, pos/neg
	-- joy, #, but, #
	-- You cannot set Hats and Axes as the jump button. Bummer.
	
	mouseowner = 1
	
	controls = {}
	
	local i = 1
	controls[i] = {}
	controls[i]["right"] = {"d"}
	controls[i]["left"] = {"a"}
	controls[i]["down"] = {"s"}
	controls[i]["up"] = {"w"}
	controls[i]["run"] = {"lshift"}
	controls[i]["jump"] = {" "}
	controls[i]["aimx"] = {""} --mouse aiming, so no need
	controls[i]["aimy"] = {""}
	controls[i]["portal1"] = {""}
	controls[i]["portal2"] = {""}
	controls[i]["reload"] = {"r"}
	controls[i]["use"] = {"e"}
	
	for i = 2, 4 do
		controls[i] = {}		
		controls[i]["right"] = {"joy", i-1, "hat", 1, "r"}
		controls[i]["left"] = {"joy", i-1, "hat", 1, "l"}
		controls[i]["down"] = {"joy", i-1, "hat", 1, "d"}
		controls[i]["up"] = {"joy", i-1, "hat", 1, "u"}
		controls[i]["run"] = {"joy", i-1, "but", 3}
		controls[i]["jump"] = {"joy", i-1, "but", 1}
		controls[i]["aimx"] = {"joy", i-1, "axe", 5, "neg"}
		controls[i]["aimy"] = {"joy", i-1, "axe", 4, "neg"}
		controls[i]["portal1"] = {"joy", i-1, "but", 5}
		controls[i]["portal2"] = {"joy", i-1, "but", 6}
		controls[i]["reload"] = {"joy", i-1, "but", 4}
		controls[i]["use"] = {"joy", i-1, "but", 2}
	end
	-------------------
	-- PORTAL COLORS --
	-------------------
	
	portalhues = {}
	portalcolor = {}
	for i = 1, 99 do
		local players = 99
		portalhues[i] = {(i-1)*(1/players), (i-1)*(1/players)+0.5/players}
		portalcolor[i] = {getrainbowcolor(portalhues[i][1]), getrainbowcolor(portalhues[i][2])}
	end
	
	--hats.
	mariohats = {}
	for i = 1, 4 do
		mariohats[i] = {1}
	end
	
	------------------
	-- MARIO COLORS --
	------------------
	--1: hat, pants (red)
	--2: shirt, shoes (brown-green)
	--3: skin (yellow-orange)
	
	mariocolors = {}
	mariocolors[1] = {{224,  32,   0}, {136, 112,   0}, {252, 152,  56}}
	mariocolors[2] = {{255, 255, 255}, {  0, 160,   0}, {252, 152,  56}}
	mariocolors[3] = {{  0,   0,   0}, {200,  76,  12}, {252, 188, 176}}
	mariocolors[4] = {{ 32,  56, 236}, {  0, 128, 136}, {252, 152,  56}}
	for i = 5, players do
		mariocolors[i] = mariocolors[math.random(4)]
	end
	
	--STARCOLORS
	starcolors = {}
	starcolors[1] = {{  0,   0,   0}, {200,  76,  12}, {252, 188, 176}}
	starcolors[2] = {{  0, 168,   0}, {252, 152,  56}, {252, 252, 252}}
	starcolors[3] = {{252, 216, 168}, {216,  40,   0}, {252, 152,  56}}
	starcolors[4] = {{216,  40,   0}, {252, 152,  56}, {252, 252, 252}}

	flowercolor = {{252, 216, 168}, {216,  40,   0}, {252, 152,  56}}
	hammersuitcolor = {{  0,   0,   0}, { 255, 255, 255}, {252, 152,  56}}
	frogsuitcolor = {{  0, 168,   0}, {  0,   0,   0}, {252, 152,  56}}
	leafcolor = {{224, 32,   0}, {136, 112,   0}, {252, 152,  56}}
	iceflowercolor = {{255, 255, 255}, {156, 252, 240}, {252, 152,  56}}
	
	--options
	scale = 2
	graphicspack = "SMB"
	volume = 1
	mappack = "onlinesmb"
	vsync = false

	mappackfolder = "mappacks"
	players = oldplayers
	
	reachedworlds = {}
end

function suspendgame()
	local s = ""
	if marioworld == "M" then
		marioworld = 8
		mariolevel = 4
	end
	s = s .. "world/" .. marioworld .. "|"
	s = s .. "level/" .. mariolevel .. "|"
	s = s .. "coincount/" .. mariocoincount .. "|"
	s = s .. "score/" .. marioscore .. "|"
	s = s .. "players/" .. players .. "|"
	for i = 1, players do
		if mariolivecount ~= false then
			s = s .. "lives/" .. i .. "/" .. mariolives[i] .. "|"
		end
		if objects["player"][i] then
			s = s .. "size/" .. i .. "/" .. objects["player"][i].size .. "|"
		else
			s = s .. "size/" .. i .."/1|"
		end
	end
	s = s .. mappackfolder .. "/" .. mappack
	
	love.filesystem.write("suspend.txt", s)
	
	love.audio.stop()
	menu_load()
end

function continuegame()
	if not love.filesystem.exists("suspend.txt") then
		return
	end
	
	local s = love.filesystem.read("suspend.txt")
	
	mariosizes = {}
	mariolives = {}
	
	local split = s:split("|")
	for i = 1, #split do
		local split2 = split[i]:split("/")
		if split2[1] == "world" then
			marioworld = tonumber(split2[2])
		elseif split2[1] == "level" then
			mariolevel = tonumber(split2[2])
		elseif split2[1] == "coincount" then
			mariocoincount = tonumber(split2[2])
		elseif split2[1] == "score" then
			marioscore = tonumber(split2[2])
		elseif split2[1] == "players" then
			players = tonumber(split2[2])
		elseif split2[1] == "lives" and mariolivecount ~= false then
			mariolives[tonumber(split2[2])] = tonumber(split2[3])
		elseif split2[1] == "size" then
			mariosizes[tonumber(split2[2])] = tonumber(split2[3])
		elseif split2[1] == "mappack" then
			mappack = split2[2]
		end
	end
	
	love.filesystem.remove("suspend.txt")
end

function changescale(s, fullscreen)
	scale = s
	
	if fullscreen then
		fullscreen = true
		scale = 2
		love.graphics.setMode(800, 600, fullscreen, vsync, fsaa)
	end
	
	uispace = math.floor(width*16*scale/4)
	love.graphics.setMode(width*16*scale, 224*scale, fullscreen, vsync, fsaa) --27x14 blocks (15 blocks actual height)
	
	gamewidth = love.graphics.getWidth()
	gameheight = love.graphics.getHeight()
	
	if shaders then
		shaders:refresh()
	end

	chatlogfont = newFontFallback("chatfont.ttf", 7*scale)
	bigchatlogfont = newFontFallback("chatfont.ttf", 14*scale)
end

function love.keypressed(key, unicode)
	if keyprompt then
		keypromptenter("key", key)
		return
	end

	for i, v in pairs(guielements) do
		if v:keypress(key, unicode) then
			return
		end
	end
	
	if key == "f12" then
		love.mouse.setGrab(not love.mouse.isGrabbed())
	end
	
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" then
		--konami code
		if key == konami[konamii] then
			konamii = konamii + 1
			if konamii == #konami+1 then
				if konamisound:isStopped() then
					playsound(konamisound)
				end
				gamefinished = true
				saveconfig()
				konamii = 1
			end
		else
			konamii = 1
		end
		
		menu_keypressed(key, unicode)
	elseif gamestate == "game" then
		game_keypressed(key, unicode)
	elseif gamestate == "intro" then
		intro_keypressed()
	end
end

function love.keyreleased(key, unicode)
	if gamestate == "menu" or gamestate == "options" then
		menu_keyreleased(key, unicode)
	elseif gamestate == "game" then
		game_keyreleased(key, unicode)
	end
end

function love.mousepressed(x, y, button)
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "options" then
		menu_mousepressed(x, y, button)
	elseif gamestate == "game" then
		game_mousepressed(x, y, button)
	elseif gamestate == "intro" then
		intro_mousepressed()
	end
	
	for i, v in pairs(guielements) do
		if v.priority then
			if v:click(x, y, button) then
				return
			end
		end
	end
	
	for i, v in pairs(guielements) do
		if not v.priority then
			if v:click(x, y, button) then
				return
			end
		end
	end
end

function love.mousereleased(x, y, button)
	if gamestate == "menu" or gamestate == "options" then
		menu_mousereleased(x, y, button)
	elseif gamestate == "game" then
		game_mousereleased(x, y, button)
	end
	
	for i, v in pairs(guielements) do
		v:unclick(x, y, button)
	end
end

function love.joystickpressed(joystick, button)
	if keyprompt then
		keypromptenter("joybutton", joystick, button)
		return
	end
	
	if gamestate == "menu" or gamestate == "options" then
		menu_joystickpressed(joystick, button)
	elseif gamestate == "game" then
		game_joystickpressed(joystick, button)
	end
end

function love.joystickreleased(joystick, button)
	if gamestate == "menu" or gamestate == "options" then
		menu_joystickreleased(joystick, button)
	elseif gamestate == "game" then
		game_joystickreleased(joystick, button)
	end
end

--[[local function error_printer(msg, layer)
    print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errhand(msg)

	if clientisnetworkhost and usemagic then
		magicdns_remove()
	end
    msg = tostring(msg)

    error_printer(msg, 2)

    if not love.graphics or not love.event or not love.graphics.isCreated() then
        return
    end

    -- Load.
    if love.audio then love.audio.stop() end
    love.graphics.reset()
    love.graphics.setBackgroundColor(89, 157, 220)
    local font = love.graphics.newFont(14)
    love.graphics.setFont(font)

    love.graphics.setColor(255, 255, 255, 255)

    local trace = debug.traceback()

    love.graphics.clear()

    local err = {}

    table.insert(err, "Error\n")
    table.insert(err, msg.."\n\n")

    for l in string.gmatch(trace, "(.-)\n") do
        if not string.match(l, "boot.lua") then
            l = string.gsub(l, "stack traceback:", "Traceback\n")
            table.insert(err, l)
        end
    end

    local p = table.concat(err, "\n")

    p = string.gsub(p, "\t", "")
    p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

    local function draw()
        love.graphics.clear()
        love.graphics.setFont(font)
        love.graphics.setColor(255, 255, 255)
        love.graphics.printf(p, 70, 70, love.graphics.getWidth() - 70)
       	local newfont = love.graphics.newFont(love.graphics.getWidth()*.03)
       	love.graphics.setFont(newfont)
       	love.graphics.setColor(255, 0, 0)
       	love.graphics.printf("SEND A SCREENSHOT TO ROSSEVANSBUSINESS@GMAIL.COM", 70, 0, love.graphics.getWidth() - 70)
        love.graphics.present()
    end

    draw()

    local e, a, b, c
    while true do
        e, a, b, c = love.event.wait()

        if e == "quit" then
            return
        end
        if e == "keypressed" and a == "escape" then
            return
        end

        draw()

    end

end]]

function round(num, idp) --Not by me
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function getrainbowcolor(i)
	local whiteness = 255
	local r, g, b
	if i < 1/6 then
		r = 1
		g = i*6
		b = 0
	elseif i >= 1/6 and i < 2/6 then
		r = (1/6-(i-1/6))*6
		g = 1
		b = 0
	elseif i >= 2/6 and i < 3/6 then
		r = 0
		g = 1
		b = (i-2/6)*6
	elseif i >= 3/6 and i < 4/6 then
		r = 0
		g = (1/6-(i-3/6))*6
		b = 1
	elseif i >= 4/6 and i < 5/6 then
		r = (i-4/6)*6
		g = 0
		b = 1
	else
		r = 1
		g = 0
		b = (1/6-(i-5/6))*6
	end
	
	return {round(r*whiteness), round(g*whiteness), round(b*whiteness), 255}
end

function newRecoloredImage(path, tablein, tableout)
	local imagedata = love.image.newImageData( path )
	local width, height = imagedata:getWidth(), imagedata:getHeight()
	
	for y = 0, height-1 do
		for x = 0, width-1 do
			local oldr, oldg, oldb, olda = imagedata:getPixel(x, y)
			
			if olda > 128 then
				for i = 1, #tablein do
					if oldr == tablein[i][1] and oldg == tablein[i][2] and oldb == tablein[i][3] then
						local r, g, b = unpack(tableout[i])
						imagedata:setPixel(x, y, r, g, b, olda)
					end
				end
			end
		end
	end
	
	return love.graphics.newImage(imagedata)
end

function string:split(delimiter) --Not by me
	local result = {}
	local from  = 1
	local delim_from, delim_to = string.find( self, delimiter, from  )
	while delim_from do
		table.insert( result, string.sub( self, from , delim_from-1 ) )
		from = delim_to + 1
		delim_from, delim_to = string.find( self, delimiter, from  )
	end
	table.insert( result, string.sub( self, from  ) )
	return result
end

function tablecontains(t, entry)
	for i, v in pairs(t) do
		if v == entry then
			return true
		end
	end
	return false
end

function getaveragecolor(imgdata, cox, coy)
	local xstart = (cox-1)*17
	local ystart = (coy-1)*17
	
	local r, g, b = 0, 0, 0
	
	local count = 0
	
	for x = xstart, xstart+15 do
		for y = ystart, ystart+15 do
			local pr, pg, pb, a = imgdata:getPixel(x, y)
			if a > 127 then
				r, g, b = r+pr, g+pg, b+pb
				count = count + 1
			end
		end
	end
	
	r, g, b = r/count, g/count, b/count
	
	return r, g, b
end

function keyprompt_update()
	if keyprompt then
		for i = 1, prompt.joysticks do
			for j = 1, #prompt.joystick[i].validhats do
				local dir = love.joystick.getHat(i, prompt.joystick[i].validhats[j])
				if dir ~= "c" then
					keypromptenter("joyhat", i, prompt.joystick[i].validhats[j], dir)
					return
				end
			end
			
			for j = 1, prompt.joystick[i].axes do
				local value = love.joystick.getAxis(i, j)
				if value > prompt.joystick[i].axisposition[j] + joystickdeadzone then
					keypromptenter("joyaxis", i, j, "pos")
					return
				elseif value < prompt.joystick[i].axisposition[j] - joystickdeadzone then
					keypromptenter("joyaxis", i, j, "neg")
					return
				end
			end
		end
	end
end

function print_r (t, indent) --Not by me
	local indent=indent or ''
	for key,value in pairs(t) do
		io.write(indent,'[',tostring(key),']') 
		if type(value)=="table" then io.write(':\n') print_r(value,indent..'\t')
		else io.write(' = ',tostring(value),'\n') end
	end
end

function love.focus(f)
	if not f and gamestate == "game"and not editormode and not levelfinished and not everyonedead and not onlinemp  then
		pausemenuopen = true
		love.audio.pause()
	end
end

function openSaveFolder(subfolder) --By Slime
	local path = love.filesystem.getSaveDirectory()
	path = subfolder and path.."/"..subfolder or path
	
	local cmdstr
	local successval = 0
	
	if os.getenv("WINDIR") then -- lolwindows
		--cmdstr = "Explorer /root,%s"
		if path:match("LOVE") then --hardcoded to fix ISO characters in usernames and made sure release mode doesn't mess anything up -saso
			cmdstr = "Explorer %%appdata%%\\LOVE\\Marin0"
		else
			cmdstr = "Explorer %%appdata%%\\Marin0"
		end
		path = path:gsub("/", "\\")
		successval = 1
	elseif os.getenv("HOME") then
		if path:match("/Library/Application Support") then -- OSX
			cmdstr = "open \"%s\""
		else -- linux?
			cmdstr = "xdg-open \"%s\""
		end
	end
	
	-- returns true if successfully opened folder
	return cmdstr and os.execute(cmdstr:format(path)) == successval
end

function getupdate()
	local onlinedata, code = http.request("http://rossevansgames.com/onlineversion.txt")
	
	if code ~= 200 then
		return false
	elseif not onlinedata then
		return false
	end
	
	local latestversion
	
	latestversion = tonumber(onlinedata)
	
	if latestversion and latestversion > marioversion then
		return true
	end
	return false
end

function properprint(s, x, y)
	local startx = x
	for i = 1, string.len(tostring(s)) do
		local char = string.sub(s, i, i)
		if char == "|" then
			x = startx-((i)*8)*scale
			y = y + 10*scale
		elseif fontquads[char] then
			love.graphics.drawq(fontimage, fontquads[char], x+((i-1)*8)*scale, y, 0, scale, scale)
		end
	end
end

function properprintbackground(s, x, y, include, color, sc)
	local scale = sc or scale
	local startx = x
	local skip = 0
	for i = 1, string.len(tostring(s)) do
		if skip > 0 then
			skip = skip - 1
		else
			local char = string.sub(s, i, i)
			if char == "|" then
				x = startx-((i)*8)*scale
				y = y + 10*scale
			elseif fontquadsback[char] then
				love.graphics.drawq(fontimageback, fontquadsback[char], x+((i-1)*8)*scale, y-1*scale, 0, scale, scale)
			end
		end
	end
	
	if include then
		properprint(s, x, y, scale)
	end
end

function loadcustombackground()
	local i = 1
	custombackgroundimg = {}
	custombackgroundwidth = {}
	custombackgroundheight = {}
	--try to load map specific background first
	local levelstring = marioworld .. "-" .. mariolevel
	if mariosublevel ~= 0 then
		levelstring = levelstring .. "_" .. mariosublevel
	end
	
	while love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/" .. levelstring .. "background" .. i .. ".png") do
		custombackgroundimg[i] = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/" .. levelstring .. "background" .. i .. ".png")
		custombackgroundwidth[i] = custombackgroundimg[i]:getWidth()/16
		custombackgroundheight[i] = custombackgroundimg[i]:getHeight()/16
		i = i +1
	end
	
	if #custombackgroundimg == 0 then
		while love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/background" .. i .. ".png") do
			custombackgroundimg[i] = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/background" .. i .. ".png")
			custombackgroundwidth[i] = custombackgroundimg[i]:getWidth()/16
			custombackgroundheight[i] = custombackgroundimg[i]:getHeight()/16
			i = i +1
		end
	end
	
	if #custombackgroundimg == 0 then
		custombackgroundimg[i] = newImageFallback("portalbackground.png")
		custombackgroundwidth[i] = custombackgroundimg[i]:getWidth()/16
		custombackgroundheight[i] = custombackgroundimg[i]:getHeight()/16
	end
end

function loadcustomforeground()
	local i = 1
	customforegroundimg = {}
	customforegroundwidth = {}
	customforegroundheight = {}
	--try to load map specific foreground first
	local levelstring = marioworld .. "-" .. mariolevel
	if mariosublevel ~= 0 then
		levelstring = levelstring .. "_" .. mariosublevel
	end
	
	while love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/" .. levelstring .. "foreground" .. i .. ".png") do
		customforegroundimg[i] = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/" .. levelstring .. "foreground" .. i .. ".png")
		customforegroundwidth[i] = customforegroundimg[i]:getWidth()/16
		customforegroundheight[i] = customforegroundimg[i]:getHeight()/16
		i = i +1
	end
	
	if #customforegroundimg == 0 then
		while love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/foreground" .. i .. ".png") do
			customforegroundimg[i] = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/foreground" .. i .. ".png")
			customforegroundwidth[i] = customforegroundimg[i]:getWidth()/16
			customforegroundheight[i] = customforegroundimg[i]:getHeight()/16
			i = i +1
		end
	end
	
	if #customforegroundimg == 0 then
		customforegroundimg[i] = love.graphics.newImage("graphics/SMB/portalbackground.png")
		customforegroundwidth[i] = customforegroundimg[i]:getWidth()/16
		customforegroundheight[i] = customforegroundimg[i]:getHeight()/16
	end
end

function loadanimatedtiles() --animated
	--Taken directly from SE
	if animatedtilecount then
		for i = 1, animatedtilecount do
			tilequads[i+90000] = nil
		end
	end
	
	animatedtiles = {}
			
	local fl = love.filesystem.enumerate(mappackfolder .. "/" .. mappack .. "/animated")
	animatedtilecount = 0
	
	local i = 1
	while love.filesystem.isFile(mappackfolder .. "/" .. mappack .. "/animated/" .. i .. ".png") do
		local v = mappackfolder .. "/" .. mappack .. "/animated/" .. i .. ".png"
		if love.filesystem.isFile(v) and string.sub(v, -4) == ".png" then
			if love.filesystem.isFile(string.sub(v, 1, -5) .. ".txt") then
				animatedtilecount = animatedtilecount + 1
				local t = animatedquad:new(v, love.filesystem.read(string.sub(v, 1, -5) .. ".txt"))
				tilequads[animatedtilecount+90000] = t
				table.insert(animatedtiles, t)
			end
		end
		i = i + 1
	end
end
function love.quit()
	if onlinemp then
		if not clientisnetworkhost then
			local unconnectedstring = tostring(udp)
			local splitstring = unconnectedstring:split(":")
			if splitstring[1] == "udp{connected}" then
				udp:send("clientquit;" .. networkclientnumber)
			end
		else
			server_shutserver()
			print("shutting server")
		end
		if clientisnetworkhost then
			magicdns_remove()
		end
	end
end

function loadgraphics()
	--IMAGES--
	
	menuselection = newImageFallback("menuselect.png")
	mappackback = newImageFallback("mappackback.png")
	mappacknoicon = newImageFallback("mappacknoicon.png")
	mappackoverlay = newImageFallback("mappackoverlay.png")
	mappackhighlight = newImageFallback("mappackhighlight.png")
	
	mappackscrollbar = newImageFallback("mappackscrollbar.png")
	
	uparrowimg = love.graphics.newImage("graphics/" .. graphicspack .. "/uparrow.png")
	downarrowimg = love.graphics.newImage("graphics/" .. graphicspack .. "/downarrow.png")
	
	--tiles
	smbtilesimg = newImageFallback("smbtiles.png")
	portaltilesimg = newImageFallback("portaltiles.png")
	entitiesimg = newImageFallback("entities.png")
	tilequads = {}
	
	rgblist = {}
	
	--add smb tiles
	local imgwidth, imgheight = smbtilesimg:getWidth(), smbtilesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata = love.image.newImageData("graphics/" .. graphicspack .. "/smbtiles.png")
	
	for y = 1, height do
		for x = 1, width do
			table.insert(tilequads, quad:new(smbtilesimg, imgdata, x, y, imgwidth, imgheight))
			local r, g, b = getaveragecolor(imgdata, x, y)
			table.insert(rgblist, {r, g, b})
		end
	end
	smbtilecount = width*height
	
	--add portal tiles
	local imgwidth, imgheight = portaltilesimg:getWidth(), portaltilesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata = love.image.newImageData("graphics/" .. graphicspack .. "/portaltiles.png")
	
	for y = 1, height do
		for x = 1, width do
			table.insert(tilequads, quad:new(portaltilesimg, imgdata, x, y, imgwidth, imgheight))
			local r, g, b = getaveragecolor(imgdata, x, y)
			table.insert(rgblist, {r, g, b})
		end
	end
	portaltilecount = width*height
	
	--add entities
	entityquads = {}
	local imgwidth, imgheight = entitiesimg:getWidth(), entitiesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata = love.image.newImageData("graphics/" .. graphicspack .. "/entities.png")
	
	for y = 1, height do
		for x = 1, width do
			table.insert(entityquads, entity:new(entitiesimg, x, y, imgwidth, imgheight))
			entityquads[#entityquads]:sett(#entityquads)
		end
	end
	entitiescount = width*height
	
	fontimage2 = newImageFallback("smallfont.png")
	numberglyphs = "012458"
	font2quads = {}
	for i = 1, 6 do
		font2quads[string.sub(numberglyphs, i, i)] = love.graphics.newQuad((i-1)*4, 0, 4, 8, 32, 8)
	end
	
	oneuptextimage = newImageFallback("oneuptext.png")
	threeuptextimage = newImageFallback("threeuptext.png")
	
	blockdebrisimage = newImageFallback("blockdebris.png")
	blockdebrisquads = {}
	for y = 1, 4 do
		blockdebrisquads[y] = {}
		for x = 1, 2 do
			blockdebrisquads[y][x] = love.graphics.newQuad((x-1)*8, (y-1)*8, 8, 8, 16, 32)
		end
	end
	
	coinblockanimationimage = newImageFallback("coinblockanimation.png")
	coinblockanimationquads = {}
	for i = 1, 30 do
		coinblockanimationquads[i] = love.graphics.newQuad((i-1)*8, 0, 8, 52, 256, 64)
	end
	
	coinanimationimage = newImageFallback("coinanimation.png")
	coinanimationquads = {}
	for j = 1, 4 do
		coinanimationquads[j] = {}
		for i = 1, 4 do
			coinanimationquads[j][i] = love.graphics.newQuad((i-1)*5, (j-1)*8, 5, 8, 24, 32)
		end
	end
	
	--coinblock
	coinblockimage = newImageFallback("coinblock.png")
	coinblockquads = {}
	for j = 1, 4 do
		coinblockquads[j] = {}
		for i = 1, 4 do
			coinblockquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*16, 16, 16, 80, 64)
		end
	end

	--brickblock
	brickblockimage = newImageFallback("brickblock.png")
	brickblockquads = {}
	for j = 1, 4 do
		brickblockquads[j] = {}
		for i = 1, 4 do
			brickblockquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*16, 16, 16, 80, 64)
		end
	end
	
	--flipblock and other block-like entities
	flipblockimage = love.graphics.newImage("graphics/" .. graphicspack .. "/flipblock.png")
	blocktogglebuttonimage = love.graphics.newImage("graphics/" .. graphicspack .. "/blocktogglebutton.png")
	buttonblockimage = love.graphics.newImage("graphics/" .. graphicspack .. "/buttonblock.png")
	flipblockquad = {}
	
	for y = 1, 4 do
		flipblockquad[y] = {}
		for x = 1, 4 do
			flipblockquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 64, 64)
		end
	end
	
	bigblocktogglebuttonimage = love.graphics.newImage("graphics/" .. graphicspack .. "/bigblocktogglebutton.png")
	bigblockquad = {}
	
	for y = 1, 4 do
		bigblockquad[y] = {}
		for x = 1, 2 do
			bigblockquad[y][x] = love.graphics.newQuad((x-1)*32, (y-1)*32, 32, 32, 64, 128)
		end
	end
	
	--coin
	coinimage = newImageFallback("coin.png")
	coinquads = {}
	for i = 1, 4 do
		coinquads[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 80, 16)
	end
	
	--axe
	axeimg = newImageFallback("axe.png")
	axequads = {}
	for i = 1, 4 do
		axequads[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end
	
	--levelball
	levelballimg = newImageFallback("levelball.png")
	levelballquad = {}
	for x = 1, 4 do
		levelballquad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 16, 16, 16)
	end
	--spring, red
	springimg = newImageFallback("springred.png")
	springquads = {}
	for i = 1, 4 do
		springquads[i] = {}
		for j = 1, 3 do
			springquads[i][j] = love.graphics.newQuad((j-1)*16, (i-1)*32, 16, 32, 48, 128)
		end
	end
	
	--spring, green
	springgreenimg = newImageFallback("springgreen.png")
	springgreenquads = {}
	for i = 1, 4 do
		springgreenquads[i] = {}
		for j = 1, 3 do
			springgreenquads[i][j] = love.graphics.newQuad((j-1)*16, (i-1)*32, 16, 32, 48, 128)
		end
	end
	
	--yoshi
	yoshieggimg = newImageFallback("yoshiegg.png")
	yoshieggquad = {}
	for x = 1, 2 do
		yoshieggquad[x] = love.graphics.newQuad((x-1)*12, 0, 12, 15, 24, 15)
	end
	
	yoshiimage = newImageFallback("yoshi.png")
	yoshiquad = {}
	for x = 1, 10 do
		yoshiquad[x] = love.graphics.newQuad((x-1)*30, 0, 30, 35, 300, 35)
	end
	
	--toad
	toadimg = newImageFallback("toad.png")
	
	--queen I mean princess
	peachimg = newImageFallback("peach.png")

	--platforms
	platformimg = newImageFallback("platform.png")
	platformquad = {}
	for i = 1, 3 do
		platformquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 8, 48, 8)
	end
	platformbonusimg = newImageFallback("platformbonus.png")
	platformbonusquad = {}
	for i = 1, 3 do
		platformbonusquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 8, 48, 8)
	end
	
	seesawimg = newImageFallback("seesaw.png")
	seesawquad = {}
	for i = 1, 4 do
		seesawquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end
	
	titleimage = newImageFallback("title.png")
	titleframe = 1
	titleframes = math.floor(titleimage:getWidth()/176)
	titledelay = nil
	titlequad = {}
	for x = 1, titleframes do
		titlequad[x] = love.graphics.newQuad((x-1)*176, 0, 176, 88, titleimage:getWidth(), titleimage:getHeight())
	end
	playerselectimg = newImageFallback("playerselectarrow.png")
	
	starimg = newImageFallback("star.png")
	starquad = {}
	for i = 1, 4 do
		starquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end
	
	flowerimg = newImageFallback("flower.png")
	iceflowerimg = newImageFallback("iceflower.png")
	flowerquad = {}
	for y = 1, 4 do
		flowerquad[y] = {}
		for x = 1, 4 do
			flowerquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 64, 64)
		end
	end
	
	hammersuitimg = newImageFallback("hammersuit.png")
	hammersuitquad = {}
	for i = 1, 4 do
		hammersuitquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end
	
	frogsuitimg = newImageFallback("frogsuit.png")
	frogsuitquad = {}
	for i = 1, 4 do
		frogsuitquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end
	
	fireballimg = newImageFallback("fireball.png")
	iceballimg = newImageFallback("iceball.png")
	fireballquad = {}
	for i = 1, 4 do
		fireballquad[i] = love.graphics.newQuad((i-1)*8, 0, 8, 8, 80, 16)
	end
	
	for i = 5, 7 do
		fireballquad[i] = love.graphics.newQuad((i-5)*16+32, 0, 16, 16, 80, 16)
	end
	
	vineimg = newImageFallback("vine.png")
	vinequad = {}
	for i = 1, 4 do
		vinequad[i] = {}
		for j = 1, 2 do
			vinequad[i][j] = love.graphics.newQuad((j-1)*16, (i-1)*16, 16, 16, 32, 64) 
		end
	end
	--GLaDOS
	gladosimage = newImageFallback("glados.png")
	gladosquad = {}
	for x = 1, 2 do
		gladosquad[x] = love.graphics.newQuad((x-1)*86, 0, 86, 86, 86, 86)
	end
	
	--cores
	coreimage = newImageFallback("cores.png")
	corequad = {}
	for x = 1, 4 do
		corequad[x] = love.graphics.newQuad((x-1)*13, 0, 13, 12, 52, 12)
	end
	
	--portal gun pedestal
	pedestalimage = newImageFallback("pedestal.png")
	pedestalquad = {}
	
	for x = 1, 10 do
		pedestalquad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 16, 160, 16)
	end
	
	--dount (yummy for your tummy)
	donutimage = newImageFallback("donut.png")
	donutquad = {}
	
	for y = 1, 4 do
		donutquad[y] = {}
		for x = 1, 2 do
			donutquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 32, 64)
		end
	end
	
	--energylauncher
	energylauncherimage = newImageFallback("energylauncher.png")
	energylauncherquad = {}
	
	for y = 1, 2 do
		energylauncherquad[y] = {}
		for x = 1, 2 do
			energylauncherquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 32, 32)
		end
	end
	energyballimage = newImageFallback("energyball.png")
	energyballquad = {}
	
	for x = 1, 4 do
		energyballquad[x] = love.graphics.newQuad((x-1)*8, 0, 8, 8, 32, 8)
	end
	
	--enemies
	shyguyimg = newImageFallback("shyguy.png")
	goombratimage = newImageFallback("goombrat.png")
	drygoombaimage = newImageFallback("drygoomba.png")
	goombaimage = newImageFallback("goomba.png")
	goombaimageframes = math.floor(goombaimage:getWidth()/16)
	goombaquad = {}
	
	for y = 1, 4 do
		goombaquad[y] = {}
		for x = 1, goombaimageframes do
			goombaquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, goombaimage:getWidth(), 64)
		end
	end
	
	thwompimage = newImageFallback("thwomp.png")
	thwompquad = {}
	
	for y = 1, 4 do
		thwompquad[y] = {}
		for x = 1, 2 do
			thwompquad[y][x] = love.graphics.newQuad((x-1)*24, (y-1)*30, 24, 30, 48, 119)
		end
	end
	biggoombaimage = newImageFallback("biggoomba.png")
	biggoombaquad = {}
	
	for y = 1, 4 do
		biggoombaquad[y] = {}
		for x = 1, 2 do
			biggoombaquad[y][x] = love.graphics.newQuad((x-1)*32, (y-1)*32, 32, 32, 64, 128)
		end
	end
	sidestepperimage = newImageFallback("sidestepper.png")
	sidestepperquad = {}
	
	for y = 1, 4 do
		sidestepperquad[y] = {}
		for x = 1, 2 do
			sidestepperquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 32, 64)
		end
	end
	barrelimage = newImageFallback("barrel.png")
	barrelquad = {}
	
	for y = 1, 4 do
		barrelquad[y] = {}
		for x = 1, 2 do
			barrelquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 32, 64)
		end
	end
	ninjiimage = newImageFallback("ninji.png")
	ninjiquad = {}
	
	for y = 1, 4 do
		ninjiquad[y] = {}
		for x = 1, 2 do
			ninjiquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 32, 64)
		end
	end
	bigspikeyimg = newImageFallback("bigspikey.png")
	
	bigspikeyquad = {}
	for x = 1, 4 do
		bigspikeyquad[x] = love.graphics.newQuad((x-1)*32, 0, 32, 32, 128, 32)
	end
	--SPLUNKIN
	splunkinimage = newImageFallback("splunkin.png")
	splunkinquad = {}
	
	for y = 1, 4 do
		splunkinquad[y] = {}
		for x = 1, 2 do
			splunkinquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 32, 64)
		end
	end
	
	splunkinmadimage = newImageFallback("splunkinmad.png")
	splunkinmadquad = {}
	
	for y = 1, 4 do
		splunkinmadquad[y] = {}
		for x = 1, 2 do
			splunkinmadquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 32, 64)
		end
	end
	--enemies
	
	icicleimage = newImageFallback("icicle.png")
	iciclequad = {}
	
	for y = 1, 4 do
		iciclequad[y] = {}
		for x = 1, 2 do
			iciclequad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 32, 64)
		end
	end
	
	paragoombaimage = newImageFallback("paragoomba.png")
	paragoombaquad = {}
	
	for y = 1, 4 do
		paragoombaquad[y] = {}
		for x = 1, 3 do
			paragoombaquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*23, 16, 23, 48, 92)
		end
	end
	
	muncherimg = newImageFallback("muncher.png")
	
	muncherquad = {}
	for x = 1, 4 do
		muncherquad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 16, 64, 16)
	end
	
	spikeyimg = newImageFallback("spikey.png")
	
	spikeyquad = {}
	for x = 1, 4 do
		spikeyquad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 16, 64, 16)
	end
	
	parabeetleimg = newImageFallback("parabeetle.png")
	
	parabeetlequad = {}
	for x = 1, 4 do
		parabeetlequad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 16, 64, 16)
	end
	
	booimage = newImageFallback("boo.png")
	booquad = {}
	
	for y = 1, 4 do
		booquad[y] = {}
		for x = 1, 2 do
			booquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 32, 64)
		end
	end
	
	moleimage = newImageFallback("mole.png")
	molequad = {}
	
	for y = 1, 4 do
		molequad[y] = {}
		for x = 1, 4 do
			molequad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 64, 64)
		end
	end
	
	bigmoleimage = newImageFallback("bigmole.png")
	bigmolequad = {}
	
	for y = 1, 4 do
		bigmolequad[y] = {}
		for x = 1, 2 do
			bigmolequad[y][x] = love.graphics.newQuad((x-1)*32, (y-1)*32, 32, 32, 64, 128)
		end
	end
	
	bombimage = newImageFallback("bomb.png")
	bombquad = {}
	
	for y = 1, 4 do
		bombquad[y] = {}
		for x = 1, 3 do
			bombquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 48, 64)
		end
	end
	
	ampimage = newImageFallback("amp.png")
	ampquad = {}
	
	for y = 1, 4 do
		ampquad[y] = {}
		for x = 1, 4 do
			ampquad[y][x] = love.graphics.newQuad((x-1)*32, (y-1)*32, 32, 32, 128, 128)
		end
	end
	
	windleafimage = newImageFallback("windleaf.png")
	windleafquad = {}
	for y = 1, 4 do
		windleafquad[y] = {}
		for x = 1, 2 do
			windleafquad[y][x] = love.graphics.newQuad((x-1)*6, (y-1)*6, 6, 6, 12, 24)
		end
	end
	
	lakitoimg = newImageFallback("lakito.png")
	lakitoquad = {}
	for x = 1, 2 do
		lakitoquad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 24, 32, 24)
	end
	
	angrysunimg = newImageFallback("angrysun.png")
	angrysunquad = {}
	for x = 1, 2 do
		angrysunquad[x] = love.graphics.newQuad((x-1)*28, 0, 28, 28, 56, 28)
	end
	
	koopaimage = newImageFallback("koopa.png")
	kooparedimage = newImageFallback("koopared.png")
	beetleimage = newImageFallback("beetle.png")
	koopablueimage = newImageFallback("koopablue.png")
	koopaquad = {}
	
	for y = 1, 4 do
		koopaquad[y] = {}
		for x = 1, 5 do
			koopaquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*24, 16, 24, 128, 128)
		end
	end
	
	drybonesimage = newImageFallback("drybones.png")
	drybonesredimage = newImageFallback("drybones.png")
	drybeetleimage = newImageFallback("drybones.png")
	drybonesquad = {}
	
	for y = 1, 4 do
		drybonesquad[y] = {}
		for x = 1, 5 do
			drybonesquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*24, 16, 24, 128, 128)
		end
	end
	
	bigkoopaimage = newImageFallback("bigkoopa.png")
	bigbeetleimage = newImageFallback("bigbeetle.png")
	bigkoopaquad = {}
	
	for y = 1, 4 do
		bigkoopaquad[y] = {}
		for x = 1, 5 do
			bigkoopaquad[y][x] = love.graphics.newQuad((x-1)*32, (y-1)*48, 32, 48, 256, 256)
		end
	end
	
	cheepcheepimg = newImageFallback("cheepcheep.png")
	cheepcheepquad = {}
	
	cheepcheepquad[1] = {}
	cheepcheepquad[1][1] = love.graphics.newQuad(0, 0, 16, 16, 32, 32)
	cheepcheepquad[1][2] = love.graphics.newQuad(16, 0, 16, 16, 32, 32)
	
	cheepcheepquad[2] = {}
	cheepcheepquad[2][1] = love.graphics.newQuad(0, 16, 16, 16, 32, 32)
	cheepcheepquad[2][2] = love.graphics.newQuad(16, 16, 16, 16, 32, 32)
	
	sleepfishimg = newImageFallback("sleepfish.png") --seperate quad YAY
	sleepfishquad = {}
	
	for y = 1, 2 do
		sleepfishquad[y] = {}
		for x = 1, 2 do
			sleepfishquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 32, 32)
		end
	end
	
	meteorimg = newImageFallback("meteor.png")
	meteorquad = {}
	
	meteorquad[1] = {}
	meteorquad[1][1] = love.graphics.newQuad(0, 0, 16, 16, 32, 32)
	meteorquad[1][2] = love.graphics.newQuad(16, 0, 16, 16, 32, 32)
	
	fishboneimg = newImageFallback("fishbone.png")
	fishbonequad = {}
	
	fishbonequad[1] = {}
	fishbonequad[1][1] = love.graphics.newQuad(0, 0, 16, 16, 32, 32)
	fishbonequad[1][2] = love.graphics.newQuad(16, 0, 16, 16, 32, 32)
	
	fishbonequad[2] = {}
	fishbonequad[2][1] = love.graphics.newQuad(0, 16, 16, 16, 32, 32)
	fishbonequad[2][2] = love.graphics.newQuad(16, 16, 16, 16, 32, 32)
	
	squidimg = newImageFallback("squid.png")
	pinksquidimg = newImageFallback("pinksquid.png")
	squidquad = {}
	for x = 1, 2 do
		squidquad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 24, 32, 32)
	end
	
	bulletbillimg = newImageFallback("bulletbill.png")
	bulletbillquad = {}
	
	for y = 1, 4 do
		bulletbillquad[y] = love.graphics.newQuad(0, (y-1)*16, 16, 16, 16, 64)
	end
	
	bigbillimg = newImageFallback("bigbill.png")
	bigbillquad = {}
	
	for y = 1, 4 do
		bigbillquad[y] = love.graphics.newQuad(0, (y-1)*32, 32, 32, 32, 128)
	end
	
	kingbillimg = newImageFallback("kingbill.png")
	kingbillquad = {}
	
	for y = 1, 4 do
		kingbillquad[y] = love.graphics.newQuad(0, (y-1)*200, 200, 200, 200, 800)
	end
	
	cannonballimg = newImageFallback("cannonball.png")
	cannonballquad = love.graphics.newQuad(0, 0, 12, 12, 12, 12)
	
	torpedotedimage = newImageFallback("torpedoted.png")
	torpedotedquad = {}
	
	for y = 1, 4 do
		torpedotedquad[y] = {}
		for x = 1, 2 do
			torpedotedquad[y][x] = love.graphics.newQuad((x-1)*32, (y-1)*16, 32, 16, 64, 64)
		end
	end
	
	torpedolauncherimg = newImageFallback("torpedolauncher.png")
	torpedolauncherquads = {}
	for j = 1, 4 do
		torpedolauncherquads[j] = {}
		for i = 1, 2 do
			torpedolauncherquads[j][i] = love.graphics.newQuad((i-1)*32, (j-1)*24, 32, 24, 64, 96)
		end
	end
	
	hammerbrosimg = newImageFallback("hammerbros.png")
	hammerbrosquad = {}
	for y = 1, 4 do
		hammerbrosquad[y] = {}
		for x = 1, 4 do
			hammerbrosquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*34, 16, 34, 64, 256)
		end
	end	
	
	firebrosimg = newImageFallback("firebros.png")
	firebrosquad = {}
	for y = 1, 4 do
		firebrosquad[y] = {}
		for x = 1, 4 do
			firebrosquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*34, 16, 34, 64, 256)
		end
	end
	
	boomerangbrosimg = newImageFallback("boomerangbros.png")
	boomerangbrosquad = {}
	for y = 1, 4 do
		boomerangbrosquad[y] = {}
		for x = 1, 4 do
			boomerangbrosquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*34, 16, 34, 64, 256)
		end
	end	
	
	hammerimg = newImageFallback("hammer.png")
	hammerquad = {}
	for j = 1, 4 do
		hammerquad[j] = {}
		for i = 1, 4 do
			hammerquad[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*16, 16, 16, 64, 64)
		end
	end
	
	boomerangimg = newImageFallback("boomerang.png")
	boomerangquad = {}
	for j = 1, 4 do
		boomerangquad[j] = {}
		for i = 1, 4 do
			boomerangquad[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*16, 16, 16, 64, 64)
		end
	end
	
	plantimg = newImageFallback("plant.png")
	plantquads = {}
	for j = 1, 4 do
		plantquads[j] = {}
		for i = 1, 2 do
			plantquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*24, 16, 24, 32, 128)
		end
	end

	redplantimg = newImageFallback("redplant.png")
	redplantquads = {}
	for j = 1, 4 do
		redplantquads[j] = {}
		for i = 1, 2 do
			redplantquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*24, 16, 24, 32, 128)
		end
	end

	reddownplantimg = newImageFallback("reddownplant.png")
	reddownplantquads = {}
	for j = 1, 4 do
		reddownplantquads[j] = {}
		for i = 1, 2 do
			reddownplantquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*24, 16, 24, 32, 128)
		end
	end
	
	downplantimg = newImageFallback("downplant.png")
	downplantquads = {}
	for j = 1, 4 do
		downplantquads[j] = {}
		for i = 1, 2 do
			downplantquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*24, 16, 24, 32, 128)
		end
	end

	
	fireplantimg = newImageFallback("fireplant.png")
	fireplantquads = {}
	for j = 1, 4 do
		fireplantquads[j] = {}
		for i = 1, 2 do
			fireplantquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*23, 16, 23, 32, 128)
		end
	end
	
	downfireplantimg = newImageFallback("downfireplant.png")
	downfireplantquads = {}
	for j = 1, 4 do
		downfireplantquads[j] = {}
		for i = 1, 2 do
			downfireplantquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*23, 16, 23, 32, 128)
		end
	end
	
	longfireimg = newImageFallback("longfire.png")
	longfirequad = {}
	for i = 1, 5 do
		longfirequad[i] = love.graphics.newQuad(0, (i-1)*14, 47, 14, 47, 70)
	end
	
	fireimg = newImageFallback("fire.png")
	firequad = {love.graphics.newQuad(0, 0, 24, 8, 48, 8), love.graphics.newQuad(24, 0, 24, 8, 48, 8)}
	
	upfireimg = newImageFallback("upfire.png")
	
	bowserimg = newImageFallback("bowser.png")
	bowserquad = {}
	bowserquad[1] = {love.graphics.newQuad(0, 0, 32, 32, 64, 64), love.graphics.newQuad(32, 0, 32, 32, 64, 64)}
	bowserquad[2] = {love.graphics.newQuad(0, 32, 32, 32, 64, 64), love.graphics.newQuad(32, 32, 32, 32, 64, 64)}
	
	decoysimg = newImageFallback("decoys.png")
	decoysquad = {}
	for y = 1, 7 do
		decoysquad[y] = love.graphics.newQuad(0, (y-1)*32, 32, 32, 64, 256)
	end
	
	boximage = newImageFallback("box.png")
	box2image = newImageFallback("box2.png")
	boxquad = love.graphics.newQuad(0, 0, 12, 12, 16, 16)
	
	--turrets
		--normal
		turretarmimg = newImageFallback("turretarm.png")
		turret2armimg = newImageFallback("turret2arm.png")
		
		turretleftimg = newImageFallback("turretleft.png")
		turretrightimg = newImageFallback("turretright.png")
		turret2leftimg = newImageFallback("turret2left.png")
		turret2rightimg = newImageFallback("turret2right.png")
		
		--rocket
		rocketturretimage = newImageFallback("rocketturret.png")
		rocketturretquad = {}
		
		for x = 1, 3 do
			rocketturretquad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 16, 48, 16)
		end
		turretrocketimage = newImageFallback("turretrocket.png")
		turretrocketquad = {}
		
		for x = 1, 2 do
			turretrocketquad[x] = love.graphics.newQuad((x-1)*5, 0, 5, 5, 5, 5)
		end
	
	flagimg = newImageFallback("flag.png")
	castleflagimg = newImageFallback("castleflag.png")
	
	bubbleimg = newImageFallback("bubble.png")

	boomboomimg = newImageFallback("boomboom.png")
	
	boomboomquad = {}
	for x = 1, 8 do
		boomboomquad[x] = love.graphics.newQuad((x-1)*32, 0, 32, 32, 256, 32)
	end
	
	--eh
	rainboomimg = newImageFallback("rainboom.png")
	rainboomquad = {}
	for x = 1, 7 do
		for y = 1, 7 do
			rainboomquad[x+(y-1)*7] = love.graphics.newQuad((x-1)*204, (y-1)*182, 204, 182, 1428, 1274)
		end
	end
	
	logo = newImageFallback("stabyourself.png")
	logoblood = newImageFallback("stabyourselfblood.png")
	
	--GUI
	checkboximg = newImageFallback("GUI/checkbox.png")
	checkboxquad = {{love.graphics.newQuad(0, 0, 9, 9, 18, 18), love.graphics.newQuad(9, 0, 9, 9, 18, 18)}, {love.graphics.newQuad(0, 9, 9, 9, 18, 18), love.graphics.newQuad(9, 9, 9, 9, 18, 18)}}
	
	dropdownarrowimg = newImageFallback("GUI/dropdownarrow.png")
	
	gradientimg = newImageFallback("gradient.png");gradientimg:setFilter("linear", "linear")
	
	--Ripping off
	minecraftbreakimg = newImageFallback("Minecraft/blockbreak.png")
	minecraftbreakquad = {}
	for i = 1, 10 do
		minecraftbreakquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 160, 16)
	end
	minecraftgui = newImageFallback("Minecraft/gui.png")
	minecraftselected = newImageFallback("Minecraft/selected.png")
	
	--players
	marioanimations = {}
	marioanimations[0] = newImageFallback("player/marioanimations0.png")
	marioanimations[1] = newImageFallback("player/marioanimations1.png")
	marioanimations[2] = newImageFallback("player/marioanimations2.png")
	marioanimations[3] = newImageFallback("player/marioanimations3.png")

	classicmarioanimations = {}
	for x = 0, 3 do
		classicmarioanimations[x] = newImageFallback("player/classic/marioanimations" .. x .. ".png")
	end
	
	minecraftanimations = {}
	minecraftanimations[0] = newImageFallback("Minecraft/marioanimations0.png")
	minecraftanimations[1] = newImageFallback("Minecraft/marioanimations1.png")
	minecraftanimations[2] = newImageFallback("Minecraft/marioanimations2.png")
	minecraftanimations[3] = newImageFallback("Minecraft/marioanimations3.png")
	
	marioidle = {}
	mariorun = {}
	marioslide = {}
	mariojump = {}
	mariodie = {}
	marioclimb = {}
	marioswim = {}
	mariogrow = {}
	mariogrownogun = {}
	
	for i = 1, 5 do
		marioidle[i] = love.graphics.newQuad(0, (i-1)*20, 20, 20, 512, 128)
		
		mariorun[i] = {}
		mariorun[i][1] = love.graphics.newQuad(20, (i-1)*20, 20, 20, 512, 128)
		mariorun[i][2] = love.graphics.newQuad(40, (i-1)*20, 20, 20, 512, 128)
		mariorun[i][3] = love.graphics.newQuad(60, (i-1)*20, 20, 20, 512, 128)
		
		marioslide[i] = love.graphics.newQuad(80, (i-1)*20, 20, 20, 512, 128)
		mariojump[i] = love.graphics.newQuad(100, (i-1)*20, 20, 20, 512, 128)
		mariodie[i] = love.graphics.newQuad(120, (i-1)*20, 20, 20, 512, 128)
		
		marioclimb[i] = {}
		marioclimb[i][1] = love.graphics.newQuad(140, (i-1)*20, 20, 20, 512, 128)
		marioclimb[i][2] = love.graphics.newQuad(160, (i-1)*20, 20, 20, 512, 128)
		
		marioswim[i] = {}
		marioswim[i][1] = love.graphics.newQuad(180, (i-1)*20, 20, 20, 512, 128)
		marioswim[i][2] = love.graphics.newQuad(200, (i-1)*20, 20, 20, 512, 128)
		
		mariogrow[i] = love.graphics.newQuad(260, 0, 20, 24, 512, 128)
		mariogrownogun[i] = love.graphics.newQuad(280, 0, 20, 24, 512, 128)
	end
	
	
	bigmarioanimations = {}
	bigmarioanimations[0] = newImageFallback("player/bigmarioanimations0.png")
	bigmarioanimations[1] = newImageFallback("player/bigmarioanimations1.png")
	bigmarioanimations[2] = newImageFallback("player/bigmarioanimations2.png")
	bigmarioanimations[3] = newImageFallback("player/bigmarioanimations3.png")
	bigclassicmarioanimations = {}
	for x = 0, 3 do
		bigclassicmarioanimations[x] = newImageFallback("player/classic/bigmarioanimations" .. x .. ".png")
	end
	
	bigminecraftanimations = {}
	bigminecraftanimations[0] = newImageFallback("Minecraft/bigmarioanimations0.png")
	bigminecraftanimations[1] = newImageFallback("Minecraft/bigmarioanimations1.png")
	bigminecraftanimations[2] = newImageFallback("Minecraft/bigmarioanimations2.png")
	bigminecraftanimations[3] = newImageFallback("Minecraft/bigmarioanimations3.png")
	
	bigmarioidle = {}
	bigmariorun = {}
	bigmarioslide = {}
	bigmariojump = {}
	bigmariofire = {}
	bigmarioclimb = {}
	bigmarioswim = {}
	bigmarioduck = {} --hehe duck.
	
	for i = 1, 5 do
		bigmarioidle[i] = love.graphics.newQuad(0, (i-1)*36, 20, 36, 512, 256)
		
		bigmariorun[i] = {}
		bigmariorun[i][1] = love.graphics.newQuad(20, (i-1)*36, 20, 36, 512, 256)
		bigmariorun[i][2] = love.graphics.newQuad(40, (i-1)*36, 20, 36, 512, 256)
		bigmariorun[i][3] = love.graphics.newQuad(60, (i-1)*36, 20, 36, 512, 256)
		
		bigmarioslide[i] = love.graphics.newQuad(80, (i-1)*36, 20, 36, 512, 256)
		bigmariojump[i] = love.graphics.newQuad(100, (i-1)*36, 20, 36, 512, 256)
		bigmariofire[i] = love.graphics.newQuad(120, (i-1)*36, 20, 36, 512, 256)
		
		bigmarioclimb[i] = {}
		bigmarioclimb[i][1] = love.graphics.newQuad(140, (i-1)*36, 20, 36, 512, 256)
		bigmarioclimb[i][2] = love.graphics.newQuad(160, (i-1)*36, 20, 36, 512, 256)
		
		bigmarioswim[i] = {}
		bigmarioswim[i][1] = love.graphics.newQuad(180, (i-1)*36, 20, 36, 512, 256)
		bigmarioswim[i][2] = love.graphics.newQuad(200, (i-1)*36, 20, 36, 512, 256)
		
		bigmarioduck[i] = love.graphics.newQuad(260, (i-1)*36, 20, 36, 512, 256)
	end
	
	hammermarioanimations = {}
	hammermarioanimations[0] = newImageFallback("player/hammermarioanimations0.png")
	hammermarioanimations[1] = newImageFallback("player/hammermarioanimations1.png")
	hammermarioanimations[2] = newImageFallback("player/hammermarioanimations2.png")
	hammermarioanimations[3] = newImageFallback("player/hammermarioanimations3.png")
	
	hammerminecraftanimations = {}
	hammerminecraftanimations[0] = newImageFallback("Minecraft/hammermarioanimations0.png")
	hammerminecraftanimations[1] = newImageFallback("Minecraft/hammermarioanimations1.png")
	hammerminecraftanimations[2] = newImageFallback("Minecraft/hammermarioanimations2.png")
	hammerminecraftanimations[3] = newImageFallback("Minecraft/hammermarioanimations3.png")
	
	hammermarioidle = {}
	hammermariorun = {}
	hammermarioslide = {}
	hammermariojump = {}
	hammermariofire = {}
	hammermarioclimb = {}
	hammermarioswim = {}
	hammermarioduck = {} --hehe duck.
	
	for i = 1, 5 do
		hammermarioidle[i] = love.graphics.newQuad(0, (i-1)*36, 20, 36, 512, 256)
		
		hammermariorun[i] = {}
		hammermariorun[i][1] = love.graphics.newQuad(20, (i-1)*36, 20, 36, 512, 256)
		hammermariorun[i][2] = love.graphics.newQuad(40, (i-1)*36, 20, 36, 512, 256)
		hammermariorun[i][3] = love.graphics.newQuad(60, (i-1)*36, 20, 36, 512, 256)
		
		hammermarioslide[i] = love.graphics.newQuad(80, (i-1)*36, 20, 36, 512, 256)
		hammermariojump[i] = love.graphics.newQuad(100, (i-1)*36, 20, 36, 512, 256)
		hammermariofire[i] = love.graphics.newQuad(120, (i-1)*36, 20, 36, 512, 256)
		
		hammermarioclimb[i] = {}
		hammermarioclimb[i][1] = love.graphics.newQuad(140, (i-1)*36, 20, 36, 512, 256)
		hammermarioclimb[i][2] = love.graphics.newQuad(160, (i-1)*36, 20, 36, 512, 256)
		
		hammermarioswim[i] = {}
		hammermarioswim[i][1] = love.graphics.newQuad(180, (i-1)*36, 20, 36, 512, 256)
		hammermarioswim[i][2] = love.graphics.newQuad(200, (i-1)*36, 20, 36, 512, 256)
		
		hammermarioduck[i] = love.graphics.newQuad(260, (i-1)*36, 20, 36, 512, 256)
	end
	
	frogmarioanimations = {}
	frogmarioanimations[0] = newImageFallback("player/frogmarioanimations0.png")
	frogmarioanimations[1] = newImageFallback("player/frogmarioanimations1.png")
	frogmarioanimations[2] = newImageFallback("player/frogmarioanimations2.png")
	frogmarioanimations[3] = newImageFallback("player/frogmarioanimations3.png")
	
	frogminecraftanimations = {}
	frogminecraftanimations[0] = newImageFallback("Minecraft/frogmarioanimations0.png")
	frogminecraftanimations[1] = newImageFallback("Minecraft/frogmarioanimations1.png")
	frogminecraftanimations[2] = newImageFallback("Minecraft/frogmarioanimations2.png")
	frogminecraftanimations[3] = newImageFallback("Minecraft/frogmarioanimations3.png")
	
	frogmarioidle = {}
	frogmariorun = {}
	frogmarioslide = {}
	frogmariojump = {}
	frogmariofire = {}
	frogmarioclimb = {}
	frogmarioswim = {}
	frogmarioduck = {} --hehe duck.
	
	for i = 1, 5 do
		frogmarioidle[i] = love.graphics.newQuad(0, (i-1)*36, 20, 36, 512, 256)
		
		frogmariorun[i] = {}
		frogmariorun[i][1] = love.graphics.newQuad(20, (i-1)*36, 20, 36, 512, 256)
		frogmariorun[i][2] = love.graphics.newQuad(40, (i-1)*36, 20, 36, 512, 256)
		frogmariorun[i][3] = love.graphics.newQuad(60, (i-1)*36, 20, 36, 512, 256)
		
		frogmarioslide[i] = love.graphics.newQuad(80, (i-1)*36, 20, 36, 512, 256)
		frogmariojump[i] = love.graphics.newQuad(100, (i-1)*36, 20, 36, 512, 256)
		frogmariofire[i] = love.graphics.newQuad(120, (i-1)*36, 20, 36, 512, 256)
		
		frogmarioclimb[i] = {}
		frogmarioclimb[i][1] = love.graphics.newQuad(140, (i-1)*36, 20, 36, 512, 256)
		frogmarioclimb[i][2] = love.graphics.newQuad(160, (i-1)*36, 20, 36, 512, 256)
		
		frogmarioswim[i] = {}
		frogmarioswim[i][1] = love.graphics.newQuad(180, (i-1)*36, 20, 36, 512, 256)
		frogmarioswim[i][2] = love.graphics.newQuad(200, (i-1)*36, 20, 36, 512, 256)
		
		frogmarioduck[i] = love.graphics.newQuad(260, (i-1)*36, 20, 36, 512, 256)
	end
	
	raccoonmarioanimations = {}
	raccoonmarioanimations[0] = newImageFallback("player/raccoonmarioanimations0.png")
	raccoonmarioanimations[1] = newImageFallback("player/raccoonmarioanimations1.png")
	raccoonmarioanimations[2] = newImageFallback("player/raccoonmarioanimations2.png")
	raccoonmarioanimations[3] = newImageFallback("player/raccoonmarioanimations3.png")
	
	raccoonminecraftanimations = {}
	raccoonminecraftanimations[0] = newImageFallback("Minecraft/raccoonmarioanimations0.png")
	raccoonminecraftanimations[1] = newImageFallback("Minecraft/raccoonmarioanimations1.png")
	raccoonminecraftanimations[2] = newImageFallback("Minecraft/raccoonmarioanimations2.png")
	raccoonminecraftanimations[3] = newImageFallback("Minecraft/raccoonmarioanimations3.png")
	
	raccoonmarioidle = {}
	raccoonmariorun = {}
	raccoonmarioslide = {}
	raccoonmariojump = {}
	raccoonmariofire = {}
	raccoonmarioclimb = {}
	raccoonmarioswim = {}
	raccoonmarioduck = {} --hehe duck.
	raccoonmariofloat = {}
	raccoonmariospin = {}
	raccoonmariorunfast = {}
	raccoonmariofly = {}
	
	for i = 1, 5 do
		raccoonmarioidle[i] = love.graphics.newQuad(0, (i-1)*36, 26, 36, 598, 256)
		
		raccoonmariorun[i] = {}
		raccoonmariorun[i][1] = love.graphics.newQuad(26, (i-1)*36, 26, 36, 598, 256)
		raccoonmariorun[i][2] = love.graphics.newQuad(52, (i-1)*36, 26, 36, 598, 256)
		raccoonmariorun[i][3] = love.graphics.newQuad(78, (i-1)*36, 26, 36, 598, 256)
		
		raccoonmarioslide[i] = love.graphics.newQuad(104, (i-1)*36, 26, 36, 598, 256)
		raccoonmariojump[i] = love.graphics.newQuad(130, (i-1)*36, 26, 36, 598, 256)
		raccoonmariofire[i] = love.graphics.newQuad(156, (i-1)*36, 26, 36, 598, 256)
		
		raccoonmarioclimb[i] = {}
		raccoonmarioclimb[i][1] = love.graphics.newQuad(182, (i-1)*36, 26, 36, 598, 256)
		raccoonmarioclimb[i][2] = love.graphics.newQuad(208, (i-1)*36, 26, 36, 598, 256)
		
		raccoonmarioswim[i] = {}
		raccoonmarioswim[i][1] = love.graphics.newQuad(234, (i-1)*36, 26, 36, 598, 256)
		raccoonmarioswim[i][2] = love.graphics.newQuad(260, (i-1)*36, 26, 36, 598, 256)
		
		raccoonmarioduck[i] = love.graphics.newQuad(286, (i-1)*36, 26, 36, 598, 256)
	
		raccoonmariofloat[i] = {}
		raccoonmariofloat[i][1] = love.graphics.newQuad(312, (i-1)*36, 26, 36, 598, 256)
		raccoonmariofloat[i][2] = love.graphics.newQuad(338, (i-1)*36, 26, 36, 598, 256)
		raccoonmariofloat[i][3] = love.graphics.newQuad(130, (i-1)*36, 26, 36, 598, 256)
		raccoonmariofloat[i][4] = love.graphics.newQuad(130, (i-1)*36, 26, 36, 598, 256)
		
		raccoonmariospin[i] = {}
		raccoonmariospin[i][1] = love.graphics.newQuad(364, (i-1)*36, 26, 36, 598, 256)
		raccoonmariospin[i][2] = love.graphics.newQuad(390, (i-1)*36, 26, 36, 598, 256)
		raccoonmariospin[i][3] = love.graphics.newQuad(416, (i-1)*36, 26, 36, 598, 256)
		
		raccoonmariorunfast[i] = {}
		raccoonmariorunfast[i][1] = love.graphics.newQuad(442, (i-1)*36, 26, 36, 598, 256)
		raccoonmariorunfast[i][2] = love.graphics.newQuad(468, (i-1)*36, 26, 36, 598, 256)
		raccoonmariorunfast[i][3] = love.graphics.newQuad(494, (i-1)*36, 26, 36, 598, 256)
		
		raccoonmariofly[i] = {}
		raccoonmariofly[i][1] = love.graphics.newQuad(520, (i-1)*36, 26, 36, 598, 256)
		raccoonmariofly[i][2] = love.graphics.newQuad(546, (i-1)*36, 26, 36, 598, 256)
		raccoonmariofly[i][3] = love.graphics.newQuad(572, (i-1)*36, 26, 36, 598, 256)
	end
	
	tinymarioanimations = {}
	tinymarioanimations[0] = newImageFallback("player/tinymarioanimations0.png")
	tinymarioanimations[1] = newImageFallback("player/tinymarioanimations1.png")
	tinymarioanimations[2] = newImageFallback("player/tinymarioanimations2.png")
	tinymarioanimations[3] = newImageFallback("player/tinymarioanimations3.png")
	
	tinymarioidle = {}
	tinymariorun = {}
	tinymarioslide = {}
	tinymariojump = {}
	tinymariodie = {}
	tinymarioclimb = {}
	tinymarioswim = {}
	tinymariogrow = {}
	
	for i = 1, 5 do
		tinymarioidle[i] = love.graphics.newQuad(0, (i-1)*10, 10, 10, 256, 64)
		
		tinymariorun[i] = {}
		tinymariorun[i][1] = love.graphics.newQuad(10, (i-1)*10, 10, 10, 256, 64)
		tinymariorun[i][2] = love.graphics.newQuad(20, (i-1)*10, 10, 10, 256, 64)
		tinymariorun[i][3] = love.graphics.newQuad(30, (i-1)*10, 10, 10, 256, 64)
		
		tinymarioslide[i] = love.graphics.newQuad(40, (i-1)*10, 10, 10, 256, 64)
		tinymariojump[i] = love.graphics.newQuad(50, (i-1)*10, 10, 10, 256, 64)
		tinymariodie[i] = love.graphics.newQuad(60, (i-1)*10, 10, 10, 256, 64)
		
		tinymarioclimb[i] = {}
		tinymarioclimb[i][1] = love.graphics.newQuad(70, (i-1)*10, 10, 10, 256, 64)
		tinymarioclimb[i][2] = love.graphics.newQuad(80, (i-1)*10, 10, 10, 256, 64)
		
		tinymarioswim[i] = {}
		tinymarioswim[i][1] = love.graphics.newQuad(90, (i-1)*10, 10, 10, 256, 64)
		tinymarioswim[i][2] = love.graphics.newQuad(100, (i-1)*10, 10, 10, 256, 64)
		
		tinymariogrow[i] = love.graphics.newQuad(110, 0, 10, 12, 256, 64)
	end
	
	--portals
	portalimage = newImageFallback("portal.png")
	portal1quad = {}
	for i = 0, 7 do
		portal1quad[i] = love.graphics.newQuad(0, i*4, 32, 4, 64, 32)
	end
	
	portal2quad = {}
	for i = 0, 7 do
		portal2quad[i] = love.graphics.newQuad(32, i*4, 32, 4, 64, 32)
	end
	
	portalglow = newImageFallback("portalglow.png")
	
	portalparticleimg = newImageFallback("portalparticle.png")
	portalcrosshairimg = newImageFallback("portalcrosshair.png")
	portaldotimg = newImageFallback("portaldot.png")
	portalprojectileimg = newImageFallback("portalprojectile.png")
	portalprojectileparticleimg = newImageFallback("portalprojectileparticle.png")
	
	--Menu shit
	huebarimg = newImageFallback("huebar.png")
	huebarmarkerimg = newImageFallback("huebarmarker.png")
	volumesliderimg = newImageFallback("volumeslider.png")
	
	--Portal props
	emanceparticleimg = newImageFallback("emanceparticle.png")
	emancesideimg = newImageFallback("emanceside.png")
	
	doorpieceimg = newImageFallback("doorpiece.png")
	doorcenterimg = newImageFallback("doorcenter.png")
	
	buttonbaseimg = newImageFallback("buttonbase.png")
	buttonbuttonimg = newImageFallback("buttonbutton.png")
	
	pushbuttonimg = newImageFallback("pushbutton.png")
	pushbuttonquad = {love.graphics.newQuad(0, 0, 16, 16, 32, 16), love.graphics.newQuad(16, 0, 16, 16, 32, 16)}
	
	wallindicatorimg = newImageFallback("wallindicator.png")
	wallindicatorquad = {love.graphics.newQuad(0, 0, 16, 16, 32, 16), love.graphics.newQuad(16, 0, 16, 16, 32, 16)}
	
	walltimerimg = newImageFallback("walltimer.png")
	walltimerquad = {}
	for i = 1, 10 do
		walltimerquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 160, 16)
	end
	
	lightbridgeimg = newImageFallback("lightbridge.png")
	lightbridgesideimg = newImageFallback("lightbridgeside.png")
	
	laserimg = newImageFallback("laser.png")
	lasersideimg = newImageFallback("laserside.png")
	
	excursionfunnelimg = newImageFallback("funnel1.png")
	excursionfunnel2img = newImageFallback("funnel2.png")
	excursionbaseimg = newImageFallback("funnelbase.png")
	excursionquad = {}
	for x = 1, 8 do
		excursionquad[x] = love.graphics.newQuad((x-1)*8, 0, 8, 32, 64, 32)
	end
	
	faithplateplateimg = newImageFallback("faithplateplate.png")
	
	laserdetectorimg = newImageFallback("laserdetector.png")
	
	gel1img = newImageFallback("gel1.png")
	gel2img = newImageFallback("gel2.png")
	gel3img = newImageFallback("gel3.png")
	gel4img = newImageFallback("gel4.png")
	gelquad = {love.graphics.newQuad(0, 0, 12, 12, 36, 12), love.graphics.newQuad(12, 0, 12, 12, 36, 12), love.graphics.newQuad(24, 0, 12, 12, 36, 12)}
	
	gel1ground = newImageFallback("gel1ground.png")
	gel2ground = newImageFallback("gel2ground.png")
	gel3ground = newImageFallback("gel3ground.png")
	gel4ground = newImageFallback("gel4ground.png")
	
	geldispenserimg = newImageFallback("geldispenser.png")
	cubedispenserimg = newImageFallback("cubedispenser.png")
	
	--@DEV: No idea what these do, commented out to prevent a mess.
	--customsprites = false
	--loadcustomsprites()
	
	--optionsmenu
	skinpuppet = {}
	secondskinpuppet = {}
	classicskinpuppet = {}
	classicsecondskinpuppet = {}
	for i = 0, 3 do
		skinpuppet[i] = newImageFallback("options/skin" .. i .. ".png")
		secondskinpuppet[i] = newImageFallback("options/secondskin" .. i .. ".png")

		classicskinpuppet[i] = newImageFallback("options/classic/skin" .. i .. ".png")
		classicsecondskinpuppet[i] = newImageFallback("options/classic/secondskin" .. i .. ".png")
	end
	
end

function newImageFallback( filepath )
	if love.filesystem.exists("graphics/"..graphicspack.."/"..filepath) then
		return love.graphics.newImage("graphics/"..graphicspack.."/"..filepath)
	elseif love.filesystem.exists("graphics/SMB/"..filepath) then
		--print("WARNING: newImageFallback had to fall back on a file not found in ["..graphicspack.."]:" ..filepath)
		return love.graphics.newImage("graphics/SMB/"..filepath)
	else
		assert(false, "Attempted to load file named '"..filepath.."' but could not find it anywhere.")
	end
end

function newFontFallback( filepath )
	if love.filesystem.exists("graphics/"..graphicspack.."/"..filepath) then
		return love.graphics.newFont("graphics/"..graphicspack.."/"..filepath)
	elseif love.filesystem.exists("graphics/SMB/"..filepath) then
		--print("WARNING: newFontFallback had to fall back on a file not found in ["..graphicspack.."]:" ..filepath)
		return love.graphics.newFont("graphics/SMB/"..filepath)
	else
		assert(false, "Attempted to load file named '"..filepath.."' but could not find it anywhere.")
	end
end