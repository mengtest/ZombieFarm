--
-- @file    ui/guild/lc_mbmodifyguildbadge.lua
-- @author  shenbingkang
-- @date    2018-06-12 13:38:48
-- @desc    MBModifyGuildBadge
--

local self = ui.new()
local _ENV = self

local guildBadge
local CFG = config("guildlib")

local spSelected_SdIcon
local spSelected_PtIcon
local spSelected_BgColor
local spSelected_SdColor
local spSelected_PtColor

local function generate_icon_str()
	if guildBadge then
		return guildBadge:generate_guild_badage_str()
	end
	return ""
end

local function rfsh_guild_badge()
	local SubGuildIcon = Ref.SubMain.SubGuildIcon
	if guildBadge then
		guildBadge:show_bgcolor(SubGuildIcon.spGuildBadge)
		guildBadge:show_sdicon(SubGuildIcon.spGuildBadgeSd)
		guildBadge:show_sdcolor(SubGuildIcon.spGuildBadgeSd)
		guildBadge:show_pticon(SubGuildIcon.spGuildBadgePt)
		guildBadge:show_ptcolor(SubGuildIcon.spGuildBadgePt)
	end
end

local function build_shading_content_view()
	local SubShading = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubShading

	local iconList = CFG.get_badge_type_list("Shading")
	local GrpContent = SubShading.SubScroll.GrpContent
	GrpContent:dup(#iconList, function (i, Ent, isNew)
		ui.seticon(Ent.spIcon, iconList[i].icon)
	end)
end

local function build_pattern_content_view()
	local SubPattern = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubPattern

	local iconList = CFG.get_badge_type_list("Pattern")
	local GrpContent = SubPattern.SubScroll.GrpContent
	GrpContent:dup(#iconList, function (i, Ent, isNew)
		ui.seticon(Ent.spIcon, iconList[i].icon)
	end)
end

local function build_color_content_view()
	local SubContent = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent

	local bgColorList = CFG.get_color_map("Background")
	local GrpColors_BG = SubContent.SubBackground.GrpColors
	GrpColors_BG:dup(#bgColorList, function (i, Ent, isNew)
		Ent.spIcon.color = bgColorList[i]
	end)

	local sdColorList = CFG.get_color_map("Shading")
	local GrpColors_SD = SubContent.SubShading.GrpColors
	GrpColors_SD:dup(#sdColorList, function (i, Ent, isNew)
		Ent.spIcon.color = sdColorList[i]
	end)

	local ptColorList = CFG.get_color_map("Pattern")
	local GrpColors_PT = SubContent.SubPattern.GrpColors
	GrpColors_PT:dup(#ptColorList, function (i, Ent, isNew)
		Ent.spIcon.color = ptColorList[i]
	end)
end

local function build_all_guild_badge_view()
	local SubContents = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents
	build_shading_content_view()
	build_pattern_content_view()
	build_color_content_view()
end

local function force_select_shading_icon(go)
	if go == nil then
		local i = CFG.find_badge_icon_index("Shading", guildBadge.sdIconID)
		local GrpContent = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubShading.SubScroll.GrpContent
		local ent = GrpContent:find(i)
		if ent then
			go = ent.go
		end
	end

	libunity.SetParent(spSelected_SdIcon, go, false, -1)
	libunity.SetActive(spSelected_SdIcon, true)
end

local function force_select_pattern_icon(go)
	if go == nil then
		local i = CFG.find_badge_icon_index("Pattern", guildBadge.ptIconID)
		local GrpContent = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubPattern.SubScroll.GrpContent
		local ent = GrpContent:find(i)
		if ent then
			go = ent.go
		end
	end

	libunity.SetParent(spSelected_PtIcon, go, false, -1)
	libunity.SetActive(spSelected_PtIcon, true)
end

local function force_select_background_color(go)
	if go == nil then
		local SubContent = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent
		local ent = SubContent.SubBackground.GrpColors:find(guildBadge.bgColorID)
		if ent then
			go = ent.go
		end
	end

	libunity.SetParent(spSelected_BgColor, go, false, -1)
	libunity.SetActive(spSelected_BgColor, true)
end

local function force_select_shading_color(go)
	if go == nil then
		local SubContent = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent
		local ent = SubContent.SubShading.GrpColors:find(guildBadge.sdColorID)
		if ent then
			go = ent.go
		end
	end

	libunity.SetParent(spSelected_SdColor, go, false, -1)
	libunity.SetActive(spSelected_SdColor, true)
end

local function force_select_pattern_color(go)
	if go == nil then
		local SubContent = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent
		local ent = SubContent.SubPattern.GrpColors:find(guildBadge.ptColorID)
		if ent then
			go = ent.go
		end
	end

	libunity.SetParent(spSelected_PtColor, go, false, -1)
	libunity.SetActive(spSelected_PtColor, true)
end

local function rfsh_all_selected()
	force_select_shading_icon()
	force_select_pattern_icon()

	force_select_background_color()
	force_select_shading_color()
	force_select_pattern_color()
end

--!* [开始] 自动生成函数 *--

function on_submain_subguildicon_btnrandomicon_click(btn)
	guildBadge = _G.DEF.GuildBadge.random_badge()
	rfsh_guild_badge()
	rfsh_all_selected()
end

function on_submain_subguildicon_btnsave_click(btn)
	local newBadge = generate_icon_str()
	NW.GUILD.RequestModifyBadge(newBadge)
end

function on_submain_subguildicon_submodifyview_subtogs_tglshading_click(tgl)
	local SubShading = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubShading

	libugui.SetVisible(GO(tgl, "lbTypeName"), not tgl.value)
	libugui.SetVisible(SubShading.go, tgl.value)
end

function on_submain_subguildicon_submodifyview_subtogs_tglpattern_click(tgl)
	local SubPattern = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubPattern

	libugui.SetVisible(GO(tgl, "lbTypeName"), not tgl.value)
	libugui.SetVisible(SubPattern.go, tgl.value)
end

function on_submain_subguildicon_submodifyview_subtogs_tglcolor_click(tgl)
	local SubColor = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor

	libugui.SetVisible(GO(tgl, "lbTypeName"), not tgl.value)
	libugui.SetVisible(SubColor.go, tgl.value)
end

function on_submain_subguildicon_submodifyview_subtogs_tglempty_click(tgl)
end

function on_submain_subguildicon_submodifyview_subcontents_subshading_subscroll_grpcontent_entshading_click(btn)
	local SubGuildIcon = Ref.SubMain.SubGuildIcon
	local GrpContent = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubShading.SubScroll.GrpContent
	local i = GrpContent:getindex(btn)
	local iconList = CFG.get_badge_type_list("Shading")
	guildBadge:show_sdicon(SubGuildIcon.spGuildBadgeSd, iconList[i].badgeID)
	force_select_shading_icon(btn.go)
end

function on_submain_subguildicon_submodifyview_subcontents_subpattern_subscroll_grpcontent_entpattern_click(btn)
	local SubGuildIcon = Ref.SubMain.SubGuildIcon
	local GrpContent = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubPattern.SubScroll.GrpContent
	local i = GrpContent:getindex(btn)
	local iconList = CFG.get_badge_type_list("Pattern")
	guildBadge:show_pticon(SubGuildIcon.spGuildBadgePt, iconList[i].badgeID)
	force_select_pattern_icon(btn.go)
end

function on_submain_subguildicon_submodifyview_subcontents_subcolor_subscroll_subcontent_subbackground_grpcolors_entcolor_click(btn)
	local SubGuildIcon = Ref.SubMain.SubGuildIcon
	local SubContent = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent
	local i = SubContent.SubBackground.GrpColors:getindex(btn)
	guildBadge:show_bgcolor(SubGuildIcon.spGuildBadge, i)
	force_select_background_color(btn.go)
end

function on_submain_subguildicon_submodifyview_subcontents_subcolor_subscroll_subcontent_subshading_grpcolors_entcolor_click(btn)
	local SubGuildIcon = Ref.SubMain.SubGuildIcon
	local SubContent = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent
	local i = SubContent.SubShading.GrpColors:getindex(btn)
	guildBadge:show_sdcolor(SubGuildIcon.spGuildBadgeSd, i)
	force_select_shading_color(btn.go)
end

function on_submain_subguildicon_submodifyview_subcontents_subcolor_subscroll_subcontent_subpattern_grpcolors_entcolor_click(btn)
	local SubGuildIcon = Ref.SubMain.SubGuildIcon
	local SubContent = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent
	local i = SubContent.SubPattern.GrpColors:getindex(btn)
	guildBadge:show_ptcolor(SubGuildIcon.spGuildBadgePt, i)
	force_select_pattern_color(btn.go)
end

function on_submain_btnclose_click(btn)
	self:close()
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubShading.SubScroll.GrpContent)
	ui.group(Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubPattern.SubScroll.GrpContent)
	ui.group(Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent.SubBackground.GrpColors)
	ui.group(Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent.SubShading.GrpColors)
	ui.group(Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent.SubPattern.GrpColors)
	--!* [结束] 自动生成代码 *--

	build_all_guild_badge_view()
end

function init_logic()
	spSelected_SdIcon = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubShading.SubScroll.spSelected
	spSelected_PtIcon = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubPattern.SubScroll.spSelected
	spSelected_BgColor = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent.SubBackground.spSelected
	spSelected_SdColor = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent.SubShading.spSelected
	spSelected_PtColor = Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent.SubPattern.spSelected

	libunity.SetActive(spSelected_SdIcon, false)
	libunity.SetActive(spSelected_PtIcon, false)
	libunity.SetActive(spSelected_BgColor, false)
	libunity.SetActive(spSelected_SdColor, false)
	libunity.SetActive(spSelected_PtColor, false)

	if Context.badge then
		guildBadge = _G.DEF.GuildBadge.gen(Context.badge)
	else
		math.randomseed(os.date2secs())
		guildBadge = _G.DEF.GuildBadge.random_badge()
	end
	rfsh_guild_badge()
	rfsh_all_selected()

	Ref.SubMain.SubGuildIcon.SubModifyView.SubTogs.tglPattern.value = true
end

function show_view()
	
end

function on_recycle()
	libunity.SetParent(spSelected_SdIcon, Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubShading.SubScroll.go, true)
	libunity.SetParent(spSelected_PtIcon, Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubPattern.SubScroll.go, true)
	libunity.SetParent(spSelected_BgColor, Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent.SubBackground.go, true)
	libunity.SetParent(spSelected_SdColor, Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent.SubShading.go, true)
	libunity.SetParent(spSelected_PtColor, Ref.SubMain.SubGuildIcon.SubModifyView.SubContents.SubColor.SubScroll.SubContent.SubPattern.go, true)

	libunity.SetActive(spSelected_SdIcon, true)
	libunity.SetActive(spSelected_PtIcon, true)
	libunity.SetActive(spSelected_BgColor, true)
	libunity.SetActive(spSelected_SdColor, true)
	libunity.SetActive(spSelected_PtColor, true)

	Ref.SubMain.SubGuildIcon.SubModifyView.SubTogs.tglEmpty.value = true
end

Handlers = {
	["GUILD.SC.GUILD_CHANGE_ICON"] = function(err)
		if err == nil then
			self:close()
		end
	end,
}

return self

