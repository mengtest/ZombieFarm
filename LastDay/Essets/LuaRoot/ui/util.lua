--
-- @file    ui/util.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-01-21 12:31:44
-- @desc    描述
--

local P = {}

local InteractStyles = {
	Yellow = {
		Normal = "atlas/Common/btn_com_007",
		Highlighted = "atlas/Common/btn_com_007",
		Pressed = "atlas/Common/btn_com_008",
		Disabled = "atlas/Common/btn_com_029",
	},
	Orange = {
		Normal = "atlas/Common/btn_com_027",
		Highlighted = "atlas/Common/btn_com_027",
		Pressed = "atlas/Common/btn_com_028",
		Disabled = "atlas/Common/btn_com_029",
	},
	Red = {
		Normal = "atlas/Common/btn_com_010",
		Highlighted = "atlas/Common/btn_com_010",
		Pressed = "atlas/Common/btn_com_002",
		Disabled = "atlas/Common/btn_com_029",
	},
	Blue = {
		Normal = "atlas/Common/btn_com_030",
		Highlighted = "atlas/Common/btn_com_030",
		Pressed = "atlas/Common/btn_com_031",
		Disabled = "atlas/Common/btn_com_029",
	},
}

function P.set_interact_style(uObj, style)
	local Style = InteractStyles[style]
	for k,v in pairs(Style) do
		libugui.SetStateSprite(uObj, k, v)
	end
end

-- function P.flex_itementlist(Root, sibling, stretch, ...)
-- 	for k,v in pairs(Root) do
-- 		if type(v) == "table" then
-- 			local ent = v.go
-- 			local sub = ent.transform:Find("FlexItem=")
-- 			if sub == nil then
-- 				local go = libunity.NewChild(ent, "UI/FlexItem=")
-- 				libunity.SetSibling(go, sibling or 0)
-- 				libugui.AnchorStretch(go, stretch or 3, ...)
-- 				Root[k] = libugui.GenLuaTable(ent, "go")
-- 			end
-- 		end
-- 	end
-- end

function P.flex_itement(Root, subName, sibling, stretch, ...)
	local Sub = Root[subName]
	if Sub == nil then return end

	local ent = Sub.go
	local sub = ent.transform:Find("FlexItem=")
	if sub == nil then
		local go = libunity.NewChild(ent, "UI/FlexItem=")
		libunity.SetSibling(go, sibling or 0)
		libugui.AnchorStretch(go, stretch or 3, ...)
		Sub = ui.ref(ent, "go")
		Root[subName] = Sub
	end
	return Sub
end

function P.flex_itemgrp(Grp, sibling, stretch, ...)
	local ent = Grp.Ent.go
	local sub = ent.transform:Find("FlexItem=")
	if sub == nil then
		local go = libunity.NewChild(ent, "UI/FlexItem=")
		libunity.SetSibling(go, sibling or 0)
		libugui.AnchorStretch(go, stretch or 3, ...)
	end
end

function P.show_item_view(Item, Ent, defSprite, clip, forceShowAmount)
	if Ent then
		if Item and Item.dat and Item.dat ~= 0 then
			Item:show_view(Ent, clip, forceShowAmount)
		else
			Ent.spIcon:SetSprite(defSprite)
			if Ent.spRarity then Ent.spRarity:SetSprite(nil) end
			if Ent.lbAmount then Ent.lbAmount.text = nil end
			if Ent.barVal then libunity.SetActive(Ent.barVal, false) end
			if Ent.spSuperior then libunity.SetActive(Ent.spSuperior, false) end
		end
	end
end

function P.show_attr_view(Grp, Attr, Keys, Args)
	local AttrDEF = _G.DEF.Attr
	local sign, ignore0
	local callback
	if Args then
		sign, ignore0 = Args.sign, Args.ignore0
		callback = Args.callback
	end

	Grp:dup(#Keys, function (i, Ent, isNew)
		local attr = Keys[i]
		local value = Attr[attr]
		local sn = AttrDEF.sign_value(attr, value)
		if ignore0 and sn == 0 then Ent.go:SetActive(false); return end
		if callback then callback(i, Ent, attr, sn) end

		AttrDEF.seticon(attr, Ent.spIcon)
		if attr == "fast" and value == 0 then
			-- 攻速为零时，使用拳头的攻速属性
			value = AttrDEF.default(attr)
		end
		Ent.lbValue.text = AttrDEF.conv_value(attr, value)
	end)
end

function P.chk_name_legal(text)
	local TEXT = _G.TEXT
	local errText
	-- local length = utf8.len(text)
	-- if length < 2 then
	-- 	errText = TEXT.IllegalName.tooShort
	-- elseif length > 14 then
	-- 	errText = TEXT.IllegalName.tooLong
	-- else
	if text == DY_DATA:get_player().name then
		errText = TEXT.IllegalName.unchanged
	end

	return errText
end

function P.tween_cooldown(spCooldown, count, cycle)
	libunity.SetActive(spCooldown, true)
	local value = count / cycle
	spCooldown.fillAmount = value
	libugui.DOTween(nil, spCooldown, value, 0, {
			duration = count,
			complete = libunity.SetActive,
		})
end

-- 显示当前的主要任务目标
function P.show_goal_view(Sub, taskType)
	local Goal = rawget(DY_DATA, "Goal")
	if Goal then
		if Sub then
			libunity.SetActive(Sub.SubGoal.go,true)
			Sub.SubGoal.lbGoal.text = Goal.name
		end
		return Goal
	end

	local Task, TaskBase = DY_DATA:get_top_task(taskType)
	if TaskBase then
		local taskName = TaskBase.name()
		if #taskName > 0 then
			if Sub then
				libunity.SetActive(Sub.SubGoal.go,true)
				Sub.SubGoal.lbGoal.text = taskName
			end
			return Task
		end
	end

	if Task then
		if Sub then
			libunity.SetActive(Sub.SubGoal.go,true)
			Sub.SubGoal.lbGoal.text = "Task#" .. Task.id
		end
		return Task
	else
		if Sub then
			libunity.SetActive(Sub.SubGoal.go,false)
			Sub.SubGoal.lbGoal.text = nil
		end
	end
end

-- 启动倒计时UI
function P.start_time_counting(go, lbTime, start, add, fmt, secs2string, recycle)
	if secs2string == nil then secs2string = os.secs2clock end

	local timeTxt = secs2string(start)
	lbTime.text = fmt and fmt:csfmt(timeTxt) or timeTxt

	libunity.InvokeRepeating(go, 1, 1, function ()
		start = start + add
		local timeTxt = secs2string(start)
		lbTime.text = fmt and fmt:csfmt(timeTxt) or timeTxt
		if start < 0 then
			if recycle then recycle(go) end
			return true
		end
	end)
end

function P.check_text_string(str)
	local strNum = tonumber(str)
	if strNum then
		local textStr = config("textlib").get_dat(tonumber(str))
		if not string.find(textStr,"Text#") then
			return textStr
		end
	end

	return str

end
return P
