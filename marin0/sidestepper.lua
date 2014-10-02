sidestepper = class:new()

function sidestepper:init(x, y, t)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = -sidestepperspeed
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 4
	
	self.mask = {	true, 
					false, false, false, false, true,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true}
	
	self.emancipatecheck = true
	self.autodelete = true
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = sidestepperimage
	self.quad = sidestepperquad[spriteset][1]
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0
	
	self.animationdirection = "left"
	
	self.falling = false
	
	self.dead = false
	self.deathtimer = 0
	
	self.shot = false
end

function sidestepper:update(dt)
	
	if self.dead then
		self.deathtimer = self.deathtimer + dt
		if self.deathtimer > sidestepperdeathtime then
			return true
		else
			return false
		end
		
	elseif self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
		
	else
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > sidestepperanimationspeed do
			self.animationtimer = self.animationtimer - sidestepperanimationspeed
			if self.animationdirection == "left" then
				self.animationdirection = "right"
			else
				self.animationdirection = "left"
			end
		end
		
		--check if sidestepper offscreen		
		return false
	end
end

function sidestepper:stomp()--hehe sidestepper stomp

end

function sidestepper:shotted(dir) --fireball, star, turtle
	playsound(shotsound)
	self.shot = true
	self.speedy = -shotjumpforce
	self.direction = dir or "right"
	self.active = false
	self.gravity = shotgravity
	if self.direction == "left" then
		self.speedx = -shotspeedx
	else
		self.speedx = shotspeedx
	end
end

function sidestepper:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if a == "pixeltile" and b.dir == "right" then
		self.y = self.y - 1/16
		return false
	end
	
	self.speedx = sidestepperspeed
	
	return false
end

function sidestepper:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if a == "pixeltile" and b.dir == "left" then
		self.y = self.y - 1/16
		return false
	end
	
	self.speedx = -sidestepperspeed
	
	return false
end

function sidestepper:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function sidestepper:globalcollide(a, b)
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	
	if a == "fireball" or a == "player" then
		return true
	end
end

function sidestepper:startfall()

end

function sidestepper:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function sidestepper:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end

function sidestepper:emancipate(a)
	self:shotted()
end

function sidestepper:laser()
	self:shotted()
end