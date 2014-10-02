reddownplant = class:new()

function reddownplant:init(x, y)
	self.cox = x
	self.coy = y
	
	self.timer = 0
	
	self.x = x-8/16
	self.y = y-32/16
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
	self.graphic = reddownplantimg
	self.quad = reddownplantquads[spriteset][1]
	self.offsetX = 0
	self.offsetY = 17
	self.quadcenterX = 0
	self.quadcenterY = 0
	
	self.customscissor = {x-1, y-1, 2, 4}
	
	self.quadnum = 1
	self.timer1 = 0
	self.timer2 = reddownplantouttime+1.5
end

function reddownplant:update(dt)
	self.timer1 = self.timer1 + dt
	while self.timer1 > reddownplantanimationdelay do
		self.timer1 = self.timer1 - reddownplantanimationdelay
		if self.quadnum == 1 then
			self.quadnum = 2
		else
			self.quadnum = 1
		end
		self.quad = reddownplantquads[spriteset][self.quadnum]
	end
	
	self.timer2 = self.timer2 + dt
	if self.timer2 < reddownplantouttime then
		self.y = self.y + reddownplantmovespeed*dt
		if self.y > self.starty - reddownplantmovedist then
			self.y = self.starty - reddownplantmovedist
		end
	elseif self.timer2 < reddownplantouttime+reddownplantintime then
		self.y = self.y - reddownplantmovespeed*dt
		if self.y < self.starty then
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
			local reddownplantid
			for i, v in pairs(objects["reddownplant"]) do
				if v == self then
					reddownplantid = i
				end
			end
			table.insert(networksendqueue, "reddownplantout;" .. networkclientnumber .. ";" .. reddownplantid) 
		end
	end
	return self.destroy
end
	
function reddownplant:shotted()
	playsound(shotsound)
	self.destroy = true
	self.active = false
	
	sendobjectshotted(self, "reddownplant", "left")
end