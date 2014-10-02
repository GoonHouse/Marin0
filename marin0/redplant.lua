redplant = class:new()

function redplant:init(x, y)
	self.cox = x
	self.coy = y
	
	self.timer = 0
	
	self.x = x-8/16
	self.y = y+9/16
	self.starty = self.y
	self.width = 16/16
	self.height = 14/16
	
	self.static = true
	self.active = true
	
	self.destroy = false
	
	self.category = 29
	
	self.mask = {true}
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = redplantimg
	self.quad = redplantquads[spriteset][1]
	self.offsetX = 0
	self.offsetY = 17
	self.quadcenterX = 0
	self.quadcenterY = 0
	
	self.customscissor = {x-1, y-2, 2, 2}
	
	self.quadnum = 1
	self.timer1 = 0
	self.timer2 = redplantouttime+1.5
end

function redplant:update(dt)
	self.timer1 = self.timer1 + dt
	while self.timer1 > redplantanimationdelay do
		self.timer1 = self.timer1 - redplantanimationdelay
		if self.quadnum == 1 then
			self.quadnum = 2
		else
			self.quadnum = 1
		end
		self.quad = redplantquads[spriteset][self.quadnum]
	end
	
	self.timer2 = self.timer2 + dt
	if self.timer2 < redplantouttime then
		self.y = self.y - redplantmovespeed*dt
		if self.y < self.starty - redplantmovedist then
			self.y = self.starty - redplantmovedist
		end
	elseif self.timer2 < redplantouttime+redplantintime then
		self.y = self.y + redplantmovespeed*dt
		if self.y > self.starty then
			self.y = self.starty
		end
	else
		if (onlinemp and clientisnetworkhost or not onlinemp) then
			for i = 1, players do
				local v = objects["player"][i]
					if inrange(v.x+v.width/2, self.x+self.width/2-1, self.x+self.width/2+1) then --no player near
					return
				end
			end
			self.timer2 = 0
			local redplantid
			for i, v in pairs(objects["redplant"]) do
				if v == self then
					redplantid = i
				end
			end
			table.insert(networksendqueue, "redplantout;" .. networkclientnumber .. ";" .. redplantid) 
		end
	end
end

function redplant:shotted()
	playsound(shotsound)
	self.destroy = true
	self.active = false

	sendobjectshotted(self, "redplant", "left")
end