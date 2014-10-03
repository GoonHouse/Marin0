hatoffsets = {}
hatoffsets["idle"] = {0, 0}
hatoffsets["running"] = {{0, 0}, {0, 0}, {-1, -1}}
hatoffsets["sliding"] = {0, 0}
hatoffsets["jumping"] = {0, -1}
hatoffsets["falling"] = {0, 0}
hatoffsets["climbing"] = {{2, 0}, {2, -1}}
hatoffsets["swimming"] = {{1, -1}, {1, -1}}
hatoffsets["dead"] = false
hatoffsets["grow"] = {-6, 0}

local i
hat = {}

i = 1
hat[i] = {}
hat[i].x = 7
hat[i].y = 2
hat[i].height = 2
hat[i].graphic = newImageFallback("hats/standard.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 2
hat[i] = {}
hat[i].x = 5
hat[i].y = -3
hat[i].height = 4
hat[i].graphic = newImageFallback("hats/tyrolean.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 3
hat[i] = {}
hat[i].x = 5
hat[i].y = -1
hat[i].height = 4
hat[i].graphic = newImageFallback("hats/towering1.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 4
hat[i] = {}
hat[i].x = 5
hat[i].y = -6
hat[i].height = 8
hat[i].graphic = newImageFallback("hats/towering2.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 5
hat[i] = {}
hat[i].x = 5
hat[i].y = 1
hat[i].height = 2
hat[i].graphic = newImageFallback("hats/towering3.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 6
hat[i] = {}
hat[i].x = 5
hat[i].y = -7
hat[i].height = 10
hat[i].graphic = newImageFallback("hats/drseuss.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 7
hat[i] = {}
hat[i].x = 4
hat[i].y = -7
hat[i].height = 8
hat[i].graphic = newImageFallback("hats/bird.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 8
hat[i] = {}
hat[i].x = 4
hat[i].y = -1
hat[i].height = 3
hat[i].graphic = newImageFallback("hats/banana.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 9
hat[i] = {}
hat[i].x = 7
hat[i].y = -2
hat[i].height = 3
hat[i].graphic = newImageFallback("hats/beanie.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 10
hat[i] = {}
hat[i].x = 7
hat[i].y = -5
hat[i].height = 8
hat[i].graphic = newImageFallback("hats/toilet.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 11
hat[i] = {}
hat[i].x = 5
hat[i].y = -4
hat[i].height = 5
hat[i].graphic = newImageFallback("hats/indian.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 12
hat[i] = {}
hat[i].x = 6
hat[i].y = -1
hat[i].height = 3
hat[i].graphic = newImageFallback("hats/officerhat.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 13
hat[i] = {}
hat[i].x = 5
hat[i].y = -3
hat[i].height = 6
hat[i].graphic = newImageFallback("hats/crown.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 14
hat[i] = {}
hat[i].x = 5
hat[i].y = -5
hat[i].height = 9
hat[i].graphic = newImageFallback("hats/tophat.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 15
hat[i] = {}
hat[i].x = 6
hat[i].y = 1
hat[i].height = 2
hat[i].graphic = newImageFallback("hats/batter.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 16
hat[i] = {}
hat[i].x = 6
hat[i].y = 0
hat[i].height = 2
hat[i].graphic = newImageFallback("hats/bonk.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 17
hat[i] = {}
hat[i].x = 6
hat[i].y = 0
hat[i].height = 3
hat[i].graphic = newImageFallback("hats/bakerboy.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 18
hat[i] = {}
hat[i].x = 5
hat[i].y = 1
hat[i].height = 2
hat[i].graphic = newImageFallback("hats/troublemaker.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 19
hat[i] = {}
hat[i].x = 7
hat[i].y = 1
hat[i].height = 3
hat[i].graphic = newImageFallback("hats/whoopee.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 20
hat[i] = {}
hat[i].x = 6
hat[i].y = -1
hat[i].height = 4
hat[i].graphic = newImageFallback("hats/milkman.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 21
hat[i] = {}
hat[i].x = 6
hat[i].y = 1
hat[i].height = 2
hat[i].graphic = newImageFallback("hats/bombingrun.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 22
hat[i] = {}
hat[i].x = 4
hat[i].y = 3
hat[i].height = 0
hat[i].graphic = newImageFallback("hats/bonkboy.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 23
hat[i] = {}
hat[i].x = 6
hat[i].y = 0
hat[i].height = 3
hat[i].graphic = newImageFallback("hats/flippedtrilby.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 24
hat[i] = {}
hat[i].x = 7
hat[i].y = 0
hat[i].height = 3
hat[i].graphic = newImageFallback("hats/superfan.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 25
hat[i] = {}
hat[i].x = 6
hat[i].y = -2
hat[i].height = 4
hat[i].graphic = newImageFallback("hats/familiarfez.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 26
hat[i] = {}
hat[i].x = 3
hat[i].y = 0
hat[i].height = 4
hat[i].graphic = newImageFallback("hats/santahat.png");hat[i].graphic:setFilter("nearest", "nearest")

i = 27
hat[i] = {}
hat[i].x = 6
hat[i].y = 0
hat[i].height = 2
hat[i].graphic = newImageFallback("hats/sailor.png")

i = 28
hat[i] = {}
hat[i].x = 3
hat[i].y = -3
hat[i].height = 5
hat[i].graphic = newImageFallback("hats/koopa.png")

table.insert(hat, {x = 5, y = -5, height = 5, graphic = newImageFallback("hats/blooper.png")})

--30:
table.insert(hat, {x = 7, y = 1, height = 2, graphic = newImageFallback("hats/shyguy.png")})

table.insert(hat, {x = 6, y = 4, height = 4, graphic = newImageFallback("hats/goodnewseverybody.png")})

table.insert(hat, {x = 5, y = 1, height = 4, graphic = newImageFallback("hats/jetset.png")})

table.insert(hat, {x = 6, y = 1, height = 4, graphic = newImageFallback("hats/bestpony.png")})