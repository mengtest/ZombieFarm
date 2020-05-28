--
-- @file    data/parser/paylib.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-05-08 12:55:45
-- @desc    描述
--

local DB = {}
local PAY = dofile("config/pay_pay")
for _,v in ipairs(PAY) do
	if DB[v.ID] == nil then
		DB[v.ID] = {}
	end

	DB[v.ID][v.Num] = {
		id = v.AssetsType, amount = v.Price,
		num = v.Num,
	}
end

local Name2ID = {
	["WorldChat"] = 101,
	["ChangeName"] = 102,
	["ResetTalent"] = 103,
	["CreateGuild"] = 105,
	["ResetEnergy"] = 1,
	["RefreshGuildList"] = 106,
	["MBPass"] = 601,
}

local P = {}
function P.get_dat(dat, num, unLimit)
	if type(dat) == "string" then
		dat = Name2ID[dat]
	end
	if num == nil then
		num = 0
	end

	local data = DB[dat][num]
	if data == nil and unLimit then
		while(data == nil and num > -1) do
			num = num - 1
			data = DB[dat][num]
		end
	end

	return data
end

return P
