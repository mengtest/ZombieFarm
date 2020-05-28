--
-- @file    ui/login/lc_wnddownload.lua
-- @author  xingweizhen
-- @date    2018-10-23 14:16:24
-- @desc    WNDDownload
--

local self = ui.new()
local _ENV = self

local function show_download_progress(progress)
	Ref.lbContent.text = TEXT.fmtAssetDownloading:csfmt(string.format("%0.1f%%", progress * 100))
end

local function show_unpack_progress(progress)
	if progress < 1 then
		Ref.lbContent.text = TEXT.fmtAssetUnpacking:csfmt(string.format("%0.1f%%", progress * 100))
	else
		Ref.lbContent.text = TEXT.asset_complete
	end
end

--!* [开始] 自动生成函数 *--
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	local dl, upk = SCENE.get_progress()
	if dl then
		show_download_progress(dl)
	elseif upk then
		show_unpack_progress(upk)
	end
end

function show_view()

end

function on_recycle()

end

Handlers = {
	["CLIENT.SC.DOWNLOADING_ASSET"] = show_download_progress,
	["CLIENT.SC.UNPACKING_ASSET"] = show_unpack_progress,
}

return self

