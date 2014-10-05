geldispenser = class:new()

function geldispenser:init(x, y, id, dir, r)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.x = x-1
	self.y = y-1
	self.speedy = 0
	self.speedx = 0
	self.width = 2
	self.height = 2
	self.static = true
	self.active = true
	self.category = 7
	self.mask = {true, false, false, false, false, false}
	
	self.dir = dir
	self.id = id
	self.r = r
	self.timer = 0
	
	self.on = true
	self.outtable = {}
end

function geldispenser:input(t)
	if t == "on" then
		self.on = true
	elseif t == "off" then
		self.on = false
	elseif t == "toggle" then
		self.on = not self.on
	end
end

function geldispenser:link()
	if #self.r > 2 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[4]) == v.cox and tonumber(self.r[5]) == v.coy then
					v:addoutput(self)
					self.on = false
				end
			end
		end
	end
end

function geldispenser:update(dt)
	if self.on then
		self.timer = self.timer + dt
	end
		
	while self.timer > geldispensespeed do
		self.timer = self.timer - geldispensespeed
		if self.dir == "down" then
			table.insert(objects["gel"], gel:new(self.x+1.5 + (math.random()-0.5)*1, self.y+12/16, self.id))
			objects["gel"][#objects["gel"]].speedy = 10
		elseif self.dir == "right" then
			table.insert(objects["gel"], gel:new(self.x+14/16, self.y+1.5 + (math.random()-0.5)*1, self.id))
			objects["gel"][#objects["gel"]].speedx = 20
			objects["gel"][#objects["gel"]].speedy = -4
		elseif self.dir == "left" then
			table.insert(objects["gel"], gel:new(self.x+30/16, self.y+1.5 + (math.random()-0.5)*1, self.id))
			objects["gel"][#objects["gel"]].speedx = -20
			objects["gel"][#objects["gel"]].speedy = -4
		end
	end
	return false
end

function geldispenser:draw()
	if self.dir == "down" then
		love.graphics.draw(geldispenserimg, math.floor((self.cox-xscroll-1)*16*scale), (self.coy-1.5-yscroll)*16*scale, 0, scale, scale, 0, 0)
	elseif self.dir == "right" then
		love.graphics.draw(geldispenserimg, math.floor((self.cox-xscroll-1)*16*scale), (self.coy+.5-yscroll)*16*scale, math.pi*1.5, scale, scale, 0, 0)
	elseif self.dir == "left" then
		love.graphics.draw(geldispenserimg, math.floor((self.cox-xscroll+1)*16*scale), (self.coy-1.5-yscroll)*16*scale, math.pi*0.5, scale, scale, 0, 0)
	end
end