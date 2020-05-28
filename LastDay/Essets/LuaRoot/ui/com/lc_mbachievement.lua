--
-- @file    ui/com/lc_mbachievement.lua
-- @author  xingweizhen
-- @date    2018-06-27 15:50:51
-- @desc    MBAchievement
--

local self = ui.new()
local _ENV = self

local function enable_sub(subName)
	for k,v in pairs(Ref.SubMain.SubTarget) do
		if type(v) == "table" then
			libunity.SetActive(v.go, k == subName)
		end
	end
end

local function show_building_view(buildId)
	local SubBuilding = Ref.SubMain.SubTarget.SubBuilding
	local Data = config("unitlib").get_dat(buildId)
	ui.seticon(SubBuilding.spIcon, Data.icon)

	Ref.SubMain.lbTitle.text = Data.name
	Ref.SubMain.lbTips.text = string.format(TEXT.fmtAchieveBuilding, Data.name)
end

--!* [开始] 自动生成函数 *--

function on_submain_subop_btnconfirm_click(btn)
	_G.UI.MBox.on_btncancel_click()
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	local Achieve = config("achievelib").get_dat(Context.dat)
	local tarType = Achieve.Target.type
	if tarType == "BuildingCompleted" then
		enable_sub("SubBuilding")
		show_building_view(tonumber(Achieve.Target.Params[1]))
	end
end

function show_view()

end

function on_recycle()

end

return self

