--
-- @file    data/object/stage.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-10-30 10:03:07
-- @desc    描述
--

local UnitDEF = _G.DEF.Unit
local MAPLIB = config("maplib")
local UNITLIB = config("unitlib")

local OBJDEF = {}
OBJDEF.__index = OBJDEF
OBJDEF.__tostring = function (self)
	return string.format("[关卡#%s@%s] %dx%d", self.id, self.clock, self.w, self.h)
end

local function set_grass(coord, active)
	-- local pos = libgame.Local2World(coord)
	-- local grass = string.format("/Terrain/Grasses/grass(%d,%d)",
	-- 	math.round(pos.x), math.round(pos.z))
	-- libunity.SetActive(grass, active)
end


function OBJDEF.launch()
	libunity.SendMessage("/StageCtrl", "Launch")
end

function OBJDEF.stop()
	if NW.connected() then OBJDEF.Instance = nil end
	libunity.SendMessage("/StageCtrl", "Stop")
	_G.PKG["game/ctrl"].clear()
end

function OBJDEF.new(id, w, h)
	local self = setmetatable({
		id = id, w = w, h = h,
		Units = {},
		Floors = {}, Walls = {}, Furnitures = {}, Blocks = {},
	}, OBJDEF)
	OBJDEF.Instance = self
	_G.PKG["game/ctrl"].init(self)
	return self
end

function OBJDEF:init()
	for k,v in pairs(self.Floors) do
		set_grass(v.coord, false)
	end
	self.inited = true
end

function OBJDEF:set_dat(dat)
	local MapDat = MAPLIB.get_dat(dat)
	if MapDat == nil then
		libunity.LogE("错误的地图数据ID#{0}", dat)
	end
	self.Base = MapDat
end

function OBJDEF:set_size(w, h)
	self.w, self.h = w, h
end

function OBJDEF:get_build_size()
	return self.w - 4, self.h - 4
end

function OBJDEF:coord2index(x, y)
	local w, h = self.w, self.h
	h = h / 2
	x = math.floor(x / 2 - 1 + 0.5)
	y = math.floor(y / 2 - 1 + 0.5)
	return x * h + y
end

function OBJDEF:index2coord(index)
	local w, h = self:get_build_size()
	h = h / 2
	local x, y = math.floor(index / h), index % h
	return (x + 1) * 2, (y + 1) * 2
end

-- 用两个格子确定一个墙
function OBJDEF:key4wall(x1, y1, x2, y2)
	local index1, index2 = self:coord2index(x1, y1), self:coord2index(x2, y2)
	if index1 > index2 then index1, index2 = index2, index1 end
	--return UE.Vector2(index1, index2)
	--return index1 .. ":" .. index2
	return (index1 << 16) + index2
end

-- 根据格子和方向计算出相邻的另一个格子，再确认一个墙的位置
function OBJDEF:key4wallobj(x, y, angle)
	local x2, y2 = x, y
	if angle < 0 then angle = angle + 360 end
	if angle == 0 then
		x2 = x2 + 2
	elseif angle == 90 then
		y2 = y2 - 2
	elseif angle == 180 then
		x2 = x2 - 2
	elseif angle == 270 then
		y2 = y2 + 2
	end
	return self:key4wall(x, y, x2, y2)
end

function OBJDEF:has_floor(x, y)
	return self.Floors[self:coord2index(x, y)]
end

function OBJDEF:has_wall(x1, y1, x2, y2)
	return self.Walls[self:key4wall(x1, y1, x2, y2)]
end

function OBJDEF:has_furniture(x, y)
	return self.Furnitures[self:coord2index(x, y)]
end

function OBJDEF:get_furniture_list()
	local Furnitures = {}
	for _,v in pairs(self.Furnitures) do
		Furnitures[v] = v.id
	end
	return table.swapkv(Furnitures)
end

-- 有地板且无家具的位置
-- 返回： nil 表示位置可用，否则表示需要的地板等级
function OBJDEF:chk_space(x, y, floor)
	local buildIndex = self:coord2index(x, y)
	if self.Furnitures[buildIndex] then return -2 end

	local Floor = self.Floors[buildIndex]
	if Floor == nil then return floor end

	local FloorBase = Floor:get_base_data()
	return FloorBase.level < floor and floor or nil
end

-- 两个格子之间有间隔
function OBJDEF:has_gap(x1, y1, x2, y2)
	if self:has_wall(x1, y1, x2, y2) then return end

	local index1, index2 = self:coord2index(x1, y1), self:coord2index(x2, y2)
	local Furniture1, Furniture2 = self.Furnitures[index1], self.Furnitures[index2]
	if Furniture1 and Furniture2 and Furniture1.id == Furniture2.id then return end

	return true
end

-- 该格子是否地板边缘
function OBJDEF:has_gap_edge(x, y, x2, y2)
	return not self:has_floor(x2, y2)
		and not self:has_wall(x, y, x2, y2)
end

function OBJDEF.pos2center(pos, size, angle)
	local center = table.dup(pos)
	if size.x ~= size.z then
		-- 长宽不一样的情况下，中心点和位置点也不一样
		angle = angle % 360
		local offset = (size.x - size.z) / 2
		if angle == 0 then
			center.x = center.x - offset
		elseif angle == 90 then
			center.z = center.z + offset
		elseif angle == 180 then
			center.x = center.x + offset
		elseif angle == 270 then
			center.z = center.z - offset
		end
	end
	return center
end

-- 检查是否有空白的地面（可修建在地面上的物件：地板，农田等）
function OBJDEF:chk_empty_ground(x, y, d, size, floor, angle, obj)
	if angle == nil then angle = 0 end
	local center = OBJDEF.pos2center({x = x, z = y}, size, angle)

	-- 全区域判定
	-- local center = { x = x, z = y }
	-- size.x = math.max(size.x, size.z)
	-- size.z = size.x

	local w, h = size.x - 0.01, size.z - 0.01
	if angle % 180 ~= 0 then w, h = h, w end
	local Units = libgame.FindUnitsInside("Rectangle", UE.Vector2(center.x, center.z), w, h)

	local selfCamp = self.Self.camp
	local selfId = self.Self.id
	-- 排除友方非建筑和自己
	if Units then
		for i,v in ipairs(Units) do
			local Unit = self:find_unit(v)
			if Unit and Unit.id ~= obj and Unit.parent ~= selfId then
				if Unit:get_base_data().mType ~= nil then return 0 end
				if Unit.camp ~= selfCamp then return -1 end
			end
		end
	end

	return nil, UE.Vector3(x + size.x / 2 - 1, 0, y + size.z / 2 - 1)
end

-- 检查是否有空白的地板（可摆放家具）
function OBJDEF:chk_empty_floor(x, y, d, size, floor, angle, obj)
	if angle == nil then angle = 0 end

	local center = OBJDEF.pos2center({x = x, z = y}, size, angle)

	-- 全区域判定
	-- local center = { x = x, z = y }
	-- size.x = math.max(size.x, size.z)
	-- size.z = size.x

	local w, h = size.x - 0.01, size.z - 0.01
	if angle % 180 ~= 0 then w, h = h, w end
	local Units = libgame.FindUnitsInside("Rectangle", UE.Vector2(center.x, center.z), w, h)

	-- for i,v in ipairs(Units) do
	-- 	local Unit = self:find_unit(v)
	-- 	local UnitBase = Unit:get_base_data()
	-- 	print(Unit, UnitBase.mType, UnitBase.sType)
	-- end

	local selfCamp = self.Self.camp
	local selfId = self.Self.id
	-- 排除友方非建筑和自己
	for i=#Units,1,-1 do
		local Unit = self:find_unit(Units[i])
		if Unit then
			if Unit.id == obj or Unit.parent == selfId then
				table.remove(Units, i)
			elseif Unit.camp == selfCamp then
				local UnitBase = Unit:get_base_data()
				if UnitBase.mType == nil then
					table.remove(Units, i)
				end
			end
		end
	end

	local nUnits, area = #Units, math.ceil(size.x * size.z / 4)
	-- 阻挡数量必须等于占地大小，且必须满足地板条件
	if nUnits == area then
		for i,v in ipairs(Units) do
			local Unit = self:find_unit(v)
			if Unit == nil then return floor end

			local UnitBase = Unit:get_base_data()
			if UnitBase.sType == "WALL" or UnitBase.sType == "DOOR" then return -3 end
			if UnitBase.sType ~= "FLOOR" or  UnitBase.level < floor then return floor end
		end
	elseif nUnits > area then
		-- 有其他阻挡
		return -2
	elseif nUnits < area then
		-- 缺少地板
		return floor
	end

	return nil, UE.Vector3(x, 0, y)-- + size.x / 2 - 1, 0, y + size.z / 2 - 1)
end

-- 1 2 3
-- 4 5 6
-- 7 8 9
local WallCheckSort = {
	[1] = { 2, 4, 8, 6 },
	[2] = { 2, 4, 6, 8 },
	[3] = { 2, 6, 8, 4 },
	[4] = { 4, 8, 2, 6 },
	[6] = { 6, 2, 8, 4 },
	[7] = { 4, 8, 6, 2 },
	[8] = { 8, 6, 4, 2 },
	[9] = { 8, 6, 2, 4 },
}
local WallCheckFunc = {
	[4] = function (self, x, y)
		if self:has_gap_edge(x, y, x - 2, y)  then
			return UE.Vector3(x - 1, 0, y)
		end
	end,
	[6] = function (self, x, y)
		if self:has_gap_edge(x, y, x + 2, y) then
			return UE.Vector3(x + 1, 0, y)
		end
	end,
	[2] = function (self, x, y)
		if self:has_gap_edge(x, y, x, y - 2) then
			return UE.Vector3(x, 0, y - 1)
		end
	end,
	[8] = function (self, x, y)
		if self:has_gap_edge(x, y, x, y + 2) then
			return UE.Vector3(x, 0, y + 1)
		end
	end,
}
function OBJDEF:chk_pos4wall(x, y, d)
	if self:has_floor(x, y) then
		for _,v in ipairs(WallCheckSort[d]) do
			local ret = WallCheckFunc[v](self, x, y)
			if ret then return nil, ret end
		end
	end
	return -4
end

function OBJDEF:set_clock(clock)
	self.clock = clock
end

function OBJDEF:add_unit(Obj)
	self.Units[Obj.id] = Obj
end

function OBJDEF:find_unit(uid)
	return self.Units[uid]
end

function OBJDEF:get_unit(uid)
	local Units = self.Units
	local Unit = Units[uid]
	if Unit == nil then
		Unit = UnitDEF.new(uid)
		Units[uid] = Unit
	end
	return Unit
end

function OBJDEF:del_unit(uid)
	local Units = self.Units
	local Unit = Units[uid]
	if Unit then self:uncache_unit(Unit) end
	Units[uid] = nil
	return Unit
end

function OBJDEF:cache_grids(Grids, Unit, Size)
	for k,v in pairs(Grids) do
		if v.id == Unit.id then Grids[k] = nil end
	end

	local coord = Unit.coord
	local x, y = math.ceil(Size.x / 4) - 1, math.ceil(Size.z / 4) - 1
	if x < 0 then x = 0 end; if y < 0 then y = 0 end
	for i=-x,x,2 do
		for j =-y,y,2 do
			local buildIndex = self:coord2index(coord.x + i, coord.z + j)
			Grids[buildIndex] = Unit
		end
	end
end

-- 缓存地板、墙壁和家具位置
function OBJDEF:cache_unit(Unit)
	if not self.home then return end

	local coord = Unit.coord
	if coord == nil then return end
	local UnitBase = Unit:get_base_data()
	if UnitBase == nil or not UnitBase.building then return end

	local closedAreaDirty = false
	if UnitBase.mType == "BUILDING" then
		if UnitBase.sType == "FLOOR" then
			for k,v in pairs(self.Floors) do
				if v.id == Unit.id then
					self.Floors[k] = nil
				break end
			end
			self.Floors[self:coord2index(coord.x, coord.z)] = Unit
			closedAreaDirty = true

			if self.inited then set_grass(coord, false) end
		else
			for k,v in pairs(self.Walls) do
				if v.id == Unit.id then
					self.Walls[k] = nil
				break end
			end

			local key = self:key4wallobj(coord.x, coord.z, Unit.angle)
			self.Walls[key] = Unit
			closedAreaDirty = true
		end
	else
		local UnitTmpl = Unit:get_tmpl_data()
		self:cache_grids(self.Furnitures, Unit, UnitTmpl.size)
	end

	-- if closedAreaDirty then
	-- 	_G.next_action("/StageView", libgame.UpdateClosedArea)
	-- end
end

-- 清除地板、墙壁和家具位置
function OBJDEF:uncache_unit(Unit)
	if not self.home then return end

	local coord = Unit.coord
	if coord == nil then return end
	local UnitBase = Unit:get_base_data()
	if UnitBase == nil or not UnitBase.building then return end

	local closedAreaDirty = false
	if UnitBase.mType == "BUILDING" then
		if UnitBase.sType == "FLOOR" then
			for k,v in pairs(self.Floors) do
				if v.id == Unit.id then
					self.Floors[k] = nil
					closedAreaDirty = true
				break end
			end
			if self.inited then set_grass(coord, true) end
		else
			for k,v in pairs(self.Walls) do
				if v.id == Unit.id then
					self.Walls[k] = nil
					closedAreaDirty = true
				break end
			end
		end
	else
		for k,v in pairs(self.Furnitures) do
			if v.id == Unit.id then self.Furnitures[k] = nil end
		end
	end
	-- if closedAreaDirty then
	-- 	_G.next_action("/StageView", libgame.UpdateClosedArea)
	-- end
end

function OBJDEF:count_building_group(grp)
	local function count_buildings(Units, grp)
		local n = 0
		for _,v in pairs(Units) do
			local vBase = v:get_base_data()
			if vBase.group == grp then n = n + 1 end
		end
		return n
	end

	return count_buildings(self.Floors, grp)
		 + count_buildings(self.Walls, grp)
		 + count_buildings(self.Furnitures, grp)
end

-- 屋顶所在位置已更新
function OBJDEF:closed_area_updated()
	--print(cjson.encode(self.ClosedArea))
end

--刷新场景天气
function OBJDEF:update_weather(weatherID)
	local env = MAPLIB.get_env(weatherID)
	
	if env then
		libgame.UpdateWeather(env)
	else
		libunity.LogE("Cannot find Environment.[Id:{0}].\nForce use default env = 1.", weatherID)
		env = MAPLIB.get_env(1)
		libgame.UpdateWeather(env)
	end
end

function OBJDEF:exit()
	if NW.connected() then
		NW.send(NW.msg("MAP.CS.EXIT"):writeU64(self.id))
	else
		NW.broadcast("MAP.SC.EXIT", {})
	end
end
-- @
-- Network Data

function OBJDEF:read_units(nm, reader)
	local Objs = {}
	local n = nm:readU32()
	for i=1,n do
		local id = nm:readU32()
		local Unit = self:get_unit(id)
		local readfunc = Unit[reader]
		if readfunc == nil then
			readfunc = _G.DEF.Human[reader]
			-- libunity.LogE("{0}未知的读方法={1}", Unit, reader)
		end

		readfunc(Unit, nm)
		table.insert(Objs, Unit)

		self:cache_unit(Unit)

		if Unit.Pet then
			self:add_unit(Unit.Pet)
			if Unit.Pet.Form == nil then
				-- 新数据，需要加入变化列表
				table.insert(Objs, Unit.Pet)
			end
		end
	end
	return Objs
end

return OBJDEF
