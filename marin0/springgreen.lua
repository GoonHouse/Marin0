springgreen = class:new()

function springgreen:init(x, y)
	self.cox = x
	self.coy = y
	
	--PHYSICS STUFF
	self.x = x-1
	self.y = y-32/16
	self.width = 16/16
	self.height = 32/16
	self.static = true
	self.active = true
	
	self.drawable = false
	
	self.timer = springgreentime
	
	self.category = 19
	
	self.mask = {true}
	
	self.frame = 1
end

function springgreen:update(dt)
	if self.timer < springgreentime then
		self.timer = self.timer + dt
		if self.timer > springgreentime then
			self.timer = springgreentime
		end
		self.frame = math.ceil(self.timer/(springgreentime/3)+0.001)+1
		if self.frame > 3 then
			self.frame = 6-self.frame
		end
	end
end

function springgreen:draw()
	love.graphics.draw(springgreenimg, springgreenquads[spriteset][self.frame], math.floor((self.x-xscroll)*16*scale), (self.y*16-8)*scale, 0, scale, scale)
end

function springgreen:hit()
	self.timer = 0
end