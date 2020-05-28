--
-- @file    ui/battle/lc_frmexplore.lua
-- @author  xingweizhen
-- @date    2017-10-14 11:20:28
-- @desc    FRMExplore
--

local self = ui.new()
setfenv(1, self)

self.ChatPos = { ax = 1, ay = 0, ox = -575, oy = 14, ctrl = true }

local API = _G.PKG["game/api"]
local SKILL = _G.PKG["game/skill"]

local Name2Index = {
	SubMajor = CVar.EQUIP_MAJOR_POS,
	SubSwitch = CVar.EQUIP_MINOR_POS,
	SubLPocket = CVar.EQUIP_LPOCKET_POS,
	SubRPocket = CVar.EQUIP_RPOCKET_POS,
}
local Index2Name = table.swapkv(Name2Index)

local EMOTE_BLACK_COLOR = UE.Color(0, 0, 0, 128/255)
local EMOTE_SELECTED_COLOR = UE.Color(78/255, 165/255, 68/255, 128/255)

local StatStyles = {
	-- 饱食度
	[8] = { icon = "Battle/ico_main_014", Bg = { "#CC7612", "#B70329", }, },
	-- 饱水度
	[9] = { icon = "Battle/ico_main_010", Bg = { "#CC7612", "#B70329", }, },
	-- 清洁度
	[10] = { icon = "CommonIcon/ico_main_047", Bg = { "#CC7612", "#B70329", }, },
	-- 排泄值
	[11] = { icon = "CommonIcon/ico_main_032", Bg = { "#CC7612", "#B70329", } },
}

local PlayerChange

function set_visible(visible)
	libugui.SetVisible(Ref.go, visible)
	libugui.SetVisible(Ref.SubMap.SubMini.go, visible)

	ui.setvisible("TaskAndTeam", visible)
end

local function rfsh_radio_event_num(num)
	if num == 0 then
		num = nil
	end
	local Sub = API.get_obj_hud(-1000)
	if Sub then
		if num then
			API.set_hud_alpha("HUD#" .. -1000,1)
			Sub.SubPlate.SubBg.lbName.text = ""..num
		else
			API.set_hud_alpha("HUD#" .. -1000,0)
		end
	end
end
local function rfsh_focus_show_info(focusObj)
	if focusObj == 0 then
		focusObj = nil
		if self.lastFocus then
			API.set_hud_alpha("HUD#" .. self.lastFocus,0)
		end
		self.lastFocus = nil
	end

	local Focus = CTRL.get_obj(focusObj)
	if Focus and Focus.type == "Building" and Focus.interact == 3 then

		local Sub = API.get_obj_hud(focusObj)
		if Sub == nil then
			Sub = API.create_obj_hud(focusObj, "BuildingHUD")
			Sub.SubPlate.lbName.text = (Focus.totalCap - Focus.remainingCap).."/"..Focus.totalCap
			Sub.go.name = "HUD#" .. focusObj
			libgame.SetUnitHud(focusObj, Sub.go)
		end

		if Sub then
			libugui.SetAlpha(Sub.go, 1)
		end
		if self.lastFocus then
			API.set_hud_alpha("HUD#" .. self.lastFocus,0)
		end
		self.lastFocus = focusObj
	else
		if self.lastFocus then
			API.set_hud_alpha("HUD#" .. self.lastFocus,0)
		end
		self.lastFocus = nil
	end

end

local function rfsh_building_working_fx(obj)
	local tm = _G.DY_TIMER.get_timer("UnitWorking#"..obj)

	local view = libgame.GetViewOfObj(obj)

	local Obj = CTRL.get_obj(obj)
	local tmpl = Obj:get_tmpl_data()
	if tmpl == nil then
		return
	end

	local modelName = string.lower(tmpl.model)
	local workingRes = string.format("%s/working_%s", modelName, modelName)
	libgame.StopFx(obj, workingRes)

	if tm and not tm.paused then
		libunity.SetActive(workingAnchor, true)

		if Obj.dat == 51006 then
			API.init_gardenbed_working(view, Obj, tm.count)
		end

		--建筑工作中
		libasset.LoadAsync(nil, "fx/"..workingRes, "Cache", function(a, o, p)
			libgame.StopFx(obj, workingRes)
			libgame.PlayFx(obj, workingRes, obj, true, o)
		end)

		tm:subscribe_counting(view, function(tm)
			if Obj.dat == 51006 then
				API.show_gardenbed_working(view, Obj, tm.count)
			end

			if tm.count == 0 then
				DY_TIMER.stop_timer("UnitWorking#"..obj)
				libgame.StopFx(obj, workingRes)
				return
			end
		end)
	else
		if Obj.dat == 51006 then
			--Obj.formulaTotalTime = 0
			API.init_gardenbed_working(view, Obj)
		end
		libgame.StopFx(obj, workingRes)
	end
end

local function random_bubble_dialogue_text(bubbleTextArr)
	local randomIndex = math.random(#bubbleTextArr)
	return bubbleTextArr[randomIndex]
end

local function show_bubble_dialogue(objId, bubbleGroupID, sequenceIndex)
	local BBDlgLib = config("dialoguebubblelib")
	local bbDialogueInfo
	local view = libgame.GetViewOfObj(objId)
	if view then
		bbDialogueInfo = BBDlgLib.get_dialogue_bubble_dat(bubbleGroupID)

		if bbDialogueInfo then
			local Bubble = API.get_chat_bubble(objId)
			local showText
			--1:随机一个始终显示
			if bbDialogueInfo.type == 1 then
				showText = random_bubble_dialogue_text(bbDialogueInfo.bubbleText)
				libugui.DOTween("Alpha", Bubble.go, nil, 1, {
					duration = 0.3,
				})

			--2：间隔bubbleTime秒切换一次
			elseif bbDialogueInfo.type == 2 then
				if sequenceIndex == nil or
				   sequenceIndex > #bbDialogueInfo.bubbleText then
					sequenceIndex = 1
				end
				showText = bbDialogueInfo.bubbleText[sequenceIndex]
				sequenceIndex = sequenceIndex + 1
				libugui.DOTween("Alpha", Bubble.go, nil, 1, {
					duration = 0.3,
				})
				libugui.DOTween("Alpha", Bubble.go, nil, 0, {
					delay = bbDialogueInfo.bubbleTime,
					duration = 0.3,
					complete = function()
						show_bubble_dialogue(objId, bubbleGroupID, sequenceIndex)
					end,
				})

			--3：随机显示一次，持续bubble秒消失
			elseif bbDialogueInfo.type == 3 then
				showText = random_bubble_dialogue_text(bbDialogueInfo.bubbleText)
				libugui.DOTween("Alpha", Bubble.go, nil, 1, {
					duration = 0.3,
					complete = function()
						if Stage.Obj_Append and Stage.Obj_Append[obj] then
							show_bubble_dialogue(objId, Stage.Obj_Append[objId])
						end
					end
				})
				libugui.DOTween("Alpha", Bubble.go, nil, 0, {
					delay = bbDialogueInfo.bubbleTime,
					duration = 0.3,
					complete = function()
						if Stage.Obj_Append and Stage.Obj_Append[obj] then
							show_bubble_dialogue(objId, Stage.Obj_Append[objId])
						else
							libgame.Recycle(Bubble.go)
						end
					end,
				})
			end

			Bubble.lbContent.text = showText
			libugui.Follow(Bubble.go, GO(view, "HUD"))

		end
	end
end

local function rfsh_obj_view(obj, Sub, all)
	local Obj = obj ~= 0 and CTRL.get_obj(obj) or nil
	local ObjForm = Obj and Obj.Form

	local operId = ObjForm and ObjForm.Data.Init.operId or nil
	if ObjForm and (Obj.camp > 0 or operId == nil or operId < 0) then
		if all or not Sub.go.activeSelf then
			Sub.go:SetActive(true)
			local objName = Obj:get_name()

			if Obj.level and Obj.level > 0 then
				Sub.lbName.text = string.format("LV.%d %s", Obj.level, objName)
			else
				Sub.lbName.text = objName
			end

			if Obj.id ~= CTRL.selfId then
				Sub.lbName.color = API.get_unit_color(Obj)
			end
		end
		local value, limit = libgame.GetUnitHealth(obj)
		--print("[刷新血量]value:"..value..",limit:"..limit)
		if all then
			Sub.barHp:InitValue(value and value / limit or 1)
		else
			Sub.barHp.value = value and value / limit or 1
		end

		-- 2018年10月19日策划需求，也显示自己的血量上限
		--if Sub == Ref.SubPlayer then
		--	Sub.lbHp.text = value
		--else
		Sub.lbHp.text = value and string.format("%d/%d", value, limit) or ""
		--end
	else
		Sub.go:SetActive(false)
	end
end

local function rfsh_target_view(obj, all)
	rfsh_obj_view(obj, Ref.SubTarget, all)
end

local function rfsh_teammate_view(obj, all)
	local StageTeam = Stage.Team
	if StageTeam then
		if obj then
			for i,v in ipairs(StageTeam) do
				if v == obj then
					CTRL.handle("TEAM_MEMBER_UPDATE", i, v)
				return end
			end
		end

		-- 未找到指定的队友，全部刷新
		for i,v in ipairs(StageTeam) do
			CTRL.handle("TEAM_MEMBER_UPDATE", i, v)
		end
	end
end

local function rfsh_player_view()
	rfsh_obj_view(CTRL.selfId, Ref.SubPlayer)
end

local function rfsh_player_level()
	local Player = DY_DATA:get_player()
	local SubLevel = Ref.SubLevel

	local Level = Player:get_level_data()

	if Level.maxExp > 0 then
		local value = Player.exp / Level.maxExp
		SubLevel.barExp.value = value
		SubLevel.lbPrecent.text = math.floor(value * 100) .. "%"
	else
		SubLevel.barExp.value = 0
		SubLevel.lbPrecent.text = "0%"
	end


	local SubPlayer = Ref.SubPlayer
	local objName = Player.name
	if Player.level then
		SubPlayer.lbName.text = string.format("LV.%d %s", Player.level, objName)
	else
		SubPlayer.lbName.text = objName
	end

	DY_DATA:get_self():show_view(SubPlayer.SubHead)
end

local function rfsh_tool_dura(Tool)
	local maxDura, _ = Tool:get_max_durability()
	local dura, _ = Tool:get_durability()
	if maxDura and dura then
		Ref.SubMinor.spDura.fillAmount = maxDura > 0 and dura / maxDura or 0
	else
		libunity.LogW("工具{0}无耐久属性", Tool)
	end
end

-- 更新交互图标
local function rfsh_player_interact(focusObj)
	if focusObj == 0 then focusObj = nil end
	local operSp = nil
	local spMinorIcon = Ref.SubMinor.spIcon
	local Self = CTRL:get_self()
	local showDura = false
	if Self:urinate_error() then
		focusObj = 0
		-- 强制交互按钮为如厕且红色底闪烁
		operSp = "CommonIcon/ico_main_032"
		local Color = UE.Color
		libugui.DOTween(nil, Ref.SubMinor.spFlash, Color(1, 0, 0, 0), Color(1, 0, 0, 1), {
				duration = 0.3, loops = -1, loopType = "Yoyo", ignoreTimescale = false,
			})
	else
		libugui.KillTween(Ref.SubMinor.spFlash)
		libugui.SetAlpha(Ref.SubMinor.spFlash, 0)
		if focusObj == nil then
			if Self:urinate_warning() then
				focusObj = 0
				-- 如果交互目标为空，则按钮变为如厕
				operSp = "CommonIcon/ico_main_032"
			end
		else
			local Focus = CTRL.get_obj(focusObj)

			local oper = Focus and Focus:get_oper()


			if oper then

				local Skill = self.SKILLLIB.get_dat(oper)

				if Skill then
					if Skill.spIcon then
						operSp = "CommonIcon/"..Skill.spIcon
					else
						local FocusBase = Focus:get_base_data()
						if FocusBase then
							if FocusBase.interactIcon and FocusBase.interactIcon ~= "" then
								operSp = "CommonIcon/"..FocusBase.interactIcon
							end
						end
					end
				end


				if oper > CVar.MAX_OPER then

					-- 取工具图标作为交互图标
					local Tool = CTRL.find_tool(oper)
					if Tool then
						showDura = true
						rfsh_tool_dura(Tool)

						--operSp = Tool:get_base_data().icon
					end
				end
			else
				libunity.LogE("可交互对象{0}的交互类型为nil", focusObj)
			end
		end
	end
	libunity.SetActive(Ref.SubMinor.spDura, showDura)
	libugui.SetInteractable(Ref.SubMinor.go, focusObj)
	spMinorIcon:SetSprite(operSp or "CommonIcon/ico_main_024")
end

local function rfsh_player_healthy(Self, ignoreHp)
	local Hud = API.get_obj_hud(Self.id)
	if Hud == nil then return end

	if not ignoreHp and Self.hp then
		libgame.SetUnitHealth(Self.id, Self.hp, Self.Attr.hp)
	end

	ui.group(Hud.GrpStats)

	local Healthy = {
		Self.Hunger, Self.Thirsty, Self.Smell
	}

	local lowRate = CVar.GAME.LowAlertRate / 1000
	local LowHealty = {}
	for _,v in ipairs(Healthy) do
		if v.dat ~= 10 then
			if v.amount == 0 then
				table.insert(LowHealty, { key = v.dat, level = 2 })
			elseif v.amount / 100 < lowRate then
				table.insert(LowHealty, { key = v.dat, level = 1 })
			end
		else
			local level = _G.CVar.smell_value2level(v.amount)
			if level <= 2 then
				level = level == 2 and 1 or 2
				table.insert(LowHealty, { key = v.dat, level = level })
				libgame.PlayFx(0, "Common/cleanliness_debuff", 0)
			else
				libgame.StopFx(0, "Common/cleanliness_debuff")
			end
		end
	end

	local urinateError = Self:urinate_error()
	libgame.AnimSetParam(0, "urinate", urinateError)
	if urinateError then
		libgame.PlayerAuto(false)
		libgame.PlayerAttack()
		table.insert(LowHealty, { key = 11, level = 2 })
	elseif Self:urinate_warning() then
		table.insert(LowHealty, { key = 11, level = 1 })
	end


	rfsh_player_interact(libgame.GetFocusUnit())

	libugui.SetInteractable(Ref.SubMajor.evt, not urinateError)
	libugui.SetInteractable(Ref.SubSwitch.btn, not urinateError)
	libugui.SetInteractable(Ref.SubRPocket.evt, not urinateError)
	libugui.SetInteractable(Ref.SubLPocket.evt, not urinateError)

	local Attr = Self.Form.Data.Attr
	Ref.tglSneak.interactable = not urinateError and (rawget(Attr, "sneak") == nil or Attr.sneak > 0)
	Ref.tglAuto.interactable = not urinateError

	Hud.GrpStats:dup(#LowHealty, function (i, Ent, isNew)
		local Low = LowHealty[i]
		local Style = StatStyles[Low.key]
		if Style then
			ui.seticon(Ent.spIcon, Style.icon)
			Ent.spLay.color = Style.Bg[Low.level]
		else
			Ent.go:SetActive(false)
		end
	end)

	if self.debugging then
		local MarkColors = { "FF000040", "00FF0040", "0000FF40", }
		local nColors = #MarkColors
		local PlateText = {}
		for i,v in ipairs(Healthy) do
			local Base = v:get_base_data()
			if Base then
				local text = string.format("<mark=#%s>%s%d</mark>",
					MarkColors[(i - 1) % nColors + 1], Base.name, v.amount)
				table.insert(PlateText,  text)
			end
		end
		Hud.lbDebug2.text = string.format("#%d %s\n", Self.id, Self:get_name())
			.. table.concat(PlateText, " ")
	end
end

local bReloadFlick = false
local function rfsh_reload(hasReload, curAmmo, maxAmmo)
	if hasReload then
		local SubReload = Ref.SubReload
		local ammoRatio = curAmmo / maxAmmo
		if ammoRatio > 0.3 then
			--策划需求，当弹药数大于30%时，显示弹药数量
			--SubReload.lbReload.text = TEXT.WeaponReload.Reload
			SubReload.lbReload.text = string.format(TEXT.fmtCnt_Adequate, curAmmo, maxAmmo)

			--if bReloadFlick then
				libugui.KillTween(SubReload.spAlertReload)
				libugui.KillTween(SubReload.lbReload)
				libugui.SetAlpha(SubReload.lbReload, 1)
				libugui.SetAlpha(SubReload.spAlertReload, 0)
				bReloadFlick = false
			--end
		else
			SubReload.lbReload.text = string.format(TEXT.WeaponReload.BulletClip, curAmmo, maxAmmo)

			--连发时不重新执行tween闪烁
			if not bReloadFlick then
				local fromAlpha, toAlpha = UE.Color(1, 1, 1, 1),  UE.Color(1, 1, 1, 0)

				libugui.DOTween(nil, SubReload.spAlertReload, fromAlpha, toAlpha,{
					duration = 0.5,
					loops = -1,
					loopType = 1,
				})

				fromAlpha, toAlpha = toAlpha, fromAlpha

				libugui.DOTween(nil, SubReload.lbReload, fromAlpha, toAlpha,{
					duration = 0.5,
					loops = -1,
					loopType = 1,
				})


				bReloadFlick = true
			end
		end
	else
		if bReloadFlick then
			local SubReload = Ref.SubReload
			libugui.KillTween(SubReload.spAlertReload)
			libugui.KillTween(SubReload.lbReload)
			libugui.SetAlpha(SubReload.lbReload, 1)
			libugui.SetAlpha(SubReload.spAlertReload, 0)
			bReloadFlick = false
		end
	end
end

local function rfsh_item_cool(Item, spCooldown, cooldown, cycle)
	if cooldown == nil then
		cooldown, cycle = DY_DATA:get_item_cool(Item)
	end

	if cooldown and cooldown > 0 then
		UTIL.tween_cooldown(spCooldown, cooldown, cycle)
	else
		libunity.SetActive(spCooldown, false)
	end
end

local function show_weapon_btn(Sub, Weapon, cooldown, cycle)
	if Weapon and Weapon:usable() then
		libugui.SetAlpha(Sub.go, 1)
		Weapon:show_view(Sub)
		local spAmmo = Ref.SubReload.spAmmo
		local maxDura, maxAmmo = Weapon:get_max_durability()
		local dura, ammo = Weapon:get_durability()
		Sub.spDura.fillAmount = maxDura > 0 and dura / maxDura or 0

		if Weapon.pos == CVar.EQUIP_MAJOR_POS then
			local hasReload = Weapon:has_reload()
			rfsh_reload(hasReload, ammo, maxAmmo)
			spAmmo.fillAmount = maxAmmo > 0 and ammo / maxAmmo or 0
		end
	else
		Sub.spDura.fillAmount = 1
		local Major, Minor = CTRL.get_self():get_weapon()
		local showFist = Sub == Ref.SubMajor or Major or Minor
		libugui.SetAlpha(Sub.go, showFist and 1 or 0)
		Sub.spIcon:SetSprite(showFist and "Battle/ico_main_003" or "")
	end

	rfsh_item_cool(nil, Sub.spCooldown, cooldown, cycle)
end

local function rfsh_player_weapon(Inf)
	local Self = CTRL.get_self()
	local Major, Minor = Self:get_weapon()
	local hasReload = Major and Major:has_reload()

	libugui.SetAlpha(Ref.SubReload.go, hasReload and 1 or 0)
	libugui.SetVisible(Ref.SubMajor.lbAmount, hasReload)

	show_weapon_btn(Ref.SubMajor, Major, Inf.majorCD, Inf.majorCycle)
	show_weapon_btn(Ref.SubSwitch, Minor, Inf.minorCD, Inf.minorCycle)

	Ref.SubMajor.lbAmount.text = nil
end

local function show_pocket_item(Sub, Item, init)
	libugui.SetAlpha(Sub.go, Item and 1 or 0)
	if Item then
		Item:show_view(Sub)
		local ItemBase = Item:get_base_data()
		Sub.lbItem.text = Item.amount

		if init then
			-- 预加载投掷物资源
			if ItemBase.sType == "THROW" then
				if #ItemBase.fxBundle > 0 then
					libasset.LoadAsync(nil, "FX/"..ItemBase.fxBundle.."/", "Cache")
				end
				if #ItemBase.sfxBank > 0 then
					libasset.LoadAsync(nil, "fmod/"..ItemBase.sfxBank.."/", "Cache")
				end
			end
		end

		rfsh_item_cool(Item, Sub.spCooldown)
	end
end

local function rfsh_player_pockets()
	show_pocket_item(Ref.SubLPocket, DY_DATA:iget_item(CVar.EQUIP_LPOCKET_POS), true)
	show_pocket_item(Ref.SubRPocket, DY_DATA:iget_item(CVar.EQUIP_RPOCKET_POS), true)
end

local function rfsh_equip_dura(Item)
	local EQUIP_POS2TYPE = CVar.EQUIP_POS2TYPE
	local SType2Dress = CVar.SType2Dress
	local EQUIP_POS_ZERO = CVar.EQUIP_POS_ZERO
	local lowDuraPc = CVar.GAME.LowAlertRate / 1000
	local hasLowDura = false
	local SubDura = Ref.SubDura
	local DuraSpriteNames = {
		Weapon = "ico_main_005",
		Head = "ico_main_006",
		Body = "ico_main_007",
		Legs = "ico_main_008",
		Feet = "ico_main_004",
	}

	local function calc_dura_pc(Equip)
		if Equip then
			local maxDura, _ = Equip:get_max_durability()
			local dura, _ = Equip:get_durability()
			return dura / (maxDura or 1)
		end
	end

	local function set_dura_color(group, duraPc)
		local spName = DuraSpriteNames[group]
		local c = "#FFFFFF80"
		if duraPc == nil or duraPc == 0 then
			c = "#471E1E50"
		elseif duraPc < lowDuraPc then
			c = "#FF000080"
		end
		SubDura["sp"..group].color = c
	end

	if Item then
		local itemPos
		if type(Item) == "number" then
			itemPos = Item
			Item = DY_DATA:iget_item(Item)
		else itemPos = Item.pos end

		local duraPc = calc_dura_pc(Item)
		local group = SType2Dress[EQUIP_POS2TYPE[itemPos]]
		set_dura_color(group, duraPc)

		if duraPc == nil or duraPc >= lowDuraPc or libunity.IsActive(SubDura.go) then return end
	end

	-- 初始显示(武器、头，胸、腿、脚)
	local EquipDuras = {}
	for i=CVar.EQUIP_MAJOR_POS,CVar.EQUIP_FOOT_POS do
		local group = SType2Dress[EQUIP_POS2TYPE[i]]
		local duraPc = calc_dura_pc(DY_DATA:iget_item(i))
		EquipDuras[group] = duraPc
		if duraPc and duraPc < lowDuraPc then hasLowDura = true end
	end

	libunity.SetActive(SubDura.go, hasLowDura)
	if hasLowDura then
		for k,v in pairs(DuraSpriteNames) do
			set_dura_color(k, EquipDuras[k])
		end
	end
end

local function rfsh_nearby_unit(obj, index)
	local Obj = obj and CTRL.get_obj(obj)
	if Obj then
		if index == nil then index = self.EntsNearby[obj] end
		local Ent, isNew = Ref.GrpNearbys:gen(index)
		if isNew then
			-- 每20度放一个在半径275的圆上，217度是偏移值
			local angle = math.rad(217 - index * 20)
			local radius = 275
			libunity.SetPos(Ent.go, radius * math.cos(angle), radius * math.sin(angle))
			libugui.SetAlpha(Ent.spAuto, 0)
		end
		libugui.SetInteractable(Ent.go, true)
		libugui.DOTween("Alpha", Ent.go, nil, 1, { duration = 0.3 })

		-- TODO 图标暂时自动分配
		Ent.spIcon:SetSprite("GuildIcon/ico_tat_00" .. (obj % 5 + 1))
		Ent.lbName.text = Obj:get_name()
		local value, limit = libgame.GetUnitHealth(obj)
		Ent.spHp.fillAmount = value / limit
	else
		local Ent = index and Ref.GrpNearbys:get(index)
		if Ent then
			Ent.tgl.value = false
			libugui.SetAlpha(Ent.spAuto, 0)

			libugui.SetInteractable(Ent.go, false)
			libugui.DOTween("Alpha", Ent.go, nil, 0, { duration = 0.3 })
		end
	end
end

local function rfsh_nearby_units()
	local EntsNearby = self.EntsNearby
	local NewNearby, EntsPos = {}, {}
	if EntsNearby then
		for _,v in ipairs(UnitsNearby) do
			local index = EntsNearby[v]
			if index then
				NewNearby[v] = index
				EntsPos[index] = true
			else
				NewNearby[v] = true
			end
		end
	else
		NewNearby = table.arrvalue(UnitsNearby)
	end

	local EmptyPos = {}
	local maxNearby = Settings["battle.focus.showNearby"]
	for i=1,maxNearby do
		if EntsPos[i] == nil then table.insert(EmptyPos, i) end
	end

	for k,v in pairs(NewNearby) do
		if v == true then
			local index = table.remove(EmptyPos, 1)
			NewNearby[k] = index
			rfsh_nearby_unit(k, index)
		end
	end

	for _,v in pairs(EmptyPos) do
		rfsh_nearby_unit(nil, v)
	end

	self.EntsNearby = NewNearby
end

local function objs_data_update()
	CTRL.update_team()
	rfsh_teammate_view()
end

local function get_objID_by_itemID(sbObjIds, itemID)
	for _,sbid in pairs(sbObjIds) do
		local SbObj =  CTRL.get_obj(sbid)
		local baseInfo = SbObj:get_base_data()
		if baseInfo.id == itemID then
			return sbid
		end
	end
	return 0
end

local function calc_stage_fixedtime(timeScale)
	if timeScale >= CVar.TIME.DawnStartTime and timeScale < CVar.TIME.DayStartTime then
		return 0.27
	elseif timeScale >= CVar.TIME.DayStartTime and timeScale < CVar.TIME.NightfallStartTime then
		return 0.4
	elseif timeScale >= CVar.TIME.NightfallStartTime and timeScale < CVar.TIME.NightStartTime then
		return 0.7
	else
		return 1
	end
end

local function rfsh_team_members(Ret)
	CTRL.update_team()
end

local function tween_self_attacked()
	libugui.DOTween("Alpha", Ref.ElmWarning, 0.5, 0, { duration = 0.5, })
end

local function show_buff_tip(Buff, Sub)
	local BuffBase = config("skilllib").get_buff(Buff.id)
	if BuffBase then
		Sub.lbName.text = BuffBase.name
		Sub.lbDesc.text = "<line-indent=10%>" .. BuffBase.desc
	else
		libunity.LogW("增益#{0}配置不存在", Buff.id)
	end
end

local function on_buff_update(Obj)
	if Obj and Obj.id == CTRL.selfId then
		local SKILLLIB = config("skilllib")
		local Tip = ui.find("TIPBuff")
		local tipBuff = Tip and Tip.Context.id
		local hasBuff = false
		local GrpBuffs = Ref.SubPlayer.GrpBuffs
		GrpBuffs:dup(#Obj.Buffs, function (i, Ent, isNew)
			local Buff = Obj.Buffs[i]
			local isSurviveBuff = Buff.id == CVar.SURVIVE_BUFF_ID
			if Buff.id == tipBuff then hasBuff = true end

			if isSurviveBuff then
				libunity.SetActive(Ent.go, false)
			return end

			local BuffBase = SKILLLIB.get_buff(Buff.id)
			if BuffBase == nil or BuffBase.hidden then
				libunity.SetActive(Ent.go, false)
			return end

			ui.seticon(Ent.spIcon, BuffBase.icon)
		end)

		if Tip and not hasBuff then Tip:close() end
	end
end

local function reset_touch()
	local SubArea = Ref.SubMove.SubArea
	libugui.SetAnchoredPos(SubArea.go, 0, 0)
	libugui.SetAnchoredPos(SubArea.spTouch, 0, 0)
	libugui.SetAnchoredPos(SubArea.spCenter, 0, 0)
end

local function move_touch()
	local position = self.movingPos
	local SubArea = Ref.SubMove.SubArea
	local localPos = libugui.ScreenPoint2Local(position, SubArea.go)
	local magnitude = localPos.magnitude
	if magnitude > moveRadius then
		localPos = localPos.normalized * moveRadius
		magnitude = moveRadius
	end
	libugui.SetAnchoredPos(SubArea.spTouch, localPos * (outerRadius - innerRadius) / moveRadius)
	libugui.SetAnchoredPos(SubArea.spCenter, localPos)

	local towards = localPos / moveRadius
	local nowTime = UE.Time.time

	if nowTime - moveTime > 0.1 or UE.Vector2.Dot(towards / magnitude, moveTowards.normalized) > 0.2 then
		self.moveTowards = towards
		self.moveTime = nowTime
	end
	libgame.UnitMove(0, moveTowards, towards)
end

local function restore_user_oper()
	if self.movingPos then
		move_touch()
	end

	if self.attackTime == nil and not Ref.tglAuto.value then
		local Major = DY_DATA:iget_item(CVar.EQUIP_MAJOR_POS)
		if Major then
			local _, maxAmmo = Major:get_max_durability()
			local _, ammo = Major:get_durability()
			if ammo == 0 and maxAmmo and maxAmmo > 0 then
				-- 弹药耗尽，自动装填
				libgame.PlayerAttack(0, 0)
			end
		end
	end
end

local function init_data()
	local Self = Stage.Self
	CTRL.selfId = Self.id

	CTRL.subscribe("SAMPLE_FPS", function (fps)
		print("帧率采样结束，平均: ", fps)
		if fps < 25 then
			UE.Application.targetFrameRate = 30
			libunity.SendMessage("/AssetsMgr", "SetResolution", 720)
		elseif fps > 45 then
			UE.Application.targetFrameRate = 60
		end
	end)

	CTRL.subscribe("INIT_SELF", function (quality)
		local stoke = _G.get_graphic_settings("stroke")
		if quality < 3 then
			-- 先降低分辨率
			libunity.SendMessage("/AssetsMgr", "SetResolution", 720)
		end
		if quality < 2 then
			-- 再禁用阴影
			UE.QualitySettings.shadows = 0
		end
		libgame.EnableOutline(stoke)

		-- 回收脚底光环
		libgame.Recycle(GO(ViewROOT, "FocusAura"))
		libgame.Recycle(GO(ViewROOT, "LockAura"))
		libgame.Recycle(GO(ViewROOT, "SelfAura"))
		libgame.Recycle(GO(ViewROOT, "TarAura"))

		-- 确保先加载玩家自己
		libgame.CreateView(Self.id, Self.Form.View)
	end)

	CTRL.subscribe("INIT_STAGE", function (size)
		rfsh_player_view()
		rfsh_player_weapon{}

		-- 先排序，先加载玩家，后加载npc
		local SortedUnits = {}
		for _,v in pairs(Stage.Units) do table.insert(SortedUnits, v) end
		table.sort(SortedUnits, function (a, b)
			local aBase, bBase = a:get_base_data(), b:get_base_data()
			local building = aBase.building == bBase.building
			if building then
				if a.dat ~= b.dat then return a.dat < b.dat end
				return a.id < b.id
			else
				return aBase.building
			end
		end)

		local combBuilding = {}
		for _,v in pairs(SortedUnits) do
			if v.Form then
				--创建空的EntityView
				libgame.CreateView(v.id, v.Form.View)
				local buildObj = CTRL.get_obj(v.id)
				if buildObj.sbObjIds then
					table.insert(combBuilding, buildObj)
				end
			else
				CTRL.create(v)
			end
		end

		--将服务器传来的唯一id根据Building@Building配置的subBuilding顺序进行排序
		for _,PbObj in pairs(combBuilding) do
			local baseInfo = PbObj:get_base_data()
			if baseInfo.subBuilding then
				local sortedSbObjIds = {}
				for _,v in pairs(baseInfo.subBuilding) do
					table.insert(sortedSbObjIds, get_objID_by_itemID(PbObj.sbObjIds , v.id))
				end
				PbObj.sbObjIds = sortedSbObjIds
			end
		end

		objs_data_update()

		Stage:init()
		CTRL.update_team()
		rfsh_team_members()
	end)

	CTRL.subscribe("VIEW_LOAD", function (obj, alpha)
		local Obj = CTRL.get_obj(obj)
		if Obj == nil then
			libunity.LogW("VIEW_LOAD对象不存在：#{0}", obj)
		return end

		if Obj.type == "Building" then
			rfsh_building_working_fx(obj)

			if table.ifind(Obj.helpUserList, CTRL.get_self().pid) then
				libgame.PlayFx(0, "Common/workbench_accelerate", obj)
			end
		elseif Obj.type == "Monster" then
			-- todo:后续应根据idleStatus来确定要播放哪个出生前状态动作
			if Obj.idleStatus then
				local bornIdleAniIndex = Obj.idleStatus - 1
				libgame.UnitAnimate(obj, "_bornidle_"..bornIdleAniIndex, 0.25)
			end
		end

		if obj == CTRL.selfId then
			libgame.SetFOWStatus(obj, 1)
			ui.close("WNDLoading")
		elseif table.ifind(Stage.Team, obj) then
			libgame.ReplaceView(obj, { mapIco = "Battle/mmap_otherRole_b_d", mapItor = "Common/ico_com_104" })
		end

		local ObjForm = Obj.Form
		local class = ObjForm.class

		local Sub = API.get_obj_hud(obj)
		if Sub == nil then
			local objName = Obj.name
			if class == "Player" then
				Sub = API.create_obj_hud(Obj, "PlayerHUD")
			elseif class == "Human" then
				if self.debugging or (objName and #objName > 0) then
					Sub = API.create_obj_hud(Obj, "HumanHUD")
					Sub.SubPlate.lbName.text = objName
					Sub.SubPlate.lbName.color = API.get_unit_color(Obj)
				end
			elseif class == "Role" then
				if self.debugging or (objName and #objName > 0) then
					Sub = API.create_obj_hud(Obj, "RoleHUD")
					Sub.SubPlate.lbName.text = objName
					Sub.SubPlate.lbName.color = API.get_unit_color(Obj)
				end
			else
				local ObjBase = Obj:get_base_data()
				if ObjBase.buildingType == 24 then
					local Sub = API.get_obj_hud(-1000)
					if Sub == nil then
						Sub = API.create_obj_hud(-1000, "EventHUD")

						Sub.go.name = "HUD#" .. -1000
						libugui.SetAlpha(Sub.go, 1)
						libgame.SetUnitHud(obj, Sub.go)
					end
					if Stage.radioEventNum == 0 then
						Stage.radioEventNum = nil
					end
					API.set_hud_alpha("HUD#" .. -1000,Stage.radioEventNum and 1 or 0)
					Sub.SubPlate.SubBg.lbName.text = ""..(Stage.radioEventNum or 0)
				end
			end
		end

		if Stage.Obj_Append and Stage.Obj_Append[obj] then
			show_bubble_dialogue(obj, Stage.Obj_Append[obj])
		end

		if Sub then
			Sub.go.name = "HUD#" .. obj
			libugui.SetAlpha(Sub.go, alpha)
			libgame.SetUnitHud(obj, Sub.go)
			if class == "Player" then
				rfsh_player_healthy(Obj, true)
			elseif class == "Human" then
				libgame.AnimSetParam(obj, "urinate", Obj:urinate_error())
			end
		end
	end)

	CTRL.subscribe("VIEW_UNLOAD", function (obj)
		API.del_obj_hud(obj)
		API.del_chat_bubble(obj)
	end)

	CTRL.subscribe("OBJ_DEAD", function (obj)
		API.del_obj_hud(obj)
		API.del_chat_bubble(obj)

		if obj == CTRL.selfId then
			-- 自己死亡了。
			libunity.LogI("DEAD.")

			--如果在地图边界被干死了
			local objBar = API.find_hud_elm("CastBar")
			if objBar then
				libugui.KillTween(objBar)
				libgame.Recycle(objBar)
			end
		end

		local Obj = CTRL.get_obj(obj)
		if Obj then
			local ObjCorpse = Obj:get_tmpl_data().Corpse
			if ObjCorpse then
				libgame.ReplaceView(obj, { mapIco = ObjCorpse.ico, mapLayer = ObjCorpse.layer })
			end
		end
	end)

	CTRL.subscribe("TARGET_CHANGED", function (obj, target)
		if obj == CTRL.selfId then
			CTRL.target = target
			rfsh_target_view(target, true)
		end
	end)

	CTRL.subscribe("TARGET_LOCKED", function (target)
		libugui.SetAlpha(Ref.btnUnlock, (target and not lockedIndex) and 1 or 0)

		if Settings["battle.focus.showNearby"] == 5 then
			if target == nil and lockedIndex then
				libugui.AllTogglesOff(Ref.GrpNearbys.go)
				lockedIndex = nil
			end

			if lockedIndex then target = nil end
			local Idx2Obj = table.swapkv(EntsNearby)
			for i,v in Ref.GrpNearbys:pairs() do
				if target then
					libugui.SetAlpha(v.spAuto, Idx2Obj[i] == target and 1 or 0)
				else
					libugui.SetAlpha(v.spAuto, 0)
				end
			end
		end
	end)

	CTRL.subscribe("UNITS_NEARBY", function (Units)
		table.sort(Units)
		local UnitsNearby = self.UnitsNearby
		if UnitsNearby then
			if #UnitsNearby == #Units then
				local diff = false
				for i,v in ipairs(UnitsNearby) do
					if v ~= Units[i] then diff = true; break end
				end

				-- 集合无变化直接返回
				if not diff then return end
			end
		end

		self.UnitsNearby = Units
		rfsh_nearby_units()
	end)

	CTRL.subscribe("FOCUS_CHANGED", function (obj, focus)
		if obj == CTRL.selfId then
			rfsh_player_interact(focus)
			rfsh_focus_show_info(focus)
		end
	end)

	CTRL.subscribe("HEALTH_CHANGED", function (obj, Inf)
		if Inf.change > 0 and Inf.value == Inf.change then
			-- 死而复活
			local ObjTmpl = CTRL.get_obj(obj):get_tmpl_data()
			libgame.ReplaceView(obj, {
				model = ObjTmpl.model,
				mapIco = ObjTmpl.mapIco,
				mapLayer = ObjTmpl.mapLayer,
			})
		end

		if obj == CTRL.selfId then
			local rate = Inf.value / Inf.limit
			local Params = { health = rate }
			if not libunity.SetAudioParams("UI/HealthLow", Params) then
				if rate < 0.35 then
					libunity.PlayAudio("UI/HealthLow", nil, nil, Params)
				end
			end

			rfsh_player_view()
			if Inf.change < 0 then
				tween_self_attacked()
			end
		else
			if obj == CTRL.target then rfsh_target_view(obj) end
			if EntsNearby ~= nil then
				local index = EntsNearby[obj]
				if index then rfsh_nearby_unit(obj, index) end
			end
		end

		rfsh_teammate_view(obj)
	end)

	CTRL.subscribe("DURA_CHANGED", function (obj, Inf)
		local pos = Inf.pos
		if obj == CTRL.selfId then
			local toolBroken = false
			local Self = CTRL.get_obj(obj)
			local Item = DY_DATA:iget_item(pos)

			if pos > CVar.EQUIP_MINOR_POS and pos < CVar.EQUIP_BAG_POS then
				rfsh_equip_dura(Item or pos)
			end

			if Item and Item:usable() then
				if not NW.connected() then
					Item:set_durability(Inf.dura, Inf.ammo)
					if Inf.dura == 0 then
						toolBroken = true
						-- 损坏
						local ItemBase = Item:get_base_data()
						if ItemBase.lossType == "Destroy" then
							Item:play_loss()
							Item.dat = 0
							Item.amount = 0
							NW.PACKAGE.set_item_amount(Item)
						end
						NW.broadcast("PACKAGE.SC.SYNC_ITEM", { Item })
					end
				end

				if Inf.change ~= 0 then
					local SubWeapon = Ref[Index2Name[pos]]
					if SubWeapon then
						local ItemBase = Item:get_base_data()
						if ItemBase.wType then
							show_weapon_btn(SubWeapon, Item)
						else
							show_pocket_item(SubWeapon, Item)
						end
					end
				end
			else
				-- 损坏
				toolBroken = true

				local posName = Index2Name[pos]
				local SubWeapon = Ref[posName]
				if SubWeapon then
					if posName == "SubMajor" or posName == "SubSwitch" then
						show_weapon_btn(SubWeapon)
					else
						show_pocket_item(SubWeapon)
					end
				end
				NW.PACKAGE.set_slot_dirty(pos)
				NW.broadcast("PACKAGE.SC.SYNC_ITEM", { _G.DEF.Item.create(pos, 0, 0) })
			end

			if Self.tool == pos then
				if toolBroken then
					rfsh_player_interact(libgame.GetFocusUnit())

					local ItemBase = config("itemlib").get_dat(Inf.dat)
					if ItemBase then
						UI.MonoToast.make("Play", TEXT.fmtItemBroken:csfmt(ItemBase.name)):show(0.5, "#DD5105")
					end
				else
					rfsh_tool_dura(Item)
				end
			end
		end
	end)

	CTRL.subscribe("VISIBLE_CHANGED", function (obj, alpha)
		if obj ~= CTRL.selfId then
			local Hud = API.get_obj_hud(obj)
			if Hud then
				libugui.DOTween("Alpha", Hud.go, nil, alpha, { duration = 0.5 })
			end
		end

		local Obj = CTRL.get_obj(obj)
		if Obj.Pet then
			local form = alpha < 1 and 1 or (obj == CTRL.selfId and 0.5 or 0)
			libgame.UnitFade(Obj.Pet.id, form, alpha, 0.5)
		end
	end)

	CTRL.subscribe("FSM_STATE_TRANS", function (obj, from, to)
		if obj == CTRL.selfId then
			if to == "MOVE" then
				if CTRL.delete_itor then
					CTRL.delete_itor()
				end
			end
		end
	end)

	CTRL.subscribe("SHIFT_RATE_CHANGE", function (obj, value)
		if obj == CTRL.selfId then
			Ref.tglSneak.value = value < 1
		end
	end)

	CTRL.subscribe("SWAP_WEAPON", function (obj, Inf)
		if obj == CTRL.selfId then
			rfsh_player_weapon(Inf)
		end
	end)

	CTRL.subscribe("ACTION_START", function (caster, action, duration, target)
		if caster == CTRL.selfId then
			-- 人物表情不需要显示头顶条
			if action < CVar.PET_OPER and duration > 0 then
				local view = libgame.GetViewOfObj(target or caster)
				if view then
					local Bar = API.need_hud_elm("CastBar", "CastBar")
					libugui.Follow(Bar.bar, GO(view, "HUD"))
					libugui.DOTween(nil, Bar.bar, 0, 1, {
						ignoreTimescale = false,
						duration = duration / 30,
						complete = libgame.Recycle,
					})
				end
			return end

			SKILL.special_func(action, true)
		end
	end)

	CTRL.subscribe("ACTION_BREAK", function (caster, action, remain, target)
		if caster == CTRL.selfId then
			if action < CVar.MAX_OPER and remain > 0 then
				local Bar = API.need_hud_elm("CastBar")
				if Bar then libugui.StopTween(Bar.bar, true) end
			return end

			SKILL.special_func(action, false)
			next_action(Ref.go, restore_user_oper)
		end
	end)

	CTRL.subscribe("ACTION_SUCCESS", function (caster, pos, action, cooldown)
		if caster == CTRL.selfId then
			if pos == CVar.EQUIP_LPOCKET_POS or pos == CVar.EQUIP_RPOCKET_POS then
				local Sub = Ref[Index2Name[pos]]
				cooldown = cooldown / 30
				DY_DATA:set_item_cool(pos, cooldown)
				if not NW.connected() then
					rfsh_item_cool(nil, Sub.spCooldown, cooldown, cooldown)
				end
			end

			SKILL.special_func(action, false)
			next_action(Ref.go, restore_user_oper)
		end
	end)

	CTRL.subscribe("ACTION_FINISH", function (caster)
		if caster == CTRL.selfId then
			next_action(Ref.go, restore_user_oper)
		end
	end)

	CTRL.subscribe("EFFECTING", function (who, whom, effId, duration)
		print(who, whom, effId, duration)
	end)

	CTRL.subscribe("BUFF_UPDATE", on_buff_update)

	CTRL.subscribe("EXIT_AUTO", function (autoRet, operId)
		Ref.tglAuto.value = false
		API.toast_oper_fail(autoRet, operId)
	end)

	CTRL.subscribe("LEAVING_STAGE", function (isLeave)
		local objPlayer = libgame.GetViewOfObj(0).transform
		local Bar = API.need_hud_elm("CastBar", "CastBar")
		if isLeave == true then
			libugui.Follow(Bar.bar, GO(objPlayer, "HUD"))
			libugui.DOTween(nil, Bar.bar, 0, 1, {
				ignoreTimescale = false,
				duration = 3,
				complete = function (bar)
					Stage:exit()
					libgame.Recycle(bar)
				end,
			})
		else
			libugui.KillTween(Bar.bar)
			libgame.Recycle(Bar.bar)
		end
	end)

	--昼夜交替变化通知 eDayNight：1-白天 2-黑夜
	CTRL.subscribe("DayNightAlternate", function (eDayNight)
		--todo:昼夜交替变化
	end)

	-- 注册额外的事件
	CTRL.register()

	-- 进入该地图
	if NW.connected() then
		NW.send(NW.msg("MAP.CS.JOIN"):writeU64(Stage.id))
	else
		NW.broadcast("MAP.SC.JOIN", {})
	end

	CTRL.subscribe("monster_idlestatus_modify", function (obj)
		local Obj = CTRL.get_obj(obj)
		if Obj == nil then
			libunity.LogW("VIEW_LOAD对象不存在：#{0}", obj)
		return end

		if Obj.idleStatus then
			local bornIdleAniIndex = Obj.idleStatus - 1
			libgame.UnitAnimate(obj, "_bornidle_"..bornIdleAniIndex, 0.25)
		end
	end)
end
-- ----------

local function on_battery_timer()
	local SubBattery = Ref.SubSys.SubBattery
	local batteryLevel = UE.SystemInfo.batteryLevel
	if batteryLevel < 0 then batteryLevel = 1 end
	SubBattery.bar.value = batteryLevel
	SubBattery.lbPercent.text = string.format("%d%%", math.floor(batteryLevel * 100 + 0.5))
	libugui.SetVisible(SubBattery.spCharge, UE.SystemInfo.batteryStatus.name == "Charging")
end

local function on_network_status()
	local SubSys = Ref.SubSys
	local status = UE.Application.internetReachability.name
	local Status2Name = {
		NotReachable = "",
		ReachableViaCarrierDataNetwork = "ico_main_030",
		ReachableViaLocalAreaNetwork = "ico_main_027",
	}
	SubSys.SubNet.spIcon.spriteName = Status2Name[status]
end

local function init_frame()
	local SubArea = Ref.SubMove.SubArea
	self.outerRadius = libugui.GetRectSize(SubArea.spOuter).x / 2
	self.innerRadius = libugui.GetRectSize(SubArea.spTouch).x / 2
	self.moveRadius = libugui.GetRectSize(SubArea.go).x / 2

	on_network_status()

	local Tm = DY_TIMER.get_timer("BATTERY")
	if Tm then Tm:subscribe_cycle(Ref.go, on_battery_timer) end
	on_battery_timer()

	libunity.SetActive(Ref.SubMove.go, true)
	libunity.SetActive(Ref.SubMajor.go, true)
	libunity.SetActive(Ref.SubMinor.go, true)
	libunity.SetActive(Ref.SubSwitch.go, true)
	libunity.SetActive(Ref.SubReload.go, true)
	libunity.SetActive(Ref.SubRPocket.go, true)
	libunity.SetActive(Ref.SubLPocket.go, true)
	libunity.SetActive(Ref.SubFuncs.btnInventory, true)
	libunity.SetActive(Ref.SubFuncs.btnCraft, true)
	libunity.SetActive(Ref.SubFuncs.btnBuild, true)
	libunity.SetActive(Ref.SubCancel.go, false)
	-- libunity.SetActive(Ref.SubFuncs.btnMall, true)

	-- 仅在邻居家显示快捷退出
	libunity.SetActive(Ref.btnExit, not Stage.home and Stage.Base.type == 0)

	libunity.SetActive(Ref.tglSneak, true)

	Ref.SubTarget.go:SetActive(false)
	Ref.SubPlayer.go:SetActive(false)

	libunity.SetActive(Ref.SubLPocket.spThumb, false)
	libunity.SetActive(Ref.SubLPocket.spLay, false)
	libunity.SetActive(Ref.SubRPocket.spThumb, false)
	libunity.SetActive(Ref.SubRPocket.spLay, false)
	libunity.SetActive(Ref.SubMajor.spLay, false)

	libunity.SetActive(Ref.btnUnlock, Settings["battle.focus.lockOnHit"])
	libugui.SetAlpha(Ref.btnUnlock, 0)

	Ref.tglAuto.value = false

	-- 现在周围玩家 - 功能已砍
	-- local showNearby = Settings["battle.focus.showNearby"] == 5
	-- libunity.SetActive(Ref.btnRefresh, showNearby)
	-- libunity.SetActive(Ref.GrpNearbys.go, showNearby)

	libugui.SetAlpha(Ref.SubMinor.spFlash, 0)
	libugui.SetAlpha(Ref.ElmWarning, 0)

	rfsh_player_pockets()
	rfsh_equip_dura()
	rfsh_player_level()
	local Player = DY_DATA:get_player()
	libunity.SetActive(Ref.tglAuto, Player.level >= CVar.AUTO.UnlockLevel)

	local Travel = DY_DATA.World.Travel
	if Travel then
		local _, Entrance = DY_DATA.World:find_entrance()
		if Entrance.name and #Entrance.name > 0 then
			Ref.SubMap.SubMini.SubOuter.lbName.text = Entrance.name
		else
			local EntData = config("maplib").get_ent(Travel.src)
			Ref.SubMap.SubMini.SubOuter.lbName.text = EntData.name
		end
	else
		Ref.SubMap.SubMini.SubOuter.lbName.text = nil
	end

	-- 限制区域
	local LimitAreas = Stage.LimitAreas
	if LimitAreas then
		for i,v in ipairs(LimitAreas) do
			API.show_limit_area(v)
		end
	end
end

local function coro_healthy()
	local Self = CTRL.get_self()
	local Healthy = { Self.Hunger, Self.Thirsty, Self.Smell }
	local lowRate = CVar.GAME.LowAlertRate / 1000
	local HealthyComplain = TEXT.HealthyComplain
	libunity.InvokeRepeating(Ref.go, 0, 10, function (i)
		local hp, _ = libgame.GetUnitHealth(0)
		-- 死亡即结束
		if hp == 0 then return true end

		local Value = Healthy[i % #Healthy + 1]
		if Value.amount / 100 < lowRate then
			API.show_chat_bubble(0, HealthyComplain[Value.dat])
		end
	end)
end

local function on_player_dress_changed()
	local Self = CTRL.get_self()
	local Model = Self:get_view_dresses()
	CTRL.update(Self, nil, { model = Model })
end

local function on_player_data_changed()
	if PlayerChange == nil then return end
	local duraDirty = false

	local Self = CTRL.get_self()
	local Attr, Weapons, model
	local Affixes = {}
	if PlayerChange.major or PlayerChange.minor then
		rfsh_player_interact(libgame.GetFocusUnit())
		Weapons = Self:get_weapon_data()
		-- 两把武器同时变化，视为交换武器？
		Weapons.switch = PlayerChange.major and PlayerChange.minor
		if Major and Weapons.switch then
			Major:play_drop()
		end
		if not PlayerChange.major then Weapons.majorId = -1 end
		if not PlayerChange.minor then Weapons.minorId = -1 end

		if PlayerChange.major then
			duraDirty = true
			Attr = true
		end
	end

	if PlayerChange.bag then
		table.insert(Affixes, Self:update_view_affix(CVar.EQUIP_TYPE2SLOT.BAG))
	end

	if PlayerChange.dress then
		model = Self:get_view_dresses()
		duraDirty = true
		Attr = true
	end

	local NewAttr
	if Attr then
		Attr = _G.DEF.Attr.new()
		local OldAttr = Self.Form.Data.Attr
		NewAttr = Self:calc_attr()
		for key,name,old,new in _G.DEF.Attr.pairs(OldAttr, NewAttr) do
			if old ~= new then Attr[key] = tonumber(new) or 0 end
		end

		if rawget(Attr, "sneak") then
			Ref.tglSneak.interactable = not Self:urinate_error() and Attr.sneak > 0
		end
	end

	if #Affixes == 0 then Affixes = nil end
	if Attr or Weapons or Affixes or model then
		CTRL.update(Self,
			{ Attr = NewAttr, Weapons = Weapons, },
			{ model = model, Affixes = Affixes })
	end

	if PlayerChange.pocket then
		rfsh_player_pockets()
	end

	if duraDirty then rfsh_equip_dura() end

	PlayerChange = nil
end

local function rfsh_pocketcd(Items)
	if Items == nil then return end
	local pocketL_Item = DY_DATA:iget_item(CVar.EQUIP_LPOCKET_POS)
	local pocketR_Item = DY_DATA:iget_item(CVar.EQUIP_RPOCKET_POS)

	if pocketL_Item then
		rfsh_item_cool(pocketL_Item, Ref.SubLPocket.spCooldown)
	end

	if pocketR_Item then
		rfsh_item_cool(pocketR_Item, Ref.SubRPocket.spCooldown)
	end
end

local function on_item_changed(Items)
	if Items == nil then return end

	if PlayerChange == nil then PlayerChange = {} end
	local EQUIP_POS2NAME = CVar.EQUIP_POS2NAME
	local Self = CTRL.get_self()
	local toolPos = Self.tool
	local toolChanged
	for _,v in ipairs(Items) do
		local name = EQUIP_POS2NAME[v.pos]
		if name == "pocket" or name == "bag" then
			PlayerChange[name] = v.amount or 0
		end
		if v.pos == toolPos then
			if v.dat == 0 then
				-- 工具已损毁
				PlayerChange.tool = 0
			else
				-- 工具发生变化（工具所在的槽位可能发生变化）
				toolChanged = true
			end
		end
	end

	if PlayerChange.tool then
		PlayerChange.tool = nil
		libgame.PlayerAuto()
	end

	if next(PlayerChange) then
		next_action(Ref.go, on_player_data_changed)
	end

	return toolChanged
end

local function chk_tool_changed(Items)
	if Items == nil then return	end
	for _,v in ipairs(Items) do
		if v.dat ~= 0 then
			local Base = v:get_base_data()
			if Base and Base.Oper then
				rfsh_player_interact(libgame.GetFocusUnit())
			return end
		end
	end
end

local function player_start_skill(Item, skill, evt)
	local Skill = self.SKILLLIB.get_dat(skill)

	if Skill == nil then
		if skill ~=0 then
			libunity.LogE("空技能:"..skill)
		end
		return
	end

	if Skill.oper ~= 1 then
		if libgame.IsUnitActing(0) then
			-- 非循环操作的技能只能在空闲时释放
			print("玩家动作进行中")
		return end

		if libgame.IsActionCooling(0, skill) then
			-- 非循环操作的技能未就绪时无法施放
			print(string.format("技能：%d冷却中", skill))
		return end
	end

	if Skill.tarType == 1 then
		-- 目标模式：单位，没什么可做的
		return Skill, nil
	else
		local tarPos
		local function create_skill_itor()
			tarPos = CTRL.create_itor(Skill, Item.pos)

			local evtName = evt.name
			local spThumb = Ref[evtName].spThumb
			libunity.SetActive(spThumb, true)
			libugui.SetAnchoredPos(spThumb, UE.Vector3.zero)
			libunity.SetActive(Ref[evtName].spLay, true)
		end

		if Skill.oper ~= 1 then
			libunity.SetActive(Ref.SubCancel.go, true)
			libugui.SetColor(Ref.SubCancel.go, "#FFFFFF")
		end

		if Skill.oper == 2 then
			-- 只单发的技能，仅创建拖拽指示器
			create_skill_itor()
			return
		else
			-- 其他操作类型，直接施放技能，创建目标拖拽
			create_skill_itor()
			return Skill, tarPos
		end
	end
end

function cancel_moving(forced)
	movePointer = nil
	movingPos = nil
	libgame.UnitStay(0, forced)
	reset_touch()
end

local function do_asset_tips(str)
	_G.UI.MonoToast.make("Play", str):show(0.5)
end

local expamount = 0
local function do_exp_tips(str)
	local formatTip = expamount > 0 and TEXT.fmtObtainItem or TEXT.fmtLostItem
	local expBase = config("itemlib").get_dat(4)
	local tips = formatTip:csfmt(math.abs(expamount), expBase.name)

	expamount = 0
	_G.UI.MonoToast.make("Play", tips):show(0.5)
end

-- 处理地图事件显示
local function start_show_mapmessage(eventInfo)

    local m_text = Ref.SubGoal.lbGoal
	local duration = eventInfo.time
	m_text.text = eventInfo.EventHintText
    coroutine.yield(duration)

	m_text.text = ""
	libunity.SetActive(Ref.SubGoal.go,false)
end
local function refsh_map_ent(eventInfo)

	libunity.SetActive(Ref.SubGoal.go,true)

	libunity.StopAllCoroutine(Ref.SubGoal.go)
	libunity.StartCoroutine(Ref.SubGoal.go,start_show_mapmessage,eventInfo)
end

local function rfsh_survive_buff()
	-- 存活Buff
	local SubSurvive = Ref.SubPlayer.SubSurvive
	local BuffBase = config("skilllib").get_buff(CVar.SURVIVE_BUFF_ID)
	ui.seticon(SubSurvive.spIcon, BuffBase.icon)
	local surviveTime = DY_DATA:get_self():calc_survive_time()
	local surviveRewardDura = surviveTime - tonumber(CVar.SURVIVE.SurviveTimeReward)
	if surviveRewardDura < 0 then
		libugui.SetVisible(SubSurvive.spLight, false)
		SubSurvive.spIcon.grayscale = true
		libunity.Invoke(Ref.go, -surviveRewardDura, function ()
			libugui.SetVisible(SubSurvive.spLight, true)
			SubSurvive.spIcon.grayscale = false
		end)
	else
		libugui.SetVisible(SubSurvive.spLight, true)
		SubSurvive.spIcon.grayscale = false
	end
end

local function rfsh_mapevent(eventInfo)
	if eventInfo == nil then return end

	local eventType = type(eventInfo) == "number" and eventInfo or eventInfo.eventType
	if eventType == 2 then
		_G.UI.Toast.norm(config("textlib").get_dat(eventInfo.textId))
	elseif eventType == 3 then
		Stage:update_weather(Stage.weather)
	elseif eventType == 4 then
		for _,v in pairs(eventInfo.ItemList) do
			local id, amount = v.id, v.amount
			if amount ~= 0 then
				local ItemBase = config("itemlib").get_dat(id)
				local formatTip = amount > 0 and TEXT.fmtObtainItem or TEXT.fmtLostItem
				local tips = formatTip:csfmt(math.abs(amount), ItemBase.name)

				if ItemBase.mType ~= "ASSET" then
					libunity.Invoke(nil, eventInfo.delayTime, do_asset_tips, tips)
				elseif id == 4 then
					--获得经验提示特殊化
					expamount = expamount + amount
					if expamount == amount then
						libunity.Invoke(nil, 0.1, do_exp_tips, tips)
					end
				end
			end
		end
	elseif eventType == 6 then
		_G.UI.MonoToast.make("Play", TEXT.levelup):show(0.5, "#00C850")
		libgame.PlayFx(0, "Common/LevelUpRole")
		libunity.SetActive(Ref.tglAuto, eventInfo.level >= CVar.AUTO.UnlockLevel)

	elseif eventType == 7 then
		local deathType = eventInfo.deathType
		local liveTime = eventInfo.liveTime
		local monsterID = eventInfo.monsterID
		local killerName = eventInfo.killerName

		local deathTitle = TEXT.DeathReasonTitle[deathType]
		local deathReasonStr = TEXT.DeathReason[deathType]
		if deathType == 4 then
			deathReasonStr = deathReasonStr:csfmt(killerName)
		elseif deathType == 6 then
			local unitData = config("unitlib").get_dat(monsterID)
			local randomName = tonumber(killerName)
			if randomName and randomName > 0 then
				randomName = config("textlib").get_dat(randomName)
			else
				randomName = ""
			end
			local monsterName = string.format("%s %s", unitData.name, randomName)
			deathReasonStr = deathReasonStr:csfmt(monsterName)
		end
		ui.show("UI/WNDDeath", 0, { deathTitle = deathTitle, deathReason = deathReasonStr, liveTime = liveTime })

	elseif eventType == 8 then
		local EventArrowInfo = Stage.EventArrowInfo
		if EventArrowInfo then
			if EventArrowInfo.targetType == 0 then
				API.show_arrow(Ref.go, EventArrowInfo.obj)
			elseif EventArrowInfo.targetType == 1 then
				local lookPos = libgame.Local2World(UE.Vector3(EventArrowInfo.x, 0, EventArrowInfo.y))
				API.show_arrow(Ref.go, lookPos)
			end
		else
			--隐藏箭头
			API.show_arrow()
		end

	elseif eventType == 9 then
		if type(eventInfo) ~= "table" then
			eventInfo = { state = Stage.EventHintText ~= nil, showType = 0,EventHintText = Stage.EventHintText }
		end
		libunity.SetActive(Ref.SubGoal.go, eventInfo.state)
		if eventInfo.state then
			if eventInfo.showType == 0 or eventInfo.showType == 2 then
				API.show_goal(eventInfo.EventHintText or "")
			elseif eventInfo.showType == 1 then
				-- 倒计时
				local counttime = eventInfo.time - os.date2secs()
				if counttime > 0 then
					_G.PKG["ui/util"].start_time_counting(Ref.SubGoal.go, Ref.SubGoal.lbGoal,
						counttime, -1, eventInfo.EventHintText, tostring, libunity.SetActive)
				else
					libunity.SetActive(Ref.SubGoal.go, false)
				end
			elseif eventInfo.showType == 3 then
				refsh_map_ent(eventInfo)
			end
		end
	elseif eventType == 10 then
		rfsh_radio_event_num(Stage.radioEventNum)
	elseif eventType == 11 then
		rfsh_survive_buff()
	elseif eventType == 12 then
		for i,v in pairs(eventInfo.helpLogList) do
			libunity.Invoke(nil, 0.5 * (i-1), function(logStr)
				UI.Toast.norm(logStr)
			end, v.helpLog)
		end
	elseif eventType == 14 then
		API.show_limit_area(eventInfo)
	end
end

local function on_app_focus(focus)
	if not focus then
		cancel_moving(false)
	end
end

--!* [开始] 自动生成函数 *--

function on_grpnearbys_entunit_click(tgl)
	local index = ui.index(tgl)
	if tgl.value then
		lockedIndex = index
		for k,v in pairs(EntsNearby) do
			if v == index then
				libgame.PlayerLockTarget(k)
			break end
		end
	elseif lockedIndex == index then
		lockedIndex = nil
		libgame.PlayerLockTarget()
	end
end

function on_submove_drag(evt, data)
	self.movingPos = data.position
	if movePointer == data.pointerId then
		if self.attackTime == nil or UE.Time.time - self.attackTime > 0.1 then
			move_touch()
		end
	end
end

function on_submove_ptrdown(evt, data)
	self.movingPos = data.position
	if movePointer == nil then
		movePointer = data.pointerId
		local SubArea = Ref.SubMove.SubArea
		local localPos = libugui.ScreenPoint2Local(movingPos, Ref.SubMove.go)
		libugui.SetAnchoredPos(SubArea.go, localPos)
		libugui.InsideScreen(SubArea.go)

		move_touch()
	end
end

function on_submove_ptrup(evt, data)
	self.movingPos = nil
	if movePointer == data.pointerId then
		cancel_moving(true)
	end
end

function on_tglauto_click(tgl)
	local value = tgl.value
	libgame.PlayerAuto(value)

	local color = value and "#CB963B" or "#FFFFFF"
	libugui.SetColor(GO(tgl, "spIcon"), color)
	libugui.SetColor(GO(tgl, "spIcon/lbAuto"), color)
end

function on_tglsneak_click(tgl)
	if not libgame.IsUnitFree(0) then return end

	local sneak = tgl.value
	local color = sneak and "#CB963B" or "#FFFFFF"
	libugui.SetColor(GO(tgl, "spIcon"), color)
	libugui.SetColor(GO(tgl, "spIcon/lbSneak"), color)

	local Self = CTRL.get_self()
	if Self then
		local Attr = Self.Form.Data.Attr
		local value = rawget(Attr, "sneak")
		if value and value <= 0 then
			-- 异常状态，不能潜行的情况下进行潜行
		return end

		libgame.UnitSneak(0, sneak)
	end
end

function on_btnunlock_click(btn)
	libgame.PlayerLockTarget()
end

function on_btnexit_click(btn)
	UI.MBox.operate("LeaveNeighborAlert", function ()
		Stage:exit()
	end)
end

function on_btnrefresh_click(btn)
	libgame.PlayerRelockNearby()
end

function on_subcancel_ptrin(evt, data)
	self.cancelDrag = true
	libugui.SetColor(evt, "#FF0000")
end

function on_subcancel_ptrout(evt, data)
	self.cancelDrag = nil
	libugui.SetColor(evt, "#FFFFFF")
end

function on_subreload_click(btn)
	if not libgame.IsUnitFree(0) then return end

	libgame.PlayerAttack(0, 0)
end

function on_subminor_ptrdown(evt, data)
	if not libgame.IsUnitFree(0) then return end

	-- 查找当前可交互的道具
	local obj = libgame.GetFocusUnit()

	local Self = CTRL.get_self()
	if Self:urinate_error() then
		-- 强制排泄
		Self:urinate()
	return end

	if obj then
		local Obj = CTRL.get_obj(obj)
		local operId = Obj:get_oper()
		if operId == nil then return end

		if not CTRL.check_stakable(Obj) then
			UI.Toast.norm(TEXT.tipInventoryFull)
		return end

		local OperData = self.SKILLLIB.get_dat(operId)
		local operRet
		if operId > CVar.MAX_OPER then
			local Tool = CTRL.load_tool(operId)
			if Tool then
				operRet = libgame.PlayerInteract(Tool.pos, operId)
			else
				-- notool
				operRet = 3
				libgame.UnitTransState(0, "LEAVE_ACTION")
				local tip = TEXT.tipNeedTool
				if OperData then
					local reqTip = config("textlib").get_dat(OperData.reqTip)
					if reqTip then tip = reqTip end
				end
				UI.MonoToast.make("Play", tip):show(0.5)
			end
		else
			local interactTime = 0
			if operId == self.SKILLLIB.FRIENDLY_WORK_ID then
				interactTime = self.SKILLLIB.get_dat(self.SKILLLIB.FRIENDLY_WORK_ID).interactTime
			else
				local ObjBase = Obj:get_base_data()
				interactTime = ObjBase.interactTime
			end
            if operId == self.SKILLLIB.OPEN_ID and Obj.status ~= 0 then
				interactTime = 0
			end
			operRet = libgame.PlayerInteract(0, operId, nil, interactTime)
		end
		API.toast_oper_fail(operRet, operId)
	else
		if Self:urinate_warning() then
			-- 默认排泄
			Self:urinate()
		end
	end
end

function on_subminor_ptrup(evt, data)
	libgame.PlayerInteract(nil)
end

function on_subswitch_click(btn)
	NW.move_item(CVar.EQUIP_MAJOR_POS, CVar.EQUIP_MINOR_POS)
end

function on_submajor_ptrdown(evt, data)
	if not libgame.IsUnitFree(0) then return end

	if dragPointer then return end
	if data then dragPointer = data.pointerId end

	CTRL.get_self().tool = nil
	local Item = DY_DATA:iget_item(CVar.EQUIP_MAJOR_POS) or CTRL.get_def_weapon()
	local _, maxAmmo = Item:get_max_durability()
	local dura, ammo = Item:get_durability()
	if maxAmmo == 0 or ammo > 0 then
		local skill = libgame.GetDefSkill(0)
		local Skill, Tar = player_start_skill(Item, skill, evt)
		if Skill then
			self.attackTime = UE.Time.time
			libgame.PlayerAttack(-1, Tar)
		end
	else
		libgame.PlayerAttack(0, 0)
	end
end

function on_joystick_move(evt, data)
	if CTRL.move_itor and dragPointer == data.pointerId then
		local localPos = libugui.ScreenPoint2Local(data.position, evt)
		libugui.SetAnchoredPos(Ref[evt.name].spThumb, localPos)

		local dragOffset = UE.Vector3(localPos.x, 0, localPos.y) / 20
		local tarPos = CTRL.move_itor(dragOffset)
		libgame.SetUnitTarget(0, tarPos)
	end
end

function on_joystick_stop(evt, data)
	if data == nil or dragPointer == data.pointerId then
		local evtName = evt.name
		libunity.SetActive(Ref[evtName].spThumb, false)
		libunity.SetActive(Ref[evtName].spLay, false)

		if CTRL.delete_itor then
			local tarPos, Skill, itemPos = CTRL.delete_itor()
			if not self.cancelDrag then
				if Skill.oper == 2 then
					-- 单发技能，拖拽完成后开始释放
					if itemPos then
						libgame.PlayerInteract(itemPos, Skill.id, tarPos)
					else
						libgame.PlayerAttack(-1, tarPos)
					end
				else
					-- 连发技能：取消
					-- 蓄力技能：完成
					libgame.PlayerAttack()
				end
			else
				self.cancelDrag = nil
				if Skill.oper ~= 2 then
					libgame.UnitBreak(0)
				end
			end
			libunity.SetActive(Ref.SubCancel.go, false)
		else
			libgame.PlayerAttack()
		end
		self.dragPointer = nil
		self.attackTime = nil
	end
end

function on_pocket_click(evt, data)
	if not libgame.IsUnitFree(0) then return end

	local Item = DY_DATA:iget_item(Name2Index[evt.name])
	if Item then
		local ItemBase = Item:get_base_data()
		if ItemBase.sType == "USE" then
			if NW.connected() then
				NW.use_item(Item)
			else
				Item.amount = Item.amount - 1
				if Item.amount == 0 then
					DY_DATA:iset_item(Item.pos, nil)
				end

				--设置冷却时间
				DY_DATA:set_item_cool(Item)
				NW.broadcast("PACKAGE.SC.ITEM_USE", { Item })
			end
		end
	end
end

function on_pocket_ptrdown(evt, data)
	if not libgame.IsUnitFree(0) then return end

	if dragPointer then return end
	dragPointer = data.pointerId
	local evtName = evt.name
	local Item = DY_DATA:iget_item(Name2Index[evtName])
	if Item then
		local ItemBase = Item:get_base_data()
		if ItemBase.sType == "THROW" then
			CTRL.get_self().tool = nil

			local Skill, Tar = player_start_skill(Item, ItemBase.Skills[1], evt)
			if Skill then
				self.attackTime = UE.Time.time
				libgame.PlayerInteract(Item.pos, Skill.id, Tar)
			end
		end
	end
end

function on_subpet_click(btn)

end

function on_subplayer_click(btn)
	local Team = rawget(DY_DATA, "Team")
	if Team then
		local RoomList = rawget(DY_DATA, "RoomList")
		local Room = RoomList and table.match(RoomList, { mapId = Team.mapId })
		if Room then
			ui.open("UI/WNDCreateTeam", nil, Room)
		end
	end
end

function on_subplayer_subsurvive_ptrdown(evt, data)
	local Buff = { id = CVar.SURVIVE_BUFF_ID }
	local Sub = ui.ref(ui.show("UI/TIPSurvive").go)
	show_buff_tip(Buff, Sub)

	local Self = DY_DATA:get_self()
	local totalSurviveTime = Self:calc_survive_time()
	Sub.lbDura.text = os.last2string(totalSurviveTime, 4, nil, 2)
	if Self.isSurviveTiming then
		libunity.InvokeRepeating(Sub.go, 1, 1, function ()
			totalSurviveTime = totalSurviveTime + 1
			Sub.lbDura.text = os.last2string(totalSurviveTime, 4, nil, 2)
		end)
	end

	local expRate = Self:calc_survive_exp(totalSurviveTime)
	Sub.lbReward.text = string.format("%.1f%%", expRate * 100)
end

function on_subplayer_subsurvive_ptrup(evt, data)
	ui.close("TIPSurvive")
end

function on_subplayer_grpbuffs_entbuff_ptrdown(evt, data)
	local Buff = CTRL.get_self().Buffs[ui.index(evt)]
	if Buff then
		local Sub = ui.ref(ui.show("UI/TIPBuff", nil, Buff).go)
		show_buff_tip(Buff, Sub)
		if Buff.disappear > 0 then
			local timestamp = libgame.SyncTimestamp()
			if timestamp < Buff.disappear then
				local secs = (Buff.disappear - timestamp) / 1000
				_G.PKG["ui/util"].start_time_counting(Sub.go, Sub.SubDura.lbDura,
					math.floor(secs + 0.5), -1)
			else
				libunity.SetActive(Sub.SubDura.go, false)
			end
		else
			libunity.SetActive(Sub.SubDura.go, false)
		end
	end
end

function on_subplayer_grpbuffs_entbuff_ptrup(evt, data)
	local TIPBuff = ui.find("TIPBuff")
	if TIPBuff then
		libunity.CancelInvoke(TIPBuff.go)
	end
	ui.close("TIPBuff")
end

function on_subplayer_subhead_click(btn)
	local UserCard = DY_DATA:get_usercard()
	ui.show("UI/MBPlayerInfoCard",0 , UserCard)
end

function on_showemote_longpress(evt, data)
	if data then
		self.selectEmote = nil
		Ref.SubEmote.SubEmotePanel.spFollow.color = EMOTE_BLACK_COLOR
		Ref.SubEmote.SubEmotePanel.spHi.color = EMOTE_BLACK_COLOR
		Ref.SubEmote.SubEmotePanel.spSurrender.color = EMOTE_BLACK_COLOR
		Ref.SubEmote.SubEmotePanel.spTaunt.color = EMOTE_BLACK_COLOR

		libunity.SetActive(Ref.SubEmote.SubEmotePanel.go, true)
	end
end

function on_hideemote_pointerup(evt, data)
	if self.selectEmote ~= nil then
		libgame.PlayerInteract(0, self.selectEmote, 0)
	end

	libunity.SetActive(Ref.SubEmote.SubEmotePanel.go, false)
	self.selectEmote = nil
end

function on_enter_emote_follow(evt, data)
	self.selectEmote = self.SKILLLIB.EMOTE_FOLLOW_ID
	libugui.DOTween(nil, evt:GetComponent("UISprite"), EMOTE_BLACK_COLOR, EMOTE_SELECTED_COLOR, { duration = 0.2})
end

function on_exit_emote_elem(evt, data)
	self.selectEmote = nil
	libugui.DOTween(nil, evt:GetComponent("UISprite"), nil, EMOTE_BLACK_COLOR, { duration = 0.2})
end

function on_enter_emote_hi(evt, data)
	self.selectEmote = self.SKILLLIB.EMOTE_HI_ID
	libugui.DOTween(nil, evt:GetComponent("UISprite"), EMOTE_BLACK_COLOR, EMOTE_SELECTED_COLOR, { duration = 0.2})
end

function on_enter_emote_surrender(evt, data)
	self.selectEmote = self.SKILLLIB.EMOTE_SURRENDER_ID
	libugui.DOTween(nil, evt:GetComponent("UISprite"), EMOTE_BLACK_COLOR, EMOTE_SELECTED_COLOR, { duration = 0.2})
end

function on_enter_emote_taunt(evt, data)
	self.selectEmote = self.SKILLLIB.EMOTE_TAUNT_ID
	libugui.DOTween(nil, evt:GetComponent("UISprite"), EMOTE_BLACK_COLOR, EMOTE_SELECTED_COLOR, { duration = 0.2})
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.GrpNearbys)
	ui.group(Ref.SubPlayer.GrpBuffs)
	--!* [结束] 自动生成代码 *--

	self.UTIL = _G.PKG["ui/util"]
	self.Settings = _G.Prefs.Settings:load()
	self.Stage = DY_DATA:get_stage()
	self.SKILLLIB = config("skilllib")
	self.debugging = _G.ENV.debug

	self.ViewROOT = libunity.NewChild(nil, "Game/StageView")

	self.moveTime = 0
	self.moveTowards = UE.Vector2.zero

	rfsh_survive_buff()

	DY_DATA.RedSystem:BuildRedDotUI(CVar.RedDotName.BuildNew,Ref.SubFuncs.btnBuild)

	DY_DATA.RedSystem:BuildRedDotUI(CVar.RedDotName.CraftNew,Ref.SubFuncs.btnCraft)

	DY_DATA.RedSystem:BuildRedDotUI(CVar.RedDotName.MailNew,GO(Ref.btnMail,"spPoint"))

	NW.MAIL.CheckHaveUnLookMail()
	DY_DATA:get_player():check_newbuild_state()
	DY_DATA:get_player():check_newcraft_state()
end

function init_logic()
	self.camTrans = UE.Camera.main.transform

	--API.InitMapEventHint(Ref.go, -3)
	Ref.SubGoal.lbGoal.text = nil

	rfsh_mapevent(8)
	rfsh_mapevent(9)

	local cv = Ref.go:GetComponent("Canvas")
	cv.overrideSorting = true
	cv.sortingLayerName = "Lay"

	-- 预实例化脚底光圈
	libgame.AddChild(ViewROOT, "FX/Common/FocusAura")
	libgame.AddChild(ViewROOT, "FX/Common/LockAura")
	libgame.AddChild(ViewROOT, "FX/Common/SelfAura")
	libgame.AddChild(ViewROOT, "FX/Common/TarAura")

	libugui.SetAlpha(Ref.go, 1)
	local dn = libgame.GetDayNight()

	libunity.SetActive(Ref.SubEmote.SubEmotePanel.go, false)

	--设置地图天气
	if Stage.weather then
		Stage:update_weather(Stage.weather)
		libunity.LogI("Init Weather:{0}", Stage.weather)
	end

	--设置固定地图昼夜
	if Stage.timeScale then
		local fixedTime = calc_stage_fixedtime(Stage.timeScale)
		libunity.LogI("TimeScale:{0},FixedTime:{1}", Stage.timeScale, fixedTime)
		dn:SendMessage("SetFixTime", fixedTime)
	else
		dn:SendMessage("SetFixTime", -1)
	end

	AUD.push("Music/Battle BGM")

	reset_touch()
	init_frame()
	init_data()
	coro_healthy()

	ui.show("UI/TaskAndTeam", nil, CTRL)

	_G.PKG["framework/notify"].subscribe_focus(Ref.go, on_app_focus)

	Ref.SubSys.lbLatency.text = DY_DATA:get_network_letency()
end

function show_view()

end

function on_recycle()
	DY_DATA.RedSystem:UnbuildRedDotUI(CVar.RedDotName.BuildNew)
	DY_DATA.RedSystem:UnbuildRedDotUI(CVar.RedDotName.CraftNew)
	DY_DATA.RedSystem:UnbuildRedDotUI(CVar.RedDotName.MailNew)

	local WorkingUnits = self.Stage.WorkingUnits
	if WorkingUnits then
		for _,v in ipairs(WorkingUnits) do
			DY_TIMER.stop_timer(v)
		end
	end

	_G.PKG["framework/notify"].unsubscribe_focus(Ref.go, on_app_focus)
end

Handlers = {
	["CLIENT.SC.WND_OPEN"] = function (Wnd)
		if Wnd.name == "WNDTopBar" then
			set_visible(false)
			cancel_moving(false)
		end
	end,
	["CLIENT.SC.WND_CLOSE"] = function (Wnd)
		if Wnd.name == "WNDTopBar" then
			set_visible(true)
		end
	end,

	["CLIENT.SC.SETTINGS"] = function (Settings)
		libgame.UpdateSettings(Settings)

		libunity.SetActive(Ref.btnUnlock, Settings["battle.focus.lockOnHit"])
		local showNearby = Settings["battle.focus.showNearby"] == 5
		--libunity.SetActive(Ref.btnRefresh, showNearby)
		libunity.SetActive(Ref.GrpNearbys.go, showNearby)
	end,

	["CLIENT.SC.EQUIP_CHANGED"] = function (pos)
		if PlayerChange == nil then PlayerChange = {} end

		local Item = DY_DATA:iget_item(pos)
		local name = CVar.EQUIP_POS2NAME[pos]
		PlayerChange[name] = Item and Item.amount or 0
		next_action(Ref.go, on_player_data_changed)
	end,

	["CLIENT.SC.SELF_HEALTHY"] = function (Changed)
		local change = Changed.Smell
		local threshold = -_G.CVar.BATTLE.PlayerCleanlinessCriticalValue
		if change and change <= threshold then
			-- 清洁度减少量
			_G.UI.MonoToast.make("Icon", { tips = "-", icon = "CommonIcon/ico_main_047" })
				:show(0.5, "#FF0000")
		end
	end,

	["PACKAGE.SC.ITEM_COMPOSE"] = function (Items)
		if Items then
			on_item_changed(Items)
			chk_tool_changed(Items)
		end
	end,
	["PACKAGE.SC.ITEM_DEL"] = function (Items)
		on_item_changed(Items)
		rfsh_player_interact(libgame.GetFocusUnit())
	end,
	["PACKAGE.SC.SYNC_ITEM"] = function (Items)
		on_item_changed(Items)
		chk_tool_changed(Items)
	end,
	["PACKAGE.SC.ITEM_MOVE"] = function (Items)
		 if on_item_changed(Items) then
		 	libgame.PlayerAuto()
		 end
		 chk_tool_changed(Items)
	end,
	["PACKAGE.SC.ITEM_USE"] = function (Items)
		on_item_changed(Items)
		rfsh_pocketcd(Items)
	end,

	["PACKAGE.SC.PACKAGE_OPEN"] = function (Bag)
		if Bag == nil then
			-- 打开箱子/工作台...失败，还原动作
			libgame.UnitBreak(0)
		return end

		local bagType = Bag.type or 0
		if bagType < 0 then
			libgame.UnitBreak(0)
		return end

		ui.close("WNDTopBar", true)
		if Bag.Data then
			if bagType == 1 then
				--Bag.wndName = "WNDWorkBag"
				Bag.title = TEXT.S_Processing
				Bag.pageIcon = "CommonIcon/ico_main_001"

				local Obj = CTRL.get_obj(Bag.obj)
				local ObjBase = Obj:get_base_data()
				if ObjBase then
					Bag.title = Obj:get_name()
					if ObjBase.interactIcon and ObjBase.interactIcon ~= "" then
						Bag.pageIcon = "CommonIcon/"..ObjBase.interactIcon
					end
				end
				ui.open("UI/WNDWorkBagNew", nil, Bag)
				return
			elseif bagType == 2 then
				local Obj = CTRL.get_obj(Bag.obj)
				local ObjBase = Obj:get_base_data()
				Bag.title = ObjBase.name
				Bag.pageIcon = "CommonIcon/ico_main_039"
				Bag.wndName = "WNDConstructing"
			elseif bagType == 3 then
				Bag.wndName = "WNDVehicleUse"
				Bag.title = TEXT.S_Carrier
				Bag.pageIcon = "CommonIcon/ico_main_038"
			elseif bagType == 5 then
				local Obj = CTRL.get_obj(Bag.obj)
				local ObjBase = Obj:get_base_data()
				local WorkingLIB = config("workinglib")
				local Formula = WorkingLIB.get_dat(Bag.Data.FormulaID)
				local Mats = {}
				local ItemDEF = _G.DEF.Item
				for i,v in ipairs(Formula.Mats) do
					table.insert(Mats, ItemDEF.new(v.id, v.amount))
				end
				UI.MBox.make("MBItemSubmit")
					:set_param("title", ObjBase.name)
					:set_param("tips", Formula.machiningText)
					:set_param("Items", Mats)
					:set_event(function ()
						NW.op_produce(Bag.obj, 0)
					end)
					:show()
				return
			elseif bagType == 7 then
				ui.open("UI/WNDRadio", 20, Bag)
				return
			elseif bagType == 8 then
				config("buildingfunclib").open(Bag.Data.obj, Bag.Data.funcId)
				return
			else
				libunity.LogW("异常：箱子类型({0})未定义!", bagType)
				return
			end
		else
			Bag.wndName = "WNDLootBag"

			local value = libgame.GetUnitHealth(Bag.obj)

			if value and value <= 0 then
				Bag.pageIcon ="CommonIcon/ico_main_056"
				Bag.title= TEXT.S_Corpse
			else
				local Obj = CTRL.get_obj(Bag.obj)
				local ObjBase = Obj:get_base_data()

				Bag.title = ObjBase.name
				Bag.pageIcon = "CommonIcon/ico_main_031"
			end
		end
		ui.open("UI/WNDPackage", nil, Bag)
	end,

	["MAP.SC.JOIN"] = function ()
		libunity.SendMessage("/StageView", "Launch")
	end,

	["MAP.SC.EXIT"] = function (Ret)
		if Ret and Ret.err == nil then
			-- 某些情况下还没有加载完成就触发了离开地图
			ui.close("WNDLoading", true)
			if DY_DATA:get_stage() == nil then
				-- 容错保护，避免退出两次地图
				libunity.LogE("attempt to exit while stage is nil")
			return end

			-- 不再处理消息
			self:unsubscribe()

			local Self = DY_DATA:get_self()
			local value, limit = libgame.GetUnitHealth(0)
			Self.hp = value
			Self.Attr.hp = limit

			local function on_exit_map()
				DY_DATA.flagExitStage = true
				SCENE.load_main()
				table.take(_G.SCENE, "showSmoke")
				local Session = _G.PKG["network/login"].get_session()
				if Session then
					libsystem.SetAppTitle(string.format("%s@%s",
						Session.Account.acc, Session.Server.serverName))
				end
			end
			if self.hook_exit_map then
				self.hook_exit_map(on_exit_map)
			else
				Stage.stop()
				on_exit_map()
			end
		end
	end,

	["ROLE.SC.ROLE_REVIVAL"] = function (Ret)
		if Ret.err == nil then
			-- 不再处理消息
			self:unsubscribe()

			-- 复活，起点变更为营地
			local World = rawget(DY_DATA, "World")
			if World and World.Travel then
				World.Travel.src = CVar.HOME_ID
			end
			DY_DATA:get_self().hp = nil

			Stage.stop()
		end
	end,

	["ROLE.SC.GET_ROLE_INFO"] = function(Ret)
		rfsh_player_level()
		rfsh_player_healthy(Ret)
	end,

	["PLAYER.SC.GET_ROLE_INFO"] = function(Ret)
		rfsh_player_level()
	end,

	["TRANSPORT.SC.TRANSPORT_INFO"] = function (Ret)
		if Ret.Info then
			local transType = Ret.Info.type
			local wndName
			if transType == 1 then
				wndName = "UI/WNDStageLift"
			elseif transType == 2 then
				wndName = "UI/WNDStageLift"
			end
			if wndName then ui.open(wndName, nil, Ret.Info) end
		end
	end,

	["PLAYER.SC.ROLE_ASSET_GET"] = function ()
		rfsh_player_level()
	end,

	["MAP.SC.SYNC_ROLE_SURVIVE_INFO"] = function (Objs)
		for i,v in ipairs(Objs) do
			if v.urinate_error then
				local urinateError = v:urinate_error()
				libgame.AnimSetParam(v.id, "urinate", urinateError)
				if urinateError and v.id == CTRL.selfId then
					libgame.PlayerAttack()
				end
			end
			libgame.SetUnitHealth(v.id, v.hp, v.Attr.hp)
		end
	end,

	["MAP.SC.SYNC_MAP_TEAMPLATE"] = function (Objs)
		next_action(Ref.go, objs_data_update)
	end,
	["MAP.SC.SYNC_OBJ_INFO"] = function (Objs)
		next_action(Ref.go, objs_data_update)
		for i,v in ipairs(Objs) do
			if v.id == CTRL.target then
				rfsh_target_view(v, true)
			end
			rfsh_building_working_fx(v.id)
		end
	end,
	["MAP.SC.SYNC_OBJ_ADD_JOIN"] = function (Objs)
		next_action(Ref.go, objs_data_update)
	end,
	["MAP.SC.SYNC_OBJ_REMOVE"] = function (IDs)
		for _,v in ipairs(IDs) do
			API.del_obj_hud(v, 0.5)
		end
	end,
	["BATTLE.SC.SYNC_OBJ_BASE_INFO"] = function (Unit)
		if Unit and Unit.gender then
			if Unit.player then
				next_action(Ref.go, objs_data_update)
			else
				rfsh_teammate_view(Unit.id, true)
			end
		end
	end,
	["BATTLE.SC.SYNC_OBJ_BUFF_INFO"] = on_buff_update,

	["WORLD_MAP.SC.SELECT_MOVE_TOOL"] = function (Ret)
		if Ret.err == nil then
			self.hook_exit_map = function (on_exit)
				libugui.SetAlpha(Ref.go, 0)
				local toolView = libgame.GetViewOfObj(libgame.GetFocusUnit())
				local selfView = libgame.GetViewOfObj(0)
				Stage.stop()

				local viewTrans = toolView.transform
				local tarPos = viewTrans.position + viewTrans.forward * 10
				libugui.DOTween("PositionW", toolView, nil, tarPos, {
						duration = 3, ease = "InCubic", delay = 3,
						ignoreTimescale = false,
						start = function ()
							libunity.SetParent(GO(selfView, "Model"), GO(toolView, "Model/DRIVER"))
						end,
						complete = on_exit,
					})
			end

			-- 退出地图
			Stage:exit()
		end
	end,

	["CHAT.SC.CHAT_BROADCAST"] = function (Msgs)
		for i,v in ipairs(Msgs) do
			if v.channel == 5 then
				local Human = CTRL.get_human(v.Sender.id)
				if Human then
					API.show_chat_bubble(Human.id, tostring(v))
				end
			end
		end
	end,

	["PRODUCE.SC.PRODUCEINFO"] = function (Ret)
		if Ret.err == nil then
			local Produce = Ret.Produce
			if Produce.produceType == 1 then
				local Obj = CTRL.get_obj(Produce.obj)
				if Obj then
					Obj:update_workingtime(Produce.lastTime, Produce.workedTime)
					--rfsh_building_working_fx(Produce.obj)
				end
			elseif Produce.produceType == 5 then
				API.start_building_interaction(Produce.obj, true)
			end
		end
	end,

	["MAP.SC.SYNC_OBJ_APPEND"] = function(MapObjAppendInfoArr)
		for _,v in pairs(MapObjAppendInfoArr) do
			show_bubble_dialogue(v.objId, v.bubbleGroupID)
		end
	end,

	["SUB_BATTLE.SC.OBJ_TALK_NPC"] = function(Ret)
		if Ret then
			local npclib = config("npclib")
			local npcData = npclib.get_dat(Ret.dlg)
			if npcData and npcData.action == "bubble" then
				show_bubble_dialogue(Ret.objId, Ret.dlg)
			end
		end
	end,

	["TEAM.SC.SYNC_ROLE_JOIN"] = rfsh_team_members,
	["TEAM.SC.SYNC_ROLE_EXIT"] = rfsh_team_members,
	["TEAM.SC.SYNC_TEAM_INFO"] = rfsh_team_members,

	["PRODUCE.SC.PRODUCE_FRIEND_HELP"] = function (obj)
		if obj then
			libgame.PlayFx(0, "Common/workbench_help", obj)
			libgame.PlayFx(0, "Common/workbench_accelerate", obj)

			local Obj = CTRL.get_obj(obj)
			table.insert(Obj.helpUserList, CTRL.get_self().pid)
		end
	end,
	["MAP.SC.SYNC_MAP_EVENT"] = rfsh_mapevent,
	["COM.CS.KEEP_HEART"] = function ()
		Ref.SubSys.lbLatency.text = DY_DATA:get_network_letency()
	end,
}

return self

