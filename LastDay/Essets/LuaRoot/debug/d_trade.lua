--
-- @file    debug/d_trade.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-06-13 15:46:19
-- @desc    描述
--

local GoodsDEF = DEF.Goods

local TradeGoods = setmetatable({}, _G.MT.AutoGen)

local function new_goods(category, dat, amount, price)
	table.insert(TradeGoods[category], GoodsDEF.new(dat, math.random(999, 99999), math.random(1, 999)))
end

new_goods(1, 901)
new_goods(1, 902)
new_goods(1, 903)
new_goods(1, 904)
new_goods(1, 911)
new_goods(1, 912)
new_goods(1, 1001)
new_goods(1, 1101)
new_goods(1, 1501)
new_goods(1, 2001)
new_goods(1, 2203)

new_goods(2, 5001)
new_goods(2, 6001)
new_goods(2, 7001)
new_goods(2, 8001)
new_goods(2, 9001)

new_goods(3, 102)
new_goods(3, 103)
new_goods(3, 110)
new_goods(3, 117)
new_goods(3, 15001)
new_goods(3, 16004)

new_goods(4, 10003)
new_goods(4, 10004)
new_goods(4, 10005)
new_goods(4, 10006)


DY_DATA.TradeGoods = TradeGoods
