local BI_CUSTOM_EVENT_NAME = {
	guide_record = true,--新手引导记录
	chat_earlychat = true,--修理完成收音机前使用聊天功能触发
	chat_InterphoneFirstTime = true,--首次点击对讲机触发，由前端上报触发
	chat_FriendChat = true,	--好友对话后生成日志
	chat_StrangerChat = true,--陌生人对话后生成日志
	chat_StrangerChatSource = true,--与陌生人聊天记录路径，生成日志
	chat_NearbyChat = true,--附近频道聊天生成日志
	chat_ShelterChat = true,--避难所频道聊天生成日志
	friend_AddSource = true,--添加好友记录路径，生成日志
	chat_ReceivingCHFirstTime = true,--首次点击设置“接受频道勾选“触发
	chat_search = true,--点击搜索功能触发
	shelter_TypeNumFirstTime = true,--首次使用数字键入触发
	shelter_TypeEnter = true,--使用“ENTER“按钮触发
	shelter_TypeClear = true,--使用”C“按钮触发
	shelter_TypeLR = true,--使用左右切换推送避难所触发，由前端上报
	shelter_Quit = true,--主动退出避难所时触发
	shleter_TapShelterTips = true,--首次升级界面内点击查看避难所详情时触发，由前端上报
	shleter_TapShopTips = true,--首次升级界面内点击查看贩卖机详情时触发，由前端上报
	shleter_TapGeneratorTips = true,--首次升级界面内点击查看发电机详情时触发，由前端上报
	shleter_TapLatheTips = true,--首次升级界面内点击查看建造车床详情时触发，由前端上报
	shleter_TapBlueprinterTips = true,--首次升级界面内点击查看蓝图打印机详情时触发，由前端上报

	loading = true,
}

local BI_LOADING_EVENT = {
	loading_loadkgsdk = 1,--加载KGSDK
	loading_compasset = 2,--资源比较
	loading_loadshader = 3,--加载shader
	loading_loaduiroot = 4,--加载UIRoot
	loading_loadlua = 5,--加载Lua
	loading_initlua = 6,--初始化Lua依赖库
	loading_loadconst = 7,--加载Constant常量
	loading_loadsingleton = 8,--加载Singleton
	loading_loadstagectrl = 9,--加载StageCtrl
	loading_loadcfg = 10,--读取用户配置信息
	loading_loadcommon = 11,--预加载公用资源
	--loading_loadlogin = 12,--加载登陆界面
	loading_login = 12,--登陆
	loading_loadrole = 13,--加载玩家数据(GS)
	loading_initgme = 14,--初始化GME SDK

	download_hotdown = 1,--热更下载
	download_packagedown = 1,--分包下载
	download_packageunzip = 2,--分包解压
	asset_loadscene = 1,--场景加载
	asset_loadstartcg = 1,--开场动画
}

local P = {}
setmetatable(P, {
	__index = function(...) return emptyFun end
})

-- BI日志首次记录标识
-- ============================================================================
local CustomBIEventPref = _G.DEF.Pref.new("bi_event")
local loadpref = CustomBIEventPref.load
CustomBIEventPref.load = function (self)
	local Data = loadpref(self)
	if Data.EvnetList == nil then Data.EvnetList = {} end
	return Data
end

-- 获取bi_event_name
function P.try_load_bieventname(eventName)
    local CustomBIEvents = CustomBIEventPref:load()
	return CustomBIEvents.EvnetList[eventName]
end

-- 保存eventname
function P.save_bieventname(eventName)
	local CustomBIEvents = CustomBIEventPref:load()
	CustomBIEvents.EvnetList[eventName] = 1
	CustomBIEventPref:save()
end

function P.clear_bieventname()
	CustomBIEventPref:clear()
end

-- ============================================================================

function P.IsActive(eventName)
	return BI_CUSTOM_EVENT_NAME[eventName]
end

function P.get_loading_event_step(eventName)
	return BI_LOADING_EVENT[eventName]
end

return P