--
-- @file    ui/social/lc_wnddlgoptions.lua
-- @author  xingweizhen
-- @date    2018-06-12 10:00:49
-- @desc    WNDDlgOptions
--

local self = ui.new()
local _ENV = self

local OPTION_PANEL_DELAY_TIME = 0.4
local OPTION_PANEL_FADEIN_TIME = 0.3

self.fullScreen = true

local function fade_in_grpoptions()
	libugui.DOTween("Alpha", Ref.SubOptions.go, 0, 1, { duration = OPTION_PANEL_FADEIN_TIME, })
end

--!* [开始] 自动生成函数 *--

function on_suboptions_grpoptions_entopt_click(btn)
	local Opt = Context.Dlg.Params[ui.index(btn)]

	if #Opt.UIArgs == 0 then
		local nm = NW.gamemsg("SUB_BATTLE.CS.OBJ_TALK_NPC")
		NW.send(nm:writeU32(Context.obj):writeU32(Opt.id):writeString(""))
	else
		self:close(true)
		config("npclib").gotoui(Context.obj, Opt.UIArgs)
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubOptions.GrpOptions)
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	local Wnd = ui.find("FRMExplore")
	if Wnd then Wnd.set_visible(false) end

	local DlgData = Context.Dlg
	local Obj = CTRL.get_obj(Context.obj)

	local SubMain = Ref.SubMain
	libugui.SetAlpha(Ref.SubOptions.go, 0)

	SubMain.lbName.text = Obj.Form.View.name

	local Util = _G.PKG["ui/util"]
	local Opts = DlgData.Params
	Ref.SubOptions.GrpOptions:dup(#Opts, function (i, Ent, isNew)
		if isNew then
			Util.flex_itement(Ent, "SubItem")
		end
		local Opt = Opts[i]
		Ent.lbOpt.text = Opts[i].option

		local enabled = true

		local ReqItem
		for i,v in ipairs(Opt.Conds) do
			if v.type == "checkItem" then
				ReqItem = _G.DEF.Item.gen(v.Params[1])
			break end
		end
		libunity.SetActive(GO(Ent.SubItem.go, "FlexItem="), ReqItem ~= nil)
		if ReqItem then
			ReqItem:show_view(Ent.SubItem)
			local nOwn = DY_DATA:nget_item(ReqItem.dat)
			Ent.SubItem.lbAmount.text = string.own_needs(nOwn, ReqItem.amount)
			enabled = nOwn >= ReqItem.amount
			Ent.btn.interactable = enabled
		end

		Ent.lbOpt.color = enabled and "#C5C5C5" or "#808080"

		libunity.SetActive(Ent.spLine, i ~= #Opts)
	end)

	if DlgData.content == nil then
		SubMain.lbContent.text = nil
		libunity.SetActive(SubMain.go, false)
		libunity.SetActive(Ref.btnEmptyClose, true)
		fade_in_grpoptions()
	else
		libunity.SetActive(SubMain.go, true)
		libunity.SetActive(Ref.btnEmptyClose, false)
		SubMain.lbContent.text = DlgData.content
		libunity.Invoke(Ref.go, OPTION_PANEL_DELAY_TIME, function()
			fade_in_grpoptions()
		end)
	end
end

function show_view()

end

function on_recycle()
	local Wnd = ui.find("FRMExplore")
	if Wnd then Wnd.set_visible(true) end
	libgame.UnitBreak(0)
end

Handlers = {
	["SUB_BATTLE.SC.OBJ_TALK_NPC"] = function (Ret)
		if Ret.err == nil then
			self:close(true)
		end
	end
}

return self

