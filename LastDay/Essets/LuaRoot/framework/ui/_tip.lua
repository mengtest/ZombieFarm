--
-- @file 	ui/_tool/_tip.lua
-- @anthor  xing weizhen (xingweizhen@firedoggame.com)
-- @date	2016-11-05 14:36:05
-- @desc    描述
--

local function coro_show(self, target)
	libngui.SetAlpha(self.go, 0)

	coroutine.yield()
	local root = libunity.FindGameObject(self.go, "SubMain")
	libngui.AnchorTo(root, self.from, target, self.to, self.offset.x, self.offset.y)
	libngui.InsideScreen(root)
	libngui.SetAlpha(self.go, 1)
end

local OBJDEF = {}
OBJDEF.__index = OBJDEF
OBJDEF.__tostring = function (self)
	return string.format("[提示:{%s}]", table.concat(self.List, ","))
end

function OBJDEF.new(event, depth)
	local self = {
		List = {},
		from = "Bottom",
		to = "Top",
		offset = UE.Vector2.zero,
		event = event,
		depth = depth,
	}

	local Delegate = System.Delegate
	if event == "onPress" then
		self.Event = {
			[event] = Delegate.Create("EventDelegate.Callback", function ()
				local evt = NGUI.UINotify.current
				if evt.pressed then
					self:show(evt, self.depth):anchor(evt)
				else
					self:hide()
				end
			end)
		}
	elseif event == "onClick" then
		self.Event = {
			[event] = Delegate.Create("EventDelegate.Callback", function ()
				local evt = NGUI.UINotify.current
				if not libunity.IsActive(self.go) then
					self:show(evt, self.depth)
				end
			end)
		}
	else
		self.Event = {}
	end
	
	return setmetatable(self, OBJDEF)
end

function OBJDEF:release()
	local event = self.event
	if event and #event > 0 then
		for uobj,_ in pairs(self.List) do
			local evt = uobj:GetComponent("UINotify")
			if evt then evt[event]:Clear() end
		end
	end
end

function OBJDEF:reg(uobj)
	local event = self.event
	if event and #event > 0 then
		local UINotify = typeof(UGUI.UINotify)
		local evt = uobj:GetComponent(UINotify) or uobj.gameObject:AddComponent(UINotify)
		local onEvent = evt[event]
		onEvent:Clear()
		onEvent:Add(self.Event[event])
		return evt
	else
		return uobj
	end	
end

function OBJDEF:add(key, value)
	local evt = self:reg(key)
	self.List[evt] = value
	return self
end

function OBJDEF:set_anchor(from, to, offset)
	self.from, self.to, self.offset = from, to, offset
	return self
end

function OBJDEF:set_event(on_show, on_hide)
	self.on_show = on_show
	self.on_hide = on_hide
	return self
end

function OBJDEF:show(index, depth)
	local Obj = self.List[index]
	if Obj and Obj.show_tip then
		self:hide()
		self.go = Obj:show_tip(self.event, depth)
		if self.on_show then self:on_show() end
	else
		libunity.LogW("{0}没有show_tip方法", Obj)
	end
	return self
end

function OBJDEF:anchor(target)
	if libunity.IsActive(self.go) then
		libunity.StartCoroutine(self.go, coro_show, self, target)
	end
	return self
end

function OBJDEF:hide()
	if libunity.IsActive(self.go) then
		_G.PKG["ui/uimgr"].close(self.go)
		if self.on_hide then self:on_hide() end
		self.go = nil
	end
end

function OBJDEF.text(content)
	local UIMGR = _G.PKG["ui/uimgr"]
	if content then
		local root = ui.create("UI/TIPText")
		local Sub = ui.ref(root)
		if Sub.btnClose.onClick.Count == 0 then
			Sub.btnClose.onClick:Add(OBJDEF.text)
		end
		Sub.lbContent.text = content
		
		libunity.ReActive(root)
		OBJDEF["GO:TextTip"] = root
	else
		UIMGR.ani_close(OBJDEF["GO:TextTip"])
		OBJDEF["GO:TextTip"] = nil
	end
end

_G.UI.Tip = OBJDEF
