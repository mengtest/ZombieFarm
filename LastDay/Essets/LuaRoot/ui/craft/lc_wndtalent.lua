--
-- @file    ui/craft/lc_wndtalent.lua
-- @author  xingweizhen
-- @date    2018-05-07 13:06:45
-- @desc    WNDTalent
--

local self = ui.new()
local _ENV = self
self.StatusBar = {
	AssetBar = true,
	HealthyBar = true,
}

local function scroll_to_ent(row)
	local scroll = Ref.SubTree.go:GetComponent("ScrollRect")
	if row > 0 then
		local Formulas = DY_DATA:get_formula_list(2)
		local nFormula = #Formulas

		local viewSize = libugui.GetRectSize(scroll.viewport).y
		local contentSize = libugui.GetRectSize(scroll.content).y
		local cell, padding = 136, 0
		local line = cell + padding
		local totalHeight = contentSize - viewSize

		local offset = 20 + (row - 1) * line + cell
		pos = 1 - offset / totalHeight
	else
		pos = 1
	end
	scroll.verticalNormalizedPosition = pos
end

local function get_selected_group()
	local tgl = libugui.GetTogglesOn(Ref.GrpTabs.go)[1]
	if tgl then
		return FormulaLIB.TalentGrps[ui.index(tgl)]
	end
end

local function get_selected_group_talents()
	local Group = get_selected_group()
	if Group then
		return FormulaLIB.get_talents(Group.id), Group
	end
end

local function get_selected_talent()
	local Talents = get_selected_group_talents()
	if Talents then
		local tgl = libugui.GetTogglesOn(Ref.SubTree.SubView.GrpTalents.go)[1]
		if tgl then
			return Talents[ui.index(tgl)]
		end
	end
end

local function rfsh_talent_points()
	local nPoint = DY_DATA:nget_asset("Talent")
	Ref.SubPoints.lbPoint.text = string.format("%d/%d", nPoint, nPoint + (DY_DATA.Talents.points or 0))
end

-- 刷新天赋树列表
local function rfsh_talent_tree(reset)
	local offsetY = 20
	local Cell = { x = 136, y = 136, }
	local maxY = 0
	local Talents, Group = get_selected_group_talents()
	local GrpTalents = Ref.SubTree.SubView.GrpTalents
	if reset then
		libugui.AllTogglesOff(GrpTalents.go)
	end

	local groupLocked = Group.points > (DY_DATA.Talents.points or 0)
	libunity.SetActive(Ref.SubTree.SubView.SubLock.go, groupLocked)
	if groupLocked then
		Ref.SubTree.SubView.SubLock.lbLock.text = string.format(TEXT.tipTalentGroupLocked, Group.points)
	end

	GrpTalents:dup(#Talents, function (i, Ent, isNew)
		local Talent = Talents[i]
		ui.seticon(Ent.spIcon, Talent.icon)

		local talentStatus = DY_DATA:get_talent_status(Talent)
		if talentStatus then
			-- 可制作
			Ent.spFrame.grayscale = false
			Ent.spFrame.color = "#FFFFFF"
			Ent.spIcon.color = "#FFFFFF"
			--Ent.spIcon.grayscale = false
		elseif talentStatus == false then
			-- 已激活，未解锁
			Ent.spFrame.grayscale = true
			Ent.spFrame.color = "#808080"
			Ent.spIcon.color = "#FFFFFF"
			--Ent.spIcon.grayscale = false
		else
			-- 未激活
			Ent.spFrame.grayscale = true
			Ent.spFrame.color = "#808080"
			Ent.spIcon.color = "#808080"
			--Ent.spIcon.grayscale = true
		end

		local Pos = Talent.Pos
		libugui.SetAnchoredPos(Ent.go, (Pos.x - 1) * Cell.x, (1 - Pos.y) * Cell.y - offsetY)
		maxY = math.max(maxY, Pos.y)

		-- 绘制前置天赋到本天赋的箭头
		local prevTalent = Talent.prevTalent
		libugui.SetVisible(Ent.spLine, prevTalent > 0)
		if prevTalent > 0 then
			local PrevTalent = FormulaLIB.get_dat(prevTalent)
			local PrevPos = PrevTalent.Pos
			local offx, offy = Pos.x - PrevPos.x, Pos.y - PrevPos.y
			local length = math.sqrt(offx ^ 2 + offy ^ 2)
			-- 距离取整，箭头长度为图片原始长度的奇数倍(1, 3, ...)
			local repSiz = 26
			libugui.SetAnchoredSize(Ent.spLine, nil, math.ceil(length) * repSiz * 2 - repSiz)
			libugui.SetAnchoredPos(Ent.spLine, -Cell.x * offx / 2, Cell.y * offy / 2)

			local eulerAngles
			if offx == 0 then
				eulerAngles = offy > 0 and UE.Vector3.zero or UE.Vector3(0, 0, 180)
			elseif offy == 0 then
				eulerAngles = offx > 0 and UE.Vector3(0, 0, 90) or UE.Vector3(0, 0, -90)
			else
				local rad = math.atan(offx / offy)
				eulerAngles = UE.Vector3(0, 0, math.deg(rad))
			end
			Ent.spLine.transform.localEulerAngles = eulerAngles
			--Ent.spLine.color = PrevTalent.upgradeId == Talent.id and "#00FF00" or "#FFD237"
		end

		if reset and (TarTalent == nil and i == 1 or TarTalent and TarTalent.id == Talent.id) then
			Ent.tgl.value = true
		end
	end)

	-- 指定的天赋只选中一次
	if TarTalent then
		scroll_to_ent(TarTalent.Pos.y)
		self.TarTalent = nil
	end

	libugui.SetAnchoredSize(GrpTalents.go, nil, maxY * Cell.y + offsetY)
end

local function rfsh_talent_info(Talent)
	local SubInfo = Ref.SubInfo
	SubInfo.lbName.text = cfgname(Talent)
	SubInfo.lbDesc.text = Talent.desc

	local Player = DY_DATA:get_player()
	local PrevTalent = Talent.prevTalent > 0 and FormulaLIB.get_dat(Talent.prevTalent)
	SubInfo.lbRequire.text = table.concat({
			string.color(TEXT.fmtLevel:csfmt(Talent.reqPlayerLevel),
				Talent.reqPlayerLevel > Player.level and "#FF0000" or nil),
			PrevTalent and string.color(PrevTalent.name,
				not DY_DATA:get_talent_status(PrevTalent) and "#FF0000" or nil) or nil,
		}, "\n")

	local ItemData = Talent.ItemEx or Talent.Item
	local Item = _G.DEF.Item.new(ItemData.id)
	SubInfo.lbInfo.text = Item:get_base_data().desc

	local SubUnlock = SubInfo.SubUnlock
	local talentStatus = DY_DATA:get_talent_status(Talent)
	libunity.SetActive(SubInfo.btnCrafting, talentStatus)
	libunity.SetActive(SubUnlock.go, not talentStatus)
	if not talentStatus then
		SubUnlock.lbPoint.text = string.own_needs(DY_DATA:nget_asset("Talent"), Talent.unlockCost)
		SubUnlock.btnUnlock.interactable = talentStatus == false
	else
		local Group = get_selected_group()
		SubInfo.btnCrafting.interactable = Group and Group.points <= (DY_DATA.Talents.points or 0)
	end
end

--!* [开始] 自动生成函数 *--

function on_btncraft_click(btn)
	self:close(true)
	ui.open("UI/WNDCraft")
end

function on_btnreset_click(btn)
	local Cost = _G.DEF.Item.gen(config("paylib").get_dat("ResetTalent"))
	UI.MBox.consume(Cost, "ResetTalent", function ()
		NW.send(NW.msg("TALENT.CS.RESET"))
	end)
end

function on_grptabs_enttabs_click(tgl)
	if tgl.value then
		rfsh_talent_tree(true)
	end
end

function on_subinfo_subunlock_btnunlock_click(btn)
	local Talent = get_selected_talent()
	if Talent then
		if NW.connected() then
			NW.send(NW.msg("TALENT.CS.LOCK"):writeU32(Talent.id))
		else
			DY_DATA.Talents[Talent.id] = true
			DY_DATA.Talents.points = DY_DATA.Talents.points + Talent.unlockCost
			local TalentPoint = DY_DATA:get_player().Assets[12]
			TalentPoint.amount = TalentPoint.amount - Talent.unlockCost

			NW.broadcast("TALENT.SC.LOCK", { ret = 1, talentId = Talent.id, points = DY_DATA.Talents.points })
		end
	end
end

function on_subinfo_btncrafting_click(btn)
	local Talent = get_selected_talent()
	self:close(true)
	ui.open("UI/WNDCraft", nil, Talent)
end

function on_subtree_subview_grptalents_enttalent_click(tgl)
	if tgl.value then
		rfsh_talent_info(get_selected_talent())
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.GrpTabs)
	ui.group(Ref.SubTree.SubView.GrpTalents)
	--!* [结束] 自动生成代码 *--

	self.FormulaLIB = config("formulalib")
end

function init_logic()
	libgame.UnitStay(0, false)

	self.TarTalent = self.Context

	-- 初始化页签
	for i,v in ipairs(FormulaLIB.TalentGrps) do
		local Ent, isNew = Ref.GrpTabs:gen(i)
		Ent.lbName.text = v.name
		Ent.lbCheck.text = v.name

		if (TarTalent == nil and i == 1 or TarTalent and TarTalent.talentGrp == v.id) then
			Ent.tgl.value = true
		end
	end

	rfsh_talent_points()
end

function show_view()

end

function on_recycle()
	libugui.AllTogglesOff(Ref.GrpTabs.go)
	libugui.AllTogglesOff(Ref.SubTree.SubView.GrpTalents.go)
end

Handlers = {
	["PLAYER.SC.ROLE_ASSET_GET"] = function ()
		rfsh_talent_points()
		rfsh_talent_info(get_selected_talent())
	end,

	["TALENT.SC.LOCK"] = function (Ret)
		if Ret.err == nil then
			rfsh_talent_points()
			rfsh_talent_tree()
			rfsh_talent_info(get_selected_talent())

			-- 检测是否激活了下一个天赋组
			local Talent = FormulaLIB.get_dat(Ret.talentId)
			local currPoints = Ret.points
			prevPoints = currPoints - Talent.unlockCost

			local NewGroup, NextGroup
			for _,v in ipairs(FormulaLIB.TalentGrps) do
				if NewGroup == nil then
					if prevPoints < v.points and currPoints >= v.points then
						NewGroup = v
					end
				else
					NextGroup = v
				break end
			end

			if NewGroup then
				local Content = {
					string.format(TEXT.fmtNewTalentGroup, NewGroup.name)
				}
				if NextGroup then
					table.insert(Content, string.format(TEXT.fmtNextTalentGroup, NextGroup.name))
					table.insert(Content, string.format(TEXT.fmtTalentPointsRequired, NextGroup.points))
				end

				local content = string.tag(table.concat(Content, "\n"), {
						align = "left", margin = "20%", ["line-height"] = 60,
					})

				UI.MBox.make("MBNormal")
					:set_param("title", TEXT.titleTalentGroupUnlock)
					:set_param("content", content)
					:set_param("single", true)
					:show()
			end
		end
	end,

	["TALENT.SC.LIST"] = function ()
		rfsh_talent_points()
		rfsh_talent_tree()
		rfsh_talent_info(get_selected_talent())
	end,
}

return self

