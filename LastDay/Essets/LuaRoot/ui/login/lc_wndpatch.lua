--
-- @file    ui/login/lc_wndpatch.lua
-- @author  xingweizhen
-- @date    2018-09-03 21:05:59
-- @desc    WNDPatch
--

local self = ui.new()
local _ENV = self

local libcsharpio = require "libcsharpio.cs"
local patchRoot, bundleRoot
local filelist = "filelist"

local failCount
local function on_download_fail(err, cbf_retry)
	local function ask_retry()
		UI.MBox.make()
			:set_param("content", string.format(TEXT.fmtDownloadException, tostring(err)))
			:set_param("txtConfirm", TEXT.tipRetryPatch)
			:set_param("block", true)
			:set_event(
				function () failCount = 0; cbf_retry() end,
				libunity.AppQuit)
			:show()
	end

	if err == 404 then
		ask_retry()
	else
		failCount = failCount + 1
		if failCount == 3 then
			ask_retry()
		else
			-- 重试
			libunity.Invoke(nil, 1, cbf_retry)
		end
	end
end

-- 整包下载管理
local do_app_download
local function on_app_download(tag, current, total, isDone, err)
	if err then
		on_download_fail(err, do_app_download)
	else
		local progress = current / total
		Ref.SubProgress.bar.value = progress
		if progress == 1 then
			-- 提示安装
		end
	end
end

local appName = "zonez.apk"
do_app_download = function ()
	NW.http_download(Context.appUrl..appName, patchRoot..appName, on_app_download)
end

-- 资源下载管理
local coroDL, LocalFileList, RemoteFileList, UpdateFileList
local totalSiz, currSiz, currPatch
local function on_download(url, current, total, isDone, err)
	if err then
		on_download_fail(err, function ()
			coroutine.resume(coroDL, "retry")
		end)
	else
		local progress = current / total
		Ref.SubProgress.bar.value = (currPatch.Info.siz * progress + currSiz) / totalSiz
		local siz = (currPatch.Info.siz * progress + currSiz)
		Ref.SubProgress.lbSiz.text = string.format("%0.2fM/%0.2fM", siz / 1048576, totalSiz / 1048576)
		if isDone then
			-- 记录已下载文件
			UpdateFileList.Assets[currPatch.name] = currPatch.Info
			libcsharpio.WriteAllText(patchRoot..filelist, cjson.encode(UpdateFileList))
			-- 更新总大小
			currSiz = currSiz + currPatch.Info.siz
			-- 继续下一个下载任务
			if coroutine.status(coroDL) == "suspended" then
				-- 唤醒并通知协程内部，下载成功，继续下一个
				failCount = 0
				coroutine.resume(coroDL, "next")
			end
		end
	end
end

local function coro_download(Queue)
	local resUrl = Context.resUrl
	while Queue:count() > 0 do
		currPatch = Queue:peek()
		local url = resUrl .. currPatch.name
		local saveFile = patchRoot .. currPatch.name
		NW.http_download(url, saveFile, on_download)
		print("downloading: " .. url)
		local ret = coroutine.yield()
		if ret == "next" then
			-- 下载成功，当前任务出队列
			Queue:dequeue()
		elseif ret == "stop" then
			return
		end
	end

	next_action(Ref.go, function ()
		-- 下载完成，安装所有文件
		libcsharpio.DeleteFile(patchRoot..filelist)
		for k,v in pairs(UpdateFileList.Assets) do
			LocalFileList.Assets[k] = v
			libcsharpio.MoveFile(patchRoot..k, bundleRoot..k, true)
			if k == "lua/script" then
				require("libasset.cs").UpdateLua(v.md5)
				print("Update using lua to [%s]", v.md5)
			end

		end

		LocalFileList.version = UpdateFileList.version
		libcsharpio.WriteAllText(bundleRoot..filelist, cjson.encode(LocalFileList))

		libcsharpio.DeleteDir(patchRoot)
		libunity.Destroy("/AssetsMgr")
		libunity.Destroy("/UIROOT")
		libunity.Destroy("/StageCtrl")
		libunity.Destroy("/ObjectPoolManager")
		libunity.NewLevel("Launch")
	end)
end

local function close_window()
	self:close()
end

--!* [开始] 自动生成函数 *--
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
	patchRoot = string.format("%s/Updates/", _G.ENV.app_persistentdata_path)
	bundleRoot = string.format("%s/AssetBundles/", _G.ENV.app_persistentdata_path)

	Ref.lbInfo.text = nil
	Ref.lbTips.text = nil
	Ref.SubProgress.lbSiz.text = nil
	Ref.SubProgress.bar.value = 0
end

function init_logic()
	libcsharpio.CreateDir(patchRoot)
	if Context.appUrl then
		-- 下载整包
		failCount = 0
		do_app_download()
	else
		-- 下载资源
		-- 本地文件列表
		LocalFileList = _G.ENV.LFL
		-- 哪些文件需要更新
		RemoteFileList = Context.LFL
		-- 已下载的文件
		local filelist = libcsharpio.ReadAllText(patchRoot .. filelist)
		UpdateFileList = filelist and cjson.decode(filelist)
		if UpdateFileList == nil or UpdateFileList.version ~= RemoteFileList.version then
			-- 不存在已下载列表或者已下载的版本不是最新版则清空数据
			UpdateFileList = {
				version = RemoteFileList.version,
				Assets = {},
			}
		end

		local LocalAssets, RemoteAssets, UpdateAssets
			= LocalFileList.Assets, RemoteFileList.Assets, UpdateFileList.Assets
		local QuePatch = _G.DEF.Queue.new()
		totalSiz, currSiz = 0, 0
		for k,v in pairs(RemoteAssets) do
			local LocalF = UpdateAssets[k]
			if LocalF and LocalF.md5 == v.md5 then
				-- 已下载的文件
				currSiz = currSiz + LocalF.siz
			else
				-- 是否需要下载
				LocalF = LocalAssets[k]
			end
			if LocalF == nil or LocalF.md5 ~= v.md5 then
				QuePatch:enqueue({name = k, Info = v})
				totalSiz = totalSiz + v.siz
			end
		end

		failCount = 0

		coroDL = coroutine.create(coro_download)
		local network = UE.Application.internetReachability.name

		-- 在WIFI环境下，或者更新资源量小于5M不提示
		if network == "ReachableViaLocalAreaNetwork" or totalSiz <= 5242880 then
			coroutine.resume(coroDL, QuePatch, totalSiz)
		else
			UI.MBox.legacy(string.format(TEXT.fmtConfirmResUpdate, totalSiz / 1024 / 1024),
				function () coroutine.resume(coroDL, QuePatch, totalSiz) end, true, close_window)
		end
	end
end

function show_view()

end

function on_recycle()

end

return self

