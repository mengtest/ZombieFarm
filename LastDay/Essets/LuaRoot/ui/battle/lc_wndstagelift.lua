--
-- @file    ui/battle/lc_wndstagelift.lua
-- @author  xingweizhen
-- @date    2018-01-29 10:51:52
-- @desc    WNDStageLift
--

local self = ui.new()
setfenv(1, self)

local function rfsh_elevator_view()
	local Info = Context

	Ref.SubElevator.lbCurFloor.text = Info.floor

	self.Dsts = table.dup(Info.Dsts)
	table.insert(self.Dsts,  {
			id = Info.id, floor = Info.floor,
		})
	table.sort(self.Dsts, function(a, b)
			return a.floor < b.floor
		end)

	Ref.SubElevator.GrpLayers:dup(#self.Dsts, function (i, Ent, isNew)
		local Dst = self.Dsts[i]
		Ent.lbLayer.text = Dst.floor
		Ent.lbLayer.color = "#E7A21D"
		libugui.SetInteractable(Ent.go, true)
		if Dst.id == Context.id then
			libugui.SetInteractable(Ent.go, false)
			Ent.lbLayer.color = "#432816"
			libunity.SetParent(self.spSelected, Ent.go, false, 0)
			libunity.SetActive(self.spSelected, true)
		end
		--todo:需要服务器新增不可到达层的数据
		libunity.SetActive(Ent.spMask.go, false)
	end)

	libugui.RebuildLayout(Ref.SubElevator.go)
end

--!* [开始] 自动生成函数 *--

function on_subelevator_grplayers_entlayer_click(btn)
	local index = Ref.SubElevator.GrpLayers:getindex(btn)
	local Dst = self.Dsts[index]
	local nm = NW.gamemsg("TRANSPORT.CS.TRANSPORT")	
	NW.send(nm:writeU32(Context.id):writeU32(Dst.id))
end

function on_substairs_btnstairs_click(btn)
	local Dst = Context.Dsts[1]
	local nm = NW.gamemsg("TRANSPORT.CS.TRANSPORT")	
	NW.send(nm:writeU32(Context.id):writeU32(Dst.id))
end
--!* [结束] 自动生成函数  *--

--function on_submain_sublift_subview_grplayers_entlayer_click(btn)
--	local Dst = Context.Dsts[ui.index(btn)]
--	local nm = NW.gamemsg("TRANSPORT.CS.TRANSPORT")	
--	NW.send(nm:writeU32(Context.id):writeU32(Dst.id))
--end

function init_view()
	ui.group(Ref.SubElevator.GrpLayers)
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	self.spSelected = Ref.SubElevator.spSelected
	libunity.SetActive(self.spSelected, false)

	local objPlayer = libgame.GetViewOfObj(0).transform

	if Context.type == 1 then
		libunity.SetActive(Ref.SubElevator.go, true)
		libunity.SetActive(Ref.SubStairs.go, false)
		rfsh_elevator_view()
		libugui.Follow(Ref.SubElevator.go, GO(objPlayer, "HUD"))
	elseif Context.type == 2 then
		libunity.SetActive(Ref.SubElevator.go, false)
		libunity.SetActive(Ref.SubStairs.go, true)
		libugui.Follow(Ref.SubStairs.go, GO(objPlayer, "HUD"))
	end
end

function show_view()
	
end

function on_recycle()
	libunity.SetParent(self.spSelected, Ref.SubElevator.go, true)
	libunity.SetActive(self.spSelected, true)
end

return self

