--
-- @file    data/object/goods.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-06-13 09:54:20
-- @desc    描述
--

local OBJDEF = setmetatable({}, _G.DEF.Item)
OBJDEF.__index = OBJDEF
OBJDEF.__tostring = function (self)
	return string.format("[Goods#%s x%s=%s]",
		tostring(self.dat), tostring(self.amount), tostring(self.price))
end

local OrderStatus = { "Selling", "SoldOut", "OffShelves" }

function OBJDEF.new(dat, amount, price)
	local self = {
		 dat = dat, amount = amount, price = price,
	}
	return setmetatable(self, OBJDEF)
end

-- 实例化一个简单商品
-- VendueBaseInfo
function OBJDEF.read(nm)
	return OBJDEF.new(nm:readU32(), nm:readU32(), nm:readU32())
end

-- 实例化一个订单商品
-- OwnerVendueInfo
function OBJDEF.order(nm)
	local self = OBJDEF.read(nm)
	self:read_info(nm)
	return self
end

function OBJDEF:read_base(nm)
	self.dat = nm:readU32()
	self.amount = nm:readU32()
	self.price = nm:readU32()
end

function OBJDEF:read_info(nm)
	self.order = nm:readU32()
	self.status = OrderStatus[nm:readU32()]
	self.expireDate = math.floor(nm:readU64() / 1000)
end

return OBJDEF
