--
-- @file    debug/d_item.lua
-- @authors xing weizhen (xingweizhen@firedoggame.com)
-- @date    2017-11-01 23:01:17
-- @desc    描述
--

local ItemDEF = _G.DEF.Item

local function add_item(pos, dat, amount)
	local Item = ItemDEF.create(pos, dat, amount)
	DY_DATA:iset_item(pos, Item)
	return Item
end

add_item(1, 902, 1):set_durability(1, 0)
add_item(2, 901, 1):set_durability(1, 0)
add_item(3, 12002, 10)
add_item(4, 2001, 1)
add_item(5, 5001, 1)
add_item(6, 6001, 1)
add_item(7, 8099, 1)
add_item(8, 2101, 1):set_durability(30, 1)
add_item(9, 912, 1)
add_item(10, 911, 1)
add_item(11, 9001, 1)
add_item(12, 5002, 1)
add_item(13, 6002, 1)
add_item(14, 7002, 1)
add_item(15, 8002, 1)
add_item(16, 1101, 1)
add_item(17, 1205, 1)
add_item(18, 1209, 1)
add_item(19, 2601, 1)
add_item(20, 10001, 19)
add_item(21, 11001, 20)
add_item(22, 11002, 20)
add_item(23, 12001, 20)
add_item(24, 13001, 20)
add_item(25, 1501, 1)
add_item(26, 2501, 1)
add_item(27, 2202, 1)
add_item(28, 14001, 10)
add_item(29, 21102, 20)
add_item(30, 20202, 20)
add_item(31, 21104, 20)
add_item(32, 10003, 20)
add_item(33, 2303, 1)
add_item(34, 20701, 20)
add_item(35, 20702, 20)
add_item(36, 22001, 20)
add_item(37, 20401, 20)
add_item(38, 20402, 20)
add_item(39, 20301, 20)
add_item(40, 20306, 20)

add_item(108, 4003, 17)
add_item(109, 113, 16)
add_item(101, 1001, 1)
--add_item(102, 999, 1)
add_item(105, 7001, 1)
add_item(106, 8001, 1)

DY_DATA.bagCap = 70
DY_DATA.get_item_amount = DY_DATA.nget_item
