--
-- @file    ui/guild/lc_mbguildbuffmenu.lua
-- @author  shenbingkang
-- @date    2018-06-14 20:11:56
-- @desc    MBGuildBuffMenu
--

local self = ui.new()
local _ENV = self

local function rfsh_buff_menu()
	local buffMenuList = self.CFG.get_guild_buff_menu_list()
	local GrpMenuList = Ref.SubMain.SubMenuView.GrpMenuList

	GrpMenuList:dup(#buffMenuList, function (i, Ent, isNew)
		ui.group(Ent.GrpBuffIcon)
		Ent.lbLevel.text = string.format(TEXT.fmtGuildBuffBuildingLevel, i)
		local buffLevelMenuList = buffMenuList[i]

		Ent.GrpBuffIcon:dup(#buffLevelMenuList, function (idx, EntBuff, isNewIcon)
			UTIL.flex_itement(EntBuff, "SubItem", 0)
			libugui.SetVisible(EntBuff.SubItem.lbAmount, false)
			
			local buffData = buffLevelMenuList[idx]
			local Item = _G.DEF.Item.new(buffData.effect, 1)
			local baseItemInfo = Item:get_base_data()
			show_item_view(Item, EntBuff.SubItem)
			EntBuff.lbBuffName.text = buffData.name
			EntBuff.lbBuffDesc.text = buffData.desc
		end)

		libugui.RebuildLayout(Ent.go)
	end)

	libugui.RebuildLayout(GrpMenuList.go)
end

--!* [开始] 自动生成函数 *--
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubMenuView.GrpMenuList)
	--!* [结束] 自动生成代码 *--
	self.CFG = config("guildlib")

	self.UTIL = _G.PKG["ui/util"]
	self.show_item_view = UTIL.show_item_view
end

function init_logic()
	rfsh_buff_menu()
end

function show_view()
	
end

function on_recycle()
	
end

return self

