--
-- @file    ui/com/lc_wndtopbar.lua
-- @author  xingweizhen
-- @date    2018-04-11 16:04:00
-- @desc    WNDTopBar
--

local self = ui.new()
setfenv(1, self)

local function forceUpdateSelected(go)
	libunity.SetParent(self.spSelected, go, false, 0)
	libunity.SetActive(self.spSelected, true)
end

local function update_all_entmenu_sprite()
	local cnt = #self.MenuList
	for i=1,cnt do
		local Ent = Ref.GrpMenu:find(i)
		libugui.SetColor(Ent.spIcon, self.currIndex == i and "#c9c9c9" or "#69625e")
	end
end

local function rfsh_role_hp(id)
	if id == DY_DATA.Self.id then
		local Ent, isNew = Ref.SubBTM.GrpHealthy:gen(1)
		if isNew then
			Ent.spFill:SetSprite("Common/ico_com_001")
			Ent.spFill:SetNativeSize()
			Ent.spFill.color = "#FF0000"

			Ent.spIcon.overrideSprite = Ent.spFill.overrideSprite
			Ent.spIcon:SetNativeSize()
		end

		local value, limit = libgame.GetUnitHealth(id)
		if value == nil or limit == nil then
			value, limit = DY_DATA.Self.hp, DY_DATA.Self.Attr.hp
		end

		Ent.lbValue.text = value
		Ent.spFill.fillAmount = value / limit
	end
end

local function rfsh_role_healthy()
	local Self = DY_DATA:get_self()

	local function show_healthy_view(index, Data)
		local Ent, isNew = Ref.SubBTM.GrpHealthy:gen(index)
		if isNew then
			Data:show_ico(Ent.spFill)
			Ent.spFill:SetNativeSize()

			Ent.spIcon.overrideSprite = Ent.spFill.overrideSprite
			Ent.spIcon:SetNativeSize()
		end

		Ent.lbValue.text = Data.amount
		Ent.spFill.fillAmount = Data.amount / 100
	end

	rfsh_role_hp(DY_DATA.Self.id)
	show_healthy_view(2, Self.Hunger)
	show_healthy_view(3, Self.Thirsty)
end

local function rfsh_player_assets()
	local Player = DY_DATA:get_player()
	local Assets = { }
	if type(Context.AssetBar) == "table" then
		for i,v in ipairs(Context.AssetBar) do
			local vType = type(v)
			if vType == "string" then
				table.insert(Assets, Player.Assets[CVar.ASSET_TYPE[v]])
			elseif vType == "number" then
				table.insert(Assets, Player.Assets[v])
			end
		end
	else
	 	table.insert(Assets, Player.Assets[CVar.ASSET_TYPE.Gold])
	end

	Ref.SubTOP.GrpAssets:dup(#Assets, function (i, Ent, isNew)
		local Asset = Assets[i]
		local AssetBase = Asset:get_base_data()
		ui.seticon(Ent.spIcon, AssetBase.icon)
		Ent.lbAmount.text = Asset.amount
	end)
end

local function set_wnd_visible(Wnd, visible)
	libugui.SetVisible(Wnd.go, visible)
	if Wnd.Secondary then
		libugui.SetVisible(Wnd.Secondary.go, visible)
	end

	if visible then
		NW.broadcast("CLIENT.SC.TOPBAR_WND_SHOW", Wnd)
	else
		NW.broadcast("CLIENT.SC.TOPBAR_WND_HIDE", Wnd)
	end
end

function rfsh_topbar()
	libunity.SetActive(Ref.SubTOP.go, Context.AssetBar)
	libunity.SetActive(Ref.SubBTM.go, Context.HealthyBar)
	rfsh_player_assets()
end

--!* [开始] 自动生成函数 *--

function on_wndclose_click(btn)
	function func_close()
		self:close()
	end

	local CurrMenu = MenuList[currIndex]
	local CurrWnd = ui.find(CurrMenu.name)

	if CurrWnd and CurrWnd.on_wnd_switch_off then
		CurrWnd.on_wnd_switch_off(func_close)
		return
	end

	func_close()
end

function on_grpmenu_entmenu_click(btn)
	local CurrMenu = MenuList[currIndex]
	local CurrWnd = ui.find(CurrMenu.name)

	function func_switch_ent()
		local index = Ref.GrpMenu:getindex(btn)
		local NextMenu = MenuList[index]
		forceUpdateSelected(btn)
		libugui.SetColor(GO(btn, "spIcon"),  "#c9c9c9")
		if index == currIndex then return end

		local NextWnd = ui.find(NextMenu.name)
		if CurrMenu.name ~= NextMenu.name then
			set_wnd_visible(CurrWnd, false)
		end
		if CurrWnd.Secondary then
			CurrWnd.Secondary:close(true)
			CurrWnd.Secondary = nil
		end

		if NextWnd then
			set_wnd_visible(NextWnd, true)
			local WndContext = NextMenu.Context
			if WndContext then
				NextWnd.Context = WndContext
				if WndContext.wndName then
					WndContext.Primary = NextWnd
					ui.show("UI/" .. WndContext.wndName, ui.DEPTH_WND + 1, WndContext)
				end
			end
			Context = NextWnd.StatusBar
			rfsh_topbar()
		else
			NextWnd = ui.show("UI/" .. NextMenu.name, ui.DEPTH_WND, NextMenu.Context)
		end

		NW.broadcast("CLIENT.SC.TOPBAR_SWITCH", NextWnd)

		self.currIndex = index
		update_all_entmenu_sprite()
	end

	if CurrWnd.on_wnd_switch_off then
		CurrWnd.on_wnd_switch_off(func_switch_ent)
		return
	end

	func_switch_ent()
end

function on_subtop_grpassets_entasset_btnadd_click(btn)

end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.GrpMenu)
	ui.group(Ref.SubTOP.GrpAssets)
	ui.group(Ref.SubBTM.GrpHealthy)
	--!* [结束] 自动生成代码 *--

	libugui.SetInteractable(Ref.go, true)
end

function init_logic()
	self.spSelected = Ref.spSelected
	libunity.SetActive(self.spSelected, false)

	CTRL.subscribe("HEALTH_CHANGED", rfsh_role_hp)

	rfsh_role_hp(DY_DATA.Self.id)
	rfsh_role_healthy()

	rfsh_topbar()

	libunity.SetActive(Ref.spMenuBg, Context.Menu)
	libunity.SetActive(Ref.GrpMenu.go, Context.Menu)

	if Context.Menu then
		local EquipMenu = {
			icon = "CommonIcon/ico_main_001", title = TEXT.S_Inventory, name = "WNDPackage",
			Context = { wndName = "WNDEquipBag" },
		}
		local CraftMenu = { icon = "CommonIcon/ico_main_022", title = TEXT["n.craft"], name = "WNDCraft", }
		self.MenuList = { EquipMenu }
		local guide = _G.PKG["guide/api"].load(0) or -1
		if guide == 0 or guide > 3 then
			table.insert(self.MenuList, CraftMenu)
		end

		local defaultIndex = #MenuList

		if type(Context.Menu) == "table" then
			table.insert(MenuList, Context.Menu)
			currIndex = #MenuList
		else
			currIndex = Context.Menu
		end

		Ref.GrpMenu:dup(#MenuList, function (i, Ent, isNew)
			local Menu = MenuList[i]
			Ent.spIcon:SetSprite(Menu.icon)

			if i > defaultIndex then
				if i == currIndex then
					forceUpdateSelected(Ent.go)
					libugui.SetAnchor(Ent.go,0.5,1,0.5,1)
					libugui.SetAnchoredPos(Ent.go, -3, -130)
					libugui.SetColor(Ent.spIcon, "#c9c9c9")
				else

					libugui.SetAnchor(Ent.go,0.5,0,0.5,0)
					local  realindex = i > currIndex and i-1 or i
					libugui.SetAnchoredPos(Ent.go, -3, 145 * (realindex - 1))
					libugui.SetColor(Ent.spIcon, "#69625e")
				end
			else
				libugui.SetAnchor(Ent.go,0.5,0,0.5,0)
				if i == currIndex then
					forceUpdateSelected(Ent.go)
					libugui.SetColor(Ent.spIcon, "#c9c9c9")
				else
					libugui.SetColor(Ent.spIcon, "#69625e")
				end
				libugui.SetAnchoredPos(Ent.go, -3, 145 * (i - 1))
			end

		end)
	end
end

function show_view()
	self.Wnd:set_close(function () self:close(true) end)

	local go = UE.GameObject.FindGameObjectWithTag("MainCamera")
	libunity.SetEnable(GO(go, nil, "Camera"), false)
end

function on_recycle()
	libunity.SetParent(self.spSelected, Ref.go, true, -1)
	libunity.SetActive(self.spSelected, true)

	if MenuList then
		for i,v in ipairs(MenuList) do ui.close(v.name, true) end
	else
		self.Wnd:close(true)
	end

	libugui.AllTogglesOff(Ref.GrpMenu.go)

	CTRL.unsubscribe("HEALTH_CHANGED", rfsh_role_hp)

	local go = UE.GameObject.FindGameObjectWithTag("MainCamera")
	libunity.SetEnable(GO(go, nil, "Camera"), true)
end

Handlers = {
	["ROLE.SC.GET_ROLE_INFO"] = rfsh_role_healthy,
	["PLAYER.SC.ROLE_ASSET_GET"] = rfsh_player_assets,
}

return self

