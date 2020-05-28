--
-- @file    ui/guild/lc_mbmodifyguildinfo.lua
-- @author  shenbingkang
-- @date    2018-06-08 11:44:22
-- @desc    MBModifyGuildInfo
--

local self = ui.new()
local _ENV = self

local guildBadge

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

local function rfsh_content_view()
	local SubMain = Ref.SubMain

	SubMain.lbTitle.text = Context.title

	local showType = Context.showType
	libunity.SetActive(SubMain.SubGuildName.go, (showType & 1) ~= 0)
	libunity.SetActive(SubMain.SubGuildNotice.go, (showType & 2) ~= 0)
	libunity.SetActive(SubMain.SubGuildIcon.go, (showType & 4) ~= 0)

	if Context.cost then
		libugui.SetVisible(SubMain.SubOp.SubAmount.go, true)
		SubMain.SubOp.SubAmount.lbAmount.text = Context.cost
	else
		libugui.SetVisible(SubMain.SubOp.SubAmount.go, false)
	end

end

--!* [开始] 自动生成函数 *--

function on_submain_subguildname_inpguildname_submit(inp, text)
	
end

function on_submain_subguildnotice_inpguildnotice_submit(inp, text)
	
end

function on_submain_subguildicon_spguildbadge_click(btn)

end

function on_submain_subguildicon_btneidticon_click(btn)
	ui.show("UI/MBModifyGuildBadge", 0, 
		{ title = Context.title, modifyType = Context.modifyType, showType = Context.showType, 
		 cost = Context.cost,
		 badge = generate_icon_str(),})
	self:close()
end

function on_submain_subop_btnconfirm_click(btn)
	local SubMain = Ref.SubMain

	if Context.modifyType == 1 then
		NW.GUILD.RequestCreateGuild(
			SubMain.SubGuildName.inpGuildName.text,
			SubMain.SubGuildNotice.inpGuildNotice.text,
			generate_icon_str())
	elseif Context.modifyType == 2 then
		NW.GUILD.RequestModifyGuildNotice(SubMain.SubGuildNotice.inpGuildNotice.text)
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	rfsh_content_view()
	if Context.badge then
		guildBadge = _G.DEF.GuildBadge.gen(Context.badge)
	else
		math.randomseed(os.date2secs())
		guildBadge = _G.DEF.GuildBadge.random_badge()
	end
	rfsh_guild_badge()
end

function show_view()
	
end

function on_recycle()
	
end

Handlers = {
	["GUILD.SC.CREATE_GUILD"] = function (err)
		if err == nil then
			self:close()
		end
	end,
	["GUILD.SC.GUILD_CHANGE_DESC"] = function (ret)
		if ret then
			self:close()
		end
	end,
}

return self

