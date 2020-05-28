using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ZFrame;

public class GameSettings : ZFrame.Asset.LiveTuneSettings
{
    private GameSettings() { }
    public static GameSettings Instance = new GameSettings();

    protected override string defaultSettings {
        get {
            var lua = LuaScriptMgr.Instance.L;
            lua.GetGlobal("def_graphic_settings");
            var ret = lua.OptString(-1, string.Empty);
            lua.Pop(1);
            return ret;
        }
    }
     
    protected override void ApplySettings(string settingsJson, bool isBaseline, string segmentName)
    {
        var lua = LuaScriptMgr.Instance.L;
        lua.GetGlobal("apply_graphic_settings");
        var b = lua.BeginPCall();
        lua.PushString(settingsJson);
        lua.PushBoolean(isBaseline);
        lua.PushString(segmentName);
        lua.ExecPCall(3, 0, b);
    }
}
