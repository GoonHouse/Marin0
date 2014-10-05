networkupdatelimit = .03
networkupdatetimer = 0
enemyupdatetimer = 0
angletimer = 0

networkclientnumber = 0
networksendqueue = {}

chatlog = {}

chatmessageinprogressstring = "> "
chatmessagegradient = 0

local chatmessageoriginaldeletetimer = 0
local chatmessagedeletecharactertimer = 0

function game_load(suspended)
	scrollfactor = 0
	backgroundcolor = {}
	backgroundcolor[1] = {92, 148, 252}
	backgroundcolor[2] = {0, 0, 0}
	backgroundcolor[3] = {32, 56, 236}
	love.graphics.setBackgroundColor(backgroundcolor[1])
	backgroundrgbon = false
	backgroundrgb = {0, 0, 0}
	backgroundcolor[4] = backgroundrgb

	scrollingstart = 12 --when the scrolling begins to set in (Both of these take the player who is the farthest on the left)
	scrollingcomplete = 10 --when the scrolling will be as fast as mario can run
	scrollingleftstart = 6 --See above, but for scrolling left, and it takes the player on the right-estest.
	scrollingleftcomplete = 4
	superscroll = 100
	
	--BLOCKTOGGLE STUFF
	solidblocksred = true
	solidblocksblue = true
	solidblocksyellow = true
	solidblocksgreen = true
	
	--GLaDOS
	gladoshp = 3
	neurotoxin = false
	toxintime = 150
	
	--LINK STUFF
	
	mariocoincount = 0
	marioscore = 0
	
	--get mariolives
	mariolivecount = 3
	if love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/settings.txt") then
		local s = love.filesystem.read( mappackfolder .. "/" .. mappack .. "/settings.txt" )
		local s1 = s:split("\n")
		for j = 1, #s1 do
			local s2 = s1[j]:split("=")
			if s2[1] == "lives" then
				mariolivecount = tonumber(s2[2])
			end
		end
	end
	
	if mariolivecount == 0 then
		mariolivecount = false
	end
	
	mariolives = {}
	for i = 1, players do
		mariolives[i] = mariolivecount
	end
	
	mariosizes = {}
	for i = 1, players do
		mariosizes[i] = 1
	end
	
	autoscroll = true
	
	inputs = { "door", "groundlight", "wallindicator", "cubedispenser", "walltimer", "notgate", "laser", "lightbridge"}
	inputsi = {28, 29, 30, 43, 44, 45, 46, 47, 48, 67, 74, 84, 52, 53, 54, 55, 36, 37, 38, 39}
	
	outputs = { "button", "laserdetector", "box", "pushbutton", "walltimer", "notgate"}
	outputsi = {40, 56, 57, 58, 59, 20, 68, 69, 74, 84}
	
	enemies = { "goomba", "koopa", "hammerbro", "plant", "lakito", "bowser", "cheep", "squid", "flyingfish", "goombahalf", "koopahalf", "cheepwhite", "cheepred", "koopared", "kooparedhalf", "koopa", "kooparedflying", "beetle", "beetlehalf", "spikey", "spikeyhalf", "redplant", "reddownplant", "downplant"}
	
	jumpitems = { "mushroom", "oneup", "poisonmush" }
	
	marioworld = 1
	mariolevel = 1	
	mariosublevel = 0
	respawnsublevel = 0
	
	objects = nil
	if suspended == true then
		continuegame()
	elseif suspended then
		marioworld = suspended
	end
	
	--remove custom sprites
	for i = smbtilecount+portaltilecount+1, #tilequads do
		tilequads[i] = nil
	end
	
	for i = smbtilecount+portaltilecount+1, #rgblist do
		rgblist[i] = nil
	end
	
	--add custom tiles
	local bla = love.timer.getTime()
	if love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/tiles.png") then
		customtiles = true
		customtilesimg = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/tiles.png")
		local imgwidth, imgheight = customtilesimg:getWidth(), customtilesimg:getHeight()
		local width = math.floor(imgwidth/17)
		local height = math.floor(imgheight/17)
		local imgdata = love.image.newImageData(mappackfolder .. "/" .. mappack .. "/tiles.png")
		
		for y = 1, height do
			for x = 1, width do
				table.insert(tilequads, quad:new(customtilesimg, imgdata, x, y, imgwidth, imgheight))
				local r, g, b = getaveragecolor(imgdata, x, y)
				table.insert(rgblist, {r, g, b})
			end
		end
		customtilecount = width*height
	else
		customtiles = false
		customtilecount = 0
	end
	print("Custom tileset loaded in: " .. round(love.timer.getTime()-bla, 5))
	
	smbspritebatch = {}
	portalspritebatch = {}
	customspritebatch = {}
	spritebatchX = {}
	spritebatchY = {}
	for i = 1, players do
		smbspritebatch[i] = love.graphics.newSpriteBatch( smbtilesimg, 1000 )
		portalspritebatch[i] = love.graphics.newSpriteBatch( portaltilesimg, 1000 )
		if customtiles then
			customspritebatch[i] = love.graphics.newSpriteBatch( customtilesimg, 1000 )
		end
		spritebatchX[i] = 0
		spritebatchY[i] = 0
	end
	
	custommusic = false
	for i = 0, 9 do
		_G["custommusic" .. tostring(i)] = false
		if love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/music" .. tostring(i) .. ".ogg") then
			_G["custommusic" .. tostring(i)] = mappackfolder .. "/" .. mappack .. "/music" .. tostring(i) .. ".ogg"
			music:load(_G["custommusic" .. tostring(i)])
		elseif love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/music" .. tostring(i) .. ".mp3") then
			_G["custommusic" .. tostring(i)] = mappackfolder .. "/" .. mappack .. "/music" .. tostring(i) .. ".mp3"
			music:load(_G["custommusic" .. tostring(i)])
		end
	end
	if love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/music.ogg") then
		custommusic1 = mappackfolder .. "/" .. mappack .. "/music.ogg"
		music:load(custommusic1)
	elseif love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/music.mp3") then
		custommusic1 = mappackfolder .. "/" .. mappack .. "/music.mp3"
		music:load(custommusic1)
	end
	print(custommusic)
	
	--FINALLY LOAD THE DAMN LEVEL
	levelscreen_load("initial")


	--set singulargamemode for testing
end

function game_update(dt)

	--------
	--GAME--
	--------
	
	--earthquake reset
	if earthquake > 0 then
		earthquake = math.max(0, earthquake-dt*earthquake*2-0.001)
		sunrot = sunrot + dt
	end


	if chatmessagegradient < 20 then
		chatmessagegradient = 0
	else
		chatmessagegradient = chatmessagegradient - 18*dt
	end

	--pausemenu
	if (pausemenuopen and not onlinemp) then
		return
	end


	if endpressbutton and (onlinemp and clientisnetworkhost or not onlinemp) then
		endpressbutton = false
		endgame()
		return
	end
	
	--coinanimation "THIS CONTROLS THE FRAMES OF THE COIN, ?BLOCKS, AXE, AND HUD COIN ICON" -HammerGuy
	coinanimation = coinanimation + dt*6.75
	while coinanimation > 5 do
		coinanimation = coinanimation - 4
	end	
	
	if math.floor(coinanimation) == 3 then
		coinframe = 3
	elseif math.floor(coinanimation) == 4 then
		coinframe = 4
	else
		coinframe = math.floor(coinanimation)
	end
	
	--SCROLLING SCORES
	local delete = {}
	
	for i, v in pairs(scrollingscores) do
		if scrollingscores[i]:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(scrollingscores, v) --remove
	end
	
	--If everyone's dead, just update the players and coinblock timer.
	if everyonedead then
		for i, v in pairs(objects["player"]) do
			v:update(dt)
		end
		
		return
	end
	
	--timer	
	if editormode == false then
		--get if any player has their controls disabled
		local notime = false
		for i = 1, players do
			if (objects["player"][i].controlsenabled == false and objects["player"][i].dead == false) then
				notime = true
			end
		end
		
		if notime == false and infinitetime == false and mariotime ~= 0 then
			mariotime = mariotime - 2.5*dt
			
			if mariotime > 0 and mariotime + 2.5*dt >= 99 and mariotime < 99 then
				love.audio.stop()
				playsound(lowtime)
			end
			
			if mariotime > 0 and mariotime + 2.5*dt >= 99-7.5 and mariotime < 99-7.5 then
				local star = false
				for i = 1, players do
					if objects["player"][i].starred then
						star = true
					end
				end
				
				if not star then
					playmusic()
				else
					music:play("starmusic")
				end
			end
			
			if mariotime <= 0 then
				mariotime = 0
				for i, v in pairs(objects["player"]) do
					v:die("time")
				end
			end
		end
	end
	
	--check if updates are blocked for whatever reason
	if noupdate then
		for i, v in pairs(objects["player"]) do
			v:update(dt)
		end
		return
	end
	
	--portalgundelay
	for i = 1, players do
		if portaldelay[i] > 0 then
			portaldelay[i] = math.max(0, portaldelay[i] - dt/speed)
		end
	end
	
	--coinblockanimation
	local delete = {}
	
	for i, v in pairs(coinblockanimations) do
		if coinblockanimations[i]:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(coinblockanimations, v) --remove
	end
	
	--nothing to see here
	local delete = {}
	
	for i, v in pairs(rainbooms) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(rainbooms, v) --remove
	end
	
	--userects
	local delete = {}
	
	for i, v in pairs(userects) do
		if v.delete == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(userects, v) --remove
	end
	
	--blockbounce
	local delete = {}
	
	for i, v in pairs(blockbouncetimer) do
		if blockbouncetimer[i] < blockbouncetime then
			blockbouncetimer[i] = blockbouncetimer[i] + dt
			if blockbouncetimer[i] > blockbouncetime then
				blockbouncetimer[i] = blockbouncetime
				if blockbouncecontent then
					item(blockbouncecontent[i], blockbouncex[i], blockbouncey[i], blockbouncecontent2[i])
				end
				table.insert(delete, i)
			end
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(blockbouncetimer, v)
		table.remove(blockbouncex, v)
		table.remove(blockbouncey, v)
		table.remove(blockbouncecontent, v)
		table.remove(blockbouncecontent2, v)
	end
	
	if #delete >= 1 then
		generatespritebatch()
	end
	
	--coinblocktimer things
	for i, v in pairs(coinblocktimers) do
		if v[3] > 0 then
			v[3] = v[3] - dt
		end
	end
	
	--blockdebris
	local delete = {}
	
	for i, v in pairs(blockdebristable) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(blockdebristable, v) --remove
	end
	
	--@DEV: Special hook for EntranceJew because not being able to hit reload to clear my portals was pissing me off.
	if objects["player"][mouseowner] and playertype == "portal" and objects["player"][mouseowner].controlsenabled then
		if love.mouse.isDown("m") then
			objects["player"][mouseowner]:removeportals()
		end
	end

	--gelcannon
	if objects["player"][mouseowner] and playertype == "gelcannon" and objects["player"][mouseowner].controlsenabled then
		if gelcannontimer > 0 then
			gelcannontimer = gelcannontimer - dt
			if gelcannontimer < 0 then
				gelcannontimer = 0
			end
		else
			if love.mouse.isDown("l") then
				gelcannontimer = gelcannondelay
				objects["player"][mouseowner]:shootgel(1)
			elseif love.mouse.isDown("r") then
				gelcannontimer = gelcannondelay
				objects["player"][mouseowner]:shootgel(2)
			elseif love.mouse.isDown("m") or love.mouse.isDown("wd") or love.mouse.isDown("wu") or love.mouse.isDown("x1") then
				gelcannontimer = gelcannondelay
				objects["player"][mouseowner]:shootgel(4)
			elseif love.mouse.isDown("x2") then
				gelcannontimer = gelcannondelay
				objects["player"][mouseowner]:shootgel(3)
			end
		end
	end
	
	--seesaws
	for i, v in pairs(seesaws) do
		v:update(dt)
	end
	
	--platformspawners
	for i, v in pairs(platformspawners) do
		v:update(dt)
	end
	
	--Bubbles
	local delete = {}
	
	for i, v in pairs(bubbles) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(bubbles, v) --remove
	end
	
	--Miniblocks
	local delete = {}
	
	for i, v in pairs(miniblocks) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(miniblocks, v) --remove
	end
	
	--Fireworks
	local delete = {}
	
	for i, v in pairs(fireworks) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(fireworks, v) --remove
	end
	
	--EMANCIPATION GRILLS
	local delete = {}
	for i, v in pairs(emancipationgrills) do
		if v:update(dt) then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(emancipationgrills, v)
	end
	
	--BULLET BILL LAUNCHERS
	local delete = {}
	for i, v in pairs(rocketlaunchers) do
		if v:update(dt) then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(rocketlaunchers, v)
	end
	
	--UPDATE OBJECTS
	for i, v in pairs(objects) do
		if i ~= "tile" and i ~= "portalwall" and i ~= "screenboundary" then
			delete = {}
			
			for j, w in pairs(v) do
				if w.update and w:update(dt) then
					table.insert(delete, j)
				elseif w.autodelete then
					if onlinemp then
						local getdelete = true
						for x, y in pairs(objects["player"]) do

							--A bit farther than offscreen, but it's close enough
							--@TODO: Do a yscroll check or some shit!!!
							if w.x > y.x - width*.75 and w.y < 16 then
								getdelete = false
								break
							end
						end

						if getdelete then
							table.insert(delete, j)
						end
					else


						if w.x < xscroll - width or w.y > mapheight+1 then
							table.insert(delete,j)
						end
					end
				end
			end
			
			if #delete > 0 then
				table.sort(delete, function(a,b) return a>b end)
				
				for j, w in pairs(delete) do
					table.remove(v, w)
				end
			end
		end
	end
	
	--SCROLLING
	
	--HORIZONTAL
	
	local oldscroll = splitxscroll[1]
	
	if autoscroll and minimapdragging == false then
		local splitwidth = width/#splitscreen
		for split = 1, #splitscreen do
			local oldscroll = splitxscroll[split]
			--scrolling
			--LEFT
			local i = 1
			while i <= players and objects["player"][i].dead do
				i = i + 1
			end
			local fastestplayer = objects["player"][i]
			
			if fastestplayer then
				for i = 1, players do
					if not objects["player"][i].dead and objects["player"][i].x > fastestplayer.x then
						fastestplayer = objects["player"][i]
					end
				end

				if onlinemp then
					fastestplayer = objects["player"][1]
					if objects["player"][1].dead then
						for i = 1, players do
							if not objects["player"][i].dead and objects["player"][i].x > fastestplayer.x then
								fastestplayer = objects["player"][i]
							end
						end
					end
				end
				
				local oldscroll = splitxscroll[split]
				
				if autoscrolling == false then
					if fastestplayer.x < splitxscroll[split] + scrollingleftstart and splitxscroll[split] > 0 then
						if fastestplayer.x < splitxscroll[split] + scrollingleftstart and fastestplayer.speedx < 0 then
							if fastestplayer.speedx < -scrollrate then
								splitxscroll[split] = splitxscroll[split] - scrollrate*dt
							else
								splitxscroll[split] = splitxscroll[split] + fastestplayer.speedx*dt
							end
						end
					
						if fastestplayer.x < splitxscroll[split] + scrollingleftcomplete then
							if fastestplayer.x > splitxscroll[split] + scrollingleftcomplete - 1/16 then
								splitxscroll[split] = splitxscroll[split] - scrollrate*dt
							else
								splitxscroll[split] = splitxscroll[split] - superscrollrate*dt
							end
						end
						
						if splitxscroll[split] < 0 then
							splitxscroll[split] = 0
						end
					end
				else
					splitxscroll[split] = splitxscroll[split] + 1.5*dt
				end
				
				--RIGHT
				
				if autoscrolling == false then
					if fastestplayer.x > splitxscroll[split] + width - scrollingstart and splitxscroll[split] < mapwidth - width then
						if fastestplayer.x > splitxscroll[split] + width - scrollingstart and fastestplayer.speedx > 0.3 then
							if fastestplayer.speedx > scrollrate then
								splitxscroll[split] = splitxscroll[split] + scrollrate*dt
							else
								splitxscroll[split] = splitxscroll[split] + fastestplayer.speedx*dt
							end
						end
					
						if fastestplayer.x > splitxscroll[split] + width - scrollingcomplete then
							if fastestplayer.x > splitxscroll[split] + width - scrollingcomplete then
								splitxscroll[split] = splitxscroll[split] + scrollrate*dt
								if splitxscroll[split] > fastestplayer.x - (width - scrollingcomplete) then
									splitxscroll[split] = fastestplayer.x - (width - scrollingcomplete)
								end
							else
								splitxscroll[split] = fastestplayer.x - (width - scrollingcomplete)
							end
						end
					end
				else
					splitxscroll[split] = splitxscroll[split] + 1.5*dt
				end
				
				--just force that shit
				if not levelfinished and not autoscrolling then
					if fastestplayer.x > splitxscroll[split] + width - scrollingcomplete then
						splitxscroll[split] = splitxscroll[split] + superscroll*dt
						if fastestplayer.x < splitxscroll[split] + width - scrollingcomplete then
							splitxscroll[split] = fastestplayer.x - width + scrollingcomplete
						end
						--splitxscroll[split] = fastestplayer.x + width - scrollingcomplete - width
					end
				end
					
				if splitxscroll[split] > mapwidth-width then
					splitxscroll[split] = math.max(0, mapwidth-width)
					hitrightside()
				end
					
				if (axex and splitxscroll[split] > axex-width and axex >= width) then
					splitxscroll[split] = axex-width
					hitrightside()
				end
			end
		end
		
	end
	
	
	--VERTICAL SCROLLING
	--@TODO: Not vetted for multiplayer. Call the police.
	for split = 1, #splitscreen do
		if autoscroll and mapheight ~= 15 then
			splityscroll[split] = objects["player"][1].y-height/2
		
			if splityscroll[split] > mapheight-height-1 then
				splityscroll[split] = math.max(0, mapheight-height-1)
			end
			
			if splityscroll[split] < 0 then
				splityscroll[split] = 0
			end
		end
	end
	
	if players == 2 then
		--updatesplitscreen()
	end
	
	if singularmariogamemode then

		--1 Mario, x portals
		for x = 1, players do
			if convertclienttoplayer(currentmarioplayermoving) ~= x then
				objects["player"][x].x = objects["player"][convertclienttoplayer(currentmarioplayermoving)].x
				objects["player"][x].y = objects["player"][convertclienttoplayer(currentmarioplayermoving)].y
				objects["player"][x].gravity = 0
				objects["player"][x].controlsenabled = false
				objects["player"][x].active = false
			else
				if objects["player"][x].x > mariodistancepoints[x].distance then
					mariodistancepoints[x].score = mariodistancepoints[x].score+(objects["player"][x].x-mariodistancepoints[x].distance)
					mariodistancepoints[x].distance = objects["player"][x].x
				end
			end
		end
	end
	
	--SPRITEBATCH UPDATE and CASTLEREPEATS
	if math.floor(splitxscroll[1]) ~= spritebatchX[1] then
		if not editormode then
			for currentx = lastrepeat+1, math.floor(splitxscroll[1])+2 do
				lastrepeat = math.floor(currentx)
				--castlerepeat?
				--get mazei
				local mazei = 0
				
				for j = 1, #mazeends do
					if mazeends[j] < currentx+width then
						mazei = j
					end
				end
				
				--check if maze was solved!
				for i = 1, players do
					if objects["player"][i].mazevar == mazegates[mazei] then
						local actualmaze = 0
						for j = 1, #mazestarts do
							if objects["player"][i].x > mazestarts[j] then
								actualmaze = j
							end
						end
						mazesolved[actualmaze] = true
						for j = 1, players do
							objects["player"][j].mazevar = 0
						end
						break
					end
				end
				
				if not mazesolved[mazei] or mazeinprogress then --get if inside maze
					if not mazesolved[mazei] then
						mazeinprogress = true
					end
					
					local x = math.ceil(currentx)+width
					
					if repeatX == 0 then
						repeatX = mazestarts[mazei]
					end
					
					table.insert(map, x, {{1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}, {1}})
					for y = 1, 15 do
						for j = 1, #map[repeatX][y] do
							map[x][y][j] = map[repeatX][y][j]
							map[x][y].nullifymaze = false
						end
						map[x][y]["gels"] = {}
						
						for cox = mapwidth, x, -1 do
							--move objects
							if objects["tile"][cox .. "-" .. y] then
								objects["tile"][cox + 1 .. "-" .. y] = tile:new(cox, y-1, 1, 1, true)
								objects["tile"][cox .. "-" .. y] = nil
							end
						end
						
						--create object for block
						if tilequads[map[repeatX][y][1]].collision == true then
							objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1, 1, 1, true)
						end
					end
					mapwidth = mapwidth + 1
					repeatX = repeatX + 1
					if flagx then
						flagx = flagx + 1
						flagimgx = flagimgx + 1
						objects["screenboundary"]["flag"].x = objects["screenboundary"]["flag"].x + 1
					end
					
					if axex then
						axex = axex + 1
						objects["screenboundary"]["axe"].x = objects["screenboundary"]["axe"].x + 1
					end
					
					if firestartx then
						firestartx = firestartx + 1
					end
					
					objects["screenboundary"]["right"].x = objects["screenboundary"]["right"].x + 1
					
					--move mazestarts and ends
					for i = 1, #mazestarts do
						mazestarts[i] = mazestarts[i]+1
						mazeends[i] = mazeends[i]+1
					end
					
					--check for endblock
					local x = math.ceil(currentx)+width
					for y = 1, 15 do
						if map[x][y][2] and entityquads[map[x][y][2]].t == "mazeend" then
							if mazesolved[mazei] then
								repeatX = mazestarts[mazei+1]
							end
							mazeinprogress = false
						end
					end
					
					--reset thingie
					
					local x = math.ceil(currentx)+width-1
					for y = 1, 15 do
						if map[x][y][2] and entityquads[map[x][y][2]].t == "mazeend" then
							for j = 1, players do
								objects["player"][j].mazevar = 0
							end
						end
					end
				end
			end
		end
		
		generatespritebatch()
		spritebatchX[1] = math.floor(splitxscroll[1])
		
		if editormode == false and splitxscroll[1] < mapwidth-width then
			for x = math.ceil(oldscroll)+width+1, math.floor(splitxscroll[1])+width+1 do
				for y = 1, mapheight do
					spawnenemy(x, y)
				end
				if goombaattack then
					local randomtable = {}
					for y = 1, mapheight do
						table.insert(randomtable, y)
					end
					while #randomtable > 0 do
						local rand = math.random(#randomtable)
						if tilequads[map[x][randomtable[rand]][1]].collision then
							table.remove(randomtable, rand)
						else
							table.insert(objects["goomba"], goomba:new(x-.5, math.random(13)))
							break
						end
					end
				end
			end
		end
	elseif math.floor(splityscroll[1]) ~= spritebatchY[1] then
		generatespritebatch()
		spritebatchY[1] = splityscroll[split]
	end
	
	--portal animation
	portalanimationtimer = portalanimationtimer + dt
	while portalanimationtimer > portalanimationdelay do
		portalanimationtimer = 0
		portalanimation = portalanimation + 1
		if portalanimation > portalanimationcount then
			portalanimation = 1
		end
	end
	
	--portal particles
	portalparticletimer = portalparticletimer + dt
	while portalparticletimer > portalparticletime do
		portalparticletimer = portalparticletimer - portalparticletime
		
		for i, v in pairs(objects["player"]) do
			if v.portal1facing ~= nil then
				local x1, y1
				
				if v.portal1facing == "up" then
					x1 = v.portal1X + math.random(1, 30)/16 -1
					y1 = v.portal1Y-1
				elseif v.portal1facing == "down" then
					x1 = v.portal1X + math.random(1, 30)/16-2
					y1 = v.portal1Y
				elseif v.portal1facing == "left" then
					x1 = v.portal1X-1
					y1 = v.portal1Y + math.random(1, 30)/16-2
				elseif v.portal1facing == "right" then
					x1 = v.portal1X
					y1 = v.portal1Y + math.random(1, 30)/16-1
				end
				
				local color
				if players == 1 then
					color = {157, 222, 254}
				else
					color = v.portal1color
				end
				
				table.insert(portalparticles, portalparticle:new(x1, y1, color, v.portal1facing))
			end
			
			if v.portal2facing ~= nil then
				local x2, y2
				
				if v.portal2facing == "up" then
					x2 = v.portal2X + math.random(1, 30)/16 -1
					y2 = v.portal2Y-1
				elseif v.portal2facing == "down" then
					x2 = v.portal2X + math.random(1, 30)/16-2
					y2 = v.portal2Y
				elseif v.portal2facing == "left" then
					x2 = v.portal2X-1
					y2 = v.portal2Y + math.random(1, 30)/16-2
				elseif v.portal2facing == "right" then
					x2 = v.portal2X
					y2 = v.portal2Y + math.random(1, 30)/16-1
				end
				
				local color
				if players == 1 then
					color = {255, 122, 66}
				else
					color = v.portal2color
				end
				
				table.insert(portalparticles, portalparticle:new(x2, y2, color, v.portal2facing))
			end
		end
	end
	
	delete = {}
	
	for i, v in pairs(portalparticles) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(portalparticles, v) --remove
	end
	
	--PORTAL PROJECTILES
	delete = {}
	
	for i, v in pairs(portalprojectiles) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(portalprojectiles, v) --remove
	end
	
	--FIRE SPAWNING
	if not levelfinished and firestarted and (not objects["bowser"][1] or (objects["bowser"][1].backwards == false and objects["bowser"][1].shot == false and objects["bowser"][1].fall == false)) then
		firetimer = firetimer + dt
		while firetimer > firedelay do
			firetimer = firetimer - firedelay
			firedelay = math.random(4)
			local x = splitxscroll[1]+width
			if onlinemp then
				local farthestplayer = 1
				for x = 1, players do
					if objects["player"][x].x > objects["player"][farthestplayer].x then
						farthestplayer = x
					end
				end

				x = objects["player"][farthestplayer].x + width*.4
			end
			local y = math.random(3)+7
			local newfire = fire:new(x, y)
			table.insert(objects["fire"], newfire)
			table.insert(networksendqueue, "firespawn;" .. networkclientnumber .. ";" .. newfire.x .. ";" .. newfire.y .. ";" .. newfire.targety)
		end
	end
	
	--FLYING FISH
	if not levelfinished and flyingfishstarted then
		flyingfishtimer = flyingfishtimer + dt
		while flyingfishtimer > flyingfishdelay and (onlinemp and clientisnetworkhost or not onlinemp) do
			flyingfishtimer = flyingfishtimer - flyingfishdelay
			flyingfishdelay = math.random(6, 20)/10
			local fish = flyingfish:new()
			table.insert(networksendqueue, "fishspawn;" .. networkclientnumber .. ";" .. fish.x .. ";" .. fish.speedx)
			table.insert(objects["flyingfish"], fish)

		end
	end
	
	--METEORS
	if not levelfinished and meteorstarted then
		meteortimer = meteortimer + dt
		while meteortimer > meteordelay do
			meteortimer = meteortimer - meteordelay
			meteordelay = math.random(6, 20)/10
			table.insert(objects["meteor"], meteor:new())
		end
	end
	
	--BULLET BILL
	if not levelfinished and bulletbillstarted and (onlinemp and clientisnetworkhost or not onlinemp) then
		bulletbilltimer = bulletbilltimer + dt
		while bulletbilltimer > bulletbilldelay do
			bulletbilltimer = bulletbilltimer - bulletbilldelay
			bulletbilldelay = math.random(5, 40)/10
			local farthestplayer = 1
			for x = 2, players do
				if objects["player"][x].x > objects["player"][farthestplayer].x then
					farthestplayer = x
				end
			end
			local bulletx

			if farthestplayer == 1 then
				bulletx = splitxscroll[1]+width+2
			else
				bulletx = objects["player"][farthestplayer].x + scrollingstart + 2
			end

			if bulletx < width + 2 then
				bulletx = width + 2
			end

			local bullety = math.random(4, 12)

			local newbullet = bulletbill:new(bulletx, bullety, "left")

			table.insert(networksendqueue, "bullet;" .. networkclientnumber .. ";" .. bulletx .. ";" .. bullety .. ";left")

			table.insert(objects["bulletbill"], newbullet)
		end
	end
	
	--NEUROTOXIN
	if not levelfinished and neurotoxin then
		toxintime = toxintime - dt
		if toxintime <= 0 then
			toxintime = 0
		end
	end
	
	--WIND
	if not levelfinished and windstarted then
		--[[if raccoonplanesound:isStopped() then --coulnd't find a wind sound!!!
			playsound(raccoonplanesound)
		end]]
		local player1 = objects["player"][1]
		if player1.animationdirection == "left" and player1.animationstate ~= "idle" then
			if not player1.spring and not player1.springgreen and not player1.springgreenhigh and not player1.springhigh then
				player1.speedx = player1.speedx + 0.06
			else
				
			end
		elseif player1.animationstate ~= "idle" then
			if not player1.spring and not player1.springgreen and not player1.springgreenhigh and not player1.springhigh then
				player1.speedx = player1.speedx + 0.03
			else
				
			end
		elseif player1.animationstate == "idle" then
			player1.speedx = player1.speedx + 1
		end
		--make leafs apear
		windleaftimer = windleaftimer + dt
		while windleaftimer > 0.05 do
			windleaftimer = windleaftimer - 0.05
			table.insert(objects["windleaf"], windleaf:new(xscroll-1, math.random(1, 14)))
		end
	end
	
	--minecraft stuff
	if breakingblockX then
		breakingblockprogress = breakingblockprogress + dt
		if breakingblockprogress > minecraftbreaktime then
			breakblock(breakingblockX, breakingblockY)
			breakingblockX = nil
		end
	end
	
	--Editor
	if editormode then
		editor_update(dt)
	end
	
	--PHYSICS
	physicsupdate(dt)
end

function game_draw()
	for split = 1, #splitscreen do
		love.graphics.translate((split-1)*width*16*scale/#splitscreen, yoffset*scale)
		
		--This is just silly
		if earthquake > 0 and #objects["glados"] == 0 then
			local colortable = {{242, 111, 51}, {251, 244, 174}, {95, 186, 76}, {29, 151, 212}, {101, 45, 135}, {238, 64, 68}}
			for i = 1, backgroundstripes do
				local r, g, b = unpack(colortable[math.mod(i-1, 6)+1])
				local a = earthquake/rainboomearthquake*255
				
				love.graphics.setColor(r, g, b, a)
				
				local alpha = math.rad((i/backgroundstripes + math.mod(sunrot/5, 1)) * 360)
				local point1 = {width*8*scale+300*scale*math.cos(alpha), 112*scale+300*scale*math.sin(alpha)}
				
				local alpha = math.rad(((i+1)/backgroundstripes + math.mod(sunrot/5, 1)) * 360)
				local point2 = {width*8*scale+300*scale*math.cos(alpha), 112*scale+300*scale*math.sin(alpha)}
				
				love.graphics.polygon("fill", width*8*scale, 112*scale, point1[1], point1[2], point2[1], point2[2])
			end
		end
		
		love.graphics.setColor(255, 255, 255, 255)
		--tremoooor!
		if earthquake > 0 then
			tremorx = (math.random()-.5)*2*earthquake
			tremory = (math.random()-.5)*2*earthquake
			
			love.graphics.translate(round(tremorx), round(tremory))
		end
		
		local currentscissor = {(split-1)*width*16*scale/#splitscreen, 0, width*16*scale/#splitscreen, height*16*scale}
		love.graphics.setScissor(unpack(currentscissor))
		xscroll = splitxscroll[split]
		yscroll = splityscroll[split]
	
		love.graphics.setColor(255, 255, 255, 255)
		
		local xtodraw
		if mapwidth < width+1 then
			xtodraw = math.ceil(mapwidth/#splitscreen)
		else
			if mapwidth > width and xscroll < mapwidth-width then
				xtodraw = width+1
			else
				xtodraw = width
			end
		end
		
		local ytodraw
		if mapheight > height-1 and yscroll < mapheight-height-1 then
			ytodraw = height+2
		else
			ytodraw = height+1
		end
		
		--custom background
		if custombackground then
			for i = #custombackgroundimg, 1, -1  do
				local xscroll = xscroll / (i * scrollfactor + 1)
				local yscroll = yscroll / (i * scrollfactor + 1)
				if reversescrollfactor() == 1 then
					xscroll = 0
					yscroll = 0
				end
				for y = 1, math.ceil(mapheight/custombackgroundheight[i])+1 do
					for x = 1, math.ceil(width/custombackgroundwidth[i])+1 do
						love.graphics.draw(custombackgroundimg[i], math.floor(((x-1)*custombackgroundwidth[i])*16*scale) - math.floor(math.mod(xscroll, custombackgroundwidth[i])*16*scale), math.floor(((y-1)*custombackgroundheight[i])*16*scale) - math.floor(math.mod(yscroll, custombackgroundheight[i])*16*scale), 0, scale, scale)
					end
				end
			end
		end
		
		--Mushroom under tiles
		for j, w in pairs(objects["mushroom"]) do
			w:draw()
		end
		
		--Flowers under tiles
		for j, w in pairs(objects["flower"]) do
			w:draw()
		end
		
		--Oneupunder tiles
		for j, w in pairs(objects["oneup"]) do
			w:draw()
		end
		
		--star tiles
		for j, w in pairs(objects["star"]) do
			w:draw()
		end

		--Poisonmush under tiles
		for j, w in pairs(objects["poisonmush"]) do
			w:draw()
		end

		--Threeupunder tiles
		for j, w in pairs(objects["threeup"]) do
			w:draw()
		end
		
		-- + Clock under tiles
		for j, w in pairs(objects["plusclock"]) do
			w:draw()
		end
		
		--Hammersuit under tiles
		for j, w in pairs(objects["hammersuit"]) do
			w:draw()
		end
		
		--Frogsuit under tiles
		for j, w in pairs(objects["frogsuit"]) do
			w:draw()
		end
		
		--Mini Mushroom under tiles
		for j, w in pairs(objects["minimushroom"]) do
			w:draw()
		end
		
		--Yoshi egg under tiles
		for j, w in pairs(objects["yoshiegg"]) do
			w:draw()
		end
		
		--castleflag
		if levelfinished and levelfinishtype == "flag" and not custombackground then
			love.graphics.draw(castleflagimg, math.floor((flagx+6-xscroll)*16*scale), (106*scale+castleflagy-yscroll)*16*scale, 0, scale, scale)
		end
		
		--TILES
		love.graphics.draw(smbspritebatch[split], math.floor(-math.mod(xscroll, 1)*16*scale), math.floor(-math.mod(yscroll, 1)*16*scale))
		love.graphics.draw(portalspritebatch[split], math.floor(-math.mod(xscroll, 1)*16*scale), math.floor(-math.mod(yscroll, 1)*16*scale))
		if customtiles then
			love.graphics.draw(customspritebatch[split], math.floor(-math.mod(xscroll, 1)*16*scale), math.floor(-math.mod(yscroll, 1)*16*scale))
		end
		
		local lmap = map
		
		for y = 1, ytodraw do
			for x = 1, xtodraw do
				local bounceyoffset = 0
				for i, v in pairs(blockbouncex) do
					if blockbouncex[i] == math.floor(xscroll)+x and blockbouncey[i] == math.floor(yscroll)+y then
						if blockbouncetimer[i] < blockbouncetime/2 then
							bounceyoffset = blockbouncetimer[i] / (blockbouncetime/2) * blockbounceheight
						else
							bounceyoffset = (2 - blockbouncetimer[i] / (blockbouncetime/2)) * blockbounceheight
						end
					end	
				end
				
				local t = lmap[math.floor(xscroll)+x][math.floor(yscroll)+y]
				
				local tilenumber = t[1]
				if not tilequads[tilenumber] then
					print(tilenumber, tilequads)
				end
				if tilequads[tilenumber].coinblock and tilequads[tilenumber].invisible == false then --coinblock
					love.graphics.draw(coinblockimage, coinblockquads[spriteset][coinframe], math.floor((x-1-math.mod(xscroll, 1))*16*scale), ((y-1-bounceyoffset)*16-8)*scale, 0, scale, scale)
				elseif tilequads[tilenumber].coin then --coin
					love.graphics.draw(coinimage, coinquads[coinframe], math.floor((x-1-math.mod(xscroll, 1))*16*scale), ((y-1-bounceyoffset)*16-8)*scale, 0, scale, scale)
				elseif tilequads[tilenumber].breakable and tilequads[tilenumber].invisible == false then --coinblock
					love.graphics.draw(brickblockimage, brickblockquads[spriteset][coinframe], math.floor((x-1-math.mod(xscroll, 1))*16*scale), ((y-1-bounceyoffset)*16-8)*scale, 0, scale, scale)
				elseif bounceyoffset ~= 0 then
					if tilequads[tilenumber].invisible == false or editormode then
						love.graphics.draw(tilequads[tilenumber].image, tilequads[tilenumber].quad, math.floor((x-1-math.mod(xscroll, 1))*16*scale), ((y-1-bounceyoffset)*16-8)*scale, 0, scale, scale)
					end
				end
				
				--Gel overlays!
				if t["gels"] then
					for i = 1, 4 do
						local dir = "top"
						local r = 0
						if i == 2 then
							dir = "right"
							r = math.pi/2
						elseif i == 3 then
							dir = "bottom"
							r = math.pi
						elseif i == 4 then
							dir = "left"
							r = math.pi*1.5
						end
						
						if t["gels"][dir] == 1 then
							love.graphics.draw(gel1ground, math.floor((x-.5-math.mod(xscroll, 1))*16*scale), ((y-1-math.mod(yscroll, 1)-bounceyoffset)*16)*scale, r, scale, scale, 8, 8)
						elseif t["gels"][dir] == 2 then
							love.graphics.draw(gel2ground, math.floor((x-.5-math.mod(xscroll, 1))*16*scale), ((y-1-math.mod(yscroll, 1)-bounceyoffset)*16)*scale, r, scale, scale, 8, 8)
						elseif t["gels"][dir] == 3 then
							love.graphics.draw(gel3ground, math.floor((x-.5-math.mod(xscroll, 1))*16*scale), ((y-1-math.mod(yscroll, 1)-bounceyoffset)*16)*scale, r, scale, scale, 8, 8)
						elseif t["gels"][dir] == 4 then
							love.graphics.draw(gel4ground, math.floor((x-.5-math.mod(xscroll, 1))*16*scale), ((y-1-math.mod(yscroll, 1)-bounceyoffset)*16)*scale, r, scale, scale, 8, 8)
						end
					end
				end
				
				if editormode then
					if tilequads[t[1]].invisible and t[1] ~= 1 then
						love.graphics.draw(tilequads[t[1]].image, tilequads[t[1]].quad, math.floor((x-1-math.mod(xscroll, 1))*16*scale), ((y-1-math.mod(yscroll, 1))*16-8)*scale, 0, scale, scale)
					end
					
					if #t > 1 and t[2] ~= "link" then
						tilenumber = t[2]
						love.graphics.setColor(255, 255, 255, 150)
						love.graphics.draw(entityquads[tilenumber].image, entityquads[tilenumber].quad, math.floor((x-1-math.mod(xscroll, 1))*16*scale), ((y-1-math.mod(yscroll, 1))*16-8)*scale, 0, scale, scale)
						love.graphics.setColor(255, 255, 255, 255)
					end
				end
			end
		end
		
		--coin
		for j, w in pairs(objects["coin"]) do
			w:draw()
		end
		
		---UI
		love.graphics.setColor(255, 255, 255)
		love.graphics.translate(0, -yoffset*scale)
		if yoffset < 0 then
			love.graphics.translate(0, yoffset*scale)
		end
		
		properprint("mario", uispace*.5 - 24*scale, 8*scale)
		properprint(addzeros(marioscore, 6), uispace*0.5-24*scale, 16*scale)
		
		properprint("*", uispace*1.5-8*scale, 16*scale)
		
		love.graphics.draw(coinanimationimage, coinanimationquads[spriteset][coinframe], uispace*1.5-16*scale, 16*scale, 0, scale, scale)
		properprint(addzeros(mariocoincount, 2), uispace*1.5-0*scale, 16*scale)
		
		properprint("world", uispace*2.5 - 20*scale, 8*scale)
		properprint(marioworld .. "-" .. mariolevel, uispace*2.5 - 12*scale, 16*scale)
		
		properprint("time", uispace*3.5 - 16*scale, 8*scale)
		if editormode then
			if linktool then
				properprint("link", uispace*3.5 - 16*scale, 16*scale)
			else
				properprint("edit", uispace*3.5 - 16*scale, 16*scale)
			end
		else
			properprint(addzeros(math.ceil(mariotime), 3), uispace*3.5-8*scale, 16*scale)
		end
		
		if players > 1 then
			for i = 1, players do
				local x = (width*16)/players/2 + (width*16)/players*(i-1)
				if mariolivecount ~= false then

					local printedvalue = mariolives[i]
					if infinitelives then 
						printedvalue = mariodeaths[i]
					end
					if not singularmariogamemode then
						properprint("p" .. i .. " * " .. printedvalue, (x-string.len("p" .. i .. " * " .. printedvalue)*4+4)*scale, 25*scale)
					else
						properprint("dist:", (x-string.len("dist:")*4+4)*scale, 25*scale)
						properprint(round(mariodistancepoints[i].score, 2), (x-string.len(tostring(round(mariodistancepoints[i].score, 2)))*4+4)*scale, 34*scale)
					end

					local colorthing = i
					if i == 1 then
						colorthing = playerconfig
					end
					love.graphics.setColor(mariocolors[colorthing][1])
					--love.graphics.rectangle("fill", (x-string.len("p" .. i .. " * " .. mariolives[i])*4-3)*scale, 25*scale, 7*scale, 7*scale)
					love.graphics.setColor(255, 255, 255, 255)

					for count = 0, 3 do
						love.graphics.setScissor((x-string.len("p" .. i .. " * " .. printedvalue)*4-14)*scale, 22*scale, 22*scale, 9*scale)
						if count > 0 then
							love.graphics.setColor(unpack(mariocolors[i][count]))
						else
							love.graphics.setColor(255, 255, 255)
						end
						love.graphics.draw(marioanimations[count], marioidle[3], (x-string.len("p" .. i .. " * " .. printedvalue)*4-14)*scale, 22*scale, 0, scale)
						love.graphics.setScissor()


					end
					if infinitelives then
						love.graphics.setLineWidth(scale)
						love.graphics.setColor(255, 0, 0, 255)
						love.graphics.line((x-string.len("p" .. i .. " * " .. printedvalue)*4-8)*scale, 24*scale, (x-string.len("p" .. i .. " * " .. printedvalue)*4-8)*scale+12*scale, 31*scale)
						love.graphics.line( (x-string.len("p" .. i .. " * " .. printedvalue)*4-8)*scale+12*scale, 24*scale, (x-string.len("p" .. i .. " * " .. printedvalue)*4-8)*scale, 31*scale)
					end
					love.graphics.setColor(255, 255, 255, 255)
				end
			end
		end
		
		love.graphics.setColor(255, 255, 255)
		--text
		for j, w in pairs(objects["text"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--vines
		for j, w in pairs(objects["vine"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--warpzonetext
		if displaywarpzonetext then
			properprint("welcome to warp zone!", (mapwidth-14-1/16-xscroll)*16*scale, (5.5-yscroll)*16*scale)
			for i, v in pairs(warpzonenumbers) do
				properprint(v[3], math.floor((v[1]-xscroll-1-9/16)*16*scale), (v[2]-3-yscroll)*16*scale)
			end
		end
		
		love.graphics.setColor(255, 255, 255)
		--platforms
		for j, w in pairs(objects["platform"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--platforms
		for j, w in pairs(objects["seesawplatform"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--seesaws
		for j, w in pairs(seesaws) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
	
		--springs
		for j, w in pairs(objects["spring"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		
		--green springs
		for j, w in pairs(objects["springgreen"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--flag
		if flagx then
			love.graphics.draw(flagimg, math.floor((flagimgx-1-xscroll)*16*scale), ((flagimgy-yscroll)*16-8)*scale, 0, scale, scale)
			if levelfinishtype == "flag" then
				properprint2(flagscore, math.floor((flagimgx+4/16-xscroll)*16*scale), ((14-flagimgy-yscroll)*16-8)*scale, 0, scale, scale)
			end
		end
		
		love.graphics.setColor(255, 255, 255)
		--axe
		if axex then
			love.graphics.draw(axeimg, axequads[coinframe], math.floor((axex-1-xscroll)*16*scale), (axey-1.5-yscroll)*16*scale, 0, scale, scale)
			
			if marioworld ~= 8 then
				love.graphics.draw(toadimg, math.floor((mapwidth-7-xscroll)*16*scale), (11.0625-yscroll)*16*scale, 0, scale, scale)
			else
				love.graphics.draw(peachimg, math.floor((mapwidth-7-xscroll)*16*scale), (11.0625-yscroll)*16*scale, 0, scale, scale)
			end
		end
		
		love.graphics.setColor(255, 255, 255)
		--levelfinish text and toad
		if levelfinished and levelfinishtype == "castle" then
			if levelfinishedmisc2 == 1 then
				if levelfinishedmisc >= 1 then
					properprint("thank you mario!", math.floor(((mapwidth-12-xscroll)*16-1)*scale), 72*scale)
				end
				if levelfinishedmisc == 2 then
					properprint("but our princess is in", math.floor(((mapwidth-13.5-xscroll)*16-1)*scale), 104*scale) --say what
					properprint("another castle!", math.floor(((mapwidth-13.5-xscroll)*16-1)*scale), 120*scale) --bummer.
				end
			else
				if levelfinishedmisc >= 1 then
					properprint("thank you mario!", math.floor(((mapwidth-12-xscroll)*16-1)*scale), 72*scale)
				end
				if levelfinishedmisc >= 2 then
					properprint("your quest is over.", math.floor(((mapwidth-12.5-xscroll)*16-1)*scale), 96*scale)
				end
				if levelfinishedmisc >= 3 then
					properprint("we present you a new quest.", math.floor(((mapwidth-14.5-xscroll)*16-1)*scale), 112*scale)
				end
				if levelfinishedmisc >= 4 then
					properprint("push button b", math.floor(((mapwidth-11-xscroll)*16-1)*scale), 136*scale)
				end
				if levelfinishedmisc == 5 then
					properprint("to play as steve", math.floor(((mapwidth-12-xscroll)*16-1)*scale), 152*scale)
				end
			end
			
			if marioworld ~= 8 then
				love.graphics.draw(toadimg, math.floor((mapwidth-7-xscroll)*16*scale), (11.0625-yscroll)*16*scale, 0, scale, scale)
			else
				love.graphics.draw(peachimg, math.floor((mapwidth-7-xscroll)*16*scale), (11.0625-yscroll)*16*scale, 0, scale, scale)
			end
		end
		
		love.graphics.setColor(255, 255, 255)
		--Fireworks
		for j, w in pairs(fireworks) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--Buttons
		for j, w in pairs(objects["button"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--Upfires
		for j, w in pairs(objects["upfire"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--Pushbuttons
		for j, w in pairs(objects["pushbutton"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--portal gun pedestal
		for j, w in pairs(objects["pedestal"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--hardlight bridges
		for j, w in pairs(objects["lightbridgebody"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--laser
		for j, w in pairs(objects["laser"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--laserdetector
		for j, w in pairs(objects["laserdetector"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--lightbridge
		
		for j, w in pairs(objects["lightbridge"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--Groundlights
		for j, w in pairs(objects["groundlight"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--Faithplates
		for j, w in pairs(objects["faithplate"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--turrets
		for j, w in pairs(objects["turret"]) do
			w:draw()
		end
		for j, w in pairs(objects["turretshot"]) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--Bubbles
		for j, w in pairs(bubbles) do
			w:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--miniblocks
		for i, v in pairs(miniblocks) do
			v:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		--excursionfunnel
		for j, w in pairs(objects["funnel"]) do
			w:draw()
		end
		
		--OBJECTS
		for j, w in pairs(objects) do	
			if j ~= "tile" then
				for i, v in pairs(w) do
					local pass = false
					if j == "player" then

						if (singularmariogamemode and v.playernumber == convertclienttoplayer(currentmarioplayermoving) or not singularmariogamemode) then
							pass = true
						end
					else
						pass = true
					end
					if v.drawable and pass then
						love.graphics.setColor(255, 255, 255)
						local dirscale
						
						if j == "player" then
							if v.pointingangle > 0 then
								dirscale = -scale
							else
								dirscale = scale
							end

							if classicmodeactive then
								if v.playernumber == 1 then
									if v.animationdirection == "left" then
										dirscale = -scale
									else
										dirscale = scale
									end
								else
									if v.speedx > 0 then
										v.lastspeedx = v.speedx
										dirscale = scale
									elseif v.speedx < 0 then
										v.lastspeedx = v.speedx
										dirscale = -scale
									else
										if not v.lastspeedx then
											v.lastspeedx = 1
										end
										if v.lastspeedx > 0 then
											dirscale = scale
										else
											dirscale = -scale
										end
									end
								end
							end

							if bigmario then
								dirscale = dirscale * scalefactor
							end
						else
							if v.animationdirection == "left" then
								dirscale = -scale
							else
								dirscale = scale
							end
						end
						
						local horscale = scale
						if v.shot then
							horscale = -scale
						end
						
						if j == "player" then --VVVVVV gel
							if v.gravitydir == "up" then
								horscale = -scale
								if j == "player" and bigmario then
									horscale = horscale * scalefactor
								end
							else
								horscale = scale
								if j == "player" and bigmario then
									horscale = horscale * scalefactor
								end
							end
						end
						
						local ply, portaly = insideportal(v.x, v.y, v.width, v.height)
						local entryX, entryY, entryfacing, exitX, exitY, exitfacing
						
						--SCISSOR FOR ENTRY
						if v.static then
							if v.customscissor then
								love.graphics.setScissor(math.floor((v.customscissor[1]-xscroll)*16*scale), math.floor((v.customscissor[2]-.5-yscroll)*16*scale), v.customscissor[3]*16*scale, v.customscissor[4]*16*scale)
							end
						end
							
						if v.static == false and v.portalable ~= false then
							if v.customscissor then
								love.graphics.setScissor(math.floor((v.customscissor[1]-xscroll)*16*scale), math.floor((v.customscissor[2]-.5-yscroll)*16*scale), v.customscissor[3]*16*scale, v.customscissor[4]*16*scale)
							elseif ply ~= false and (v.active or v.portaloverride) then
								if portaly == 1 then
									entryX, entryY, entryfacing = objects["player"][ply].portal1X, objects["player"][ply].portal1Y, objects["player"][ply].portal1facing
									exitX, exitY, exitfacing = objects["player"][ply].portal2X, objects["player"][ply].portal2Y, objects["player"][ply].portal2facing
								else
									entryX, entryY, entryfacing = objects["player"][ply].portal2X, objects["player"][ply].portal2Y, objects["player"][ply].portal2facing
									exitX, exitY, exitfacing = objects["player"][ply].portal1X, objects["player"][ply].portal1Y, objects["player"][ply].portal1facing
								end
								
								if entryfacing == "right" then
									love.graphics.setScissor(math.floor((entryX-xscroll)*16*scale), math.floor(((entryY-3.5-yscroll)*16)*scale), 64*scale, 96*scale)
								elseif entryfacing == "left" then
									love.graphics.setScissor(math.floor((entryX-xscroll-5)*16*scale), math.floor(((entryY-4.5-yscroll)*16)*scale), 64*scale, 96*scale)
								elseif entryfacing == "up" then
									love.graphics.setScissor(math.floor((entryX-xscroll-3)*16*scale), math.floor(((entryY-5.5-yscroll)*16)*scale), 96*scale, 64*scale)
								elseif entryfacing == "down" then
									love.graphics.setScissor(math.floor((entryX-xscroll-4)*16*scale), math.floor(((entryY-0.5-yscroll)*16)*scale), 96*scale, 64*scale)
								end
							end
						end
						
						if type(v.graphic) == "table" then
							for k = 1, #v.graphic do
								if v.colors[k] then
									love.graphics.setColor(v.colors[k])
								else
									love.graphics.setColor(255, 255, 255)
								end
								love.graphics.draw(v.graphic[k], v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							end
							
							if v.drawhat and hatoffsets[v.animationstate] then
								local offsets = {}
								if v.graphic == v.biggraphic or v.animationstate == "grow" then
									if v.yoshi ~= nil then
										offsets = bighatoffsets["climbing"][v.climbframe]
									elseif v.animationstate == "grow" then
										offsets = hatoffsets["grow"]
									elseif v.fireanimationtimer < fireanimationtime then
										offsets = bighatoffsets["fire"]
									elseif underwater and (v.animationstate == "jumping" or v.animationstate == "falling") then
										offsets = bighatoffsets["swimming"][v.swimframe]
									elseif v.ducking then
										offsets = bighatoffsets["ducking"]
									elseif v.animationstate == "running" or v.animationstate == "falling"  then
										offsets = bighatoffsets["running"][v.runframe]
									elseif v.animationstate == "climbing" then
										offsets = bighatoffsets["climbing"][v.climbframe]
									else
										offsets = bighatoffsets[v.animationstate]
									end
								else
									if v.yoshi ~= nil then
										offsets = hatoffsets["climbing"][v.climbframe]
									elseif underwater and (v.animationstate == "jumping" or v.animationstate == "falling") then
										offsets = hatoffsets["swimming"][v.swimframe]
									elseif v.animationstate == "running" or v.animationstate == "falling"  then
										offsets = hatoffsets["running"][v.runframe]
									elseif v.animationstate == "climbing" then
										offsets = hatoffsets["climbing"][v.climbframe]
									else
										offsets = hatoffsets[v.animationstate]
									end
								end
						
								if #v.hats > 0 then
									local yadd = 0
									for i = 1, #v.hats do
										if v.hats[i] == 1 then
											love.graphics.setColor(v.colors[1])
										else
											love.graphics.setColor(255, 255, 255)
										end
										if v.graphic == v.biggraphic or v.animationstate == "grow" then
											love.graphics.draw(bighat[v.hats[i]].graphic, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX - bighat[v.hats[i]].x + offsets[1], v.quadcenterY - bighat[v.hats[i]].y + offsets[2] + yadd)
											yadd = yadd + bighat[v.hats[i]].height
										else
											love.graphics.draw(hat[v.hats[i]].graphic, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX - hat[v.hats[i]].x + offsets[1], v.quadcenterY - hat[v.hats[i]].y + offsets[2] + yadd)
											yadd = yadd + hat[v.hats[i]].height
										end
									end
								end
							end
							
							if v.graphic[0] then
								love.graphics.setColor(255, 255, 255)
								love.graphics.draw(v.graphic[0], v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							end
						else
							if v.graphic and v.quad then
								if v.frozen or v.freezed then
									love.graphics.setColor(0, 244, 244)
								else
									love.graphics.setColor(255, 255, 255)
								end
								love.graphics.draw(v.graphic, v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							end
						end
						
						--portal duplication
						if v.static == false and (v.active or v.portaloverride) and v.portalable ~= false then
							if v.customscissor then
								
							elseif ply ~= false then
								love.graphics.setScissor(unpack(currentscissor))
								local px, py, pw, ph, pr, pad = v.x, v.y, v.width, v.height, v.rotation, v.animationdirection
								px, py, d, d, pr, pad = portalcoords(px, py, 0, 0, pw, ph, pr, pad, entryX, entryY, entryfacing, exitX, exitY, exitfacing)
								
								if pad ~= v.animationdirection then
									dirscale = -dirscale
								end
								
								horscale = scale
								if v.shot then
									horscale = -scale
								end
								
								if exitfacing == "right" then
									love.graphics.setScissor(math.floor((exitX-xscroll)*16*scale), math.floor(((exitY-3.5-yscroll)*16)*scale), 64*scale, 96*scale)
								elseif exitfacing == "left" then
									love.graphics.setScissor(math.floor((exitX-xscroll-5)*16*scale), math.floor(((exitY-4.5-yscroll)*16)*scale), 64*scale, 96*scale)
								elseif exitfacing == "up" then
									love.graphics.setScissor(math.floor((exitX-xscroll-3)*16*scale), math.floor(((exitY-5.5-yscroll)*16)*scale), 96*scale, 64*scale)
								elseif exitfacing == "down" then
									love.graphics.setScissor(math.floor((exitX-xscroll-4)*16*scale), math.floor(((exitY-0.5-yscroll)*16)*scale), 96*scale, 64*scale)
								end
								
								if type(v.graphic) == "table" then
									for k = 1, #v.graphic do
										if v.colors[k] then
											love.graphics.setColor(v.colors[k])
										else
											love.graphics.setColor(255, 255, 255)
										end
										love.graphics.draw(v.graphic[k], v.quad, math.ceil(((px-xscroll)*16+v.offsetX)*scale), math.ceil(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
									end
									
									if v.drawhat and hatoffsets[v.animationstate] then
										local offsets = {}
										if v.graphic == v.biggraphic or v.animationstate == "grow" then
											if v.yoshi ~= nil then
												offsets = bighatoffsets["climbing"][v.climbframe]
											elseif v.animationstate == "grow" then
												offsets = hatoffsets["grow"]
											elseif v.fireanimationtimer < fireanimationtime then
												offsets = bighatoffsets["fire"]
											elseif underwater and (v.animationstate == "jumping" or v.animationstate == "falling") then
												offsets = bighatoffsets["swimming"][v.swimframe]
											elseif v.ducking then
												offsets = bighatoffsets["ducking"]
											elseif v.animationstate == "running" or v.animationstate == "falling"  then
												offsets = bighatoffsets["running"][v.runframe]
											elseif v.animationstate == "climbing" then
												offsets = bighatoffsets["climbing"][v.climbframe]
											else
												offsets = bighatoffsets[v.animationstate]
											end
										else
											if v.yoshi ~= nil then
												offsets = hatoffsets["climbing"][v.climbframe]
											elseif underwater and (v.animationstate == "jumping" or v.animationstate == "falling") then
												offsets = hatoffsets["swimming"][v.swimframe]
											elseif v.animationstate == "running" or v.animationstate == "falling"  then
												offsets = hatoffsets["running"][v.runframe]
											elseif v.animationstate == "climbing" then
												offsets = hatoffsets["climbing"][v.climbframe]
											else
												offsets = hatoffsets[v.animationstate]
											end
										end
								
										if #v.hats > 0 then
											local yadd = 0
											for i = 1, #v.hats do
												if v.hats[i] == 1 then
													love.graphics.setColor(v.colors[1])
												else
													love.graphics.setColor(255, 255, 255)
												end
												if v.graphic == v.biggraphic or v.animationstate == "grow" then
													love.graphics.draw(bighat[v.hats[i]].graphic, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - bighat[v.hats[i]].x + offsets[1], v.quadcenterY - bighat[v.hats[i]].y + offsets[2] + yadd)
													yadd = yadd + bighat[v.hats[i]].height
												else
													love.graphics.draw(hat[v.hats[i]].graphic, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - hat[v.hats[i]].x + offsets[1], v.quadcenterY - hat[v.hats[i]].y + offsets[2] + yadd)
													yadd = yadd + hat[v.hats[i]].height
												end
											end
										end
									end
									
									if v.graphic[0] then
										love.graphics.setColor(255, 255, 255)
										love.graphics.draw(v.graphic[0], v.quad, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
									end
								else
									love.graphics.draw(v.graphic, v.quad, math.ceil(((px-xscroll)*16+v.offsetX)*scale), math.ceil(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
								end
							end
						end
						love.graphics.setScissor(unpack(currentscissor))
					end
				end
			end
		end
		
		love.graphics.setColor(255, 255, 255)
		
		--regiontrigger
		for j, w in pairs(objects["regiontrigger"]) do
			w:draw()
		end
		
		--bowser
		for j, w in pairs(objects["bowser"]) do
			w:draw()
		end
		
		--lakito
		for j, w in pairs(objects["lakito"]) do
			w:draw()
		end
		
		--angrysun
		for j, w in pairs(objects["angrysun"]) do
			w:draw()
		end
		
		--Geldispensers
		for j, w in pairs(objects["geldispenser"]) do
			w:draw()
		end
		
		--Cubedispensers
		for j, w in pairs(objects["cubedispenser"]) do
			w:draw()
		end
		
		--Emancipationgrills
		for j, w in pairs(emancipationgrills) do
			w:draw()
		end
		
		--Doors
		for j, w in pairs(objects["door"]) do
			w:draw()
		end
		
		--Wallindicators
		for j, w in pairs(objects["wallindicator"]) do
			w:draw()
		end
		
		--Walltimers
		for j, w in pairs(objects["walltimer"]) do
			w:draw()
		end
		
		--Notgates
		for j, w in pairs(objects["notgate"]) do
			w:draw()
		end
		
		--Squarewave
		for j, w in pairs(objects["squarewave"]) do
			w:draw()
		end
		
		--Delayers
		for j, w in pairs(objects["delayer"]) do
			w:draw()
		end
		
		--Randomizer
		for j, w in pairs(objects["randomizer"]) do
			w:draw()
		end
		
		--Musicchanger
		for j, w in pairs(objects["musicchanger"]) do
			w:draw()
		end
		
		--particles
		for j, w in pairs(portalparticles) do
			w:draw()
		end
			
		--portals
		for i = 1, players do
			if objects["player"][i].portal1X ~= false then
				local rotation = 0
				local offsetx, offsety = 8, -3
				if objects["player"][i].portal1facing == "right" then
					rotation = math.pi/2
					offsetx, offsety = 11, 0
				elseif objects["player"][i].portal1facing == "down" then
					rotation = math.pi
					offsety = 3
				elseif objects["player"][i].portal1facing == "left" then
					rotation = math.pi*1.5
					offsetx, offsety = 5, 0
				end
				
				local portalframe = portalanimation
				local glowalpha = 100
				if objects["player"][i].portal2X == false then
				
				else
					love.graphics.setColor(255, 255, 255, 80 - math.abs(portalframe-3)*10)
					love.graphics.draw(portalglow, math.floor(((objects["player"][i].portal1X-1-xscroll)*16+offsetx)*scale), math.floor(((objects["player"][i].portal1Y-1-yscroll)*16+offsety)*scale), rotation, scale, scale, 8, 20)
					love.graphics.setColor(255, 255, 255, 255)
				end
				
				love.graphics.setColor(unpack(objects["player"][i].portal1color))
				love.graphics.draw(portalimage, portal1quad[portalframe], math.floor(((objects["player"][i].portal1X-1-xscroll)*16+offsetx)*scale), math.floor(((objects["player"][i].portal1Y-1-yscroll)*16+offsety)*scale), rotation, scale, scale, 8, 8)
			end
			
			if objects["player"][i].portal2X ~= false then
				rotation = 0
				offsetx, offsety = 8, -3
				if objects["player"][i].portal2facing == "right" then
					rotation = math.pi/2
					offsetx, offsety = 11, 0
				elseif objects["player"][i].portal2facing == "down" then
					rotation = math.pi
					offsety = 3
				elseif objects["player"][i].portal2facing == "left" then
					rotation = math.pi*1.5
					offsetx, offsety = 5, 0
				end
				
				local portalframe = portalanimation
				if objects["player"][i].portal1X == false then
					
				else
					love.graphics.setColor(255, 255, 255, 80 - math.abs(portalframe-3)*10)
					love.graphics.draw(portalglow, math.floor(((objects["player"][i].portal2X-1-xscroll)*16+offsetx)*scale), math.floor(((objects["player"][i].portal2Y-1-yscroll)*16+offsety)*scale), rotation, scale, scale, 8, 20)
					love.graphics.setColor(255, 255, 255, 255)
				end
				
				love.graphics.setColor(unpack(objects["player"][i].portal2color))
				love.graphics.draw(portalimage, portal2quad[portalframe], math.floor(((objects["player"][i].portal2X-1-xscroll)*16+offsetx)*scale), math.floor(((objects["player"][i].portal2Y-1-yscroll)*16+offsety)*scale), rotation, scale, scale, 8, 8)
			end
		end		
		
		love.graphics.setColor(255, 255, 255)
		
		--COINBLOCKANIMATION
		for i, v in pairs(coinblockanimations) do
			love.graphics.draw(coinblockanimationimage, coinblockanimationquads[coinblockanimations[i].frame], math.floor((coinblockanimations[i].x - xscroll)*16*scale), math.floor(((coinblockanimations[i].y - yscroll)*16-8)*scale), 0, scale, scale, 4, 54)
		end
		
		--SCROLLING SCORE
		for i, v in pairs(scrollingscores) do
			if type(scrollingscores[i].i) == "number" then
				properprint2(scrollingscores[i].i, math.floor((scrollingscores[i].x-0.4)*16*scale), math.floor((scrollingscores[i].y-1.5-scrollingscoreheight*(scrollingscores[i].timer/scrollingscoretime))*16*scale))
			elseif scrollingscores[i].i == "1up" then
				love.graphics.draw(oneuptextimage, math.floor((scrollingscores[i].x)*16*scale), math.floor((scrollingscores[i].y-1.5-scrollingscoreheight*(scrollingscores[i].timer/scrollingscoretime))*16*scale), 0, scale, scale)
			elseif scrollingscores[i].i == "3up" then
				love.graphics.draw(threeuptextimage, math.floor((scrollingscores[i].x)*16*scale), math.floor((scrollingscores[i].y-1.5-scrollingscoreheight*(scrollingscores[i].timer/scrollingscoretime))*16*scale), 0, scale, scale)
			end
		end
		
		--BLOCK DEBRIS
		for i, v in pairs(blockdebristable) do
			v:draw()
		end
		
		local minex, miney, minecox, minecoy
		
		--PORTAL UI STUFF
		if levelfinished == false and not classicmodeactive then
			for pl = 1, players do
				if objects["player"][pl].controlsenabled and objects["player"][pl].t == "portal" and objects["player"][pl].vine == false then
					local sourcex, sourcey = objects["player"][pl].x+6/16, objects["player"][pl].y+6/16
					local cox, coy, side, tend, x, y = traceline(sourcex, sourcey, objects["player"][pl].pointingangle)
					
					local portalpossible = true
					if cox == false or getportalposition(1, cox, coy, side, tend) == false then
						portalpossible = false
					end
					
					love.graphics.setColor(255, 255, 255, 255)
					
					local dist = math.sqrt(((x-xscroll)*16*scale - (sourcex-xscroll)*16*scale)^2 + ((y-.5-yscroll)*16*scale - (sourcey-.5)*16*scale)^2)/16/scale
					
					for i = 1, dist/portaldotsdistance+1 do
						if((i-1+objects["player"][pl].portaldotstimer/portaldotstime)/(dist/portaldotsdistance)) < 1 then
							local xplus = ((x-xscroll)*16*scale - (sourcex-xscroll)*16*scale)*((i-1+objects["player"][pl].portaldotstimer/portaldotstime)/(dist/portaldotsdistance))
							local yplus = ((y-.5-yscroll)*16*scale - (sourcey-.5-yscroll)*16*scale)*((i-1+objects["player"][pl].portaldotstimer/portaldotstime)/(dist/portaldotsdistance))
						
							local dotx = (sourcex-xscroll)*16*scale + xplus
							local doty = (sourcey-.5-yscroll)*16*scale + yplus
						
							local radius = math.sqrt(xplus^2 + yplus^2)/scale
							
							local alpha = 255
							if radius < portaldotsouter then
								alpha = (radius-portaldotsinner) * (255/(portaldotsouter-portaldotsinner))
								if alpha < 0 then
									alpha = 0
								end
							end
							
							
							if portalpossible == false then
								love.graphics.setColor(255, 0, 0, alpha)
							else
								love.graphics.setColor(0, 255, 0, alpha)
							end
						
							love.graphics.draw(portaldotimg, math.floor(dotx-0.25*scale), math.floor(doty-0.25*scale), 0, scale, scale)
						end
					end
				
					love.graphics.setColor(255, 255, 255, 255)
					
					if cox ~= false then
						if portalpossible == false then
							love.graphics.setColor(255, 0, 0)
						else
							love.graphics.setColor(0, 255, 0)
						end
						
						local rotation = 0
						if side == "right" then
							rotation = math.pi/2
						elseif side == "down" then
							rotation = math.pi
						elseif side == "left" then
							rotation = math.pi/2*3
						end
						love.graphics.draw(portalcrosshairimg, math.floor((x-xscroll)*16*scale), math.floor((y-.5-yscroll)*16*scale), rotation, scale, scale, 4, 8)
					end
				end
			end
		end
		
		--Portal projectile
		for i, v in pairs(portalprojectiles) do
			v:draw()
		end
		
		love.graphics.setColor(255, 255, 255)
		
		--nothing to see here
		for i, v in pairs(rainbooms) do
			v:draw()
		end
		
		--Minecraft
		--black border
		if objects["player"][mouseowner] and playertype == "minecraft" and not levelfinished then
			local v = objects["player"][mouseowner]
			local sourcex, sourcey = v.x+6/16, v.y+6/16
			local cox, coy, side, tend, x, y = traceline(sourcex, sourcey, v.pointingangle)
			
			if cox then
				local dist = math.sqrt((v.x+v.width/2 - x)^2 + (v.y+v.height/2 - y)^2)
				if dist <= minecraftrange then
					love.graphics.setColor(0, 0, 0, 170)
					love.graphics.rectangle("line", math.floor((cox-1-xscroll)*16*scale)-.5, (coy-1-.5-yscroll)*16*scale-.5, 16*scale, 16*scale)
				
					if breakingblockX and (cox ~= breakingblockX or coy ~= breakingblockY) then
						breakingblockX = cox
						breakingblockY = coy
						breakingblockprogress = 0
					elseif not breakingblockX and love.mouse.isDown("l") then
						breakingblockX = cox
						breakingblockY = coy
						breakingblockprogress = 0
					end
				elseif love.mouse.isDown("l") then
					breakingblockX = cox
					breakingblockY = coy
					breakingblockprogress = 0
				end
			else
				breakingblockX = nil
			end
			--break animation
			if breakingblockX then
				love.graphics.setColor(255, 255, 255, 255)
				local frame = math.ceil((breakingblockprogress/minecraftbreaktime)*10)
				if frame ~= 0 then
					love.graphics.draw(minecraftbreakimg, minecraftbreakquad[frame], (breakingblockX-1-xscroll)*16*scale, (breakingblockY-1.5-yscroll)*16*scale, 0, scale, scale)
				end
			end
			love.graphics.setColor(255, 255, 255, 255)
			
			--gui
			love.graphics.draw(minecraftgui, (width*8-91)*scale, 202*scale, 0, scale, scale)
			
			love.graphics.setColor(255, 255, 255, 200)
			for i = 1, 9 do
				local t = inventory[i].t
				
				if t ~= nil then
					local img = customtilesimg
					if t <= smbtilecount then
						img = smbtilesimg
					elseif t <= smbtilecount+portaltilecount then
						img = portaltilesimg
					end
					love.graphics.draw(img, tilequads[t].quad, (width*8-88+(i-1)*20)*scale, 205*scale, 0, scale, scale)
				end
			end
			
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.draw(minecraftselected, (width*8-92+(mccurrentblock-1)*20)*scale, 201*scale, 0, scale, scale)
			
			for i = 1, 9 do
				if inventory[i].t ~= nil then
					local count = inventory[i].count
					properprint(count, (width*8-72+(i-1)*20-string.len(count)*8)*scale, 205*scale)
				end
			end
		end
		
		love.graphics.translate(-(split-1)*width*16*scale/#splitscreen, 0)
	end
	love.graphics.setScissor()
	
	if neurotoxin then
		love.graphics.setColor(0, 0, 255)
		properprint("neurotoxin time: " .. math.floor(toxintime), uispace*.5 - 24*scale, 34*scale)
	end
	love.graphics.setColor(255, 255, 255)
	
	if earthquake > 0 then
		love.graphics.translate(-round(tremorx), -round(tremory))
	end
	
	for i = 2, #splitscreen do
		love.graphics.line((i-1)*width*16*scale/#splitscreen, 0, (i-1)*width*16*scale/#splitscreen, mapheight*16*scale)
	end
	
	if editormode then
		editor_draw()
	end
	
	--speed gradient
	if speed < 1 then
		love.graphics.setColor(255, 255, 255, 255-255*speed)
		love.graphics.draw(gradientimg, 0, 0, 0, scale, scale)
	end
	
	if yoffset < 0 then
		love.graphics.translate(0, -yoffset*scale)
	end
	love.graphics.translate(0, yoffset*scale)
	
	if testlevel then
		love.graphics.setColor(255, 0, 0)
		properprint("testing level - press esc to return to editor", 0, 0)
	end
	love.graphics.setFont(chatlogfont)
	if mappack == "onlineportal" then
		love.graphics.setColor(0, 0, 0, chatmessagegradient)
	else
		love.graphics.setColor(255, 255, 255, chatmessagegradient)
	end
	for x = 1, #chatlog do

		love.graphics.print(string.upper(chatlog[x].id) .. ": " .. chatlog[x].message, 0, love.graphics.getHeight()/2-((x-1)*10*scale))
	end
	if mappack == "onlineportal" then
		love.graphics.setColor(0, 0, 0)
		
	else

		love.graphics.setColor(255, 255, 255)
	end

	if typinginchat then
		love.graphics.print(chatmessageinprogressstring, 0, love.graphics.getHeight()/2+15*scale)
		local dt = love.timer.getDelta()
		if love.keyboard.isDown("backspace") then
			chatmessageoriginaldeletetimer = chatmessageoriginaldeletetimer + dt
			if chatmessageoriginaldeletetimer > .2 then
				chatmessagedeletecharactertimer = chatmessagedeletecharactertimer + dt
				if chatmessagedeletecharactertimer > .1 then
					chatmessagedeletecharactertimer = 0
					if string.len(chatmessageinprogressstring) > 2 then
						chatmessageinprogressstring = string.sub(chatmessageinprogressstring, 1, string.len(chatmessageinprogressstring)-1)
					end
				end
			end
		else
			chatmessageoriginaldeletetimer = 0
		end
	end
	
	--pause menu
	if pausemenuopen then
		love.graphics.setColor(0, 0, 0, 100)
		love.graphics.rectangle("fill", 0, 0, width*16*scale, 224*scale)
		
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", (width*8*scale)-50*scale, (112*scale)-75*scale, 100*scale, 150*scale)
		love.graphics.setColor(255, 255, 255)
		drawrectangle(width*8-49, 112-74, 98, 148)
		
		for i = 1, #pausemenuoptions do
			love.graphics.setColor(100, 100, 100, 255)
			if pausemenuselected == i and not menuprompt and not desktopprompt then
				love.graphics.setColor(255, 255, 255, 255)
				properprint(">", (width*8*scale)-45*scale, (112*scale)-60*scale+(i-1)*25*scale)
			end
			properprint(pausemenuoptions[i], (width*8*scale)-35*scale, (112*scale)-60*scale+(i-1)*25*scale)
			properprint(pausemenuoptions2[i], (width*8*scale)-35*scale, (112*scale)-50*scale+(i-1)*25*scale)
			
			if pausemenuoptions[i] == "volume" then
				drawrectangle((width*8)-34, 68+(i-1)*25, 74, 1)
				drawrectangle((width*8)-34, 65+(i-1)*25, 1, 7)
				drawrectangle((width*8)+40, 65+(i-1)*25, 1, 7)
				love.graphics.draw(volumesliderimg, math.floor(((width*8)-35+74*volume)*scale), (112*scale)-47*scale+(i-1)*25*scale, 0, scale, scale)
			end
		end
		
		if menuprompt then
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
			love.graphics.setColor(255, 255, 255, 255)
			drawrectangle((width*8)-99, 112-24, 198, 48)
			properprint("quit to menu?", (width*8*scale)-string.len("quit to menu?")*4*scale, (112*scale)-10*scale)
			if pausemenuselected2 == 1 then
				properprint(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
				love.graphics.setColor(255, 255, 255, 255)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(100, 100, 100, 255)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale) 
			else
				properprint(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
				love.graphics.setColor(100, 100, 100, 255)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(255, 255, 255, 255)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
			end
		end
		
		if desktopprompt then
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
			love.graphics.setColor(255, 255, 255, 255)
			drawrectangle((width*8)-99, 112-24, 198, 48)
			properprint("quit to desktop?", (width*8*scale)-string.len("quit to desktop?")*4*scale, (112*scale)-10*scale)
			if pausemenuselected2 == 1 then
				properprint(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
				love.graphics.setColor(255, 255, 255, 255)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(100, 100, 100, 255)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
			else
				properprint(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
				love.graphics.setColor(100, 100, 100, 255)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(255, 255, 255, 255)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
			end
		end
		
		if suspendprompt then
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
			love.graphics.setColor(255, 255, 255, 255)
			drawrectangle((width*8)-99, 112-24, 198, 48)
			if not onlinemp then
				properprint("suspend game? this can", (width*8*scale)-string.len("suspend game? this can")*4*scale, (112*scale)-20*scale)
				properprint("only be loaded once!", (width*8*scale)-string.len("only be loaded once!")*4*scale, (112*scale)-10*scale)
			else
				properprint("return to lobby?", (width*8*scale)-string.len("return to lobby?")*4*scale, (112*scale)-10*scale)
			end
			if pausemenuselected2 == 1 then
				properprint(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
				love.graphics.setColor(255, 255, 255, 255)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(100, 100, 100, 255)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
			else
				properprint(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
				love.graphics.setColor(100, 100, 100, 255)
				properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(255, 255, 255, 255)
				properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
			end
		end
	end

	if disconnectprompt then
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
		love.graphics.setColor(255, 255, 255, 255)
		drawrectangle((width*8)-99, 112-24, 198, 48)
		properprint("quit to menu?", (width*8*scale)-string.len("quit to menu?")*4*scale, (112*scale)-10*scale)
		if pausemenuselected2 == 1 then
			properprint(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
			love.graphics.setColor(255, 255, 255, 255)
			properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
			love.graphics.setColor(100, 100, 100, 255)
			properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
		else
			properprint(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
			love.graphics.setColor(100, 100, 100, 255)
			properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
			love.graphics.setColor(255, 255, 255, 255)
			properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
		end
	end
end

function updatesplitscreen()
	if players == 2 and netplay == false then
		if #splitscreen == 1 then
			if math.abs(objects["player"][1].x - objects["player"][2].x) > width - scrollingstart - scrollingleftstart then
				if objects["player"][1].x < objects["player"][2].x then
					splitscreen = {{1}, {2}}
				else
					splitscreen = {{2}, {1}}
				end
				
				splitxscroll = {xscroll, xscroll+width/2}
				generatespritebatch()
			end
		else
			if splitxscroll[2] <= splitxscroll[1]+width/2 then
				splitscreen = {{1, 2}}
				
				xscroll = splitxscroll[1]
				generatespritebatch()
			end
		end
	end
end

function startlevel(level)
	if singularmariogamemode then
		for x = 1, players do
			mariodistancepoints[x].distance = 0
		end
	end
	skipupdate = true
	love.audio.stop()

	local sublevel = false
	if type(level) == "number" then
		sublevel = true
	end
	
	if sublevel then
		prevsublevel = mariosublevel
		mariosublevel = level
		if level ~= 0 then
			level = marioworld .. "-" .. mariolevel .. "_" .. level
		else
			level = marioworld .. "-" .. mariolevel
		end
	else
		mariosublevel = 0
		prevsublevel = false
		mariotime = 400
	end
	
	--MISC VARS
	everyonedead = false
	levelfinished = false
	coinanimation = 1
	flagx = false
	levelfinishtype = nil
	firestartx = false
	firestarted = false
	firedelay = math.random(4)
	flyingfishdelay = 1
	flyingfishstarted = false
	flyingfishstartx = false
	flyingfishendx = false
	meteordelay = 1
	meteorstarted = false
	meteorstartx = false
	meteorendx = false
	bulletbilldelay = 1
	bulletbillstarted = false
	bulletbillstartx = false
	bulletbillendx = false
	bigbilldelay = 1
	bigbillstarted = false
	bigbillstartx = false
	bigbillendx = false
	kingbilldelay = 1
	kingbillstarted = false
	kingbillstartx = false
	kingbillendx = false
	windstarted = false
	windstartx = false
	windendx = false
	windleaftimer = 0.1
	firetimer = firedelay
	flyingfishtimer = flyingfishdelay
	meteortimer = meteordelay
	bulletbilltimer = bulletbilldelay
	bigbilltimer = bigbilldelay
	kingbilltimer = kingbilldelay
	windleaftimer = 0.1
	axex = false
	axey = false
	lakitoendx = false
	lakitoend = false
	angrysunendx = false
	angrysunend = false
	noupdate = false
	xscroll = 0
	yscroll = 0
	splitscreen = {{}}
	checkpoints = {}
	checkpointpoints = {}
	repeatX = 0
	lastrepeat = 0
	displaywarpzonetext = false
	for i = 1, players do
		table.insert(splitscreen[1], i)
	end
	checkpointi = 0
	mazestarts = {}
	mazeends = {}
	mazesolved = {}
	mazesolved[0] = true
	mazeinprogress = false
	earthquake = 0
	sunrot = 0
	gelcannontimer = 0
	pausemenuselected = 1
	coinblocktimers = {}
	
	portaldelay = {}
	for i = 1, players do
		portaldelay[i] = 0
	end
	
	--Minecraft
	breakingblockX = false
	breakingblockY = false
	breakingblockprogress = 0
	
	--class tables
	coinblockanimations = {}
	scrollingscores = {}
	portalparticles = {}
	portalprojectiles = {}
	emancipationgrills = {}
	platformspawners = {}
	rocketlaunchers = {}
	bigbilllaunchers = {}
	kingbilllaunchers = {}
	cannonballlaunchers = {}
	userects = {}
	blockdebristable = {}
	fireworks = {}
	seesaws = {}
	bubbles = {}
	rainbooms = {}
	miniblocks = {}
	inventory = {}
	for i = 1, 9 do
		inventory[i] = {}
	end
	mccurrentblock = 1
	
	blockbouncetimer = {}
	blockbouncex = {}
	blockbouncey = {}
	blockbouncecontent = {}
	blockbouncecontent2 = {}
	warpzonenumbers = {}
	
	objects = {}
	objects["player"] = {}
	objects["portalwall"] = {}
	objects["tile"] = {}
	objects["goomba"] = {}
	objects["koopa"] = {}
	objects["mushroom"] = {}
	objects["flower"] = {}
	objects["oneup"] = {}
	objects["star"] = {}
	objects["vine"] = {}
	objects["box"] = {}
	objects["door"] = {}
	objects["button"] = {}
	objects["groundlight"] = {}
	objects["wallindicator"] = {}
	objects["walltimer"] = {}
	objects["notgate"] = {}
	objects["lightbridge"] = {}
	objects["lightbridgebody"] = {}
	objects["faithplate"] = {}
	objects["laser"] = {}
	objects["laserdetector"] = {}
	objects["gel"] = {}
	objects["geldispenser"] = {}
	objects["cubedispenser"] = {}
	objects["pushbutton"] = {}
	objects["bulletbill"] = {}
	objects["hammerbro"] = {}
	objects["hammer"] = {}
	objects["fireball"] = {}
	objects["platform"] = {}
	objects["platformspawner"] = {}
	objects["plant"] = {}
	objects["castlefire"] = {}
	objects["castlefirefire"] = {}
	objects["fire"] = {}
	objects["bowser"] = {}
	objects["spring"] = {}
	objects["cheep"] = {}
	objects["flyingfish"] = {}
	objects["upfire"] = {}
	objects["seesawplatform"] = {}
	objects["lakito"] = {}
	objects["squid"] = {}

	objects["poisonmush"] = {}
	objects["downplant"] = {}
	objects["bigbill"] = {}
	objects["kingbill"] = {}
	objects["sidestepper"] = {}
	objects["barrel"] = {}
	objects["icicle"] = {}
	objects["angrysun"] = {}
	objects["splunkin"] = {}
	objects["threeup"] = {}
	objects["biggoomba"] = {}
	objects["bigkoopa"] = {}
	objects["firebro"] = {}
	objects["brofireball"] = {}
	objects["plusclock"] = {}
	objects["springgreen"] = {}
	objects["redplant"] = {}
	objects["reddownplant"] = {}
	objects["thwomp"] = {}
	objects["fishbone"] = {}
	objects["drybones"] = {}
	objects["muncher"] = {}
	objects["meteor"] = {}
	objects["dryplant"] = {}
	objects["drydownplant"] = {}
	objects["donut"] = {}
	objects["boomerangbro"] = {}
	objects["boomerang"] = {}
	objects["parabeetle"] = {}
	objects["ninji"] = {}
	objects["hammersuit"] = {}
	objects["mariohammer"] = {}
	objects["boo"] = {}
	objects["mole"] = {}
	objects["bigmole"] = {}
	objects["bomb"] = {}
	objects["fireplant"] = {}
	objects["plantfire"] = {}
	objects["flipblock"] = {}
	objects["downfireplant"] = {}
	objects["torpedolauncher"] = {}
	objects["torpedoted"] = {}
	objects["frogsuit"] = {}
	objects["boomboom"] = {}
	objects["levelball"] = {}
	objects["leaf"] = {}
	objects["mariotail"] = {}
	objects["windleaf"] = {}
	objects["energylauncher"] = {}
	objects["energyball"] = {}
	objects["energycatcher"] = {}
	objects["turret"] = {}
	objects["turretshot"] = {}
	objects["blocktogglebutton"] = {}
	objects["buttonblock"] = {}
	objects["squarewave"] = {}
	objects["delayer"] = {}
	objects["coin"] = {}
	objects["amp"] = {}
	objects["funnel"] = {}
	objects["longfire"] = {}
	objects["cannonball"] = {}
	objects["minimushroom"] = {}
	objects["rocketturret"] = {}
	objects["turretrocket"] = {}
	objects["glados"] = {}
	objects["core"] = {}
	objects["pedestal"] = {}
	objects["portal"] = {}
	objects["text"] = {}
	objects["regiontrigger"] = {}
	objects["pixeltile"] = {}
	objects["tiletool"] = {}
	objects["iceball"] = {}
	objects["enemytool"] = {}
	objects["randomizer"] = {}
	objects["yoshiegg"] = {}
	objects["yoshi"] = {}
	objects["musicchanger"] = {}
	
	objects["screenboundary"] = {}
	objects["screenboundary"]["left"] = screenboundary:new(0)
	
	splitxscroll = {0}
	splityscroll = {0}
	
	startx = 3
	starty = 13
	pipestartx = nil
	pipestarty = nil
	animation = nil
	
	enemiesspawned = {}
	
	intermission = false
	haswarpzone = false
	underwater = false
	bonusstage = false
	custombackground = false
	customforeground = false
	autoscrolling = false
	portalgun = true
	custommusici = 1
	mariotimelimit = 400
	spriteset = 1
	--LOAD THE MAP
	if loadmap(level) == false then --make one up
		mapwidth = width
		if love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/heights/" .. marioworld .. "-" .. mariolevel .. "_" .. mariosublevel .. ".txt") then
			local s11 = love.filesystem.read(mappackfolder .. "/" .. mappack .. "/heights/" .. marioworld .. "-" .. mariolevel .. "_" .. mariosublevel .. ".txt")
			mapheight = tonumber(s11)
		else
			mapheight = 15
		end
		map = {}
		for x = 1, width do
			map[x] = {}
			for y = 1, mapheight do
				if y > 13 then
					map[x][y] = {2}
					objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1, 1, 1, true)
					map[x][y]["gels"] = {}
				else
					map[x][y] = {1}
					map[x][y]["gels"] = {}
				end
			end
		end
	else
		if sublevel == false and mariosublevel ~= 0 then
			level = marioworld .. "-" .. mariolevel
			mariosublevel = 0
			loadmap(level)
		end
	end
	custommusic = _G["custommusic" .. custommusici]
	
	objects["screenboundary"]["right"] = screenboundary:new(mapwidth)
	
	if flagx then
		objects["screenboundary"]["flag"] = screenboundary:new(flagx+6/16)
	end
	
	if axex then
		objects["screenboundary"]["axe"] = screenboundary:new(axex+1)
	end
	
	if intermission then
		animation = "intermission"
	end
	
	if not sublevel then
		mariotime = mariotimelimit
	elseif subleveltest then
		mariotime = mariotimelimit
	end
	
	--Maze setup
	--check every block between every start/end pair to see how many gates it contains
	if #mazestarts == #mazeends then
		mazegates = {}
		for i = 1, #mazestarts do
			local maxgate = 1
			for x = mazestarts[i], mazeends[i] do
				for y = 1, mapheight do
					if map[x][y][2] and entityquads[map[x][y][2]].t == "mazegate" then
						if tonumber(map[x][y][3]) > maxgate then
							maxgate = tonumber(map[x][y][3])
						end
					end
				end
			end
			mazegates[i] = maxgate
		end
	else
		print("Mazenumber doesn't fit!")
	end
	
	--background
	if backgroundrgbon == true then
		love.graphics.setBackgroundColor(unpack(backgroundrgb))
	else
		love.graphics.setBackgroundColor(backgroundcolor[background])
	end
	
	--check if it's a bonusstage (boooooooonus!)
	if bonusstage then
		animation = "vinestart"
	end
	
	--set startx to checkpoint
	if checkpointx and checkcheckpoint then
		startx = checkpointx
		starty = checkpointpoints[checkpointx] or mapheight - 2
		
		--clear enemies from spawning near
		for y = starty-15, starty+15 do
			for x = startx-8, startx+8 do
				if inmap(x, y) and #map[x][y] > 1 then
					if tablecontains(enemies, entityquads[map[x][y][2]].t) then
						table.insert(enemiesspawned, {x, y})
					end
				end
			end
		end
		
		--find which i it is
		for i = 1, #checkpoints do
			if checkpointx == checkpoints[i] then
				checkpointi = i
			end
		end
	end
	
	--set startx to pipestart
	if pipestartx then
		startx = pipestartx-1
		starty = pipestarty
		--check if startpos is a colliding block
		if tilequads[map[startx][starty][1]].collision then
			animation = "pipeup"
		end
	end
	
	splitxscroll = {startx-scrollingleftcomplete-2}
	if splitxscroll[1] > mapwidth - width then
		splitxscroll[1] = mapwidth - width
	end
	
	if splitxscroll[1] < 0 then
		splitxscroll[1] = 0
	end
		
	--ADD ENEMIES ON START SCREEN
	if editormode == false then
		local xtodo = width+1
		if mapwidth < width+1 then
			xtodo = mapwidth
		end
			
		for x = math.floor(splitxscroll[1]), math.floor(splitxscroll[1])+xtodo do
			for y = 1, mapheight do
				spawnenemy(x, y)
			end
		end
	end
	
	--add the players
	local mul = 0.5
	if mariosublevel ~= 0 or prevsublevel ~= false then
		mul = 2/16
	end
	
	objects["player"] = {}
	for i = 1, players do
		if startx then
			objects["player"][i] = mario:new(startx + (i-1)*mul-6/16, starty-1, i, animation, mariosizes[i], playertype)
		else
			objects["player"][i] = mario:new(1.5 + (i-1)*mul-6/16+1.5, 13, i, animation, mariosizes[i], playertype)
		end
	end
	
	--PLAY BGM
	if intermission == false then
		playmusic()
	else
		playsound(intermissionsound)
	end
	
	--load editor
	editor_load()
	
	--Do stuff
	for i, v in pairs(objects["laser"]) do
		v:updaterange()
	end
	for i, v in pairs(objects["lightbridge"]) do
		v:updaterange()
	end
	for i, v in pairs(objects["funnel"]) do
		v:updaterange()
	end
	
	generatespritebatch()
end

function loadmap(filename)
	print("Loading " .. mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt")
	
	if love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt") == false then
		print(mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt not found!")
		return false
	end
	local s = love.filesystem.read( mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt" )
	local s2 = s:split(";")
	
	if love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/heights/" .. marioworld .. "-" .. mariolevel .. "_" .. mariosublevel .. ".txt") then
		local s11 = love.filesystem.read(mappackfolder .. "/" .. mappack .. "/heights/" .. marioworld .. "-" .. mariolevel .. "_" .. mariosublevel .. ".txt")
		mapheight = tonumber(s11)
	else
		mapheight = 15
	end
	
	--MAP ITSELF
	local t = s2[1]:split(",")
	
	if math.mod(#t, mapheight) ~= 0 then
		print("Incorrect number of entries: " .. #t)
		return false
	end
	
	mapwidth = #t/mapheight
	
	map = {}
	unstatics = {}
	
	for x = 1, #t/mapheight do
		map[x] = {}
		for y = 1, mapheight do
			map[x][y] = {}
			map[x][y]["gels"] = {}
			
			local r = tostring(t[(y-1)*(#t/mapheight)+x]):split("-")
			
			if tonumber(r[1]) > smbtilecount+portaltilecount+customtilecount then
				r[1] = 1
			end
			
			for i = 1, #r do
				if r[i] ~= "link" then
					map[x][y][i] = tonumber(r[i])
				else
					map[x][y][i] = r[i]
				end
			end
			
			--create object for block
			if tilequads[tonumber(r[1])].collision == true then
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1, 1, 1, true)
			end
		end
	end
	
	for y = 1, mapheight do
		for x = 1, #t/mapheight do
			local r = map[x][y]
			if #r > 1 then
				local t = entityquads[r[2]].t
				if t == "spawn" then
					startx = x
					starty = y
					
				elseif not editormode then
					if t == "warppipe" then
						table.insert(warpzonenumbers, {x, y, r[3]})
						
					elseif t == "manycoins" then
						map[x][y][3] = 7
						
					elseif t == "text" then
						table.insert(objects["text"], text:new(x, y, r, r[3]))
						
					elseif t == "tiletool" then
						table.insert(objects["tiletool"], tiletool:new(x, y, r, r[3]))
						
					elseif t == "enemytool" then
						table.insert(objects["enemytool"], enemytool:new(x, y, r, r[3]))
						
					elseif t == "regiontrigger" then
						table.insert(objects["regiontrigger"], regiontrigger:new(x, y, r[3], r))
						
					elseif t == "flag" then
						flagx = x-1	
						flagy = y
						
					elseif t == "pipespawn" and (prevsublevel == r[3] or (mariosublevel == r[3] and blacktime == sublevelscreentime)) then
						pipestartx = x
						pipestarty = y
						
					elseif t == "emancehor" then
						table.insert(emancipationgrills, emancipationgrill:new(x, y, "hor"))
					elseif t == "emancever" then
						table.insert(emancipationgrills, emancipationgrill:new(x, y, "ver"))
						
					elseif t == "doorver" then
						table.insert(objects["door"], door:new(x, y, r, "ver"))
					elseif t == "doorhor" then
						table.insert(objects["door"], door:new(x, y, r, "hor"))
						
					elseif t == "button" then
						table.insert(objects["button"], button:new(x, y))
						
					elseif t == "pushbuttonleft" then
						table.insert(objects["pushbutton"], pushbutton:new(x, y, "left"))
					elseif t == "pushbuttonright" then
						table.insert(objects["pushbutton"], pushbutton:new(x, y, "right"))
						
					elseif t == "wallindicator" then
						table.insert(objects["wallindicator"], wallindicator:new(x, y, r))
						
					elseif t == "groundlightver" then
						table.insert(objects["groundlight"], groundlight:new(x, y, 1, r))
					elseif t == "groundlighthor" then
						table.insert(objects["groundlight"], groundlight:new(x, y, 2, r))
					elseif t == "groundlightupright" then
						table.insert(objects["groundlight"], groundlight:new(x, y, 3, r))
					elseif t == "groundlightrightdown" then
						table.insert(objects["groundlight"], groundlight:new(x, y, 4, r))
					elseif t == "groundlightdownleft" then
						table.insert(objects["groundlight"], groundlight:new(x, y, 5, r))
					elseif t == "groundlightleftup" then
						table.insert(objects["groundlight"], groundlight:new(x, y, 6, r))
						
					elseif t == "faithplateup" then
						table.insert(objects["faithplate"], faithplate:new(x, y, "up"))
					elseif t == "faithplateright" then
						table.insert(objects["faithplate"], faithplate:new(x, y, "right"))
					elseif t == "faithplateleft" then
						table.insert(objects["faithplate"], faithplate:new(x, y, "left"))
						
					elseif t == "laserright" then
						table.insert(objects["laser"], laser:new(x, y, "right", r))
					elseif t == "laserdown" then
						table.insert(objects["laser"], laser:new(x, y, "down", r))
					elseif t == "laserleft" then
						table.insert(objects["laser"], laser:new(x, y, "left", r))
					elseif t == "laserup" then
						table.insert(objects["laser"], laser:new(x, y, "up", r))
						
					elseif t == "lightbridgeright" then
						table.insert(objects["lightbridge"], lightbridge:new(x, y, "right", r))
					elseif t == "lightbridgeleft" then
						table.insert(objects["lightbridge"], lightbridge:new(x, y, "left", r))
					elseif t == "lightbridgedown" then
						table.insert(objects["lightbridge"], lightbridge:new(x, y, "down", r))
					elseif t == "lightbridgeup" then
						table.insert(objects["lightbridge"], lightbridge:new(x, y, "up", r))
						
					elseif t == "funnelright" then
						table.insert(objects["funnel"], funnel:new(x, y, "right", r))
					elseif t == "funneldown" then
						table.insert(objects["funnel"], funnel:new(x, y, "down", r))
					elseif t == "funnelleft" then
						table.insert(objects["funnel"], funnel:new(x, y, "left", r))
					elseif t == "funnelup" then
						table.insert(objects["funnel"], funnel:new(x, y, "up", r))
						
					elseif t == "laserdetectorright" then
						table.insert(objects["laserdetector"], laserdetector:new(x, y, "right"))
					elseif t == "laserdetectordown" then
						table.insert(objects["laserdetector"], laserdetector:new(x, y, "down"))
					elseif t == "laserdetectorleft" then
						table.insert(objects["laserdetector"], laserdetector:new(x, y, "left"))
					elseif t == "laserdetectorup" then
						table.insert(objects["laserdetector"], laserdetector:new(x, y, "up"))
						
					elseif t == "boxtube" then
						table.insert(objects["cubedispenser"], cubedispenser:new(x, y, r))
						
					elseif t == "bluegeldown" then
						table.insert(objects["geldispenser"], geldispenser:new(x, y, 1, "down", r))
					elseif t == "bluegelright" then
						table.insert(objects["geldispenser"], geldispenser:new(x, y, 1, "right", r))
					elseif t == "bluegelleft" then
						table.insert(objects["geldispenser"], geldispenser:new(x, y, 1, "left", r))
									
					elseif t == "orangegeldown" then
						table.insert(objects["geldispenser"], geldispenser:new(x, y, 2, "down", r))
					elseif t == "orangegelright" then
						table.insert(objects["geldispenser"], geldispenser:new(x, y, 2, "right", r))
					elseif t == "orangegelleft" then
						table.insert(objects["geldispenser"], geldispenser:new(x, y, 2, "left", r))
									
					elseif t == "whitegeldown" then
						table.insert(objects["geldispenser"], geldispenser:new(x, y, 3, "down", r))
					elseif t == "whitegelright" then
						table.insert(objects["geldispenser"], geldispenser:new(x, y, 3, "right", r))
					elseif t == "whitegelleft" then
						table.insert(objects["geldispenser"], geldispenser:new(x, y, 3, "left", r))
							
					elseif t == "purplegeldown" then
						table.insert(objects["geldispenser"], geldispenser:new(x, y, 4, "down", r))
					elseif t == "purplegelright" then
						table.insert(objects["geldispenser"], geldispenser:new(x, y, 4, "right", r))
					elseif t == "purplegelleft" then
						table.insert(objects["geldispenser"], geldispenser:new(x, y, 4, "left", r))
					
					elseif t == "timer" then
						table.insert(objects["walltimer"], walltimer:new(x, y, r[3], r))
					elseif t == "notgate" then
						table.insert(objects["notgate"], notgate:new(x, y, r))
						
					elseif t == "platformspawnerup" then
						table.insert(platformspawners, platformspawner:new(x, y, "up", r[3]))
					elseif t == "platformspawnerdown" then
						table.insert(platformspawners, platformspawner:new(x, y, "down", r[3]))
						
					elseif t == "box" then
						table.insert(objects["box"], box:new(x, y))
					elseif t == "box2" then
						table.insert(objects["box"], box:new(x, y, "box2"))
						
					elseif t == "energylauncherright" then
						table.insert(objects["energylauncher"], energylauncher:new(x, y, "right"))
					elseif t == "energylauncherleft" then
						table.insert(objects["energylauncher"], energylauncher:new(x, y, "left"))
					elseif t == "energylauncherup" then
						table.insert(objects["energylauncher"], energylauncher:new(x, y, "up"))
					elseif t == "energylauncherdown" then
						table.insert(objects["energylauncher"], energylauncher:new(x, y, "down"))
			
					elseif t == "energycatcherright" then
						table.insert(objects["energycatcher"], energycatcher:new(x, y, "right"))
					elseif t == "energycatcherleft" then
						table.insert(objects["energycatcher"], energycatcher:new(x, y, "left"))
					elseif t == "energycatcherup" then
						table.insert(objects["energycatcher"], energycatcher:new(x, y, "up"))
					elseif t == "energycatcherdown" then
						table.insert(objects["energycatcher"], energycatcher:new(x, y, "down"))
						
					elseif t == "turretleft" then
						table.insert(objects["turret"], turret:new(x, y, "left"))
					elseif t == "turretright" then
						table.insert(objects["turret"], turret:new(x, y, "right"))
					elseif t == "turret2left" then
						table.insert(objects["turret"], turret:new(x, y, "left", "turret2"))
					elseif t == "turret2right" then
						table.insert(objects["turret"], turret:new(x, y, "right", "turret2"))
						
					elseif t == "squarewave" then
						table.insert(objects["squarewave"], squarewave:new(x, y, r, r[3]))
					elseif t == "delayer" then
						table.insert(objects["delayer"], delayer:new(x, y, r, r[3]))
						
					elseif t == "rocketturret" then
						table.insert(objects["rocketturret"], rocketturret:new(x, y))
						
					elseif t == "glados" then
						table.insert(objects["glados"], glados:new(x, y))
						
					elseif t == "pedestal" then
						table.insert(objects["pedestal"], pedestal:new(x, y, r[3]))
						
					elseif t == "portal1" then
						table.insert(objects["portal"], portal:new(x, y, r, 1, r[3]))
					elseif t == "portal2" then
						table.insert(objects["portal"], portal:new(x, y, r, 2, r[3]))
						
					elseif t == "randomizer" then
						table.insert(objects["randomizer"], randomizer:new(x, y, r[3], r))
					elseif t == "musicchanger" then
						table.insert(objects["musicchanger"], musicchanger:new(x, y, r, r[3]))
						
					elseif t == "firestart" then
						firestartx = x
						
					elseif t == "longfire" then
						table.insert(objects["longfire"], longfire:new(x, y, r[3]))
						
					elseif t == "flyingfishstart" then
						flyingfishstartx = x
					elseif t == "flyingfishend" then
						flyingfishendx = x
						
					elseif t == "meteorstart" then
						meteorstartx = x
					elseif t == "meteorend" then
						meteorendx = x
						
					elseif t == "bulletbillstart" then
						bulletbillstartx = x
					elseif t == "bulletbillend" then
						bulletbillendx = x
						
					elseif t == "bigbillstart" then
						bigbillstartx = x
					elseif t == "bigbillend" then
						bigbillendx = x
						
					elseif t == "kingbillstart" then
						kingbillstartx = x
					elseif t == "kingbillend" then
						kingbillendx = x
					
					elseif t == "windstart" then
						windstartx = x
					elseif t == "windend" then
						windendx = x
						
					elseif t == "axe" then
						axex = x
						axey = y
					
					elseif t == "lakitoend" then
						lakitoendx = x
						
					elseif t == "angrysunend" then
						angrysunendx = x
						
					elseif t == "spring" then
						table.insert(objects["spring"], spring:new(x, y))
					
					elseif t == "springgreen" then
						table.insert(objects["springgreen"], springgreen:new(x, y))
						
					elseif t == "seesaw" then
						table.insert(seesaws, seesaw:new(x, y, r[3]))
						
					elseif t == "checkpoint" then
						if not tablecontains(checkpoints, x) then
							table.insert(checkpoints, x)
							checkpointpoints[x] = y
						end
					elseif t == "mazestart" then
						if not tablecontains(mazestarts, x) then
							table.insert(mazestarts, x)
						end
						
					elseif t == "mazeend" then
						if not tablecontains(mazeends, x) then
							table.insert(mazeends, x)
						end
						
					elseif t == "geltop" then
						if tilequads[map[x][y][1]].collision then
							map[x][y]["gels"]["top"] = r[3]
						end
					elseif t == "gelleft" then
						if tilequads[map[x][y][1]].collision then
							map[x][y]["gels"]["left"] = r[3]
						end
					elseif t == "gelbottom" then
						if tilequads[map[x][y][1]].collision then
							map[x][y]["gels"]["bottom"] = r[3]
						end
					elseif t == "gelright" then
						if tilequads[map[x][y][1]].collision then
							map[x][y]["gels"]["right"] = r[3]
						end
					end
				end
			end
		end
	end
	
	--sort checkpoints
	table.sort(checkpoints)
	
	--Add links
	for i, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.link then
				w:link()
			end
		end
	end
	
	if flagx then
		flagimgx = flagx+8/16
		flagimgy = 3+1/16
	end
	
	for x = 0, -30, -1 do
		map[x] = {}
		for y = 1, 13 do
			map[x][y] = {1}
		end
	
		for y = 14, mapheight do
			map[x][y] = {2}
			objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1, 1, 1, true)
		end
	end
	
	--MORE STUFF
	for i = 2, #s2 do
		s3 = s2[i]:split("=")
		if s3[1] == "background" then
			if tonumber(s3[2]) ~= nil then
				background = tonumber(s3[2])
				backgroundrgbon = false
			else
				local s4 = s3[2]:split(",")
				background = 4
				backgroundrgbon = true
				backgroundrgb = {tonumber(s4[1]), tonumber(s4[2]), tonumber(s4[3])}
				backgroundcolor[4] = backgroundrgb
			end
		elseif s3[1] == "spriteset" then
			spriteset = tonumber(s3[2])
		elseif s3[1] == "intermission" then
			intermission = true
		elseif s3[1] == "haswarpzone" then
			haswarpzone = true
		elseif s3[1] == "underwater" then
			underwater = true
		elseif s3[1] == "music" then
			musici = tonumber(s3[2])
		elseif s3[1] == "bonusstage" then
			bonusstage = true
		elseif s3[1] == "custombackground" or s3[1] == "portalbackground" then
			custombackground = true
		elseif s3[1] == "timelimit" then
			mariotimelimit = tonumber(s3[2])
		elseif s3[1] == "scrollfactor" then
			scrollfactor = tonumber(s3[2])
		elseif s3[1] == "autoscrolling" then
			autoscrolling = true
		elseif s3[1] == "customforeground" then
			customforeground = true
		elseif s3[1] == "noportalgun" then
			portalgun = false
		elseif s3[1] == "custommusic" then
			if tonumber(s3[2]) ~= nil then
				custommusici = tonumber(s3[2])
			end
		end
	end
	
	if custombackground then
		loadcustombackground()
	end
	if customforeground then
		loadcustomforeground()
	end
	
	if love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/worldlevels.txt") then
		local s = love.filesystem.read(mappackfolder .. "/" .. mappack .. "/worldlevels.txt")
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
			if s3[1] == tostring(marioworld) then
				maxlevels = tonumber(s2[2])
			end
		end
	end
	
	return true
end

function changemapwidth(width)
	if width > mapwidth then
		for x = mapwidth+1, width do
			map[x] = {}
			for y = 1, 13 do
				map[x][y] = {1}
				map[x][y]["gels"] = {}
			end
		
			for y = 14, mapheight do
				map[x][y] = {2}
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1, 1, 1, true)
				map[x][y]["gels"] = {}
			end
		end
	end

	mapwidth = width
	objects["screenboundary"]["right"].x = mapwidth
	
	if objects["player"][1].x > mapwidth then
		objects["player"][1].x = mapwidth-1
	end
end

function changemapheight(height)
	print(height)
	if height > mapheight then
		for x = 1, mapwidth do
			for y = mapheight+1, height do
				map[x][y] = {1}
				map[x][y]["gels"] = {}
			end
		end
	end
	mapheight = height
	if objects["player"][1].y > mapheight then
		objects["player"][1].y = mapheight-1
	end
end

function generatespritebatch()
	for split = 1, #splitscreen do
		local smbmsb = smbspritebatch[split]
		local portalmsb = portalspritebatch[split]
		local custommsb
		if customtiles then
			custommsb = customspritebatch[split]
		end
		smbmsb:clear()
		portalmsb:clear()
		if customtiles then
			custommsb:clear()
		end
		
		local xtodraw
		if mapwidth < width+1 then
			xtodraw = math.ceil(mapwidth/#splitscreen)
		else
			if mapwidth > width and splitxscroll[split] < mapwidth-width then
				xtodraw = width+1
			else
				xtodraw = width
			end
		end
		
		local ytodraw
		if mapheight > height-1 and splityscroll[split] < mapheight-height-1 then
			ytodraw = height+2
		else
			ytodraw = height+1
		end
		
		
		local lmap = map
		
		for y = 1, ytodraw do
			for x = 1, xtodraw do			
				local bounceyoffset = 0
				
				local draw = true
				for i, v in pairs(blockbouncex) do
					if blockbouncex[i] == math.floor(splitxscroll[split])+x and blockbouncey[i] == math.floor(splityscroll[split])+y then
						draw = false
					end	
				end
				if draw == true then
					local t = lmap[math.floor(splitxscroll[split])+x][math.floor(splityscroll[split])+y]
					
					local tilenumber = t[1]
					if tilenumber ~= 0 and tilequads[tilenumber].invisible == false and tilequads[tilenumber].coinblock == false and tilequads[tilenumber].coin == false then
						if tilenumber <= smbtilecount then
							smbmsb:add( tilequads[tilenumber].quad, (x-1)*16*scale, ((y-1)*16-8)*scale, 0, scale, scale )
						elseif tilenumber <= smbtilecount+portaltilecount then
							portalmsb:add( tilequads[tilenumber].quad, (x-1)*16*scale, ((y-1)*16-8)*scale, 0, scale, scale )
						elseif tilenumber <= smbtilecount+portaltilecount+customtilecount then
							custommsb:add( tilequads[tilenumber].quad, (x-1)*16*scale, ((y-1)*16-8)*scale, 0, scale, scale )
						end
					end
				end
			end
		end
	end
end

function game_keypressed(key, unicode)
	if pausemenuopen then
		if menuprompt then
			if (key == "left" or key == "a") then
				pausemenuselected2 = 1
			elseif (key == "right" or key == "d") then
				pausemenuselected2 = 2
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
				if pausemenuselected2 == 1 then
					if onlinemp then
						network_quit()
					end
					love.audio.stop()
					pausemenuopen = false
					menuprompt = false
					menu_load()
				else
					menuprompt = false
				end
			elseif key == "escape" then
				menuprompt = false
			end
			return
		elseif desktopprompt then
			if (key == "left" or key == "a") then
				pausemenuselected2 = 1
			elseif (key == "right" or key == "d") then
				pausemenuselected2 = 2
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
				if pausemenuselected2 == 1 then
					love.audio.stop()
					love.event.quit()
				else
					desktopprompt = false
				end
			elseif key == "escape" then
				desktopprompt = false
			end
			return
		elseif suspendprompt then
			if (key == "left" or key == "a") then
				pausemenuselected2 = 1
			elseif (key == "right" or key == "d") then
				pausemenuselected2 = 2
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
				if pausemenuselected2 == 1 then
					if not onlinemp then
						love.audio.stop()
						suspendgame()
						suspendprompt = false
						pausemenuopen = false
					else
						if clientisnetworkhost then
							endgame()
						else
							pausemenuopen = false
							suspendprompt = false
							pausemenuselected = 1
							pausemenuselected2 = 1
							network_quit()
							menu_load()
							onlinemenu_load()
						end
					end
				else
					suspendprompt = false
				end
			elseif key == "escape" then
				suspendprompt = false
			end
			return
		end
		if (key == "down" or key == "s") then
			if pausemenuselected < #pausemenuoptions then
				pausemenuselected = pausemenuselected + 1
			end
		elseif (key == "up" or key == "w") then
			if pausemenuselected > 1 then
				pausemenuselected = pausemenuselected - 1
			end
		elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
			if pausemenuoptions[pausemenuselected] == "resume" then
				pausemenuopen = false
				love.audio.resume()
			elseif pausemenuoptions[pausemenuselected] == "suspend" or pausemenuoptions[pausemenuselected] == "return to" then
				suspendprompt = true
				pausemenuselected2 = 1
			elseif pausemenuoptions2[pausemenuselected] == "menu" then
				menuprompt = true
				pausemenuselected2 = 1
			elseif pausemenuoptions2[pausemenuselected] == "desktop" then
				desktopprompt = true
				pausemenuselected2 = 1
			end
		elseif key == "escape" then
			pausemenuopen = false
			love.audio.resume()
		elseif (key == "right" or key == "d") then
			if pausemenuoptions[pausemenuselected] == "volume" then
				if volume < 1 then
					volume = volume + 0.1
					love.audio.setVolume( volume )
					soundenabled = true
					playsound(coinsound)
				end
			end
			
		elseif (key == "left" or key == "a") then
			if pausemenuoptions[pausemenuselected] == "volume" then
				volume = math.max(volume - 0.1, 0)
				love.audio.setVolume( volume )
				if volume == 0 then
					soundenabled = false
				end
				playsound(coinsound)
			end
		end
			
		return
	end

	if typinginchat then
		if key == ";" then
			return
		end
		if key == "escape" then
			typinginchat = false
			objects["player"][1].controlsenabled = true
			return
		elseif (key == "return" or key == "enter" or key == "kpenter") then
			typinginchat = false
			objects["player"][1].controlsenabled = true

			chatmessageinprogressstring = string.sub(chatmessageinprogressstring, 2)
			if string.len(chatmessageinprogressstring) > 1 then
				local newstring = lobby_playerlist[1].nick .. ":" .. chatmessageinprogressstring

				network_sendchat(newstring)
				chatmessagegradient = 180
			end
			chatmessageinprogressstring = "> "

		elseif key == "backspace" then
			if string.len(chatmessageinprogressstring) > 2 then
				chatmessageinprogressstring = string.sub(chatmessageinprogressstring, 1, string.len(chatmessageinprogressstring)-1)
			end
		else
			if string.len(chatmessageinprogressstring) < 50 then
				if (unicode > 32 and unicode < 127) or key == " " then
					local keyvalue = key
					if love.keyboard.isDown("capslock") or love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
						keyvalue = string.upper(keyvalue)
						if keyvalue == string.upper(keyvalue) then
							local pass = false
							if type(tonumber(keyvalue)) ~= "number" then
								pass = true
							elseif type(tonumber(keyvalue)) == "number" then
								if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
									pass = true
								end
							end
							if pass then
								for i, v in pairs(keyshiftvalueschat) do
									if v.value == keyvalue then
										keyvalue = v.change
										break
									end
								end
							end
						end
					end
					chatmessageinprogressstring = chatmessageinprogressstring .. keyvalue
				end
			end
		end
	end

	if disconnectprompt then
		if (key == "left" or key == "a") then
			pausemenuselected2 = 1
		elseif (key == "right" or key == "d") then
			pausemenuselected2 = 2
		elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
			if pausemenuselected2 == 1 then
				disconnectprompt = false
				network_quit()
			else
				disconnectprompt = false
			end
		elseif key == "escape" then
			disconnectprompt = false
		end
		return
	end

	local finalvalue = players
	if onlinemp then
		finalvalue = 1
	end
	for i = 1, finalvalue do
		if controls[i]["jump"][1] == key then
			objects["player"][i]:jump()
			if onlinemp then
				if i == 1 then
					table.insert(networksendqueue, "jump;" .. networkclientnumber)
				end
			end
		elseif controls[i]["run"][1] == key then
			objects["player"][i]:fire()
		elseif controls[i]["reload"][1] == key then
			objects["player"][i]:removeportals()
		elseif controls[i]["use"][1] == key then
			objects["player"][i]:use()
		elseif controls[i]["left"][1] == key then
			objects["player"][i]:leftkey()
		elseif controls[i]["right"][1] == key then
			objects["player"][i]:rightkey()
		end
		
		if controls[i]["portal1"][i] == key then
			shootportal(i, 1, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
			return
		end
		
		if controls[i]["portal2"][i] == key then
			shootportal(i, 2, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
			return
		end
	end
	
	if key == "escape" then
		if not editormode and testlevel then
			marioworld = testlevelworld
			mariolevel = testlevellevel
			testlevel = false
			editormode = true
			if mariosublevel ~= 0 then
				startlevel(mariosublevel)
			else
				startlevel(marioworld .. "-" .. mariolevel)
			end
			return
		elseif not editormode and not everyonedead then
			pausemenuopen = true
			love.audio.pause()
			playsound(pausesound)
		end
	end

	if key == "t" and onlinemp then
		local player = objects["player"][1]
		if player.controlsenabled or player.dead then
			player.controlsenabled = false
			player.speedx = 0
			typinginchat = true
		end

	end


	
	if editormode then
		editor_keypressed(key)
	end
end

function game_keyreleased(key, unicode)
	local finalvalue = players
	if (onlinemp) then
		finalvalue = 1
	end
	for i = 1, finalvalue do
		if controls[i]["jump"][1] == key then
			objects["player"][i]:stopjump()
		end
	end
end

function createportal(plnumber, i, cox, coy, side, tendency, x, y, newxrelay, newyrelay, relayed)
	if playersaresharingportals then
		plnumber = convertclienttoplayer(1)
	end
	local relayedportal = relayed
	if cox ~= false then
		local otheri = 1
		if i == 1 then
			otheri = 2
		end
		
		moveoutportal(i)
	
		--remove the portal temporarily so that it doesn't obstruct itself
		local oldx, oldy, oldfacing
		if i == 1 then
			oldx, oldy, oldfacing = objects["player"][plnumber].portal1X, objects["player"][plnumber].portal1Y, objects["player"][plnumber].portal1facing
			objects["player"][plnumber].portal1X, objects["player"][plnumber].portal1Y = false, false
		else
			oldx, oldy, oldfacing = objects["player"][plnumber].portal2X, objects["player"][plnumber].portal2Y, objects["player"][plnumber].portal2facing
			objects["player"][plnumber].portal2X, objects["player"][plnumber].portal2Y = false, false
		end
		local newx, newy = newxrelay, newyrelay
		if not relayed then
			newx, newy = getportalposition(i, cox, coy, side, tendency)
		end
		if newx and (newx ~= oldx or newy ~= oldy or side ~= oldfacing) then
			if i == 1 then
				objects["player"][plnumber].portal1X = newx
				objects["player"][plnumber].portal1Y = newy
				objects["player"][plnumber].portal1facing = side
			else
				objects["player"][plnumber].portal2X = newx
				objects["player"][plnumber].portal2Y = newy
				objects["player"][plnumber].portal2facing = side
			end
	
			--physics
			--Recreate old hole
			if oldfacing == "up" then	
				modifyportaltiles(oldx, oldy, 1, 0, plnumber, i, "add")
			elseif oldfacing == "down" then	
				modifyportaltiles(oldx, oldy, -1, 0, plnumber, i, "add")
			elseif oldfacing == "left" then	
				modifyportaltiles(oldx, oldy, 0, -1, plnumber, i, "add")
			elseif oldfacing == "right" then	
				modifyportaltiles(oldx, oldy, 0, 1, plnumber, i, "add")
			end
			
			--Create and remove new stuff
			if side == "up" then
				objects["portalwall"][plnumber .. "-" .. i .. "-1"] = portalwall:new(newx-1, newy, 2, 0, true)
				objects["portalwall"][plnumber .. "-" .. i .. "-2"] = portalwall:new(newx-1, newy-1, 0, 1, true)
				objects["portalwall"][plnumber .. "-" .. i .. "-3"] = portalwall:new(newx+1, newy-1, 0, 1, true)
				
				modifyportaltiles(newx, newy, 1, 0, plnumber, i, "remove")
			elseif side == "down" then
				objects["portalwall"][plnumber .. "-" .. i .. "-1"] = portalwall:new(newx-2, newy-1, 2, 0, true)
				objects["portalwall"][plnumber .. "-" .. i .. "-2"] = portalwall:new(newx-2, newy-1, 0, 1, true)
				objects["portalwall"][plnumber .. "-" .. i .. "-3"] = portalwall:new(newx, newy-1, 0, 1, true)
				
				modifyportaltiles(newx, newy, -1, 0, plnumber, i, "remove")
			elseif side == "left" then
				objects["portalwall"][plnumber .. "-" .. i .. "-1"] = portalwall:new(newx, newy-2, 0, 2, true)
				objects["portalwall"][plnumber .. "-" .. i .. "-2"] = portalwall:new(newx-1, newy-2, 1, 0, true)
				objects["portalwall"][plnumber .. "-" .. i .. "-3"] = portalwall:new(newx-1, newy, 1, 0, true)
				
				modifyportaltiles(newx, newy, 0, -1, plnumber, i, "remove")
			elseif side == "right" then
				objects["portalwall"][plnumber .. "-" .. i .. "-1"] = portalwall:new(newx-1, newy-1, 0, 2, true)
				objects["portalwall"][plnumber .. "-" .. i .. "-2"] = portalwall:new(newx-1, newy-1, 1, 0, true)
				objects["portalwall"][plnumber .. "-" .. i .. "-3"] = portalwall:new(newx-1, newy+1, 1, 0, true)
				
				modifyportaltiles(newx, newy, 0, 1, plnumber, i, "remove")
			end

			if onlinemp and not relayed then
				--Just transmit all the goddamn stuff
				table.insert(networksendqueue, "portal" .. ";" .. networkclientnumber .. ";" .. i .. ";" .. cox .. ";" .. coy .. ";" .. side .. ";" .. tendency .. ";" .. x .. ";" .. y .. ";" .. newx .. ";" .. newy)
			end
			
			if oldx == false then --Remove blocks from other portal
				local x, y, side
				if otheri == 1 then
					side = objects["player"][plnumber].portal1facing
					x, y = objects["player"][plnumber].portal1X, objects["player"][plnumber].portal1Y
				else
					side = objects["player"][plnumber].portal2facing
					x, y = objects["player"][plnumber].portal2X, objects["player"][plnumber].portal2Y
				end
					
				if side == "up" then
					modifyportaltiles(x, y, 1, 0, plnumber, otheri, "remove")
				elseif side == "down" then
					modifyportaltiles(x, y, -1, 0, plnumber, otheri, "remove")
				elseif side == "left" then
					modifyportaltiles(x, y, 0, -1, plnumber, otheri, "remove")
				elseif side == "right" then
					modifyportaltiles(x, y, 0, 1, plnumber, otheri, "remove")
				end
			end
			
			objects["player"][plnumber].lastportal = i
			
			if i == 1 then
				playsound(portal1opensound)
			else
				playsound(portal2opensound)
			end
			
			
			for i, v in pairs(objects["lightbridge"]) do
				v:updaterange()
			end
	
			for i, v in pairs(objects["laser"]) do
				v:updaterange()
			end
		
			for i, v in pairs(objects["funnel"]) do
				v:updaterange()
			end
		else
			--recreate the temporarily removed portal
			if i == 1 then
				objects["player"][plnumber].portal1X, objects["player"][plnumber].portal1Y = oldx, oldy
			else
				objects["player"][plnumber].portal2X, objects["player"][plnumber].portal2Y = oldx, oldy
			end				
		end
	end
end

function shootportal(plnumber, i, sourcex, sourcey, direction, relayed)
	if classicmodeactive then
		return
	end
	--box
	if objects["player"][plnumber].pickup then
		return
	end
	--portalgun delay
	if portaldelay[plnumber] > 0 then
		return
	else
		portaldelay[plnumber] = portalgundelay
	end
	
	local otheri = 1
	local color = objects["player"][plnumber].portal2color
	if i == 1 then
		otheri = 2
		color = objects["player"][plnumber].portal1color
	end

	if onlinemp and not relayed then
		table.insert(networksendqueue, "shoot;" .. networkclientnumber .. ";" .. i .. ";" .. sourcex .. ";" .. sourcey .. ";" .. direction)
	end
	
	local cox, coy, side, tendency, x, y = traceline(sourcex, sourcey, direction)
	table.insert(portalprojectiles, portalprojectile:new(sourcex, sourcey, x, y, color, true, {plnumber, i, cox, coy, side, tendency, x, y, nil, nil, relayed}))
end

function game_mousepressed(x, y, button)
	if pausemenuopen then
		return
	end
	if editormode and editorstate ~= "portalgun" then
		editor_mousepressed(x, y, button)
	else
		if editormode then
			editor_mousepressed(x, y, button)
		end
		
		if not noupdate and objects["player"][mouseowner] and (objects["player"][mouseowner].controlsenabled or singularmariogamemode) and objects["player"][mouseowner].vine == false then
		
			if button == "l" or (button == "r" or (button == "l" and love.keyboard.isDown("rctrl"))) and objects["player"][mouseowner] then
				--knockback
				if portalknockback then
					local xadd = math.sin(objects["player"][mouseowner].pointingangle)*30
					local yadd = math.cos(objects["player"][mouseowner].pointingangle)*30
					objects["player"][mouseowner].speedx = objects["player"][mouseowner].speedx + xadd
					objects["player"][mouseowner].speedy = objects["player"][mouseowner].speedy + yadd
					objects["player"][mouseowner].falling = true
					objects["player"][mouseowner].animationstate = "falling"
					objects["player"][mouseowner]:setquad()
				end
			end
		
			if button == "l" then
				if playertype == "portal" then
					local sourcex = objects["player"][mouseowner].x+6/16
					local sourcey = objects["player"][mouseowner].y+6/16
					local direction = objects["player"][mouseowner].pointingangle
					
					shootportal(mouseowner, 1, sourcex, sourcey, direction)
				elseif playertype == "minecraft" then
					local v = objects["player"][mouseowner]
					local sourcex, sourcey = v.x+6/16, v.y+6/16
					local cox, coy, side, tend, x, y = traceline(sourcex, sourcey, v.pointingangle)
					
					if cox then
						local dist = math.sqrt((v.x+v.width/2 - x)^2 + (v.y+v.height/2 - y)^2)
						if dist <= minecraftrange then
							breakingblockX = cox
							breakingblockY = coy
							breakingblockprogress = 0
						end
					end
				end
			end
				
			if button == "r" then
				if playertype == "portal" then
					local sourcex = objects["player"][mouseowner].x+6/16
					local sourcey = objects["player"][mouseowner].y+6/16
					local direction = objects["player"][mouseowner].pointingangle
					
					shootportal(mouseowner, 2, sourcex, sourcey, direction)
				elseif playertype == "minecraft" then
					local v = objects["player"][mouseowner]
					local sourcex, sourcey = v.x+6/16, v.y+6/16
					local cox, coy, side, tend, x, y = traceline(sourcex, sourcey, v.pointingangle)
					
					if cox then
						local dist = math.sqrt((v.x+v.width/2 - x)^2 + (v.y+v.height/2 - y)^2)
						if dist <= minecraftrange then
							placeblock(cox, coy, side)
						end
					end
				end
			end
		end
			
		if button == "wd" then
			if playertype == "minecraft" then
				mccurrentblock = mccurrentblock + 1
				if mccurrentblock >= 10 then
					mccurrentblock = 1
				end
			elseif bullettime then
				speedtarget = speedtarget - 0.1
				if speedtarget < 0.1 then
					speedtarget = 0.1
				end
			end
		elseif button == "wu" then
			if playertype == "minecraft" then
				mccurrentblock = mccurrentblock - 1
				if mccurrentblock <= 0 then
					mccurrentblock = 9
				end
			elseif bullettime then
				speedtarget = speedtarget + 0.1
				if speedtarget > 1 then
					speedtarget = 1
				end
			end
		end
	end
end

function modifyportalwalls()
	--Create and remove new stuff
	if side == "up" then
		if getTile(newx-1, newy, nil, true, side) == false then
			objects["portalwall"][plnumber .. "-" .. i .. "-1"] = portalwall:new(newx-1, newy-1, 0, 1, true)
		end
		if getTile(newx, newy+1, nil, true, side) == false then
			objects["portalwall"][plnumber .. "-" .. i .. "-2"] = portalwall:new(newx-1, newy, 1, 0, true)
		end
		if getTile(newx+1, newy+1, nil, true, side) == false then
			objects["portalwall"][plnumber .. "-" .. i .. "-3"] = portalwall:new(newx, newy, 1, 0, true)
		end
		if getTile(newx+2, newy, nil, true, side) == false then
			objects["portalwall"][plnumber .. "-" .. i .. "-4"] = portalwall:new(newx+1, newy-1, 0, 1, true)
		end
		
		modifyportaltiles(newx, newy, 1, 0, plnumber, i, "remove")
	elseif side == "down" then
		objects["portalwall"][plnumber .. "-" .. i .. "-1"] = portalwall:new(newx-2, newy-1, 2, 0, true)
		objects["portalwall"][plnumber .. "-" .. i .. "-2"] = portalwall:new(newx-2, newy-1, 0, 1, true)
		objects["portalwall"][plnumber .. "-" .. i .. "-3"] = portalwall:new(newx, newy-1, 0, 1, true)
		
		modifyportaltiles(newx, newy, -1, 0, plnumber, i, "remove")
	elseif side == "left" then
		objects["portalwall"][plnumber .. "-" .. i .. "-1"] = portalwall:new(newx, newy-2, 0, 2, true)
		objects["portalwall"][plnumber .. "-" .. i .. "-2"] = portalwall:new(newx-1, newy-2, 1, 0, true)
		objects["portalwall"][plnumber .. "-" .. i .. "-3"] = portalwall:new(newx-1, newy, 1, 0, true)
		
		modifyportaltiles(newx, newy, 0, -1, plnumber, i, "remove")
	elseif side == "right" then
		objects["portalwall"][plnumber .. "-" .. i .. "-1"] = portalwall:new(newx-1, newy-1, 0, 2, true)
		objects["portalwall"][plnumber .. "-" .. i .. "-2"] = portalwall:new(newx-1, newy-1, 1, 0, true)
		objects["portalwall"][plnumber .. "-" .. i .. "-3"] = portalwall:new(newx-1, newy+1, 1, 0, true)
		
		modifyportaltiles(newx, newy, 0, 1, plnumber, i, "remove")
	end
end

function modifyportaltiles(x, y, xplus, yplus, plnumber, i, mode)
	if i == 1 then
		if objects["player"][plnumber].portal2facing ~= nil then
			if mode == "add" then
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1, 1, 1, true)
				objects["tile"][x+xplus .. "-" .. y+yplus] = tile:new(x-1+xplus, y-1+yplus, 1, 1, true)
			else
				objects["tile"][x .. "-" .. y] = nil
				objects["tile"][x+xplus .. "-" .. y+yplus] = nil
			end
		end
	else
		if objects["player"][plnumber].portal1facing ~= nil then
			if mode == "add" then
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1, 1, 1, true)
				objects["tile"][x+xplus .. "-" .. y+yplus] = tile:new(x-1+xplus, y-1+yplus, 1, 1, true)
			else
				objects["tile"][x .. "-" .. y] = nil
				objects["tile"][x+xplus .. "-" .. y+yplus] = nil
			end
		end
	end
end

function getportalposition(i, x, y, side, tendency) --returns the "optimal" position according to the parsed arguments (or false if no possible position was found)
	local xplus, yplus = 0, 0
	if side == "up" then
		yplus = -1
	elseif side == "right" then
		xplus = 1
	elseif side == "down" then
		yplus = 1
	elseif side == "left" then
		xplus = -1
	end
	
	if side == "up" or side == "down" then
		if tendency == -1 then
			if getTile(x-1, y, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x-1, y+yplus, nil, false, side) == false and getTile(x, y+yplus, nil, false, side) == false then
				if side == "up" then
					return x-1, y
				else
					return x, y
				end
			elseif getTile(x, y, true, true, side) == true and getTile(x+1, y, true, true, side) == true and getTile(x, y+yplus, nil, false, side) == false and getTile(x+1, y+yplus, nil, false, side) == false then
				if side == "up" then
					return x, y
				else
					return x+1, y
				end
			end
		else
			if getTile(x, y, true, true, side) == true and getTile(x+1, y, true, true, side) == true and getTile(x, y+yplus, nil, false, side) == false and getTile(x+1, y+yplus, nil, false, side) == false then
				if side == "up" then
					return x, y
				else
					return x+1, y
				end
			elseif getTile(x-1, y, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x-1, y+yplus, nil, false, side) == false and getTile(x, y+yplus, nil, false, side) == false then
				if side == "up" then
					return x-1, y
				else
					return x, y
				end
			end
		end
	else
		if tendency == -1 then
			if getTile(x, y-1, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x+xplus, y-1, nil, false, side) == false and getTile(x+xplus, y, nil, false, side) == false then
				if side == "right" then
					return x, y-1
				else
					return x, y
				end
			elseif getTile(x, y, true, true, side) == true and getTile(x, y+1, true, true, side) == true and getTile(x+xplus, y, nil, false, side) == false and getTile(x+xplus, y+1, nil, false, side) == false then
				if side == "right" then
					return x, y
				else
					return x, y+1
				end
			end
		else
			if getTile(x, y, true, true, side) == true and getTile(x, y+1, true, true, side) == true and getTile(x+xplus, y, nil, false, side) == false and getTile(x+xplus, y+1, nil, false, side) == false then
				if side == "right" then
					return x, y
				else
					return x, y+1
				end
			elseif getTile(x, y-1, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x+xplus, y-1, nil, false, side) == false and getTile(x+xplus, y, nil, false, side) == false then
				if side == "right" then
					return x, y-1
				else
					return x, y
				end
			end
		end
	end
	
	return false
end

function getTile(x, y, portalable, portalcheck, facing) --returns masktable value of block (As well as the ID itself as second return parameter) also includes a portalcheck and returns false if a portal is on that spot.
	--Portal on same tile doesn't work so well yet (collision code, of course), so:
	--facing = nil
	
	if portalcheck then
		for i, v in pairs(objects["player"]) do
			--Get the extra block of each portal
			local portal1xplus, portal1yplus, portal2xplus, portal2yplus = 0, 0, 0, 0
			if v.portal1facing == "up" then
				portal1xplus = 1
			elseif v.portal1facing == "right" then
				portal1yplus = 1
			elseif v.portal1facing == "down" then
				portal1xplus = -1
			elseif v.portal1facing == "left" then
				portal1yplus = -1
			end
			
			if v.portal2facing == "up" then
				portal2xplus = 1
			elseif v.portal2facing == "right" then
				portal2yplus = 1
			elseif v.portal2facing == "down" then
				portal2xplus = -1
			elseif v.portal2facing == "left" then
				portal2yplus = -1
			end
			
			if v.portal1X ~= false then
				if (x == v.portal1X or x == v.portal1X+portal1xplus) and (y == v.portal1Y or y == v.portal1Y+portal1yplus) then--and (facing == nil or v.portal1facing == facing) then
					return false
				end
			end
		
			if v.portal2X ~= false then
				if (x == v.portal2X or x == v.portal2X+portal2xplus) and (y == v.portal2Y or y == v.portal2Y+portal2yplus) then--and (facing == nil or v.portal2facing == facing) then
					return false
				end
			end
		end
	end
	
	--check for tubes
	for i, v in pairs(objects["geldispenser"]) do
		if (x == v.cox or x == v.cox+1) and (y == v.coy or y == v.coy+1) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	for i, v in pairs(objects["cubedispenser"]) do
		if (x == v.cox or x == v.cox+1) and (y == v.coy or y == v.coy+1) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	for i, v in pairs(objects["flipblock"]) do
		if (x == v.cox or x == v.cox+1) and (y == v.coy or y == v.coy+1) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	for i, v in pairs(objects["pixeltile"]) do
		if (x == v.cox or x == v.cox+1) and (y == v.coy or y == v.coy+1) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	for i, v in pairs(objects["buttonblock"]) do
		if (x == v.cox or x == v.cox+1) and (y == v.coy or y == v.coy+1) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	--bonusstage thing for keeping it from fucking up.
	if bonusstage then
		if y == mapheight and (x == 4 or x == 6) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	if x <= 0 or y <= 0 or y >= mapheight+1 or x > mapwidth then
		return false, 1
	end
	
	if tilequads[map[x][y][1]].invisible then
		return false
	end
	
	if portalcheck then
		local side
		if facing == "up" then
			side = "top"
		elseif facing == "right" then
			side = "right"
		elseif facing == "down" then
			side = "bottom"
		elseif facing == "left" then
			side = "left"
		end
		
		--To stop people from portalling under the vine, which caused problems, but was fixed elsewhere (and betterer)
		--[[for i, v in pairs(objects["vine"]) do
			if x == v.cox and y == v.coy and side == "top" then
				return false, 1
			end
		end--]]
		
		
		if map[x][y]["gels"][side] == 3 then
			return true, map[x][y][1]
		else
			return tilequads[map[x][y][1]].collision and tilequads[map[x][y][1]].portalable, map[x][y][1]
		end
	else
		return tilequads[map[x][y][1]].collision, map[x][y][1]
	end
end

function getPortal(x, y) --returns the block where you'd come out when you'd go in the argument's block
	for i, v in pairs(objects["player"]) do
		if v.portal1X ~= false and v.portal2X ~= false then
			--Get the extra block of each portal
			local portal1xplus, portal1yplus, portal2xplus, portal2yplus = 0, 0, 0, 0
			if v.portal1facing == "up" then
				portal1xplus = 1
			elseif v.portal1facing == "right" then
				portal1yplus = 1
			elseif v.portal1facing == "down" then
				portal1xplus = -1
			elseif v.portal1facing == "left" then
				portal1yplus = -1
			end
			
			if v.portal2facing == "up" then
				portal2xplus = 1
			elseif v.portal2facing == "right" then
				portal2yplus = 1
			elseif v.portal2facing == "down" then
				portal2xplus = -1
			elseif v.portal2facing == "left" then
				portal2yplus = -1
			end
			
			if v.portal1X ~= false then
				if (x == v.portal1X or x == v.portal1X+portal1xplus) and (y == v.portal1Y or y == v.portal1Y+portal1yplus) and (facing == nil or v.portal1facing == facing) then
					if v.portal1facing ~= v.portal2facing then
						local xplus, yplus = 0, 0
						if v.portal1facing == "left" or v.portal1facing == "right" then
							if y == v.portal1Y then
								if v.portal2facing == "left" or v.portal2facing == "right" then
									yplus = portal2yplus
								else
									xplus = portal2xplus
								end
							end
							
							return v.portal2X+xplus, v.portal2Y+yplus, v.portal2facing, v.portal1facing
						else
							if x == v.portal1X then
								if v.portal2facing == "left" or v.portal2facing == "right" then
									yplus = portal2yplus
								else
									xplus = portal2xplus
								end
							end
							
							return v.portal2X+xplus, v.portal2Y+yplus, v.portal2facing, v.portal1facing
						end	
					else
						return v.portal2X+(x-v.portal1X), v.portal2Y+(y-v.portal1Y), v.portal2facing, v.portal1facing
					end
				end
			end
		
			if v.portal2X ~= false then
				if (x == v.portal2X or x == v.portal2X+portal2xplus) and (y == v.portal2Y or y == v.portal2Y+portal2yplus) and (facing == nil or v.portal2facing == facing) then
					if v.portal1facing ~= v.portal2facing then
						local xplus, yplus = 0, 0
						if v.portal2facing == "left" or v.portal2facing == "right" then
							if y == v.portal2Y then
								if v.portal1facing == "left" or v.portal1facing == "right" then
									yplus = portal1yplus
								else
									xplus = portal1xplus
								end
							end
							
							return v.portal1X+xplus, v.portal1Y+yplus, v.portal1facing, v.portal2facing
						else
							if x == v.portal2X then
								if v.portal1facing == "left" or v.portal1facing == "right" then
									yplus = portal1yplus
								else
									xplus = portal1xplus
								end
							end
							
							return v.portal1X+xplus, v.portal1Y+yplus, v.portal1facing, v.portal2facing
						end	
					else
						return v.portal1X+(x-v.portal2X), v.portal1Y+(y-v.portal2Y), v.portal1facing, v.portal2facing
					end
				end
			end
		end
	end
	
	return false
end

function insideportal(x, y, width, height) --returns whether an object is in, and which, portal.
	if width == nil then
		width = 12/16
	end
	if height == nil then
		height = 12/16
	end
	for i, v in pairs(objects["player"]) do
		if v.portal1X ~= false and v.portal2X ~= false then
			for j = 1, 2 do				
				local portalx, portaly, portalfacing
				if j == 1 then
					portalx = v.portal1X
					portaly = v.portal1Y
					portalfacing = v.portal1facing
				else
					portalx = v.portal2X
					portaly = v.portal2Y
					portalfacing = v.portal2facing
				end
				
				if portalfacing == "up" then
					xplus = 1
				elseif portalfacing == "down" then
					xplus = -1
				elseif portalfacing == "left" then
					yplus = -1
				end
				
				if portalfacing == "right" then
					if (math.floor(y) == portaly or math.floor(y) == portaly-1) and inrange(x, portalx-width, portalx, false) then
						return i, j
					end
				elseif portalfacing == "left" then
					if (math.floor(y) == portaly-1 or math.floor(y) == portaly-2) and inrange(x, portalx-1-width, portalx-1, false) then
						return i, j
					end
				elseif portalfacing == "up" then
					if inrange(y, portaly-height-1, portaly-1, false) and inrange(x, portalx-1.5-.2, portalx+.5+.2, true) then
						return i, j
					end	
				elseif portalfacing == "down" then
					if inrange(y, portaly-height, portaly, false) and inrange(x, portalx-2, portalx-.5, true) then
						return i, j
					end	
				end
				
				--widen rect by 3 pixels?
				
			end
		end
	end
	
	return false
end

function moveoutportal(p0) --pushes objects out of the portal i in.
	for i, v in pairs(objects) do
		if i ~= "tile" and i ~= "portalwall" then
			for j, w in pairs(v) do
				if w.active and w.static == false then
					local p1, p2 = insideportal(w.x, w.y, w.width, w.height)
					
					if p1 ~= false and p2 == p0 then
						local portalfacing, portalx, portaly
						if p2 == 1 then
							portalfacing = objects["player"][p1].portal1facing
							portalx = objects["player"][p1].portal1X
							portaly = objects["player"][p1].portal1Y
						else
							portalfacing = objects["player"][p1].portal2facing
							portalx = objects["player"][p1].portal2X
							portaly = objects["player"][p1].portal2Y
						end
						
						if portalfacing == "right" then
							w.x = portalx
						elseif portalfacing == "left" then
							w.x = portalx - 1 - w.width
						elseif portalfacing == "up" then
							w.y = portaly - 1 - w.height
						elseif portalfacing == "down" then
							w.y = portaly
						end
					end
				end
			end
		end
	end
end

function nextlevel()
   love.audio.stop()
   if levelfinishtype == "flag" then
      mariolevel = mariolevel + 1
   else
      mariolevel = 1
      marioworld = marioworld + 1
   end
   
   levelscreen_load("next")

	if onlinemp then
		for i, v in pairs(objects["player"]) do
			v.x = 1.5
			v.y = 13
		end
	end
end

function warpzone(i)
	love.audio.stop()
	mariolevel = 1
	marioworld = i
	mariosublevel = 0
	prevsublevel = false
	
	-- minus 1 world glitch just because I can.
	if not displaywarpzonetext and i == 4 and haswarpzone then
		marioworld = "M"
	end
	
	levelscreen_load("next")
end

function game_mousereleased(x, y, button)
	if button == "l" then
		if playertype == "minecraft" then
			breakingblockX = false
		end
	end
	
	if editormode then
		editor_mousereleased(x, y, button)
	end
end

function getMouseTile(x, y)
	local xout = math.floor((x+xscroll*16*scale)/(16*scale))+1
	local yout = math.floor((y+yscroll*16*scale)/(16*scale))+1
	return xout, yout
end

function savemap(filename)
	local s = ""
	for y = 1, mapheight do
		for x = 1, mapwidth do
			if y ~= mapheight or x ~= mapwidth then
				for i = 1, #map[x][y] do
					s = s .. tostring(map[x][y][i])
					if i ~= #map[x][y] then
						s = s .. "-"
					end
				end
				s = s .. ","
			else
				for i = 1, #map[x][y] do
					s = s .. tostring(map[x][y][i])
					if i ~= #map[x][y] then
						s = s .. "-"
					end
				end
			end
		end
	end
	
	--options
	if background == 4 then
		s = s .. ";background=" .. backgroundrgb[1] .. "," .. backgroundrgb[2] .. "," .. backgroundrgb[3]
	else
		s = s .. ";background=" .. background
	end
	s = s .. ";spriteset=" .. spriteset
	s = s .. ";music=" .. musici
	if intermission then
		s = s .. ";intermission"
	end
	if bonusstage then
		s = s .. ";bonusstage"
	end
	if haswarpzone then
		s = s .. ";haswarpzone"
	end
	if underwater then
		s = s .. ";underwater"
	end
	if custombackground then
		s = s .. ";custombackground"
	end
	if autoscrolling then
		s = s .. ";autoscrolling"
	end
	if customforeground then
		s = s .. ";customforeground"
	end
	if not portalgun then
		s = s .. ";noportalgun"
	end
	if musici == 7 then
		if guielements["custommusiciinput"] then
			s = s .. ";custommusic=" .. guielements["custommusiciinput"].value
		else
			s = s .. ";custommusic=1"
		end
	end
	s = s .. ";timelimit=" .. mariotimelimit
	s = s .. ";scrollfactor=" .. scrollfactor
	
	--tileset
	
	love.filesystem.createDirectory( mappackfolder )
	love.filesystem.createDirectory( mappackfolder .. "/" .. mappack )
	love.filesystem.createDirectory( mappackfolder .. "/" .. mappack .. "/heights")
	
	love.filesystem.write(mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt", s)
	love.filesystem.write(mappackfolder .. "/" .. mappack .. "/heights/" .. marioworld .. "-" .. mariolevel .. "_" .. mariosublevel .. ".txt", mapheight)
	print("Map saved as " .. mappackfolder .. "/" .. filename .. ".txt")
end

function savelevel()
	if mariosublevel == 0 then
		savemap(marioworld .. "-" .. mariolevel)
	else
		savemap(marioworld .. "-" .. mariolevel .. "_" .. mariosublevel)
	end
end

function traceline(sourcex, sourcey, radians)
	local currentblock = {}
	local x, y = sourcex, sourcey
	currentblock[1] = math.floor(x)
	currentblock[2] = math.floor(y+1)
		
	local emancecollide = false
	for i, v in pairs(emancipationgrills) do
		if v:getTileInvolved(currentblock[1]+1, currentblock[2]) then
			emancecollide = true
		end
	end
	
	local doorcollide = false
	for i, v in pairs(objects["door"]) do
		if v.dir == "hor" then
			if v.open == false and (v.cox == currentblock[1] or v.cox == currentblock[1]+1) and v.coy == currentblock[2] then
				doorcollide = true
			end
		else
			if v.open == false and v.cox == currentblock[1]+1 and (v.coy == currentblock[2] or v.coy == currentblock[2]+1) then
				doorcollide = true
			end
		end
	end
	
	local flipblockcollide = false
	for i, v in pairs(objects["flipblock"]) do
		if (v.x == currentblock[1]) and v.y == currentblock[2]-1 and v.flip == false then
			flipblockcollide = true
		end
	end
	
	local pixeltilecollide = false
	for i, v in pairs(objects["pixeltile"]) do
		if (v.x == currentblock[1]) and v.y == currentblock[2]-1 then
			pixeltilecollide = true
		end
	end
	
	local buttonblockcollide = false
	for i, v in pairs(objects["buttonblock"]) do
		if (v.x == currentblock[1]) and v.y == currentblock[2]-1 and v.width == 16/16 then
			buttonblockcollide = true
		end
	end
	
	if emancecollide or doorcollide or flipblockcollide or buttonblockcollide or pixeltilecollide then
		return false, false, false, false, x, y
	end
	
	local side
	
	while currentblock[1]+1 > 0 and currentblock[1]+1 <= mapwidth and (flagx == false or currentblock[1]+1 <= flagx) and (axex == false or currentblock[1]+1 <= axex) and (currentblock[2] > 0 or currentblock[2] >= math.floor(sourcey+0.5)) and currentblock[2] < mapheight+1 do --while in map range
		local oldy = y
		local oldx = x
		
		--calculate X and Y diff..
		local ydiff, xdiff
		local side1, side2
		
		if inrange(radians, -math.pi/2, math.pi/2, true) then --up
			ydiff = (y-(currentblock[2]-1)) / math.cos(radians)
			y = currentblock[2]-1
			side1 = "down"
		else
			ydiff = (y-(currentblock[2])) / math.cos(radians)
			y = currentblock[2]
			side1 = "up"
		end
		
		if inrange(radians, 0, math.pi, true) then --left
			xdiff = (x-(currentblock[1])) / math.sin(radians)
			x = currentblock[1]
			side2 = "right"
		else
			xdiff = (x-(currentblock[1]+1)) / math.sin(radians)
			x = currentblock[1]+1
			side2 = "left"
		end
		
		--smaller diff wins
		
		if xdiff < ydiff then
			y = oldy - math.cos(radians)*xdiff
			side = side2
		else
			x = oldx - math.sin(radians)*ydiff
			side = side1
		end
		
		if side == "down" then
			currentblock[2] = currentblock[2]-1
		elseif side == "up" then
			currentblock[2] = currentblock[2]+1
		elseif side == "left" then
			currentblock[1] = currentblock[1]+1
		elseif side == "right" then
			currentblock[1] = currentblock[1]-1
		end
		
		local collide, tileno = getTile(currentblock[1]+1, currentblock[2])
		local emancecollide = false
		for i, v in pairs(emancipationgrills) do
			if v:getTileInvolved(currentblock[1]+1, currentblock[2]) then
				emancecollide = true
			end
		end
		
		local doorcollide = false
		for i, v in pairs(objects["door"]) do
			if v.dir == "hor" then
				if v.open == false and (v.cox == currentblock[1] or v.cox == currentblock[1]+1) and v.coy == currentblock[2] then
					doorcollide = true
				end
			else
				if v.open == false and v.cox == currentblock[1]+1 and (v.coy == currentblock[2] or v.coy == currentblock[2]+1) then
					doorcollide = true
				end
			end
		end
		
		local flipblockcollide = false
		for i, v in pairs(objects["flipblock"]) do
			if (v.x == currentblock[1]) and v.y == currentblock[2]-1 and v.flip == false then
				flipblockcollide = true
			end
		end
		
		local pixeltilecollide = false
		for i, v in pairs(objects["flipblock"]) do
			if (v.x == currentblock[1]) and v.y == currentblock[2]-1 then
				pixeltilecollide = true
			end
		end
		
		local buttonblockcollide = false
		for i, v in pairs(objects["buttonblock"]) do
			if (v.x == currentblock[1]) and v.y == currentblock[2]-1 and v.width == 16/16 then
				buttonblockcollide = true
			end
		end
		
		if collide == true then
			break
		elseif emancecollide or doorcollide or flipblockcollide or buttonblockcollide or pixeltilecollide then
			return false, false, false, false, x, y
		elseif x > xscroll + width or x < xscroll then
			return false, false, false, false, x, y
		end
	end
	
	if currentblock[1]+1 > 0 and currentblock[1]+1 <= mapwidth and (currentblock[2] > 0 or currentblock[2] >= math.floor(sourcey+0.5))  and currentblock[2] < mapheight+1 and currentblock[1] ~= nil then
		local tendency
	
		--get tendency
		if side == "down" or side == "up" then
			if math.mod(x, 1) > 0.5 then
				tendency = 1
			else
				tendency = -1
			end
		elseif side == "left" or side == "right" then
			if math.mod(y, 1) > 0.5 then
				tendency = 1
			else
				tendency = -1
			end
		end
		
		return currentblock[1]+1, currentblock[2], side, tendency, x, y
	else
		return false, false, false, false, x, y
	end
end

function spawnenemy(x, y, relayed)
	if not inmap(x, y) then
		return
	end
	if not enemiesspawned then 
		enemiesspawned = {}
		return
	end 
	for i = 1, #enemiesspawned do
		if x == enemiesspawned[i][1] and y == enemiesspawned[i][2] then
			return
		end
	end
	
	local t = map[x][y]
	if #t > 1 then
		local enemy = true
		local i = entityquads[t[2]].t
		if i == "goomba" then
			table.insert(objects["goomba"], goomba:new(x-0.5, y-1/16))
		elseif i == "goombahalf" then
			table.insert(objects["goomba"], goomba:new(x, y-1/16))
		elseif i == "koopa" then
			table.insert(objects["koopa"], koopa:new(x-0.5, y-1/16))
		elseif i == "koopahalf" then
			table.insert(objects["koopa"], koopa:new(x, y-1/16))
		elseif i == "koopared" then
			table.insert(objects["koopa"], koopa:new(x-0.5, y-1/16, "red"))
		elseif i == "kooparedhalf" then
			table.insert(objects["koopa"], koopa:new(x, y-1/16, "red"))
		elseif i == "beetle" then
			table.insert(objects["koopa"], koopa:new(x-0.5, y-1/16, "beetle"))
		elseif i == "beetlehalf" then
			table.insert(objects["koopa"], koopa:new(x, y-1/16, "beetle"))
		elseif i == "kooparedflying" then
			table.insert(objects["koopa"], koopa:new(x-.5, y-1/16, "redflying"))
		elseif i == "koopaflying" then
			table.insert(objects["koopa"], koopa:new(x-.5, y-1/16, "flying"))
		elseif i == "bowser" then
			objects["bowser"][1] = bowser:new(x, y-1/16)
		elseif i == "cheepred" then
			table.insert(objects["cheep"], cheepcheep:new(x-.5, y-1/16, 1))
		elseif i == "cheepwhite" then
			table.insert(objects["cheep"], cheepcheep:new(x-.5, y-1/16, 2))
		elseif i == "spikey" then
			table.insert(objects["goomba"], goomba:new(x-0.5, y-1/16, "spikey"))
		elseif i == "spikeyhalf" then
			table.insert(objects["goomba"], goomba:new(x, y-1/16, "spikey"))
		elseif i == "lakito" then
			table.insert(objects["lakito"], lakito:new(x, y-1/16))
		elseif i == "squid" then
			table.insert(objects["squid"], squid:new(x, y-1/16))
		elseif i == "paragoomba" then
			table.insert(objects["goomba"], goomba:new(x-0.5, y-1/16, "paragoomba")) --Ya I added entities now get out -Alesan99
		elseif i == "sidestepper" then
			table.insert(objects["sidestepper"], sidestepper:new(x-0.5, y-1/16))
		elseif i == "barrel" then
			table.insert(objects["barrel"], barrel:new(x-0.5, y-1/16))
		elseif i == "icicle" then
			table.insert(objects["icicle"], icicle:new(x-0.5, y-1/16, "icicle", t[3]))
		elseif i == "angrysun" then
			table.insert(objects["angrysun"], angrysun:new(x, y-1/16))
		elseif i == "splunkin" then
			table.insert(objects["splunkin"], splunkin:new(x-0.5, y-1/16))
		elseif i == "splunkinhalf" then
			table.insert(objects["splunkin"], splunkin:new(x, y-1/16))
		elseif i == "biggoomba" then
			table.insert(objects["biggoomba"], biggoomba:new(x-0.5, y-1/16))
		elseif i == "bigspikey" then
			table.insert(objects["biggoomba"], biggoomba:new(x-0.5, y-1/16, "bigspikey"))
		elseif i == "bigkoopa" then
			table.insert(objects["bigkoopa"], bigkoopa:new(x-0.5, y-1/16))
		elseif i == "shell" then
			table.insert(objects["koopa"], koopa:new(x-0.5, y-1/16, "shell"))
		elseif i == "goombrat" then
			table.insert(objects["goomba"], goomba:new(x-0.5, y-1/16, "goombrat"))
		elseif i == "goombrathalf" then
			table.insert(objects["goomba"], goomba:new(x, y-1/16, "goombrat"))
		elseif i == "thwomp" then
			table.insert(objects["thwomp"], thwomp:new(x-0.5, y+5/16))
		elseif i == "fishbone" then
			table.insert(objects["fishbone"], fishbone:new(x-.5, y-1/16, 1))
		elseif i == "drybones" then
			table.insert(objects["drybones"], drybones:new(x-0.5, y-1/16))
		elseif i == "dryboneshalf" then
			table.insert(objects["drybones"], drybones:new(x, y-1/16))
		elseif i == "muncher" then
			table.insert(objects["muncher"], muncher:new(x-0.5, y-1/16))
		elseif i == "bigbeetle" then
			table.insert(objects["bigkoopa"], bigkoopa:new(x-0.5, y-1/16, "bigbeetle"))
		elseif i == "drygoomba" then
			table.insert(objects["goomba"], goomba:new(x-0.5, y-1/16, "drygoomba"))
		elseif i == "drygoombahalf" then
			table.insert(objects["goomba"], goomba:new(x, y-1/16, "drygoomba"))
		elseif i == "donut" then
			table.insert(objects["donut"], donut:new(x-0.5, y-1/16))
		elseif i == "parabeetle" then
			table.insert(objects["parabeetle"], parabeetle:new(x-0.5, y-1/16))
		elseif i == "ninji" then
			table.insert(objects["ninji"], ninji:new(x-0.5, y-1/16))
		elseif i == "boo" then
			table.insert(objects["boo"], boo:new(x-0.5, y-1/16))
		elseif i == "mole" then
			table.insert(objects["mole"], mole:new(x-0.5, y-1/16))
		elseif i == "bigmole" then
			table.insert(objects["bigmole"], bigmole:new(x-0.5, y-1/16))
		elseif i == "bomb" then
			table.insert(objects["bomb"], bomb:new(x-0.5, y-1/16))
		elseif i == "bombhalf" then
			table.insert(objects["bomb"], bomb:new(x, y-1/16))
		elseif i == "flipblock" then
			table.insert(objects["flipblock"], flipblock:new(x-0.5, y-1/16))
		elseif i == "parabeetleright" then
			table.insert(objects["parabeetle"], parabeetle:new(x-0.5, y-1/16, "parabeetleright"))
		elseif i == "boomboom" then
			table.insert(objects["boomboom"], boomboom:new(x-0.5, y-1/16))
		elseif i == "levelball" then
			table.insert(objects["levelball"], levelball:new(x-0.5, y-1/16))
		elseif i == "koopablue" then
			table.insert(objects["koopa"], koopa:new(x-0.5, y-1/16, "blue"))
		elseif i == "koopabluehalf" then
			table.insert(objects["koopa"], koopa:new(x, y-1/16, "blue"))
		elseif i == "koopaflying2" then
			table.insert(objects["koopa"], koopa:new(x-.5, y-1/16, "flying2"))
		elseif i == "pinksquid" then
			table.insert(objects["squid"], squid:new(x, y-1/16, "pink"))
		elseif i == "blocktogglebutton" then
			table.insert(objects["blocktogglebutton"], blocktogglebutton:new(x-0.5, y-1/16, t[3]))
		elseif i == "buttonblockon" then
			table.insert(objects["buttonblock"], buttonblock:new(x-0.5, y-1/16, t[3], 1))
		elseif i == "buttonblockoff" then
			table.insert(objects["buttonblock"], buttonblock:new(x-0.5, y-1/16, t[3], 0))
		elseif i == "sleepfish" then
			table.insert(objects["cheep"], cheepcheep:new(x-.5, y-1/16, 3))
		elseif i == "amp" then
			table.insert(objects["amp"], amp:new(x-0.5, y-1/16, t[3]))
		elseif i == "parabeetlegreen" then
			table.insert(objects["parabeetle"], parabeetle:new(x-0.5, y-1/16, "parabeetlegreen"))
		elseif i == "parabeetlegreenright" then
			table.insert(objects["parabeetle"], parabeetle:new(x-0.5, y-1/16, "parabeetlegreenright"))
		elseif i == "shyguy" then
			table.insert(objects["goomba"], goomba:new(x-0.5, y-1/16, "shyguy"))
		elseif i == "shyguyhalf" then
			table.insert(objects["goomba"], goomba:new(x, y-1/16, "shyguy"))
		elseif i == "bigblocktogglebutton" then
			table.insert(objects["blocktogglebutton"], blocktogglebutton:new(x-0.5, y-1/16, t[3], "big"))
		elseif i == "beetleshell" then
			table.insert(objects["koopa"], koopa:new(x-0.5, y-1/16, "beetleshell"))
			
		elseif i == "platformup" then
			table.insert(objects["platform"], platform:new(x, y, "up", t[3])) --Platform right
		elseif i == "platformright" then
			table.insert(objects["platform"], platform:new(x, y, "right", t[3])) --Platform up
			
		elseif i == "platformfall" then
			table.insert(objects["platform"], platform:new(x, y, "fall", t[3])) --Platform up
			
		elseif i == "platformbonus" then
			table.insert(objects["platform"], platform:new(x, y, "justright", 3))
			
		elseif i == "plant" then
			table.insert(objects["plant"], plant:new(x, y))
	
		elseif i == "castlefirecw" then
			table.insert(objects["castlefire"], castlefire:new(x, y, tonumber(t[3]), "cw"))
			
		elseif i == "castlefireccw" then
			table.insert(objects["castlefire"], castlefire:new(x, y, tonumber(t[3]), "ccw"))
			
		elseif i == "hammerbro" then
			table.insert(objects["hammerbro"], hammerbro:new(x, y))
			
		elseif i == "boomerangbro" then
			table.insert(objects["boomerangbro"], boomerangbro:new(x, y))
			
		elseif i == "firebro" then
			table.insert(objects["firebro"], firebro:new(x, y))
			
		elseif i == "downplant" then
			table.insert(objects["downplant"], downplant:new(x, y))
		
		elseif i == "redplant" then
			table.insert(objects["redplant"], redplant:new(x, y))

		elseif i == "reddownplant" then
			table.insert(objects["reddownplant"], reddownplant:new(x, y+16/16))
		
		elseif i == "dryplant" then
			table.insert(objects["dryplant"], dryplant:new(x, y))
			
		elseif i == "drydownplant" then
			table.insert(objects["drydownplant"], drydownplant:new(x, y+16/16))
			
		elseif i == "fireplant" then
			table.insert(objects["fireplant"], fireplant:new(x, y))
			
		elseif i == "downfireplant" then
			table.insert(objects["downfireplant"], downfireplant:new(x, y+16/16))
		
		elseif i == "torpedoted" then
			table.insert(objects["torpedolauncher"], torpedolauncher:new(x, y))
		
		elseif i == "coin" then
			table.insert(objects["coin"], coin:new(x, y))
		
		elseif i == "whitegeldown" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 3, "down"))
		elseif i == "whitegelright" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 3, "right"))
		elseif i == "whitegelleft" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 3, "left"))
		
		elseif i == "bulletbill" then
			table.insert(rocketlaunchers, rocketlauncher:new(x, y))
		
		elseif i == "bluegeldown" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 1, "down"))
		elseif i == "bluegelright" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 1, "right"))
		elseif i == "bluegelleft" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 1, "left"))
			
		elseif i == "orangegeldown" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 2, "down"))
		elseif i == "orangegelright" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 2, "right"))
		elseif i == "orangegelleft" then
			table.insert(objects["geldispenser"], geldispenser:new(x, y, 2, "left"))
		elseif i == "bigbill" then
			table.insert(bigbilllaunchers, bigbilllauncher:new(x, y))
		elseif i == "kingbill" then
			table.insert(kingbilllaunchers, kingbilllauncher:new(x, y, t[3]))
		elseif i == "cannonball" then
			table.insert(cannonballlaunchers, cannonballlauncher:new(x, y, t[3]))
			
		elseif i == "upfire" then
			table.insert(objects["upfire"], upfire:new(x, y))
		else

			enemy = false
		end
		
		if enemy then	
			table.insert(enemiesspawned, {x, y})
			
			--spawn enemies in 5x1 line so they spawn as a unit and not alone.
			spawnenemy(x-2, y, true)
			spawnenemy(x-1, y, true)
			spawnenemy(x+1, y, true)
			spawnenemy(x+2, y, true)
			if not relayed then
				table.insert(networksendqueue, "spawnenemy;" .. networkclientnumber .. ";" .. x .. ";" .. y)
			end
		end
	end
end

function item(i, x, y, size)
	if i == "mushroom" then
		if size and size > 1 then
			table.insert(objects["flower"], flower:new(x-0.5, y-2/16))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
			
	elseif i == "oneup" then
		table.insert(objects["oneup"], oneup:new(x-0.5, y-2/16))
	elseif i == "star" then
		table.insert(objects["star"], star:new(x-0.5, y-2/16))
	elseif i == "vine" then
		table.insert(objects["vine"], vine:new(x, y))
	elseif i == "poisonmush" then
		table.insert(objects["poisonmush"], poisonmush:new(x-0.5, y-2/16))
	elseif i == "threeup" then
		table.insert(objects["threeup"], threeup:new(x-0.5, y-2/16))
	elseif i == "plusclock" then
		table.insert(objects["plusclock"], plusclock:new(x-0.5, y-2/16))
	elseif i == "hammersuit" then
		if size and size > 1 then
			table.insert(objects["hammersuit"], hammersuit:new(x-0.5, y-2/16))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
	elseif i == "frogsuit" then
		if size and size > 1 then
			table.insert(objects["frogsuit"], frogsuit:new(x-0.5, y-2/16))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
	elseif i == "leaf" then
		if size and size > 1 then
			table.insert(objects["leaf"], leaf:new(x-0.5, y-2/16))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
	elseif i == "minimushroom" then
		table.insert(objects["minimushroom"], minimushroom:new(x-0.5, y-2/16))
	elseif i == "iceflower" then
		if size and size > 1 then
			table.insert(objects["flower"], flower:new(x-0.5, y-2/16, "ice"))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
	elseif i == "yoshi" then
		table.insert(objects["yoshiegg"], yoshiegg:new(x-0.5, y-2/16))
	end
end

function addpoints(i, x, y)
	if i > 0 then
		marioscore = marioscore + i
		if x ~= nil and y ~= nil then
			table.insert(scrollingscores, scrollingscore:new(i, x, y-yscroll))
		end
	else
		table.insert(scrollingscores, scrollingscore:new(-i, x, y-yscroll))
	end
end

function addzeros(s, i)
	for j = string.len(s)+1, i do
		s = "0" .. s
	end
	return s
end

function properprint2(s, x, y)
	for i = 1, string.len(tostring(s)) do
		if fontquads[string.sub(s, i, i)] then
			love.graphics.draw(fontimage2, font2quads[string.sub(s, i, i)], x+((i-1)*4)*scale, y, 0, scale, scale)
		end
	end
end

function playsound(sound)
	if soundenabled then
		sound:stop()
		sound:rewind()
		sound:play()
	end
end

function runkey(i)
	if i < 5 then
		local s = controls[i]["run"]
		return checkkey(s)
	end
end

function rightkey(i)
	if i < 5 then
		local s = controls[i]["right"]
		return checkkey(s)
	end
end

function leftkey(i)
	if i < 5 then
		local s = controls[i]["left"]
		return checkkey(s)
	end
end

function downkey(i)
	if i < 5 then
		local s = controls[i]["down"]
		return checkkey(s)
	end
end

function upkey(i)
	if i < 5 then
		local s = controls[i]["up"]
		return checkkey(s)
	end
end

function jumpkey(i)
	if i < 5 then
		local s = controls[i]["jump"]
		return checkkey(s)
	end
end

function checkkey(s)
	if s[1] == "joy" then
		if s[3] == "hat" then
			if love.joystick.getHat(s[2], s[4]) == s[5] then
				return true
			else
				return false
			end
		elseif s[3] == "but" then
			if love.joystick.isDown(s[2], s[4]) then
				return true
			else
				return false
			end
		elseif s[3] == "axe" then
			if s[5] == "pos" then
				if love.joystick.getAxis(s[2], s[4]) > joystickdeadzone then
					return true
				else
					return false
				end
			else
				if love.joystick.getAxis(s[2], s[4]) < -joystickdeadzone then
					return true
				else
					return false
				end
			end
		end
	else
		if love.keyboard.isDown(s[1]) then
			return true
		else 
			return false
		end
	end
end

function game_joystickpressed( joystick, button )	
	if pausemenuopen then
		return
	end
	if endpressbutton then
		endgame()
		return
	end
	
	for i = 1, players do
		if not noupdate and objects["player"][i].controlsenabled and not objects["player"][i].vine then
			local s1 = controls[i]["jump"]
			local s2 = controls[i]["run"]
			local s3 = controls[i]["reload"]
			local s4 = controls[i]["use"]
			local s5 = controls[i]["left"]
			local s6 = controls[i]["right"]
			if s1[1] == "joy" and joystick == tonumber(s1[2]) and s1[3] == "but" and button == tonumber(s1[4]) then
				objects["player"][i]:jump()
				return
			elseif s2[1] == "joy" and joystick == s2[2] and s2[3] == "but" and button == s2[4] then
				objects["player"][i]:fire()
				return
			elseif s3[1] == "joy" and joystick == s3[2] and s3[3] == "but" and button == s3[4] then
				objects["player"][i]:removeportals()
				return
			elseif s4[1] == "joy" and joystick == s4[2] and s4[3] == "but" and button == s4[4] then
				objects["player"][i]:use()
				return
			elseif s5[1] == "joy" and joystick == s5[2] and s5[3] == "but" and button == s5[4] then
				objects["player"][i]:leftkey()
				return
			elseif s6[1] == "joy" and joystick == s6[2] and s6[3] == "but" and button == s6[4] then
				objects["player"][i]:rightkey()
				return
			end
			
			local s = controls[i]["portal1"]
			if s and s[1] == "joy" then
				if s[3] == "but" then
					if joystick == s[2] and button == s[4] then
						shootportal(i, 1, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
						return
					end
				end
			end
			
			local s = controls[i]["portal2"]
			if s and s[1] == "joy" then
				if s[3] == "but" then
					if joystick == tonumber(s[2]) and button == tonumber(s[4]) then
						shootportal(i, 2, objects["player"][i].x+6/16, objects["player"][i].y+6/16, objects["player"][i].pointingangle)
						return
					end
				end
			end
		end
	end
end

function game_joystickreleased( joystick, button )
	for i = 1, players do
		local s = controls[i]["jump"]
		if s[1] == "joy" then
			if s[3] == "but" then
				if joystick == tonumber(s[2]) and button == tonumber(s[4]) then
					objects["player"][i]:stopjump()
					return
				end
			end
		end
	end
end

function inrange(i, a, b, include)
	if a > b then
		b, a = a, b
	end
	
	if include then
		if i >= a and i <= b then
			return true
		else
			return false
		end
	else
		if i > a and i < b then
			return true
		else
			return false
		end
	end
end

function adduserect(x, y, width, height, callback)
	local t = {}
	t.x = x
	t.y = y
	t.width = width
	t.height = height
	t.callback = callback
	t.delete = false
	
	table.insert(userects, t)
	return t
end

function userect(x, y, width, height)
	local outtable = {}
	
	for i, v in pairs(userects) do
		if aabb(x, y, width, height, v.x, v.y, v.width, v.height) then
			table.insert(outtable, v.callback)
		end
	end
	
	return outtable
end

function drawrectangle(x, y, width, height)
	love.graphics.rectangle("fill", x*scale, y*scale, width*scale, scale)
	love.graphics.rectangle("fill", x*scale, y*scale, scale, height*scale)
	love.graphics.rectangle("fill", x*scale, (y+height-1)*scale, width*scale, scale)
	love.graphics.rectangle("fill", (x+width-1)*scale, y*scale, scale, height*scale)
end

function inmap(x, y)
	if not x or not y then
		return false
	end
	if x >= 1 and x <= mapwidth and y >= 1 and y <= mapheight then
		return true
	else
		return false
	end
end

function playmusic()
	if musici == 7 and custommusic then
		music:play(custommusic)
	elseif musici ~= 1 then
		if mariotime < 100 and mariotime > 0 then
			music:playIndex(musici-1, true)
		else
			music:playIndex(musici-1)
		end
	end
end

function stopmusic()
	if musici ~= 1 then
		if mariotime < 100 and mariotime > 0 then
			music:stopIndex(musici-1, true)
		else
			music:stopIndex(musici-1)
		end
	end
end
	
function updatesizes()
	mariosizes = {}
	if not objects then
		for i = 1, players do
			mariosizes[i] = 1
		end
	else
		for i = 1, players do
			mariosizes[i] = objects["player"][i].size
		end
	end
end

function hitrightside()
	if haswarpzone then
		objects["plant"] = {}
		objects["downplant"] = {}
		objects["redplant"] = {}
		objects["reddownplant"] = {}
		objects["dryplant"] = {}
		objects["drydownplant"] = {}
		objects["fireplant"] = {}
		objects["downfireplant"] = {}
		displaywarpzonetext = true
	end
end

function getclosestplayer(x)
	closestplayer = 1
	for i = 2, players do
		if math.abs(objects["player"][closestplayer].x+6/16-x) < math.abs(objects["player"][i].x+6/16-x) then
			closestplayer = i
		end
	end
	
	return closestplayer
end

function endgame()
	if not onlinemp then
		love.audio.stop()
		playertype = "minecraft"
		playertypei = 2
		gamefinished = true
		saveconfig()
		menu_load()
	else
		gamefinished = true
		love.audio.stop()
		gamestate = "lobby"
		objects = nil
		server_startgame = false
		server_startgametimer = 0
		server_inflivesvalue = infinitelives
		server_mappack = mappack

		server_globalmappacklist = mappackname

		lobby_maxplayers = 4

		loadbackground("1-1.txt")

		server_endgame()

		clientisnetworkhost = true

		local showmagicdns = lobby_showmagicdns
		lobby_load(LOBBY_HOSTNICK)
		guielements.showmagicdnsbutton.var = showmagicdns
		lobby_showmagicdns = showmagicdns

		networksynccedconfig = false

		suspendprompt = false
		pausemenuopen = false
		pausemenuselected = 1
		pausemenuselected2 = 1

	end
end

--Minecraft stuff

function placeblock(x, y, side)
	if side == "up" then
		y = y - 1
	elseif side == "down" then
		y = y + 1
	elseif side == "left" then
		x = x - 1
	elseif side == "right" then
		x = x + 1
	end
	
	if not inmap(x, y) then
		return false
	end
	
	--get block
	local tileno
	if inventory[mccurrentblock].t ~= nil then
		tileno = inventory[mccurrentblock].t
	else
		return false
	end
	
	if #checkrect(x-1, y-1, 1, 1, "all") == 0 then
		map[x][y][1] = tileno
		objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1, 1, 1, true)
		generatespritebatch()
	
		inventory[mccurrentblock].count = inventory[mccurrentblock].count - 1
		
		if inventory[mccurrentblock].count == 0 then
			inventory[mccurrentblock].t = nil
		end
		
		return true
	else
		return false
	end
end

function collectblock(i)
	local success = false
	for j = 1, 9 do
		if inventory[j].t == i and inventory[j].count < 64 then
			inventory[j].count = inventory[j].count+1
			success = true
			break
		end
	end
	
	if not success then
		for j = 1, 9 do
			if inventory[j].t == nil then
				inventory[j].count = 1
				inventory[j].t = i
				success = true
				break
			end
		end
	end
	
	return success
end

function breakblock(x, y)
	--create a cute block
	table.insert(miniblocks, miniblock:new(x-.5, y-.2, map[x][y][1]))
	
	map[x][y][1] = 1
	map[x][y]["gels"] = {}
	objects["tile"][x .. "-" .. y] = nil
	
	generatespritebatch()
end

function respawnplayers()
	if mariolivecount == false then
		return
	end
	for i = 1, players do
		if mariolives[i] == 1 and objects["player"].dead then
			objects["player"][i]:respawn()
		end
	end
end
