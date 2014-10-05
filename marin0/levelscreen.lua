local connectionstate = "connecting to server"
local levelscreenreason
local resendconnecttimer = 0

function levelscreen_load(reason, i)
	if reason ~= "sublevel" and reason ~= "vine" and testlevel then
		marioworld = testlevelworld
		mariolevel = testlevellevel
		editormode = true
		testlevel = false
		startlevel(marioworld .. "-" .. mariolevel)
		return
	end

	levelscreenreason = reason

	checkcheckpoint = false
	
	--check if lives left
	livesleft = false
	for i = 1, players do
		if mariolivecount == false or mariolives[i] > 0 then
			livesleft = true
		end
	end
	
	if reason == "sublevel" then
		gamestate = "sublevelscreen"
		blacktime = sublevelscreentime
		sublevelscreen_level = i
	elseif reason == "vine" then
		gamestate = "sublevelscreen"
		blacktime = sublevelscreentime
		sublevelscreen_level = i
	elseif livesleft then
		gamestate = "levelscreen"
		blacktime = levelscreentime
		if reason == "next" then --next level
			if onlinemp and clientisnetworkhost then
				udp:send("nextlevel")
			end
			respawnsublevel = 0
			checkpointx = nil
			
			--check if next level doesn't exist
			if not love.filesystem.exists("mappacks/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. ".txt") then
				gamestate = "mappackfinished"
				blacktime = gameovertime
				music:play("princessmusic")
			end
		else
			if levelscreenreason ~= "initial" then
				if singularmariogamemode then
					currentmarioplayermoving = currentmarioplayermoving+1
					if currentmarioplayermoving > players then
						currentmarioplayermoving = 1
					end
				end
			end
			checkcheckpoint = true
		end
	else
		gamestate = "gameover"
		blacktime = gameovertime
		playsound(gameoversound)
		checkpointx = nil
	end
	
	if editormode then
		blacktime = 0
	end
	
	if reason ~= "initial" then
		updatesizes()
	end
	
	if marioworld == 1 or mariolevel == 1 then
		blacktime = blacktime * 1.5
	end
	
	coinframe = 1
	
	love.graphics.setBackgroundColor(0, 0, 0)
	print(love.graphics.getBackgroundColor())
	levelscreentimer = 0
	
	--reached worlds
	local updated = false
	if not reachedworlds[mappack] then
		reachedworlds[mappack] = {}
	end
	
	if marioworld ~= "M" and not reachedworlds[mappack][marioworld] then
		reachedworlds[mappack][marioworld] = true
		updated = true
	end

	if levelscreenreason == "initial" and onlinemp then

		blacktimesub = 0
		levelscreentimer = 0.01
		mariodeaths = {}
		for x = 1, math.max(4, players) do
			mariolives[x] = 3
			mariodeaths[x] = 0
		end
		if singularmariogamemode then
			currentmarioplayermoving = 1
			mariodistancepoints = {}
			for x = 1, players do
				mariodistancepoints[x] = {score=0, distance=0}
			end
		end


		marioworld = 1
		mariolevel = 1

		currentmarioplayermoving = 1

		network_removeplayertimeouttables = {}
		for x = 1, math.max(players, 4) do
			network_removeplayertimeouttables[x] = 0
		end
	else
		blacktimesub = .1
	end

	
	if updated then
		saveconfig()
	end
end

function levelscreen_update(dt)
	--[[if onlinemp and levelscreenreason == "initial" then
		if connectionstate == "connecting to server" then
			resendconnecttimer = resendconnecttimer + dt
			if resendconnecttimer > 1 then
				resendconnecttimer = 0
				udp:send("connect")
			end
		end
		local data, msg = udp:receive()
		while data ~= nil do
			print(data)
			local datatable = data:split(";")
			if data == "connected" then
				connectionstate = "waiting for players"
				local string = "hats"
				for x = 1, #mariohats[1] do
					string = string .. ";" .. mariohats[1][x]
				end
				udp:send(string)
				local string = "color"
				local v = mariocolors[1]
				if v[1][1] ~= 224 or v[1][2] ~= 32 or v[1][3] ~= 0 or v[2][1] ~= 136 or v[2][2] ~= 112 or v[2][3] ~= 0 or v[3][1] ~= 252 or v[3][2] ~= 152 or v[3][3] ~= 56 then
					for set = 1, 3 do
						for color = 1, 3 do
							string = string .. ";" .. mariocolors[1][set][color]
						end
					end		
					udp:send(string)
				end



			elseif data == "startgame" then
				connectionstate = "starting game..."
				levelscreenreason = ""
				--players = 3
				print("yep")
			elseif datatable[1] == "clientnumber" then
				print("ahhh")
				print(datatable[2])
				networkclientnumber = tonumber(datatable[2])
				print(networkclientnumber)
			elseif data == "host" then
				clientisnetworkhost = true
				print("SO HOST")
			elseif datatable[1] == "hats" then
				local table = {}
				for x = 1, #datatable-2 do
					table[x] = tonumber(datatable[x+2])
				end
				mariohats[convertclienttoplayer(tonumber(datatable[2]))] = table
			elseif datatable[1] == "color" then
				mariocolors[convertclienttoplayer(tonumber(datatable[2]))] = {{datatable[3], datatable[4], datatable[5]}, {datatable[6], datatable[7], datatable[8]}, {datatable[9], datatable[10], datatable[11]}}
			end
			data, msg = udp:receive()

		end
		return
	end --]]

	levelscreentimer = levelscreentimer + dt
	if levelscreentimer > blacktime then
		if gamestate == "levelscreen" then
			gamestate = "game"
			if respawnsublevel ~= 0 then
				startlevel(marioworld .. "-" .. mariolevel .. "_" .. respawnsublevel)
			else
				startlevel(marioworld .. "-" .. mariolevel)
			end
		elseif gamestate == "sublevelscreen" then
			gamestate = "game"
			startlevel(sublevelscreen_level)
		else
			if not onlinemp then
				menu_load()
			else
				if clientisnetworkhost then
					endgame()
				end
			end
		end
		
		return
	end
end

function levelscreen_draw()
	love.graphics.setBackgroundColor(0, 0, 0)
	if levelscreentimer < blacktime - blacktimesub and levelscreentimer > blacktimesub then
		love.graphics.setColor(255, 255, 255, 255)

		--[[if levelscreenreason == "initial" and onlinemp then
			properprint(connectionstate, (width/2*16)*scale-string.len(connectionstate)*4*scale, 150*scale)
		end--]]
		
		if gamestate == "levelscreen" then
			properprint("world " .. marioworld .. "-" .. mariolevel, (width/2*16)*scale-40*scale, 72*scale - (players-1)*6*scale)
			
			for i = 1, players do
				local x = (width/2*16)*scale-29*scale
				local y = (97 + (i-1)*20 - (players-1)*8)*scale

				local colorthing = i

				if i == 1 then
					colorthing = playerconfig
				end
				for j = 1, 3 do
					love.graphics.setColor(unpack(mariocolors[colorthing][j]))
					if not classicmodeactive then
						love.graphics.draw(skinpuppet[j], x, y, 0, scale, scale)
					else
						love.graphics.draw(classicskinpuppet[j], x, y, 0, scale, scale)
					end
				end


		
				--hat
				
				offsets = hatoffsets["idle"]
				if #mariohats[colorthing] > 1 or mariohats[colorthing][1] ~= 1 then
					local yadd = 0
					for j = 1, #mariohats[colorthing] do
						love.graphics.setColor(255, 255, 255)
						love.graphics.draw(hat[mariohats[colorthing][j]].graphic, x-5*scale, y-2*scale, 0, scale, scale, - hat[mariohats[colorthing][j]].x + offsets[1], - hat[mariohats[colorthing][j]].y + offsets[2] + yadd)
						yadd = yadd + hat[mariohats[colorthing][j]].height
					end
				elseif #mariohats[colorthing] == 1 then
					love.graphics.setColor(mariocolors[colorthing][1])
					love.graphics.draw(hat[mariohats[colorthing][1]].graphic, x-5*scale, y-2*scale, 0, scale, scale, - hat[mariohats[colorthing][1]].x + offsets[1], - hat[mariohats[colorthing][1]].y + offsets[2])
				end
			
				love.graphics.setColor(255, 255, 255, 255)
				if not classicmodeactive then
					love.graphics.draw(skinpuppet[0], x, y, 0, scale, scale)
				end

				if infinitelives then
					love.graphics.setColor(255, 0, 0, 255)
					love.graphics.setLineWidth(scale)
					love.graphics.line(x, y, x+12*scale, y+16*scale)
					love.graphics.line(x+12*scale, y, x, y+16*scale)
					love.graphics.setColor(255, 255, 255)
				end
				
				if mariolivecount == false then
					properprint("*  inf", (width/2*16)*scale-8*scale, y+7*scale)
				else
					if not infinitelives then
						properprint("*  " .. mariolives[i], (width/2*16)*scale-8*scale, y+7*scale)
					else
						properprint("*  " .. mariodeaths[i], (width/2*16)*scale-8*scale, y+7*scale)
					end
				end
				
				if mappack == "smb" and marioworld == 1 and mariolevel == 1 then
					local s = "remember that you can run with "
					for i = 1, #controls[1]["run"] do
						s = s .. controls[1]["run"][i]
						if i ~= #controls[1]["run"] then
							s = s .. "-"
						end
					end
					properprint(s, (width/2*16)*scale-string.len(s)*4*scale, 200*scale)
				end
				
				if mappack == "portal" and marioworld == 1 and mariolevel == 1 then
					local s = "you can remove your portals with "
					for i = 1, #controls[1]["reload"] do
						s = s .. controls[1]["reload"][i]
						if i ~= #controls[1]["reload"] then
							s = s .. "-"
						end
					end
					properprint(s, (width/2*16)*scale-string.len(s)*4*scale, 190*scale)
					
					local s = "you can grab cubes and push buttons with "
					for i = 1, #controls[1]["use"] do
						s = s .. controls[1]["use"][i]
						if i ~= #controls[1]["use"] then
							s = s .. "-"
						end
					end
					properprint(s, (width/2*16)*scale-string.len(s)*4*scale, 200*scale)
				end
			end
			
		elseif gamestate == "mappackfinished" then
			properprint("congratulations!", (width/2*16)*scale-64*scale, 120*scale)
			properprint("you have finished this mappack!", (width/2*16)*scale-128*scale, 140*scale)
		else
			properprint("game over", (width/2*16)*scale-40*scale, 120*scale)
		end

		if singularmariogamemode and gamestate ~= "levelscreen" then
			local winner = 1
			for value = 2, players do
				if mariodistancepoints[value].score > mariodistancepoints[winner].score then
					winner = value
				end
			end

			local i = winner

			local x = (width/2*16)*scale-29*scale
			local y = 140*scale
			local colorthing = i
			if i == 1 then
				colorthing = playerconfig
			end
			for j = 1, 3 do
				love.graphics.setColor(unpack(mariocolors[colorthing][j]))
				if not classicmodeactive then
					love.graphics.draw(skinpuppet[j], x, y, 0, scale, scale)
				else
					love.graphics.draw(classicskinpuppet[j], x, y, 0, scale, scale)
				end
			end
	
			--hat
			
			offsets = hatoffsets["idle"]
			if #mariohats[colorthing] > 1 or mariohats[colorthing][1] ~= 1 then
				local yadd = 0
				for j = 1, #mariohats[colorthing] do
					love.graphics.setColor(255, 255, 255)
					love.graphics.draw(hat[mariohats[colorthing][j]].graphic, x-5*scale, y-2*scale, 0, scale, scale, - hat[mariohats[colorthing][j]].x + offsets[1], - hat[mariohats[colorthing][j]].y + offsets[2] + yadd)
					yadd = yadd + hat[mariohats[colorthing][j]].height
				end
			elseif #mariohats[colorthing] == 1 then
				love.graphics.setColor(mariocolors[colorthing][1])
				love.graphics.draw(hat[mariohats[colorthing][1]].graphic, x-5*scale, y-2*scale, 0, scale, scale, - hat[mariohats[colorthing][1]].x + offsets[1], - hat[mariohats[colorthing][1]].y + offsets[2])
			end
		
			love.graphics.setColor(255, 255, 255, 255)
			
			love.graphics.draw(skinpuppet[0], x, y, 0, scale, scale)

			properprint("won!", x+20*scale, y+5*scale)




		end
		
		love.graphics.translate(0, -yoffset*scale)
		if yoffset < 0 then
			love.graphics.translate(0, yoffset*scale)
		end
		
		properprint("mario", uispace*.5 - 24*scale, 8*scale)
		properprint(addzeros(marioscore, 6), uispace*0.5-24*scale, 16*scale)
		
		properprint("*", uispace*1.5-8*scale, 16*scale)
		
		love.graphics.draw(coinanimationimage, coinanimationquads[2][coinframe], uispace*1.5-16*scale, 16*scale, 0, scale, scale)
		properprint(addzeros(mariocoincount, 2), uispace*1.5-0*scale, 16*scale)
		
		properprint("world", uispace*2.5 - 20*scale, 8*scale)
		properprint(marioworld .. "-" .. mariolevel, uispace*2.5 - 12*scale, 16*scale)
		
		properprint("time", uispace*3.5 - 16*scale, 8*scale)
	end
end
