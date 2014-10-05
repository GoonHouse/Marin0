flower = class:new()

function flower:init(x, y, t)
	--PHYSICS STUFF
	self.starty = y
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
	self.height = 12/16
	self.static = true
	self.active = true
	self.category = 6
	self.mask = {true}
	self.destroy = false
	self.autodelete = true
	self.gravity = 0
	self.t = t or "fire"
	
	--IMAGE STUFF
	self.drawable = false
	if self.t == "ice" then
		self.graphic = iceflowerimg
	else
		self.graphic = flowerimg
	end
	self.quad = flowerquad[spriteset][1]
	self.offsetX = 7
	self.offsetY = 3
	self.quadcenterX = 9
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	self.uptimer = 0
	self.timer = 0
	self.quadi = 1
	
	self.falling = false
end

function flower:update(dt)	
	if self.uptimer < mushroomtime then
		self.uptimer = self.uptimer + dt
		self.y = self.y - dt*(1/mushroomtime)
	end
	
	if self.uptimer > mushroomtime then
		self.y = self.starty-27/16
		self.active = true
		self.drawable = true
	end
	
	--animate
	self.timer = self.timer + dt
	while self.timer > firefloweranimationdelay do
		self.quadi = self.quadi + 1
		if self.quadi == 5 then
			self.quadi = 1
		end
		self.quad = flowerquad[spriteset][self.quadi]
		self.timer = self.timer - firefloweranimationdelay
	end
	
	if self.destroy then
		return true
	else
		return false
	end
end

function flower:draw()
	if self.uptimer < mushroomtime and not self.destroy then
		--Draw it coming out of the block.
		love.graphics.drawq(self.graphic, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), 0, scale, scale, self.quadcenterX, self.quadcenterY)
	end
end

function flower:leftcollide(a, b)
	if a == "player" then
		self:use(b)
	end
	
	return false
end

function flower:rightcollide(a, b)
	if a == "player" then
		self:use(b)
	end
	
	return false
end

function flower:floorcollide(a, b)
	if self.active and a == "player" then
		self:use(b)
	end	
end

function flower:ceilcollide(a, b)
	if self.active and a == "player" then
		self:use(b)
	end	
end

function flower:jump(x)
	
end

function flower:use(b)
	if onlinemp then
		if not getifmainmario(b) then
			return false
		end
	end
	b:grow()
	if self.t == "ice" then
		if b.size == 2 or b.size == 4 or b.size == 5 or b.size == 6 then
			b.size = 7
		end
		b.size = 7
	else
		if b.size == 4 or b.size == 5 or b.size == 6 or b.size == 7 then
			b.size = 3
		end
	end

	self.active = false
	self.destroy = true
	self.drawable = false
	table.insert(networksendqueue, "powerup;" .. networkclientnumber .. ";" .. math.floor(self.x) .. ";" .. math.floor(self.y))
end