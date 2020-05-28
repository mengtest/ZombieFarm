local ITEMLib = config("itemlib")

local DB = {}
local SHOP_SHOP = dofile("config/shop_shop")
for _,v in pairs(SHOP_SHOP) do
	DB[v.ID] = {
		id = v.ID,
		type = v.type,
		assetCostType = v.assetCost,
	}
end

local GUILD_SHOP_DB = {}
local GUILD_SHOP = dofile("config/shop_guildlv")
for _,v in pairs(GUILD_SHOP) do
	if v.ID == _G.CVar.SHOP_TYPE["GUILD_SHOP"] then
		GUILD_SHOP_DB[v.ShopLv] = {
			id = v.ShopLv,
			maxCellNum = v.goodsNum,
			-- = v.Reward:splitn('|'),
		}
	end
end

local P = {}

function P.get_shop_dat(id)
	return DB[id]
end

function P.get_guild_shop_data(shoplv)
	return GUILD_SHOP_DB[shoplv]
end

return P