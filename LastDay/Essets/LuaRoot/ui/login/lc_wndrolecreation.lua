--
-- @file    ui/login/lc_wndrolecreation.lua
-- @author  xingweizhen
-- @date    2018-05-12 01:05:25
-- @desc    WNDRoleCreation
--

local self = ui.new()
local _ENV = self

local AvatarSettings = {
	[1] = {}, [2] = {}
}
local function dress_equipset(Dresses)
	if type(Dresses) == "number" then Dresses = EquipSets[Dresses].Dresses end
	for i=1,CVar.DRESS_NUM do
		Self:set_dress(i, Dresses[i])
	end
end

local function update_player_view()
	if libunity.IsActive(player) then
		libgame.UpdateUnitView(player, 0, { model = Self:get_view_dresses() })
	end
end

local function set_random_name()
	if #Context[self.gender] == 0 then
		NW.send(NW.msg("PLAYER.CS.ROLE_RANDOM_NAME"):writeU32(self.gender))
	else
		local name = table.remove(Context[self.gender])
		Ref.SubName.inpName.text = name
	end
end

local function create_player_view()
	libgame.Recycle(player and player.gameObject)
	self.player = nil

	local GenderFaces = AvatarLIB.Faces[gender]
	Ref.GrpFaces:dup(#GenderFaces, function (i, Ent, isNew)
		local Face = GenderFaces[i]
		Ent.spIcon.spriteName = Face.icon
		if self.face == Face.id then Ent.tgl.value = true end
	end)

	local GenderHairs = AvatarLIB.Hairs[gender]
	Ref.GrpHairs:dup(#GenderHairs, function (i, Ent, isNew)
		local Hair = GenderHairs[i]
		Ent.spIcon.spriteName = Hair.icon
		if self.hair == Hair.id then Ent.tgl.value = true end
	end)
	for i,v in ipairs(HairColors) do
		if v.id == self.haircolor then
			Ref.GrpHColors:get(i).tgl.value = true
		break end
	end

	self.Self = _G.DEF.Human.new(0, "Human", 0, "")
	Self:set_view(gender, color, face, hair, haircolor)

	local eqTgl = libugui.GetTogglesOn(Ref.GrpEquipSet.go)[1]
	if eqTgl then
		dress_equipset(ui.index(eqTgl))
	else
		dress_equipset(self.DefEquips)
	end

	local PlayerForm = Self:get_form_data()
	local genderTag = CVar.GenderTag[gender]
	self.player = libgame.CreateView("/UIROOT/ROLE", "PlayerOverUI" .. genderTag,
		PlayerForm.Data.Attr.weapon, PlayerForm.View)

	libugui.SetAnchoredPos(Ref.evtModel, gender == 1 and -500 or -535)
	libugui.Follow(player, Ref.evtModel, gender == 1 and 2.5 or 2.4)
	libunity.FaceCamera(player)

	--切换完性别后重新刷新玩家名称
	--set_random_name()
end

local function check_name_legal(text)
	local errText = _G.PKG["ui/util"].chk_name_legal(text)
 	if errText then
 		UI.Toast.norm(errText)
 	end


 	return errText == nil
end

local function reset_role_view(gender)
	self.gender = gender

	local GenderFaces = AvatarLIB.Faces[gender]
	local Settings = AvatarSettings[gender]

	local faceIdx = Settings.face or 1
	local Face = GenderFaces[faceIdx]
	self.face = Face.id
	self.color = Face.color

	local GenderHairs = AvatarLIB.Hairs[gender]
	local hairIdx = Settings.hair or 1
	local Hair = GenderHairs[hairIdx]
	self.hair = Hair.id

	local haircolorIdx = Settings.haircolor or 1
	self.haircolor = HairColors[haircolorIdx].id
end

--!* [开始] 自动生成函数 *--

function on_evtmodel_drag(evt, data)
	local delta = data.delta
	local trans = player.transform
	local euler = trans.localEulerAngles
	euler.y = euler.y - delta.x
	trans.localEulerAngles = euler
end

function on_grpfaces_entface_click(tgl)
	if tgl.value and player then
		local index = ui.index(tgl)
		AvatarSettings[gender].face = index

		local Face = AvatarLIB.Faces[Self.gender][index]
		if Face then
			Self.color = Face.color
			Self.face = Face.id
			update_player_view()
		end
	end
end

function on_grphairs_enthair_click(tgl)
	if tgl.value and player then
		local index = ui.index(tgl)
		AvatarSettings[gender].hair = index

		local Hair = AvatarLIB.Hairs[Self.gender][index]
		Self.hair = Hair.id
		update_player_view()
	end
end

function on_grphcolors_entcolor_click(tgl)
	if tgl.value and player then
		local index = ui.index(tgl)
		AvatarSettings[gender].haircolor = index
		local HairC =  HairColors[index]
		self.haircolor = HairC.id
		Self.haircolor = self.haircolor
		update_player_view()
	end
end

function on_grpequipset_entset_click(tgl)
	if tgl.value and player then
		dress_equipset(ui.index(tgl))
		update_player_view()
	end
end

function on_subgender_tglmale_click(tgl)
	if tgl.value then
		reset_role_view(1)
		create_player_view()
	end
end

function on_subgender_tglfemale_click(tgl)
	if tgl.value then
		reset_role_view(2)
		create_player_view()
	end
end

function on_subname_btnrandom_click(btn)
	--set_random_name()
end

function on_btnenter_click(btn)
	local nm = NW.msg("PLAYER.CS.ROLE_HEAD_CHANGE")
	nm:writeU32(Self.gender):writeU32(Self.face):writeU32(Self.hair):writeU32(Self.haircolor)
	nm:writeString("")
	NW.send(nm)
end
--!* [结束] 自动生成函数  *--

function on_subname_inpname_submit(inp, text)
	-- 姓名有效性检查
	check_name_legal(text)
end

function init_view()
	ui.group(Ref.GrpFaces)
	ui.group(Ref.GrpHairs)
	ui.group(Ref.GrpHColors)
	ui.group(Ref.GrpEquipSet)
	--!* [结束] 自动生成代码 *--
	local ItemDEF = _G.DEF.Item

	self.AvatarLIB = config("avatarlib")
	self.HairColors = CVar.RoleHairColorsArray
	self.DefEquips = { nil, ItemDEF.new(6001), ItemDEF.new(7001), ItemDEF.new(8001), }
	if _G.ENV.debug then
		self.EquipSets = {
			{ name = "T0", Dresses = {}, },
			{ name = "T1", Dresses = { ItemDEF.new(5001), ItemDEF.new(6001), ItemDEF.new(7001), ItemDEF.new(8001), }, },
			{ name = "T2", Dresses = { ItemDEF.new(5002), ItemDEF.new(6002), ItemDEF.new(7002), ItemDEF.new(8002), }, },
			{ name = "T3", Dresses = { ItemDEF.new(5003), ItemDEF.new(6003), ItemDEF.new(7003), ItemDEF.new(8003), }, },
			--{ name = "T4", Dresses = { ItemDEF.new(5004), ItemDEF.new(6004), ItemDEF.new(7004), ItemDEF.new(8004), }, },
		}
	end

	local roleCamTrans = UE.GameObject.FindGameObjectWithTag("RoleCamera").transform
	roleCamTrans.localEulerAngles = UE.Vector3(7, 0, 0)
end

function init_logic()
	libasset.LoadAsync(nil, "fmod/worldmapBGM/", "Cache",function () 
			AUD.push("Music/C_WorldmapBGM")
	end)
	
	ui.moveout(Ref.spBack, 1)

	if Context == nil then Context = {{},{}} end

	if EquipSets then
		Ref.GrpEquipSet:dup(#EquipSets, function (i, Ent, isNew)
			local Set = EquipSets[i]
			Ent.lbName.text = Set.name
		end)
	end

	Ref.GrpHColors:dup(#HairColors, function (i, Ent, isNew)
		local HairC = HairColors[i]
		Ent.spIcon.color = HairC.color
		if i == 1 then Ent.tgl.value = true end
		-- 隐藏的发色
		if HairC.hide then Ent.go:SetActive(false) end
	end)

	reset_role_view(1)

	Ref.SubGender.tglMale.value = true

	--set_random_name()
end

function show_view()

end

function on_recycle()
	--AUD.pop()

	libugui.AllTogglesOff(Ref.SubGender.go)
	libugui.AllTogglesOff(Ref.GrpFaces.go)
	libugui.AllTogglesOff(Ref.GrpHairs.go)
	libugui.AllTogglesOff(Ref.GrpHColors.go)
	libugui.AllTogglesOff(Ref.GrpEquipSet.go)
	libgame.Recycle(player and player.gameObject)
	self.player = nil

	ui.putback(Ref.spBack, Ref.go)

	local roleCamTrans = UE.GameObject.FindGameObjectWithTag("RoleCamera").transform
	roleCamTrans.localEulerAngles = UE.Vector3(10, 0, 0)
end

Handlers = {
	["PLAYER.SC.ROLE_HEAD_CHANGE"] = function (Ret)
		if Ret.err == nil then
			NW.send(NW.msg("LOGIN.CS.ENTER_GAME"), "LOGIN.SC.ENTER_GAME")
		end
	end,

	["PLAYER.SC.ROLE_RANDOM_NAME"] = function (RanNameArr)
		Context[RanNameArr.sex] = RanNameArr.RanNames
		--set_random_name()
	end,
}
return self

