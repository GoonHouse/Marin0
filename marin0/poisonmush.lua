poisonmush = class:new()

function poisonmush:init(x, y)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
	self.height = 12/16
	self.static = true
	self.active = true
	self.category = 6
	self.mask = {	true,
					false, false, true, true, true,
					false, true, false, true, true,
					false, true, true, false, true,
					true, true, false, true, true,
					false, true, true, false, false,
					true, false, true, true, true}
	self.destroy = false
	self.autodelete = true
	
	--IMAGE STUFF
	self.drawable = false
	self.graphic = entitiesimg
	self.quad = entityquads[101].quad
	self.offsetX = 7
	self.offsetY = 3
	self.quadcenterX = 9
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	self.uptimer = 0
	
	self.falling = false
end

function poisonmush:update(dt)
	--rotate back to 0 (portals)
	self.rotation = math.mod(self.rotation, math.pi*2)
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
	
	if self.uptimer < poisonmushtime then
		self.uptimer = self.uptimer + dt
		self.y = self.y - dt*(1/poisonmushtime)
		self.speedx = poisonmushspeed
		
	else
		if self.static == true then
			self.static = false
			self.active = true
			self.drawable = true
		end
	end
	
	if self.destroy then
		return true
	else
		return false
	end
end

function poisonmush:draw()
	if self.uptimer < poisonmushtime and not self.destroy then
		--Draw it coming out of the block.
		love.graphics.draw(entitiesimg, entityquads[101].quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), 0, scale, scale, self.quadcenterX, self.quadcenterY)
	end
end

function poisonmush:leftcollide(a, b)
	self.speedx = poisonmushspeed
	
	if a == "player" then
		if onlinemp then
			if not getifmainmario(b) then
				return false
			end
		end
		if b.starred == false then
			b:die("poisonmush")
		end
		self.active = false
		self.destroy = true
		self.drawable = false
		table.insert(networksendqueue, "poisonmushed;" .. networkclientnumber .. ";" .. math.floor(self.x) .. ";" .. math.floor(self.y))
	end
	
	return false
end

function poisonmush:rightcollide(a, b)
	self.speedx = -poisonmushspeed
	
	if a == "player" then
		if onlinemp then
			if not getifmainmario(b) then
				return false
			end
		end
		if b.starred == false then
			b:die("poisonmush")
		end
		self.active = false
		self.destroy = true
		self.drawable = false
		table.insert(networksendqueue, "poisonmushed;" .. networkclientnumber .. ";" .. math.floor(self.x) .. ";" .. math.floor(self.y))
	end
	
	return false
end

function poisonmush:floorcollide(a, b)
	if a == "player" then
		if onlinemp then
			if not getifmainmario(b) then
				return false
			end
		end
		if b.starred == false then
			b:die("poisonmush")
		end
		self.active = false
		self.destroy = true
		self.drawable = false
		table.insert(networksendqueue, "poisonmushed;" .. networkclientnumber .. ";" .. math.floor(self.x) .. ";" .. math.floor(self.y))
	end
end

function poisonmush:ceilcollide(a, b)
	if a == "player" then
		if onlinemp then
			if not getifmainmario(b) then
				return false
			end
		end
		if b.starred == false then
			b:die("poisonmush")
		end
		self.active = false
		self.destroy = true
		self.drawable = false
		table.insert(networksendqueue, "poisonmushed;" .. networkclientnumber .. ";" .. math.floor(self.x) .. ";" .. math.floor(self.y))
	end
end

function poisonmush:jump(x)
	self.falling = true
	self.speedy = -poisonmushjumpforce
	if self.x+self.width/2 < x-0.5 then
		self.speedx = -poisonmushspeed
	elseif self.x+self.width/2 > x-0.5 then
		self.speedx = poisonmushspeed
	end
end