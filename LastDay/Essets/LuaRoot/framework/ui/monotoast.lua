--
-- @file 	framework/ui/monotoast.lua
-- @anthor  xing weizhen (xingweizhen@rongygame.com)
-- @date	2016-03-16 10:19:34
-- @desc    描述
--

local ToastQueue = _G.DEF.Queue.new()
local CurrToast

local function on_fade_out(go)
	libunity.Recycle(go)
	if CurrToast and CurrToast.Ref.go == go then
		CurrToast = nil
	end
end

local function invoking_toast()
    while ToastQueue:count() > 0 do
    	local Toast = ToastQueue:peek()
    	if CurrToast == nil or CurrToast ~= Toast then
    		if CurrToast then
	    		libugui.DOFade(CurrToast.Ref.go, "Out", on_fade_out)
	    	end
    		CurrToast = Toast
	    	CurrToast:start()
	    	coroutine.yield(CurrToast.stay)
	    end
    	ToastQueue:dequeue()
	end
end

local InitFunctions = {
	Icon = function (self)
		local Ref = self.Ref
		Ref.lbTips.text = self.args.tips
		Ref.lbTips.color = self.color or "#C5C5C5"
		Ref.spIcon:SetSprite(self.args.icon)
		Ref.spIcon.color = self.color or "#FFFFFF"
		libugui.DOFade(Ref.go, "In", on_fade_out, true)
	end,
}

local DefCanvas = {
	Play = 1,
	Icon = 1,
}

local DefDepth = {

}
--=============================================================================

local OBJDEF = {}
OBJDEF.__index = OBJDEF
OBJDEF.__eq = function (a, b)
	return a.style == b.style and a.args == b.args
end

function OBJDEF.make(style, args, depth, canvas)
	if style == nil then style = "Norm" end
    return setmetatable({
    	args = args,
    	style = style,
    	init = InitFunctions[style],
    	depth = depth or DefDepth[style],
    	canvas = canvas or DefCanvas[style],
    }, OBJDEF)
end

function OBJDEF:start()
	local go = ui.create("UI/"..self.style.."Toast", self.depth, self.canvas)
    self.Ref = ui.ref(go)
	self:init()
end

function OBJDEF:init()
	local Ref = self.Ref
	Ref.lbTips.color = self.color or "#C5C5C5"
	Ref.lbTips.text = self.args
	libugui.DOFade(Ref.go, "In", on_fade_out, true)
end

function OBJDEF:show(stay, color)
	self.stay = stay
	self.color = color
	ToastQueue:enqueue(self)
	if ToastQueue:count() == 1 then
		libunity.StartCoroutine(nil, invoking_toast)
	end
end

function OBJDEF.clear(style)
	if style == nil then
		ToastQueue:clear()
	else
		for _,v in ipairs(ToastQueue) do
			if v.style == style then v.ignore = true end
		end
	end
end

_G.UI.MonoToast = OBJDEF
