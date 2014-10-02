cheepcheep = class:new()

function cheepcheep:init(x, y, color)
	self.x = x
	self.y = y
	self.starty = y
	self.width = 12/16
	self.height = 12/16
	self.rotation = 0 --for portals
	self.verticalmoving = false
	if (onlinemp and clientisnetworkhost or not onlinemp) then
		if math.random(2) == 1 then
			self.verticalmoving = true
		else
			self.verticalmoving = false
		end
	end
	
	self.color = color
	
	self.active = true
	self.static = false
	self.autodelete = true
	self.gravity = 0
	self.category = 24
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = cheepcheepimg
	self.quad = cheepcheepquad[self.color][1]
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	self.portalable = false
	
	self.mask = {	true, 
					true, false, true, true, true,
					true, true, true, true, true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true}
	
	self.speedy = 0
	if self.color == 1 then
		self.speedx = -cheepredspeed
	else
		self.speedx = -cheepwhitespeed
	end
	
	self.direction = "up"
	self.animationtimer = 0
	
	self.shot = false

	self.verticalmovingsynctimer = 0
end

function cheepcheep:update(dt)
	if (onlinemp and clientisnetworkhost or not onlinemp) and self.verticalmoving then
		self.verticalmovingsynctimer = self.verticalmovingsynctimer + dt
		--Need to do this to make sure that the cheep is inserted into the objects table on either side
		if self.verticalmovingsynctimer > .2 then
			local vermove = "0"
			if self.verticalmoving then
				vermove = "1"
			end 
			local id
			for i, v in pairs(objects["cheep"]) do
				if v == self then
					id = i
					break
				end
			end
			self.verticalmovingsynctimer = -2000
			--Welp that's not getting called again
			table.insert(networksendqueue, "cheepver;" .. networkclientnumber .. ";" .. vermove .. ";" .. id)
		end
	end

	--rotate back to 0 (portals)
	if self.rotation > 0 then
		self.rotation = self.rotation - portalrotationalignmentspeed*dt
		if self.rotation < 0 then
			self.rotation = 0
		end
	elseif self.rotation < 0 then
		self.rotation = self.rotation + portalrotationalignmentspeed*dt
		if self.rotation > 0 then
			self.rotation = 0
		end
	end
	
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
		
	else
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > cheepanimationspeed do
			self.animationtimer = self.animationtimer - cheepanimationspeed
			if self.frame == 1 then
				self.frame = 2
			else
				self.frame = 1
			end
			self.quad = cheepcheepquad[self.color][self.frame]
		end
		
		--move up and down
		if self.verticalmoving then
			if self.direction == "up" then
				self.speedy = -cheepyspeed
				if self.y < self.starty - cheepheight then
					self.direction = "down"
				end
			else
				self.speedy = cheepyspeed
				if self.y > self.starty + cheepheight then
					self.direction = "up"
				end
			end
		end
		
		return false
	end
end

function cheepcheep:shotted(dir) --fireball, star, turtle
	playsound(shotsound)
	self.shot = true
	self.active = false
	self.gravity = shotgravity
	self.speedy = -shotjumpforce
	self.direction = dir or "right"
	if self.direction == "left" then
		self.speedx = -shotspeedx
	else
		self.speedx = shotspeedx
	end
end

function cheepcheep:rightcollide(a, b)
	if self:globalcollide() then
		return false
	end
	
end

function cheepcheep:leftcollide(a, b)
	if self:globalcollide() then
		return false
	end
	
end

function cheepcheep:ceilcollide(a, b)
	if self:globalcollide() then
		return false
	end
	
end

function cheepcheep:floorcollide(a, b)
	if self:globalcollide() then
		return false
	end
	
end

function cheepcheep:globalcollide(a, b)
	return true	
end