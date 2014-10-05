fireball = class:new()

function fireball:init(x, y, dir, v)
	--PHYSICS STUFF
	self.y = y+4/16
	self.speedy = 0
	if dir == "right" then
		self.speedx = fireballspeed
		self.x = x+6/16
	else
		self.speedx = -fireballspeed
		self.x = x
	end
	self.width = 8/16
	self.height = 8/16
	self.active = true
	self.static = false
	self.category = 13
	
	self.mask = {	true,
					false, true, false, false, true,
					false, true, false, true, false,
					false, true, false, true, false,
					true, true, false, false, false,
					false, true, false, false, true,
					false, false, false, false, true}
					
	self.destroy = false
	self.destroysoon = false
	--self.gravity = 40
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = fireballimg
	self.quad = fireballquad[1]
	self.offsetX = 4
	self.offsetY = 4
	self.quadcenterX = 4
	self.quadcenterY = 4
	
	self.fireballthrower = v
	
	self.rotation = 0 --for portals
	self.timer = 0
	self.quadi = 1
end

function fireball:update(dt)
	--rotate back to 0 (portals)
	self.rotation = 0
	
	--animate
	self.timer = self.timer + dt
	if self.destroysoon == false then
		while self.timer > staranimationdelay do
			self.quadi = self.quadi + 1
			if self.quadi == 5 then
				self.quadi = 1
			end
			self.quad = fireballquad[self.quadi]
			self.timer = self.timer - staranimationdelay
		end
	else
		while self.timer > staranimationdelay do
			self.quadi = self.quadi + 1
			if self.quadi == 8 then
				self.destroy = true
				self.quadi = 7
			end
			
			self.quad = fireballquad[self.quadi]
			self.timer = self.timer - staranimationdelay
		end
	end
	
	if self.x < xscroll-1 or self.x > xscroll+width+1 or self.y > mapheight and self.active then
		self.fireballthrower:fireballcallback()
		self.destroy = true
	end
	
	if self.destroy then
		return true
	else
		return false
	end
end

function fireball:leftcollide(a, b)
	self.x = self.x-.5
	self:hitstuff(a, b)
	
	self.speedx = fireballspeed
	
	if a == "donut" then
		self:explode()
		playsound(blockhitsound)
	end
	
	return false
end

function fireball:rightcollide(a, b)
	self:hitstuff(a, b)
	
	self.speedx = -fireballspeed
	
	if a == "donut" then
		self:explode()
		playsound(blockhitsound)
	end
	
	return false
end

function fireball:floorcollide(a, b)
	if a ~= "tile" and a ~= "portalwall" then
		self:hitstuff(a, b)
	end
	
	self.speedy = -fireballjumpforce
	return false
end

function fireball:ceilcollide(a, b)
	self:hitstuff(a, b)
end

function fireball:passivecollide(a, b)
	self:ceilcollide(a, b)
	return false
end

function fireball:hitstuff(a, b)
	if a == "tile" or a == "bulletbill" or a == "portalwall" or a == "spring" or a == "bigbill" or a == "kingbill" or a == "barrel" or a == "angrysun" or a == "springgreen" or a == "thwomp" or a == "fishbone" or a == "drybones" or a == "muncher" or (a == "bigkoopa" and b.t == "bigbeetle") or a == "meteor" or (a == "goomba" and b.t == "drygoomba") or a == "dryplant" or a == "drydownplant" or a == "parabeetle" or a == "boo" or a == "torpedoted" then
		self:explode()
		playsound(blockhitsound)

	elseif a == "goomba" or a == "koopa" or a == "hammerbro" or a == "plant" or a == "cheep" or a == "bowser" or a == "squid" or a == "cheep" or a == "flyingfish" or a == "lakito" or a == "downplant" or a == "sidestepper" or a == "paragoomba" or a == "icicle" or a == "splunkin" or a == "biggoomba" or a == "bigkoopa" or a == "shell" or a == "goombrat" or a == "redplant" or a == "reddownplant" or a == "boomerangbro" or a == "ninji" or a == "mole" or a == "fireplant" or a == "downfireplant" or a == "firebro" then
		if a ~= "koopa" or b.t ~= "beetle" then
			b:shotted("right")
			if a ~= "bowser" then
				addpoints(firepoints[a], self.x, self.y)
			end
		end
		self:explode()
	
	elseif a == "bomb" then
		if b.explosion == false then
			b:shotted2("right")
			self:explode()
		else
			self:explode()
		end
	elseif a == "boomboom" then
		if b.ducking == false then
			b:shotted("right")
			self:explode()
		else
			self:explode()
		end
	end
end

function fireball:explode()
	if self.active then
		self.fireballthrower:fireballcallback()
		
		self.destroysoon = true
		self.quadi = 5
		self.quad = fireballquad[self.quadi]
		self.active = false
	end
end