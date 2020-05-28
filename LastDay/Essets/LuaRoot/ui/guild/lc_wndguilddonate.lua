--
-- @file    ui/guild/lc_wndguilddonate.lua
-- @author  shenbingkang
-- @date    2018-06-13 17:49:18
-- @desc    WNDGuildDonate
--

local self = ui.new()
local _ENV = self

local function rfsh_clan_building_view(buildingInfoList)
	self.buildingInfoList = buildingInfoList
	local GrpContent = Ref.SubMain.SubDonateView.SubScroll.GrpContent
	local cfg = config("guildlib")

	GrpContent:dup(#buildingInfoList, function (i, Ent, isNew)
		local buildingInfo = buildingInfoList[i]
		Ent.lbLevel.text = string.format(TEXT.fmtLv, buildingInfo.buildingLevel)
		local baseInfo, extInfo = cfg.get_building_info(buildingInfo.buildingID ,buildingInfo.buildingLevel)
		Ent.lbName.text = baseInfo.name
		Ent.lbInfo.text = baseInfo.desc
		local expPct = 1
		if extInfo.nextLevelExp ~= 0 then
			expPct = buildingInfo.buildingExp / extInfo.nextLevelExp
		end
		Ent.barExp.value = expPct
	end)
end

local function rfsh_donate_residues()
	local maxCnt = CVar.GUILD.DonateNum
	local SubNPCInfo = Ref.SubMain.SubNPCInfo
	SubNPCInfo.lbResidues.text = string.format(TEXT.fmtResiduesCnt, (maxCnt - DY_DATA.MyGuildInfo.donateCnt), maxCnt)
end

local function rfsh_npc_info()
	local Obj = CTRL.get_obj(Context.obj)
	local npcBaseInfo = Obj:get_base_data()
	local SubNPCInfo = Ref.SubMain.SubNPCInfo
	SubNPCInfo.lbNpcName.text = npcBaseInfo.name
	SubNPCInfo.lbNpcInfo.text = npcBaseInfo.desc
	--todo:npc头像
end

local function request_get_building_info()
	NW.GUILD.RequestGetBuildingInfo()
end

--!* [开始] 自动生成函数 *--

function on_submain_subnpcinfo_btndonaterank_click(btn)
	ui.show("UI/MBGuildDonateRank", 0)
end

function on_submain_subdonateview_subscroll_grpcontent_entcontribution_btndonate_click(btn)
	local GrpContent = Ref.SubMain.SubDonateView.SubScroll.GrpContent
	local index = GrpContent:getindex(btn.transform.parent)
	local buildingInfo = self.buildingInfoList[index]
	if buildingInfo then
		ui.show("UI/MBGuildDonate", 0, { buildingInfo = buildingInfo })
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubDonateView.SubScroll.GrpContent)
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	NW.GUILD.RequestGetMyGuildInfo()
	rfsh_npc_info()
	request_get_building_info()
end

function show_view()
	
end

function on_recycle()
	
end

Handlers = {
	["GUILD.SC.GET_BUILDING_INFO"] = rfsh_clan_building_view,
	["GUILD.SC.GUILD_DONATE"] = function (ret)
		if ret then
			rfsh_donate_residues()
			request_get_building_info()
		end
	end,
	["GUILD.SC.GUILD_MY_INFO"] = rfsh_donate_residues,
}


return self

