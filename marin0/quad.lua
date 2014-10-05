quad = class:new()

--I ADDED EVERY TILE PROPERTY FROM SE BONUS POINTS FOR ME!

--COLLIDE?
--INVISIBLE?
--BREAKABLE?
--COINBLOCK?
--COIN?
--_NOT_ PORTALABLE?
--JUMP_THROUGH?
--SPIKES_UP?
--SPIKES_DOWN?
--SPIKES_LEFT?
--SPIKES_RIGHT?
--GRATE?
--WATERTILE?
--MIRROR?
--FOREGROUND?
--BRIDGE?
--LAVA?
--LEFT_SLANT?
--RIGHT_SLANT?

function quad:init(img, imgdata, x, y, width, height)
	--get if empty?

	self.image = img
	self.quad = love.graphics.newQuad((x-1)*17, (y-1)*17, 16, 16, width, height)
	
	--get collision
	self.collision = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17)
	if a > 127 then
		self.collision = true
	end
	
	--get invisible
	self.invisible = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+1)
	if a > 127 then
		self.invisible = true
	end
	
	--get breakable
	self.breakable = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+2)
	if a > 127 then
		self.breakable = true
	end
	
	--get coinblock
	self.coinblock = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+3)
	if a > 127 then
		self.coinblock = true
	end
	
	--get coin
	self.coin = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+4)
	if a > 127 then
		self.coin = true
	end
	
	self.portalable = true
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+5)
	if a > 127 then
		self.portalable = false
	end
	
	--get jumpthrough
	self.jumpthrough = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+6)
	if a > 127 then
		self.jumpthrough = true
	end
	
	--get spikes
	self.spikesup = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+7)
	if a > 127 then
		self.spikesup = true
	end
	self.spikesdown = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+8)
	if a > 127 then
		self.spikesdown = true
	end
	self.spikesleft = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+9)
	if a > 127 then
		self.spikesleft = true
	end
	self.spikesright = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+10)
	if a > 127 then
		self.spikesright = true
	end
	
	--get grate
	self.grate = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+11)
	if a > 127 then
		self.grate = true
	end
	
	--get watertile
	self.water = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+12)
	if a > 127 then
		self.water = true
	end
	
	--get mirror
	self.mirror = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+13)
	if a > 127 then
		self.mirror = true
	end
	
	--get foreground
	self.foreground = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+14)
	if a > 127 then
		self.foreground = true
	end
	
	--get bridge
	self.bridge = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+15)
	if a > 127 then
		self.bridge = true
	end
	
	--get lava
	self.lava = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+16)
	if a > 127 then
		self.lava = true
	end
	
	--get left slant
	self.leftslant = false
	local r, g, b, a = imgdata:getPixel(x*17-2, (y-1)*17+16)
	if a > 127 then
		self.leftslant = true
	end
	
	--get right slant
	self.rightslant = false
	local r, g, b, a = imgdata:getPixel(x*17-3, (y-1)*17+16)
	if a > 127 then
		self.rightslant = true
	end
end