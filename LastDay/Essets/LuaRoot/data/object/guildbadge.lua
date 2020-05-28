--
-- @file    data/object/guildbadge.lua
-- @anthor  shenbingkang
-- @date    2018-06-11 15:59:30
-- @desc    描述
--

local OBJDEF = {}
OBJDEF.__index = OBJDEF
OBJDEF.__tostring = function (self)
	return string.format("%d#%d#%d#%d#%d",
		self.sdIconID, self.ptIconID, self.bgColorID, self.sdColorID, self.ptColorID)
end

local cfg = config("guildlib")

--"底图ID#图标ID#背景色Id#底图颜色ID#图标色ID"
function OBJDEF.gen(Data)
	if Data == nil then Data = "" end
	local datas = Data:splitn('#')
	local bgColorID = datas[3] and datas[3] or 1
	local sdIconID = datas[1] and datas[1] or 101
	local sdColorID = datas[4] and datas[4] or 1
	local ptIconID = datas[2] and datas[2] or 201
	local ptColorID = datas[5] and datas[5] or 1

	debug.print(string.format("%d#%d#%d#%d#%d",
		sdIconID, ptIconID, bgColorID, sdColorID, ptColorID))

	return OBJDEF.new(bgColorID, sdIconID, sdColorID, ptIconID, ptColorID)
end

function OBJDEF.new(bgColorID, sdIconID, sdColorID, ptIconID, ptColorID)
	local self = { 
		bgColorID = bgColorID, --背景色ID
		sdIconID = sdIconID,--底纹图标ID
		sdColorID = sdColorID,--底纹颜色ID
		ptIconID = ptIconID,--徽章图标ID
		ptColorID = ptColorID,--徽章颜色ID
	}
	return setmetatable(self, OBJDEF)
end

function OBJDEF.random_badge()
	cfg.get_color_map("Background")
	local bgColorID = math.random(#cfg.get_color_map("Background"))

	local shadingIconList = cfg.get_badge_type_list("Shading")
	local sdIconID = math.random(#shadingIconList)
	sdIconID = shadingIconList[sdIconID].badgeID
	local sdColorID = math.random(#cfg.get_color_map("Shading"))

	local patternIconList = cfg.get_badge_type_list("Pattern")
	local ptIconID = math.random(#patternIconList)
	ptIconID = patternIconList[ptIconID].badgeID
	local ptColorID = math.random(#cfg.get_color_map("Pattern"))

	return OBJDEF.new(bgColorID, sdIconID, sdColorID, ptIconID, ptColorID)
end

--获取公会徽章信息
function OBJDEF:get_guild_badge_info()
	local badge = {}
	badge.bgColor = cfg.get_color_map("Background")[self.bgColorID]
	badge.sdIcon = cfg.get_badge_dat(self.sdIconID).icon
	badge.sdColor = cfg.get_color_map("Shading")[self.sdColorID]
	badge.ptIcon = cfg.get_badge_dat(self.ptIconID).icon
	badge.ptColor = cfg.get_color_map("Pattern")[self.ptColorID]
	return badge
end

--生成公会徽章字符串
function OBJDEF:generate_guild_badage_str()
	return string.format("%d#%d#%d#%d#%d",
		self.sdIconID, self.ptIconID, self.bgColorID, self.sdColorID, self.ptColorID)
end

function OBJDEF:show_bgcolor(spBG, bgColorID)
	if bgColorID then
		self.bgColorID = bgColorID
	end
	spBG.color = cfg.get_color_map("Background")[self.bgColorID]
end

function OBJDEF:show_sdicon(spSD, sdIconID)
	if sdIconID then
		self.sdIconID = sdIconID
	end
	local icon = cfg.get_badge_dat(self.sdIconID).icon
	ui.seticon(spSD, icon)
end

function OBJDEF:show_sdcolor(spSD, sdColorID)
	if sdColorID then
		self.sdColorID = sdColorID
	end
	spSD.color = cfg.get_color_map("Shading")[self.sdColorID]
end

function OBJDEF:show_pticon(spPT, ptIconID)
	if ptIconID then
		self.ptIconID = ptIconID
	end
	local icon = cfg.get_badge_dat(self.ptIconID).icon
	ui.seticon(spPT, icon)
end

function OBJDEF:show_ptcolor(spPT, ptColorID)
	if ptColorID then
		self.ptColorID = ptColorID
	end
	spPT.color = cfg.get_color_map("Pattern")[self.ptColorID]
end

return OBJDEF
