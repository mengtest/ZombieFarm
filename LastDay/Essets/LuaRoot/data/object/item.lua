--
-- @file    data/object/item.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-11-06 09:56:41
-- @desc    描述
--

local OBJDEF = {}
OBJDEF.__index = OBJDEF
OBJDEF.__tostring = function (self)
	return string.format("[Item#%s@%s x%s]",
		tostring(self.dat), tostring(self.pos), tostring(self.amount))
end

OBJDEF.LIB = "itemlib"
OBJDEF.get_base_data = table.get_base_data

--tips白名单
local ShowTipAttrIDMap = {
	"Damage",
	"def",
	"hp",
	"move",
	"fast",
}

local AssetIcos = {
	-- 体力
	[1] = { icon = "Common/ico_com_005", color = "#91E619" },
	-- 生命值
	[6] = { icon = "Common/ico_com_001", color = "#FFFFFF" },
	-- 饱食度
	[8] = { icon = "Common/ico_com_002", color = "#F05A3C" },
	-- 饱水度
	[9] = { icon = "Common/ico_com_003", color = "#517EF0" },
	--
}

local RarityIcon = {
	[2] = { icon = "Common/frm_com_085", color = "#57ff63",},
	[3] = { icon = "Common/frm_com_085", color = "#2b78ff",},
	[4] = { icon = "Common/frm_com_085", color = "#9c47ec",},
}

function OBJDEF.gen(Data)
	return OBJDEF.new(Data.id, Data.amount)
end

function OBJDEF.new(dat, amount)
	local self = { dat = dat, amount = amount, }
	return setmetatable(self, OBJDEF)
end

function OBJDEF.create(pos, dat, amount)
	local self = { pos = pos, dat = dat, amount = amount, }
	return setmetatable(self, OBJDEF)
end

function OBJDEF.dup(Src)
	local self = {
		pos = Src.pos,
		dat = Src.dat,
		amount = Src.amount,
		RanAttr = Src.RanAttr,
	}
	return setmetatable(self, OBJDEF)
end

function OBJDEF:set_dat(dat)
	self.dat = dat
	self.Base = nil
end

function OBJDEF:damaged()
	local dura, _ = self:get_durability()
	if dura == 0 then
		local Base = self:get_base_data()
		return not Base.lossless
	end
end

function OBJDEF:usable()
	local maxDura, _ = self:get_max_durability()
	local dura, _ = self:get_durability()
	return maxDura == nil or maxDura == 0 or dura > 0
end

-- Equip APIs:

function OBJDEF:has_reload()
	local maxAmmo = self:get_base_data().ammo
	return maxAmmo and maxAmmo > 0
end

function OBJDEF:set_durability(dura, ammo)
	local RanAttr = table.need(self, "RanAttr")
	RanAttr[1] = dura
	RanAttr[2] = ammo
end

function OBJDEF:get_max_durability()
	local Base = self:get_base_data()
	return Base.lossless and 0 or Base.dura, Base.ammo
end

function OBJDEF:get_durability()
	local RanAttr = self.RanAttr
	local dura, ammo
	if self.RanAttr then
		dura, ammo = RanAttr[1], RanAttr[2]
	end

	local maxDura, maxAmmo = self:get_max_durability()
	if dura == nil then
		dura = maxDura
		self.dura = dura
	end
	if ammo == nil then
		ammo = maxAmmo
		self.ammo = ammo
	end
	return dura, ammo
end

function OBJDEF:calc_attr()
	local Base = self:get_base_data()
	if Base.Attr then
		local Attr = Base.Attr
		if Base.ExAttr then Attr = Attr + Base.ExAttr end
		if Base.sneak == false then
			return Attr + _G.DEF.Attr.new({ sneak = -10, })
		else
			return Attr
		end
	end
end

function OBJDEF:get_weapon_data()
	local Base = self:get_base_data()

	local maxDura, maxAmmo = self:get_max_durability()
	local dura, ammo = self:get_durability()
	return {
		pos = self.pos, dat = self.dat,
		model = Base.model,
		index = Base.affixIdx,
		prepare = Base.prepare,
		Attr = {
			pose = Base.wType,
		},
		Skills = Base.Skills,
		reload = Base.reload,
		Passive = Base.Passive,
		fxBundle = Base.fxBundle,
		sfxBank = Base.sfxBank,
		maxDura = maxDura, dura = dura,
		maxAmmo = maxAmmo, ammo = ammo,
	}
end

function OBJDEF:get_dress_data(suffix)
	local Base = self:get_base_data()
	local dressType = _G.CVar.SType2Dress[Base.sType]
	local modelName = suffix and Base.model .. suffix or Base.model
	return {
		index = Base.affixIdx,
		path = string.format("%s/%s/%s", dressType, modelName, modelName),
	}
end

function OBJDEF:read_data(nm)
	self.amount = nm:readU32()

	local RanAttr = table.need(self, "RanAttr")
	local nAttr = nm:readU32()
	for i=1,nAttr do
		local id, value = nm:readU32(), nm:readU32()
		RanAttr[id] = value
	end
end

function OBJDEF:show_ico(spIcon)
	local Ico = AssetIcos[self.dat]
	if Ico then
		ui.seticon(spIcon, Ico.icon)
		spIcon.color = Ico.color
	end
end

function OBJDEF:show_icon(spIcon, clip)
	local Base = self:get_base_data()
	if Base then
		ui.seticon(spIcon, Base.icon, clip)
		libugui.SetColor(spIcon,  "#FFFFFF")
	else
		ui.seticon(spIcon, "Common/_null", clip)
		libugui.SetColor(spIcon,  "#000000")
	end

	libugui.SetAlpha(spIcon, (self.amount == nil or self.amount > 0) and 1 or 0.5)
end

function OBJDEF:show_rarityIcon(spBorder)
	if spBorder then
		local Base = self:get_base_data()
		if Base then
			local RarityInfo = RarityIcon[Base.rarity]
			local icon = RarityInfo and RarityInfo.icon or nil
			local color = RarityInfo and RarityInfo.color or "#FFFFFF"
			ui.seticon(spBorder, icon)
			libugui.SetColor(spBorder, color)
		else
			ui.seticon(spBorder, nil)
			libugui.SetColor(spBorder, "#FFFFFF")
		end
	end
end

function OBJDEF:show_view(Ent, clip, forceShowAmount)
	self:show_icon(Ent.spIcon, clip)
	self:show_rarityIcon(Ent.spRarity)

	local Base = self:get_base_data()
	if Base then
		if Ent.lbAmount then
			Ent.lbAmount.text = forceShowAmount and
				(self.amount or 0) or (Base.nStack > 1 and self.amount or "")
		end

		if Ent.lbName then Ent.lbName.text = cfgname(Base) end
		if Ent.lbDesc then Ent.lbDesc.text = Base.desc end
		if Ent.lbScore then Ent.lbScore.text = Base.score end
		if Ent.spSuperior then libunity.SetActive(Ent.spSuperior, Base.isRefined) end
	else
		if Ent.lbAmount then Ent.lbAmount.text = "" end
		if Ent.lbName then Ent.lbName.text = "" end
		if Ent.lbDesc then Ent.lbDesc.text = "" end
		if Ent.lbScore then Ent.lbScore.text = "" end
		if Ent.spSuperior then libunity.SetActive(Ent.spSuperior, false) end
	end

	if Ent.barVal then
		local maxDura = self:get_max_durability() or 0
		libunity.SetActive(Ent.barVal, maxDura > 0)
		if maxDura > 0 then
			local dura = self:get_durability()
			Ent.barVal.value = dura / maxDura
		else
			Ent.barVal.value = 1
		end
	end
end

function OBJDEF.clear_view(Ent)
	Ent.spIcon:SetSprite("")
	if Ent.lbAmount then Ent.lbAmount.text = nil end
	libunity.SetActive(Ent.barVal, false)
end

function OBJDEF:gen_dura_tip()
	local dura, ammo = self:get_durability()
	local maxDura, maxAmmo = self:get_max_durability()
	local strDura, strAmmo = nil, ""
	local TEXT = _G.TEXT
	local colon = TEXT[":"]
	if maxDura and maxDura > 0 then
		strDura = string.format("%s%s%d/%d", TEXT.nameDura, colon, dura, maxDura)
	end
	if maxAmmo and maxAmmo > 0 then
		strAmmo = string.format("%s%s%d/%d", TEXT.nameAmmo, colon, ammo, maxAmmo)
	end

	if strDura then
		return { strDura, strAmmo }
	end
end

function OBJDEF:gen_attr_tip()
	local AttrNames = _G.TEXT.CFG_FIELD_NAME
	local colon = _G.TEXT[":"]
	local AttrDEF = _G.DEF.Attr
	local Base = self:get_base_data()
	local Content = {}
	if Base.Attr then
		for i,v in pairs(ShowTipAttrIDMap) do
			local attr = v
			local value = Base.Attr[attr]
			local sn = AttrDEF.sign_value(attr, value)
			if sn ~= 0 then
				local showValue = AttrDEF.conv_value(attr, value)
				if value ~= 0 then
					table.insert(Content, string.format("%s%s%s", AttrNames[attr], colon, showValue))
				end
			end
		end
	end
	return Content
end

function OBJDEF:show_tip(go, Diff)
	local Vector2 = UE.Vector2
	local Wnd = ui.show("UI/TIPItem", 0)
	local Ref = ui.ref(Wnd.go)
	local TIPItemView = Ref.SubTIPItem
	ui.group(TIPItemView.GrpAttrs)

	local Base = self:get_base_data()
	if _G.ENV.debug then
		local duraStr = ""
		local maxDura, maxAmmo = self:get_max_durability()
		if maxDura then
			local dura, ammo = self:get_durability()
			duraStr = self.pos and "[dur:"..dura.."/"..maxDura.."]" or "[dur:" .. dura .. "]"
		end
		TIPItemView.lbName.text = cfgname(Base)..duraStr
	else
		TIPItemView.lbName.text = Base.name
	end

	TIPItemView.lbDesc.text = "<line-indent=10%>" .. Base.desc

	libunity.SetActive(TIPItemView.GrpAttrs.go, Base.Attr ~= nil)
	if Base.Attr then
		local DiffAttr
		if Diff then
			if type(Diff) == "table" then
				local DiffBase = Diff:get_base_data()
				if DiffBase.Attr then DiffAttr = Base.Attr - DiffBase.Attr end
			else
				DiffAttr = Base.Attr
			end
		end

		TIPItemView.GrpAttrs:hide()
		local AttrDEF = _G.DEF.Attr
		local n = 1
		for i,v in pairs(ShowTipAttrIDMap) do
			local attr = v
			local value = Base.Attr[attr]
			local sn = AttrDEF.sign_value(attr, value)
			local diff = DiffAttr and DiffAttr[attr]
			local diffSn = diff and AttrDEF.sign_value(attr, diff) or 0
			if sn ~= 0 or diffSn ~= 0 then
				local showValue = AttrDEF.conv_value(attr, value)
				local Ent = TIPItemView.GrpAttrs:gen(n)
				AttrDEF.seticon(attr, Ent.spIcon)
				Ent.lbValue.text = showValue

				if diffSn ~= 0 then
					libugui.SetVisible(Ent.spDiff, true)
					if diffSn > 0 then
						Ent.lbDiff.color = "#82D250"
						Ent.spDiff.color = "#82D250"
						Ent.spDiff.transform.localEulerAngles = UE.Vector3(0, 0, 180)
					else
						Ent.lbDiff.color = "#DC1E46"
						Ent.spDiff.color = "#DC1E46"
						Ent.spDiff.transform.localEulerAngles = UE.Vector3.zero
					end

					Ent.lbDiff.text = AttrDEF.conv_value(attr, diff, false)
				else
					libugui.SetVisible(Ent.spDiff, false)
					Ent.lbDiff.text = nil
				end

				n = n + 1
			end
		end
	end

	local pos = libunity.CameraForLayer(go):WorldToViewportPoint(go.transform.position)
	if pos.x < 0.5 then
		libugui.DOAnchor(TIPItemView.go, Vector2(0, 1), go, Vector2(1, 1))
	else
		libugui.DOAnchor(TIPItemView.go, Vector2(1, 1), go, Vector2(0, 1))
	end
	--libugui.InsideScreen(Wnd.go)
end

function OBJDEF.hide_tip()
	ui.close("TIPItem")
end

function OBJDEF:play_drag()
	libunity.PlayAudio(self:get_base_data().dragSfx)
end

function OBJDEF:play_drop(slot)
	if slot == nil then slot = self.pos end

	local Base = self:get_base_data()
	local sfxName
	if slot > _G.CVar.EQUIP_POS_ZERO and slot < _G.CVar.OBJ_ITEM_LIMIT then
		sfxName = Base.equipSfx
		if sfxName == nil or #sfxName == 0 then
			sfxName = Base.dropSfx
		end
	else
		sfxName = Base.dropSfx
	end
	libunity.PlayAudio(sfxName)
end

function OBJDEF:play_loss()
	local Base = self:get_base_data()
	if Base then
		local lossSfx = Base.lossSfx
		if lossSfx and #lossSfx > 0 then
			libunity.PlayAudio(lossSfx)
		end
	end
end

return OBJDEF
