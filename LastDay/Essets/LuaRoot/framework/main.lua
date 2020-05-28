--
-- @file    framework/main.lua
-- @anthor  xing weizhen (xingweizhen@rongygame.com)
-- @date    2016-02-29 11:11:58
-- @desc    描述
--


print(_VERSION)
-- module --
dofile "framework/variable"

local function ask_quit_app()
    local TEXT = _G.TEXT
    local Alert = {
        title = UE.Application.productName,
        message = tostring(TEXT.askQuitApp),
        icon = "app_icon",
    }
    DY_DATA.AlertCBF["1"] = function ()
        libunity.AppQuit()
    end
    libunity.SendMessage("/UIROOT/Singleton", "AlertMessage", cjson.encode(Alert))
end

local KeyNotify = {
    Escape = ask_quit_app,
}

local function awake()
    print ("<color=yellow>lua awake</color>")
    
    dofile "game/init"
end

local function start()
    local ENV = _G.ENV
    print (string.format("===[INFO]===\nplatform: %s\ndata: %s\npersistent: %s\nstreaming: %s",
        tostring(ENV.unity_platform),
        tostring(ENV.app_data_path),
        tostring(ENV.app_persistentdata_path),
        tostring(ENV.app_streamingassets_Path)))

    libunity.NewChild("/UIROOT", "Launch/Singleton")

    libunity.NewChild(nil, "Launch/StageCtrl")

    -- 丝般顺滑
    UE.Application.targetFrameRate = ENV.debug and -1 or 60
    UE.QualitySettings.antiAliasing = ENV.debug and 8 or 0
    if ENV.debug or ENV.development then
        local CONSOLE = _G.PKG["framework/console/console"]
        KeyNotify.F1 = CONSOLE.open_console
    end


    -- 读用户配置
    local UserSettings = {}
    local settingRoot = ENV.debug and "" or ENV.app_persistentdata_path .. "/"
    local f, err = io.open(settingRoot .. "user-settings.txt")
    if err == nil then
        for line in f:lines() do
            local l = line:trim()
            -- not starts with ‘#’
            if #l > 0 and l:byte(1) ~= 35 then
                local k, v = l:match("([%w_]+)=([^%c]+)")
                if k and v then UserSettings[k] = v end
            end
        end
        f:close()
    end
    rawset(_G, "UserSettings", UserSettings)

    dofile("network/unpack/msgunpack")

    _G.PKG["game/timers"].launch_battery_timer()

    NW.LOGIN.heart_beat_loop()
end

local function on_key(key)
    local ntf = KeyNotify[key]
    if ntf then ntf() end
end

local function on_ui_click(go)
    -- local name = go.name
    -- local collider = go.collider
    -- local pre = name:sub(1, 3)

end

-- 在最后，禁止定义和访问未定义的全局变量
setmetatable(_G, _G.MT.Const)

return {
    awake = awake,
    start = start,
    on_key = on_key,
    on_ui_click = on_ui_click,
}
