--
-- @file    ui/com/lc_mboptionl.lua
-- @author  Administrator
-- @date    2018-10-16 16:57:24
-- @desc    MBOption
--

local self = ui.new()
local _ENV = self

local function rfsh_content_view()
	Ref.lbTitle.text = Context.subTitle

	if Context.context then
		Ref.lbContent.text = Context.context
		libunity.SetActive(Ref.lbContent,true)
	else
		libunity.SetActive(Ref.lbContent,false)
	end

	Ref.SubMain.GrpMenu:dup(#Context.MenuArr, function (i, Ent, isNew)
		local menu = Context.MenuArr[i]
		Ent.lbText.text = menu.name
		Ent.spIcon:SetSprite(menu.icon)
			
	end)

end
--!* [开始] 自动生成函数 *--

function on_submain_grpmenu_entmenu_click(btn)
	local index = Ref.SubMain.GrpMenu:getindex(btn)

	local menu = Context.MenuArr[index]

	if menu and menu.callback then
		menu.callback(menu.params)
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.GrpMenu)
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	rfsh_content_view()
end

function show_view()
	
end

function on_recycle()
	
end

return self

