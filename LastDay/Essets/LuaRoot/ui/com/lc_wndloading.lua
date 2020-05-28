--
-- @file    ui/com/lc_wndloading.lua
-- @author  xingweizhen
-- @date    2017-10-22 10:19:31
-- @desc    WNDLoading
--

local self = ui.new()
setfenv(1, self)

function bundle_loaded(_, bundleName)

end

function level_loaded(_, levelName)
	self.levelName = levelName
	if levelName:sub(1, 5) ~= "stage" then
		self:close()
	end
end

local function rfsh_role_healthy()
	local GrpHealthy = Ref.SubMain.GrpHealthy
	local Self = DY_DATA:get_self()
	if Self == nil then
		GrpHealthy:hide()
		return
	end

	local HpEnt, isNew = GrpHealthy:gen(1)
	if isNew then
		HpEnt.spFill:SetSprite("Common/ico_com_001")
		HpEnt.spFill:SetNativeSize()
		HpEnt.spFill.color = "#FF0000"

		HpEnt.spIcon.overrideSprite = HpEnt.spFill.overrideSprite
		HpEnt.spIcon:SetNativeSize()
	end

	local value, limit = Self.hp or Self.Attr.hp, Self.Attr.hp
	HpEnt.lbValue.text = value
	HpEnt.spFill.fillAmount = value / limit

	local function show_healthy_view(index, Data)
		local Ent, isNew = GrpHealthy:gen(index)
		if isNew then
			Data:show_ico(Ent.spFill)
			Ent.spFill:SetNativeSize()

			Ent.spIcon.overrideSprite = Ent.spFill.overrideSprite
			Ent.spIcon:SetNativeSize()
		end

		Ent.lbValue.text = Data.amount
		Ent.spFill.fillAmount = Data.amount / 100
	end

	show_healthy_view(2, Self.Hunger)
	show_healthy_view(3, Self.Thirsty)
end

--!* [开始] 自动生成函数 *--
--!* [结束] 自动生成函数  *--

local function check_allow_scene_activation()
	local allowSceneActivation = table.take(_G.SCENE, "allowSceneActivation")
	if allowSceneActivation ~= nil then
		libunity.SendMessage(Ref.go, "AllowLoadScene", allowSceneActivation)
	end
end

function init_view()
	ui.group(Ref.SubMain.GrpHealthy)
	--!* [结束] 自动生成代码 *--
	check_allow_scene_activation()
end

function init_logic()
	libugui.SetAlpha(Ref.go, 1)

	local limitLoadingBGM = table.take(_G.SCENE, "limitLoadingBGM")
	if not limitLoadingBGM then

		libasset.LoadAsync(nil, "fmod/worldmapBGM/", "Cache",function ()
			AUD.new("Music/C_WorldmapBGM")
			end)

	end

	local Asset4LoadingLevel = table.take(DY_DATA, "Asset4LoadingLevel")
	libunity.SetActive(Ref.SubMain.go, Asset4LoadingLevel)
	--libunity.SetActive(Ref.spLoading, not Asset4LoadingLevel)
	libugui.SetTexture(Ref.spLoading, Asset4LoadingLevel and "rawtex/bg_com_001/bg_com_001" or "rawtex/bg_com_002/bg_com_002")

	if Asset4LoadingLevel then
		rfsh_role_healthy()
		local SubTips = Ref.SubMain.SubTips
		local Tip = Asset4LoadingLevel.Tip
		local SubInfo = Ref.SubMain.SubInfo
		local entId = Asset4LoadingLevel.entId
		if entId then
			local EntData = config("maplib").get_ent(entId)
			SubInfo.lbMapName.text = EntData.name
			libugui.SetTexture(SubInfo.spLoading, Asset4LoadingLevel.picPath)
			local Stage = DY_DATA:get_stage()
			if Stage and Stage.timeScale then
				SubInfo.lbTime.text = string.format("%02d:00", Stage.timeScale)
			else
				SubInfo.spWeather:SetSprite("")
				SubInfo.lbTime.text = nil
			end

			local Session = _G.PKG["network/login"].get_session()
			if Session then
				libsystem.SetAppTitle(string.format("%s@%s - %s",
					Session.Account.acc, Session.Server.serverName, EntData.name))
			end
		else
			SubInfo.spWeather:SetSprite("")
			SubInfo.lbTime.text = nil

			SubInfo.lbMapName.text = TEXT.globalMap
			libugui.SetTexture(SubInfo.spLoading, "")
		end
		SubTips.lbTitle.text = Tip.title
		SubTips.lbTips.text = Tip.content

		local hasIcon = Tip.icon and #Tip.icon > 0
		libunity.SetActive(GO(SubTips.go, "Border="), hasIcon)
		if hasIcon then
			ui.seticon(SubTips.spIcon, Tip.icon)
		end
	end

	libunity.SetActive(Ref.barProgress, not table.take(SCENE, "hideLoadingBar"))
end

function show_view()

end

function on_recycle()
	local scene_bgm =_G.SCENE.BGMForScene[levelName]
	if scene_bgm then
		AUD.new(scene_bgm)
	end
	local closeWNDPrelude = table.take(_G.SCENE, "CloseWNDPrelude")
	if closeWNDPrelude then
		closeWNDPrelude()
	end
end

return self

