--
-- @file    ui/main/lc_frmscrollingmessage.lua
-- @author  Administrator
-- @date    2018-10-22 18:28:43
-- @desc    FRMScrollingMessage
--

local self = ui.new()
local _ENV = self

local StrList = {}

local function rfsh_chat_ent(Msg)
	local Sender = Msg.Sender
	local Content = Msg.Content
	local contentStr = Content.text
	local contentTab ={ sort = Sender.id , text = contentStr }
	table.insert(StrList, contentTab)
end
local function start_scrolling_message()
    local beginX = 340
    local duration = 10
    local speed = 50
    local m_text = Ref.SubNewsticker.lbText
	self.scrolling = true
    while #StrList > 0 do
    	local msg = table.remove(StrList,1)
    	m_text.text = ""
        libugui.SetAnchoredPos(m_text,beginX,0,0)
        local str = msg.text
        local strarr = str:split("|")

		if #strarr > 2 then
			local mailId = strarr[1]
			local content = tostring(config("othertextlib").get_dat(tonumber(mailId)))
			if content then
				str = string.gsub(content,strarr[2],strarr[3])
			end
		end

        m_text.text = str

        local sizeDelta = libugui.GetRectSize(m_text,true)--文本自身的长度.
        
    	local distance = beginX + sizeDelta.x
        duration = distance / speed

        libugui.DOTween("Position", m_text, nil, UE.Vector3(-sizeDelta.x, 0, 0), {
			duration = duration,
		})
		coroutine.yield(duration + 0.1)

	end
	coroutine.yield()
	m_text.text = ""
    self.scrolling = false

	self:close()
end
local function check_show_message()

    if not self.scrolling then
    	libunity.StopAllCoroutine(Ref.SubNewsticker.go)
    	libunity.StartCoroutine(Ref.SubNewsticker.go,start_scrolling_message)
    end

end
local function sort_msg(a, b)
	return a.sort > b.sort
end
local function rfsh_detail_chat()
	if DY_DATA.ScrollingMsgs then
		for i,v in ipairs(DY_DATA.ScrollingMsgs) do
			rfsh_chat_ent(v)
		end
		table.sort( StrList, sort_msg )
		DY_DATA.ScrollingMsgs = nil
		check_show_message()
	end
end



---------------------

--!* [开始] 自动生成函数 *--
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--

	self.scrolling = false
end

function init_logic()
    rfsh_detail_chat()
end

function show_view()

end

function on_recycle()

end

Handlers = {

	["CHAT.SC.CHAT_BROADCAST"] = function ()
		rfsh_detail_chat()
	end,
}
return self

