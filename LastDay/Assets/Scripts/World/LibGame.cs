//
//  LibGame.cs
//  survive
//
//  Created by xingweizhen on 10/13/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using World;
using World.View;
using World.Control;
#if ULUA
using LuaInterface;
#else
using XLua;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif
using ZFrame.UGUI;
using ZFrame.Tween;
using ILuaState = System.IntPtr;

public static class LibGame
{
    public const string CTRL = "game/ctrl";

    public const string LIB_NAME = "libgame.cs";

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    public static int OpenLib(ILuaState lua)
    {
        lua.NewTable();

        lua.SetDict("IsFighting", IsFighting);

        lua.SetDict("UpdateSettings", UpdateSettings);
        lua.SetDict("UpdateWeather", UpdateWeather);

        lua.SetDict("LoadModelView", LoadModelView);

        lua.SetDict("CreateObj", CreateObj);
        lua.SetDict("DeleteObj", DeleteObj);
        lua.SetDict("CreateCorpse", CreateCorpse);
        lua.SetDict("CreateView", CreateView);
        lua.SetDict("ReplaceView", ReplaceView);
        lua.SetDict("GetObjOfView", GetObjOfView);
        lua.SetDict("GetViewOfObj", GetViewOfObj);

        lua.SetDict("World2Local", World2Local);
        lua.SetDict("Local2World", Local2World);
        lua.SetDict("GetFocusUnit", GetFocusUnit);
        lua.SetDict("GetAutoTarget", GetAutoTarget);
        lua.SetDict("IsEmptyArea", IsEmptyArea);
        lua.SetDict("FindUnitsInside", FindUnitsInside);
        lua.SetDict("RaiseCamera", RaiseCamera);
        lua.SetDict("ResetCamera", ResetCamera);

        // Unit Control
        lua.SetDict("IsUnitFree", IsUnitFree);
        lua.SetDict("IsUnitActing", IsUnitActing);
        lua.SetDict("IsActionCooling", IsActionCooling);
        lua.SetDict("UnitMove", UnitMove);
        lua.SetDict("UnitTurn", UnitTurn);
        lua.SetDict("UnitSneak", UnitSneak);
        lua.SetDict("UnitStay", UnitStay);
        lua.SetDict("UnitStop", UnitStop);
        lua.SetDict("UnitBreak", UnitBreak);
        lua.SetDict("UnitFade", UnitFade);        
        lua.SetDict("PlayerAttack", PlayerAttack);
        lua.SetDict("PlayerInteract", PlayerInteract);
        lua.SetDict("PlayerAuto", PlayerAuto);
        lua.SetDict("PlayerLockTarget", PlayerLockTarget);
        lua.SetDict("PlayerRelockNearby", PlayerRelockNearby);
        lua.SetDict("IsWeaponSwith", IsWeaponSwith);
        lua.SetDict("UnitAnimate", UnitAnimate);
        lua.SetDict("UnitTransState", UnitTransState);
        lua.SetDict("AnimSetParam", AnimSetParam);
        lua.SetDict("GetSortedUnits", GetSortedUnits);

        // Unit Data
        lua.SetDict("GetUnitHealth", GetUnitHealth);
        lua.SetDict("GetUnitFSMState", GetUnitFSMState);
        lua.SetDict("GetUnitCoord", GetUnitCoord);
        lua.SetDict("GetUnitPos", GetUnitPos);
        lua.SetDict("SetUnitHealth", SetUnitHealth);
        lua.SetDict("SetUnitTarget", SetUnitTarget);
        lua.SetDict("SetUnitCoord", SetUnitCoord);
        lua.SetDict("SetUnitStealth", SetUnitStealth);
        lua.SetDict("SyncUnitInfo", SyncUnitInfo);
        lua.SetDict("GetDefSkill", GetDefSkill);
        lua.SetDict("GetHumanWeaponCooldown", GetHumanWeaponCooldown);

        lua.SetDict("SwitchUnitMajor", SwitchUnitMajor);
        lua.SetDict("UpdateUnitData", UpdateUnitData);
        lua.SetDict("UpdateUnitView", UpdateUnitView);
        lua.SetDict("SetUnitHud", SetUnitHud);

        // Unit View
        lua.SetDict("SetUnitSkin", SetUnitSkin);
        lua.SetDict("AddUnitSkin", AddUnitSkin);
        lua.SetDict("DelUnitSkin", DelUnitSkin);
        lua.SetDict("SetViewVisible", SetViewVisible);
        lua.SetDict("SetFOWStatus", SetFOWStatus);
        lua.SetDict("FindUnitHud", FindUnitHud);
        lua.SetDict("AddUnitHud", AddUnitHud);
        lua.SetDict("DelUnitHud", DelUnitHud);
        lua.SetDict("SetOverrideVision", SetOverrideVision);

        // Fx
        lua.SetDict("PlayFx", PlayFx);
        lua.SetDict("StopFx", StopFx);
        lua.SetDict("AddChild", AddChild);
        lua.SetDict("Recycle", Recycle);
        lua.SetDict("EnableFOW", EnableFOW);
        lua.SetDict("GetDayNight", GetDayNight);

        lua.SetDict("SyncTimestamp", SyncTimestamp);
        lua.SetDict("NewNetMsg", NewNetMsg);
        
        // Others
        lua.SetDict("UpdateClosedArea", UpdateClosedArea);
        lua.SetDict("EnableOutline", EnableOutline);
        lua.SetDict("EnablePointlit", EnablePointlit);

        return 1;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int IsFighting(ILuaState lua)
    {
        lua.PushBoolean(StageView.Instance);
        return 1;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UpdateSettings(ILuaState lua)
    {
        var Settings = StageCtrl.Settings;
        var player = StageCtrl.P;
        Settings.InitFromLua(lua, 1);
        if (player != null) {
            player.autoTargetFilter = Settings.targetFilter;
            player.autoTargetAmount = Settings.focus_showNearby;
            if (!Settings.focus_lockOnHit) {
                var view = player.view as PlayerView;
                if (view) view.lockedTarget = null;
            }
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UpdateWeather(ILuaState lua)
    {
        string fx = null;

        var type = lua.Type(1);
        switch (type) {
            case LuaTypes.LUA_TTABLE: {
                    fx = lua.GetString(1, "fx");
                    StageCtrl.Instance.currEnv.dayVision = lua.GetNumber(1, "dayVision");
                    StageCtrl.Instance.currEnv.nightVision = lua.GetNumber(1, "nightVision");
                    StageCtrl.Instance.currEnv.fog = lua.GetString(1, "fog");
                    break;
                }
            default: {
                    break;
                }
        }
        if (string.IsNullOrEmpty(fx))
        {
            StageCtrl.Instance.currEnv.fx = null;
            WeatherView.LoadWeather(null);
        }
        else
        {
            StageCtrl.Instance.currEnv.fx = fx;
            WeatherView.LoadWeather(fx);
        }

        return 0;
    }

    private static IObj ToWorldObj(this ILuaState lua, int index)
    {
        if (StageCtrl.L == null) return null;

        var type = lua.Type(index);
        switch (type) {
            case LuaTypes.LUA_TNUMBER:
                var uniqueId = lua.ToInteger(index);
                return uniqueId == 0 ? StageCtrl.P : StageCtrl.L.FindById(uniqueId, true);
            case LuaTypes.LUA_TTABLE: {
                    if (lua.IsClass(index, UnityEngine_Vector3.CLASS)) {
                        var pos = StageView.World2Local(lua.ToVector3(index));
                        return new LocateObj(pos, StageCtrl.L);
                    }
                    break;
                }
            default: break;
        }

        return null;
    }

    private static IObjView ToObjView(this ILuaState lua, int index)
    {
        var luaT = lua.Type(index);
        if (luaT == LuaTypes.LUA_TUSERDATA || luaT == LuaTypes.LUA_TLIGHTUSERDATA) {
            return lua.ToComponent(index, typeof(IObjView)) as IObjView;
        }

        var obj = lua.ToWorldObj(index);
        return obj != null ? obj.view : null;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LoadModelView(ILuaState lua)
    {
        var model = lua.ToString(1);
        var modelPath = Creator.Model2PrefabPath(model);
        Object asset;
        var loaded = AssetsMgr.A.Loader.TryLoad(typeof(GameObject), modelPath, out asset);
        if (!loaded) {
            var onLoad = lua.ToLuaFunction(2);
            AssetsMgr.A.LoadAsync(typeof(GameObject), modelPath, ZFrame.Asset.LoadMethod.Cache, (a, o, p) => {
                var go = o as GameObject;
                var modelName = p as string;
                var multiView = go ? go.GetComponent(typeof(MultiView)) as MultiView : null;
                if (multiView) o = multiView.Get(modelName);

                var L = onLoad.GetState();
                var b = onLoad.BeginPCall();
                L.PushString(a);
                L.PushLightUserData(o);
                L.PushString(modelName);
                L.ExecPCall(3, 0, b);
            }, model);
        } else {
            var go = asset as GameObject;
            var multiView = go ? go.GetComponent(typeof(MultiView)) as MultiView : null;
            if (multiView) asset = multiView.Get(model);

            var b = lua.BeginPCall();
            lua.PushString(modelPath);
            lua.PushLightUserData(asset);
            lua.PushString(model);
            lua.ExecPCall(3, 0, b);
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int CreateObj(ILuaState lua)
    {
        if (StageCtrl.L != null) {
            var Data = DataUtil.Get<L_OBJData>(lua, 1);
            var NewObj = Creator.CreateObj(null, ref Data);
            if (NewObj != null) {
                if (StageCtrl.Instance.JoinObj(NewObj)) {
                    var View = Data.View;
                    NewObj.CreateView(ref View);

                    lua.GetField(1, "View");
                    var alwaysView = lua.GetBoolean(-1, "alwaysView") || !StageCtrl.hideObjOnOutScreen;
                    lua.Pop(1);
                    if (alwaysView && NewObj.view != null && !string.IsNullOrEmpty(View.model)) {
                        Creator.LoadObjView(NewObj.view, View.model);
                    }
                }
            }
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DeleteObj(ILuaState lua)
    {
        if (StageCtrl.Instance) {
            var objId = lua.ToInteger(1);
            var delay = lua.OptSingle(2, 0f);
            StageCtrl.Instance.DeleteObj(objId, delay);
        }
        return 0;
    }

    /// <summary>
    /// 用尸体数据替换原玩家模型
    /// 返回true表示成功替换，后面需要更新View
    /// </summary>
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int CreateCorpse(ILuaState lua)
    {
        if (StageCtrl.L != null) {
            var data = DataUtil.Get<L_OBJData>(lua, 1);
            var newObj = Creator.CreateObj(null, ref data);
            if (newObj != null) {
                if (StageCtrl.Instance.JoinObj(newObj)) {
                    var human = lua.ToWorldObj(2) as Human;
                    
                    var view = human != null ? human.view : null;
                    if (view != null) {
                        view.Subscribe(newObj);                        
                        lua.PushBoolean(true);
                        return 1;
                    }

                    var objView = data.View;
                    newObj.CreateView(ref objView);
                }
            }
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int CreateView(ILuaState lua)
    {
        if (lua.Type(1) == LuaTypes.LUA_TNUMBER) {
            var Obj = lua.ToWorldObj(1);
            var replace = lua.OptBoolean(3, false);
            if (lua.IsTable(2) && Obj != null && (replace || Obj.view == null)) {
                var Ent = Obj as IEntity;
                var S = DataUtil.Get<L_OBJView>(lua, 2);
                if (Ent != null) {
                    Ent.Data.bodyMat = S.bodyMat;
                    Ent.Data.gender = S.gender;
                    foreach (var kv in S.Fxes) {
                        Ent.Data.SetExtend(kv.Key, kv.Value);
                    }

                    Ent.Data.SetBundle(S.fxBundle, S.sfxBank);
                    if (S.model != Ent.Data.GetExtend("model") || S.Dresses.Count > 0) {
                        Obj.CreateView(ref S);
                    }
                } else {
                    Obj.CreateView(ref S);
                }

                var alwaysView = lua.GetBoolean(2, "alwaysView") || !StageCtrl.hideObjOnOutScreen;
                if (alwaysView && Obj.view != null && !string.IsNullOrEmpty(S.model)) {
                    Creator.LoadObjView(Obj.view, S.model);
                }

                Debugger.LogI("生成可视单位：{0}", Obj);
            }
            return 0;
        } else {
            var root = lua.ToGameObject(1);
            var prefab = lua.ToString(2);
            var pose = lua.ToInteger(3);
            var S = DataUtil.Get<L_OBJView>(lua, 4);
            S.prefab = prefab;

            var func = lua.ToLuaFunction(5);
            System.Action<IRenderView> onViewLoad = null;
            if (func != null) {
                onViewLoad = view => {
                    using (func) func.Action(view);
                };
            }

            lua.PushLightUserData(Creator.CreateView(root, pose, ref S, null, onViewLoad));
            return 1;
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ReplaceView(ILuaState lua)
    {
        var xObj = lua.ToWorldObj(1) as XObject;
        if (xObj != null) {
            var model = lua.GetString(2, "model");
            var icon = lua.GetString(2, "mapIco");
            var layer = (int)lua.GetNumber(2, "mapLayer", xObj.layer);
            var itor = lua.GetString(2, "mapItor");

            // 单位死亡时要求有交互类型才替换尸体模型
            var shouldUpdateView = xObj.IsAlive() || xObj.operId >= 0;
            if (shouldUpdateView) {
                if (!string.IsNullOrEmpty(icon)) xObj.Data.SetExtend("mapIco", icon);
                if (!string.IsNullOrEmpty(model)) xObj.Data.SetExtend("model", model);
                if (!string.IsNullOrEmpty(itor)) xObj.Data.SetExtend("mapItor", itor);
            }
            var entData = new EntityData(xObj) {
                layer = layer,
            };
            xObj.InitEntity(entData, xObj.disappear);

            var view = xObj.view;
            if (view != null) {
                if (view.IsVisible() && shouldUpdateView) {
                    MiniMap.Instance.Enter(xObj);
                }
            }
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetObjOfView(ILuaState lua)
    {
        var go = lua.ToGameObject(1);
        if (go) {
            var view = go.GetComponentInParent(typeof(IObjView)) as IObjView;
            if (view != null && view.obj != null) {
                lua.PushInteger(view.obj.id);
                lua.PushLightUserData(view);
                return 2;
            }
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetViewOfObj(ILuaState lua)
    {
        var obj = lua.ToWorldObj(1);
        if (obj != null) {
            lua.PushLightUserData(obj.view);
            return 1;
        }
        return 0;
    }


    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int World2Local(ILuaState lua)
    {
        lua.PushX((Vector3)StageView.World2Local(lua.ToVector3(1)));
        return 1;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Local2World(ILuaState lua)
    {
        lua.PushX(StageView.Local2World(lua.ToVector3(1)));
        return 1;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetFocusUnit(ILuaState lua)
    {
        if (StageCtrl.focus != null) {
            lua.PushInteger(StageCtrl.focus.id);
            return 1;
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetAutoTarget(ILuaState lua)
    {
        if (StageCtrl.P != null) {
            var view = StageCtrl.P.view as PlayerView;
            if (view != null && view.autoTarget != null) {
                lua.PushInteger(view.autoTarget.id);
                return 1;
            }
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int IsEmptyArea(ILuaState lua)
    {
        var areaType = (RangeType)lua.ToEnumValue(1, typeof(RangeType));
        var center = lua.ToVector2(2);
        var param1 = Mathf.Max(0, lua.ToSingle(3));
        var param2 = Mathf.Max(0, lua.ToSingle(4));

        Shape2D area = new Shape2D();
        switch (areaType) {
            case RangeType.Circle:
                area = new Shape2D(center, param1);
                break;
            case RangeType.Rectangle:
                area = new Shape2D(center, Vector.forward, new Vector(param1, param2));
                break;
            default: break;
        }
        if (area.type != ShapeType.None) {
            var self = StageCtrl.P;
            bool ret = true;
            foreach (var tar in self.L.objs) {
                var ent = tar as IEntity;
                if (ent != null && ent.obstacle && ent.IsAlive() && ent.camp != self.camp) {
                    if (area.Intersect(ent)) {
                        ret = false;
                        break;
                    }
                }
            }
            lua.PushBoolean(ret);
            return 1;
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int FindUnitsInside(ILuaState lua)
    {
        var areaType = (RangeType)lua.ToEnumValue(1, typeof(RangeType));
        var center = lua.ToVector2(2);
        var param1 = Mathf.Max(0, lua.ToSingle(3));
        var param2 = Mathf.Max(0, lua.ToSingle(4));

        Shape2D area = new Shape2D();
        switch (areaType) {
            case RangeType.Circle:
                area = new Shape2D(center, param1);
                break;
            case RangeType.Rectangle:
                area = new Shape2D(center, Vector.forward, new Vector(param1, param2));
                break;
            default: break;
        }

        if (area.type != ShapeType.None) {
            Debugger.Draw(area, Color.green, 1f);
            lua.NewTable();
            var self = StageCtrl.P;
            int n = 1;
            foreach (var tar in self.L.objs) {
                var ent = tar as IEntity;
                if (!ObjectExt.IsNull(ent)) {
                    if (area.Intersect(ent)) lua.SetNumber(-1, n++, ent.id);
                }
            }

            return 1;
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int RaiseCamera(ILuaState lua)
    {
        var height = lua.OptSingle(1, -1);        
        var speed = lua.ToSingle(2);
        var trans = StageView.Instance.mainCam.transform;
        var srcPos = trans.localPosition;
        var dstPos = height > 0 ? srcPos.normalized * height : StageView.Instance.camperaPos;
        var duration = (dstPos - srcPos).magnitude / speed;
        ZTween.Stop(trans);

        trans.TweenLocalPosition(dstPos, duration);
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ResetCamera(ILuaState lua)
    {
        if (StageView.Instance) {
            var duration = lua.ToSingle(1);
            StageView.Instance.ResetCamera(duration);
        }
        return 0;
    }

    #region Player Control
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UnitMove(ILuaState lua)
    {
        var mover = lua.ToWorldObj(1) as IMovable;
        if (mover != null) {
            var movePos = Vector3.zero;

            var klass = lua.Class(2);
            if (klass == UnityEngine_Vector2.CLASS) {
                var v2 = lua.ToVector2(2);
                movePos = new Vector3(v2.x, 0, v2.y);
            } else if (klass == UnityEngine_Vector3.CLASS) {
                var v3 = lua.ToVector3(2);
                movePos = StageView.World2Local(v3);
            } else {
                return 0;
            }

            var towards = !lua.IsNoneOrNil(3);
            if (towards) {
                var view = mover.view as RoleView;
                if (view) {
                    var v2 = lua.ToVector2(3);
                    var euler = StageView.Instance.mainCam.transform.eulerAngles;
                    var rot = Quaternion.Euler(0, euler.y, 0);
                    view.forward = (rot * new Vector3(v2.x, 0, v2.y)).normalized;
                }
            }
            mover.Move(movePos, towards);
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UnitTurn(ILuaState lua)
    {
        var turner = lua.ToWorldObj(1) as ITurnable;
        if (turner != null) {
            Vector turnFwd;
            var klass = lua.Class(2);
            if (klass == UnityEngine_Vector2.CLASS) {
                var v2 = lua.ToVector2(2);
                turnFwd = new Vector(v2.x, 0, v2.y);
            } else if (klass == UnityEngine_Vector3.CLASS) {
                var v3 = lua.ToVector3(2);
                turnFwd = StageView.FwdWorld2Local(v3);
            } else {
                return 0;
            }

            turner.turnForward = turnFwd;
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UnitSneak(ILuaState lua)
    {
        var mover = lua.ToWorldObj(1) as IMovable;
        if (mover != null) {
            if (mover == StageCtrl.P) {
                ObjCtrl.StopAutoPlay();
            }
            var Actor = mover as CActor;
            if (Actor == null || Actor.actionable) {
                var sneak = lua.ToBoolean(2);
                mover.shiftingRate = sneak ? mover.GetAttr(ATTR.Sneak) / mover.GetAttr(ATTR.Move) : 1f;
            }
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UnitStay(ILuaState lua)
    {
        var mover = lua.ToWorldObj(1) as IMovable;
        if (mover != null) {
            mover.Stay(lua.ToBoolean(2));
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UnitStop(ILuaState lua)
    {
        var obj = lua.ToWorldObj(1) as IActor;
        if (obj != null) obj.Stop(lua.ToBoolean(2));
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UnitFade(ILuaState lua)
    {
        var obj = lua.ToWorldObj(1);
        if (obj != null) {
            var view = obj.view as IRenderView;
            if (view != null) {
                var from = lua.ToSingle(2);
                var to = lua.ToSingle(3);
                var duration = lua.ToSingle(4);
                view.FadeView(from, to, duration);
            }
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UnitBreak(ILuaState lua)
    {
        var obj = lua.ToWorldObj(1) as IActor;
        if (obj != null) {
            obj.BreakAction();
        }
        return 0;
    }


    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int PlayerAttack(ILuaState lua)
    {
        var human = StageCtrl.P;
        if (human.actionable) {
            IAction Skill = null;
            if (lua.IsNumber(1)) {
                var index = lua.ToInteger(1);
                Skill = index < CVar.SKILL_CAP ? human.IGetAction(index) : CFG_Action.Load(index);
            }
            if (Skill != null) ObjCtrl.StopAutoPlay();

            var target = lua.ToWorldObj(2);
            if (target == null) {
                var view = human.view as PlayerView;
                if (view) target = view.autoTarget;
            }
            human.Attack(Skill, target, Skill != null ? Skill.oper : ACTOper.OneShot);
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int PlayerInteract(ILuaState lua)
    {
        ObjCtrl.StopAutoPlay();

        var player = StageCtrl.P;
        if (player.actionable) {
            if (lua.IsNumber(1)) {
                var toolPos = lua.ToInteger(1);
                var actionId = lua.OptInteger(2, 0);
                player.SetTool(toolPos);

                var target = lua.ToWorldObj(3) ?? StageCtrl.focus;
                if (target != null && target.id > 0) {
                    var view = player.view as PlayerView;
                    if (view && !view.IsTargetReachable(target)) {
                        lua.PushInteger((int)PlayerView.AutoRet.NoPath);
                        return 1;
                    }
                }
                var interactTime = lua.OptInteger(4, 0);
                player.Interact(player.Tool, actionId, target, ACTOper.Auto, interactTime);
            } else {
                player.Attack(null, null);
            }
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int PlayerAuto(ILuaState lua)
    {
        var player = StageCtrl.P;
        if (player != null) {
            var view = StageCtrl.P.view as PlayerView;
            if (view) {
                if (lua.IsBoolean(1)) {
                    var auto = lua.ToBoolean(1);
                    if (view.autoMode != auto) {
                        if (view.autoMode) {
                            StageCtrl.P.Stop(false);
                        }
                        view.SetAuto(auto);
                    }
                } else if (view.autoMode) {
                    // 重置自动模式
                    player.Attack(null, null);
                }
            }
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int PlayerLockTarget(ILuaState lua)
    {
        if (StageCtrl.P != null) {
            var view = StageCtrl.P.view as PlayerView;
            if (view) view.lockedTarget = lua.ToWorldObj(1);
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int PlayerRelockNearby(ILuaState lua)
    {
        if (StageCtrl.P != null) {
            var view = StageCtrl.P.view as PlayerView;
            if (view) view.RelockNearbyAlerts(true);
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int IsUnitFree(ILuaState lua)
    {
        var Actor = lua.ToWorldObj(1) as CActor;
        lua.PushBoolean(Actor == null || Actor.actionable);
        return 1;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int IsActionCooling(ILuaState lua)
    {
        var actor = lua.ToWorldObj(1) as IActor;
        if (actor != null) {
            var actionId = lua.ToInteger(2);
            lua.PushBoolean(actor.Content.IsCooling(actionId));
            return 1;
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int IsUnitActing(ILuaState lua)
    {
        var actor = lua.ToWorldObj(1) as IActor;
        if (actor != null) {
            lua.PushBoolean(!actor.Content.idle);
            return 1;
        }

        return 0;
    }


    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int IsWeaponSwith(ILuaState lua)
    {
        if (StageCtrl.L != null) {
            var Obj = lua.ToWorldObj(1) as Human;
            if (Obj != null) {
                lua.PushBoolean(Obj.Major.readyFrame <= Obj.L.frameIndex && Obj.Minor.readyFrame <= Obj.L.frameIndex);
                return 1;
            }
            return 0;
        }

        lua.PushBoolean(true);
        return 1;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int AnimSetParam(ILuaState lua)
    {
        var entity = lua.ToWorldObj(1) as IEntity;
        if (ObjectExt.IsAlive(entity)) {
            var view = entity.view as IUnitView;
            if (view != null && view.anim) {
                var param = lua.ChkString(2);
                var type = lua.Type(3);
                switch (type) {
                    case LuaTypes.LUA_TBOOLEAN:
                        view.anim.SetBool(param, lua.ToBoolean(3));
                        break;
                    case LuaTypes.LUA_TNUMBER:
                        view.anim.SetFloat(param, lua.ToSingle(3));
                        break;
                    case LuaTypes.LUA_TSTRING:
                        view.anim.SetFloat(param, int.Parse(lua.ToString(3)));
                        break;
                    case LuaTypes.LUA_TNIL:
                    case LuaTypes.LUA_TNONE:
                        view.anim.SetTrigger(param);
                        break;
                    default: break;
                }
            }
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetSortedUnits(ILuaState lua)
    {
        lua.CreateTable(StageCtrl.Instance.SortedObjs.Count, 0);
        for (var i = 0; i < StageCtrl.Instance.SortedObjs.Count; ++i) {
            var obj = StageCtrl.Instance.SortedObjs[i];
            lua.SetNumber(-1, i + 1, obj.id);
        }
        return 1;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UnitAnimate(ILuaState lua)
    {
        var entity = lua.ToWorldObj(1) as IEntity;
        if (ObjectExt.IsAlive(entity)) {
            var view = entity.view as IUnitView;
            if (view != null && view.anim) {
                var stageName = lua.ToString(2);
                var stateId = Animator.StringToHash(stageName);
                if (view.anim.HasState(stateId)) {
                    var duration = lua.OptSingle(3, 0f);
                    if (duration > 0) {
                        view.anim.CrossFadeInFixedTime(stateId, duration);
                    } else {
                        view.anim.Play(lua.ToString(2));
                    }
                    lua.PushBoolean(true);
                    return 1;
                }
            }
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UnitTransState(ILuaState lua)
    {
        var context = lua.ToWorldObj(1) as ZFrame.HFSM.IFSMContext;
        if (context != null) {
            var state = (EVENT)lua.ToEnumValue(2, typeof(EVENT));
            context.fsm.TransState((int)state);
        }

        return 0;
    }

    #endregion

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetUnitHealth(ILuaState lua)
    {
        var living = lua.ToWorldObj(1) as ILiving;
        if (living != null) {
            var value = living.Health.GetValue();
            var limit = living.Health.GetLimit();
            lua.PushInteger(value > limit ? limit : value);
            lua.PushInteger(limit);
            return 2;
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetUnitFSMState(ILuaState lua)
    {
        var context = lua.ToWorldObj(1) as ZFrame.HFSM.IFSMContext;
        if (context != null && context.fsm != null && context.fsm.activated) {
            var state = context.fsm.GetCurrentState();
            lua.PushString(((FSM_STATE)state.id).ToString());
            return 1;
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetUnitCoord(ILuaState lua)
    {
        var obj = lua.ToWorldObj(1);
        if (obj != null) {
            var local = lua.OptBoolean(2, false);
            var coord = local ? (Vector3)obj.coord : StageView.Local2World(obj.coord);
            lua.PushX(coord);
            var ent = obj as IEntity;
            if (ent != null) {
                var forward = local ? (Vector3)ent.forward : StageView.FwdLocal2World(ent.forward);
                var angle = Vector3.SignedAngle(Vector3.forward, forward, Vector3.up);
                lua.PushInteger(Mathf.RoundToInt(angle));
            } else {
                lua.PushInteger(0);
            }
            return 2;
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetUnitPos(ILuaState lua)
    {
        var Obj = lua.ToWorldObj(1);
        if (Obj == null) return 0;

        var local = lua.OptBoolean(2, false);
        var pos = local ? (Vector3)Obj.pos : StageView.Local2World(Obj.pos);
        lua.PushX(pos);
        var Entity = Obj as IEntity;
        if (Entity != null) {
            var angle = Vector3.SignedAngle(Vector3.forward, Entity.forward, Vector3.up);
            lua.PushInteger(Mathf.RoundToInt(angle));
        } else {
            lua.PushInteger(0);
        }
        return 2;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetUnitHealth(ILuaState lua)
    {
        var Obj = lua.ToWorldObj(1);
        var living = Obj as ILiving;
        var hp = lua.ToInteger(2);
        var hpLimit = lua.ToInteger(3);
        if (living != null) {
            var health = living.Health;
            health.SetLimit(hpLimit);

            var change = hp - health.cache;
            health.SetCache(hp);
            living.ChangeHp(new VarChange(change, null, null));
            if (hp == 0 || living.Health.IsNull()) {
                Debugger.LogD("{0}已死亡。(死于自身)", living);
            }
        } else {
            Debugger.LogW("对象不存在{0}={1}", lua.ToAnyObject(1), Obj);
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetUnitTarget(ILuaState lua)
    {
        var Obj = lua.ToWorldObj(1) as IActor;
        if (Obj != null && Obj.Content.currTarget != null) {
            var targetDirty = false;
            if (Obj.Content.currTarget is LocateObj && lua.IsClass(2, UnityEngine_Vector3.CLASS)) {
                var newPos = StageView.World2Local(lua.ToVector3(2));
                var skill = Obj.Content.action as CFG_Skill;
                if (skill != null) {
                    var srcPos = Obj.coord;
                    if (skill.tarType == TARType.Direction) {
                        var forward = srcPos == newPos ? ((IEntity)Obj).forward : (newPos - srcPos).normalized;
                        newPos = srcPos + forward * skill.Target.range;
                    }

                    if (skill.oper == ACTOper.Charged) {
                        var turner = Obj as ITurnable;
                        if (turner != null) {
                            if (newPos != srcPos) {
                                var lookFwd = (newPos - srcPos).normalized;
                                turner.turnForward = lookFwd;
                                turner.forward = lookFwd;
                            }
                        }
                    }
                }
                if (newPos != Obj.Content.currTarget.pos) {
                    Obj.Content.currTarget.pos = newPos;
                    targetDirty = true;
                }
            } else {
                var newTar = lua.ToWorldObj(2);
                if (!ObjectExt.IsEqual(newTar, Obj.Content.currTarget)) {
                    Obj.Content.currTarget = newTar;
                    targetDirty = true;
                }
            }
            if (targetDirty && Obj is Player) {
                Obj.L.TargetUpdate(Obj, Obj.Content.currTarget);
            }
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetUnitCoord(ILuaState lua)
    {
        var Obj = lua.ToWorldObj(1);
        if (Obj != null && Obj.IsAlive()) {
            var vol = Obj as IVolume;
            var blockSight = vol != null && vol.blockLevel == CVar.FULL_BLOCK;
            if (blockSight) StageView.fowData.SetVolumeBlock(vol, false);

            var coord = lua.ToVector3(2);
            Obj.pos = coord;

            var Vec = Obj as IVector;
            if (Vec != null) {
                var angle = lua.ToSingle(3);
                Vec.forward = Quaternion.Euler(0, angle, 0) * Vector3.forward;
            }

            if (blockSight) StageView.fowData.SetVolumeBlock(vol, true);

            var view = Obj.view as EntityView;
            if (StageView.Instance && view) {
                var pos = StageView.Local2World(coord);
                if (view.agent) {
                    view.agent.Warp(pos);
                } else {
                    view.cachedTransform.position = pos;
                }

                if (Vec != null) {
                    view.cachedTransform.forward = StageView.FwdLocal2World(Vec.forward);
                }
            }
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetUnitStealth(ILuaState lua)
    {
        var role = lua.ToWorldObj(1) as Role;
        if (role != null && role.IsAlive()) {
            var stealth = lua.ToBoolean(2);
            if (role.stealth != stealth) {
                role.stealth = stealth;
                var view = role.view as EntityView;
                if (view) view.UpdateStealth(stealth);
            }
            var nextTime = lua.ToLong(3);
            role.stealthFrame = StageCtrl.Timestamp2Frame(nextTime);
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SyncUnitInfo(ILuaState lua)
    {
        var Obj = lua.ToWorldObj(1);
        if (lua.IsTable(2)) {
            var xObj = Obj as XObject;
            if (xObj != null) {
                var baseData = new BaseData(xObj) {
                    status = (int)lua.GetNumber(2, "status", xObj.status),
                    camp = (int)lua.GetNumber(2, "camp", xObj.camp),
                };
                xObj.InitBase(xObj.L, baseData, xObj.Data, false);

                var disappear = lua.GetValue(I2V.ToLong, 2, "disappear", -1);
                var entData = new EntityData(xObj) {
                    operLimit = (int)lua.GetNumber(2, "operLimit", xObj.operLimit),
                    operId = (int)lua.GetNumber(2, "operId", xObj.operId),
                };
                xObj.InitEntity(entData, StageCtrl.Timestamp2Frame(disappear));
            }

            var living = Obj as ILiving;
            if (living != null) {
                var hpLimit = (int)lua.GetNumber(2, "hpLimit", -1);
                living.Health.SetLimit(hpLimit);

                var hp = (int)lua.GetNumber(2, "hp", -1);
                if (hp >= 0) {
                    var change = hp - living.Health.cache;
                    if (change != 0) {
                        living.Health.SetCache(hp);
                        living.ChangeHp(new VarChange(change, null, null));
                        if (hp == 0 || living.Health.IsNull()) {
                            Debugger.LogD("{0}已死亡。", living);
                        }
                    }
                }
            }
        }
        if (Obj == null) {
            Debugger.LogW("对象不存在{0}={1}", lua.ToAnyObject(1), Obj);
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetHumanWeaponCooldown(ILuaState lua)
    {
        lua.PushX(JsonSwapWeapon.Get(lua.ToWorldObj(1)));
        return 1;
    }


    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetDefSkill(ILuaState lua)
    {
        var Actor = lua.ToWorldObj(1) as CActor;
        if (Actor != null && Actor.actionIndex < Actor.actionIds.Count) {
            lua.PushInteger(Actor.actionIds[Actor.actionIndex]);
            return 1;
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UpdateUnitData(ILuaState lua)
    {
        if (!lua.IsTable(2)) return 0;

        var Obj = lua.ToWorldObj(1);
        if (Obj == null) return 0;

        var xObj = Obj as XObject;

        var actor = Obj as CActor;
        if (actor != null) {
            lua.GetField(2, "Skills");
            if (lua.IsTable(-1)) {
                actor.actionIds.Clear();
                lua.PushNil();
                while (lua.Next(-2)) {
                    var actionId = lua.ToInteger(-1);
                    lua.Pop(1);

                    actor.actionIds.Add(actionId);
                }
            }
            lua.Pop(1);
        }

        lua.GetField(2, "Init");
        if (lua.IsTable(-1)) {
            var Vol = Obj as IVolume;
            if (Vol != null) {
                lua.GetField(-1, "size");
                if (lua.IsTable(-1)) {
                    Vol.size = lua.ToVector3(-1);
                }
                lua.Pop(1);
            }

            if (xObj != null) {
                var disappear = lua.GetValue(I2V.ToLong, -1, "disappear", -1);

                xObj.InitEntity(new EntityData(xObj) {
                    operLimit = (int)lua.GetNumber(-1, "operLimit", xObj.operLimit),
                    operId = (int)lua.GetNumber(-1, "operId", xObj.operId),
                    obstacle = lua.GetBoolean(-1, "obstacle", xObj.obstacle),
                    blockLevel = (int)lua.GetNumber(-1, "blockLevel", xObj.blockLevel),
                    layer = (int)lua.GetNumber(-1, "layer", xObj.layer),
                    offensive = lua.GetBoolean(-1, "offensive", xObj.offensive),
                }, StageCtrl.Timestamp2Frame(disappear));
            }

        }
        lua.Pop(1);

        if (xObj != null && xObj.currentAttrs != null) {
            lua.GetField(2, "Attr");
            if (lua.IsTable(-1)) {
                lua.PushNil();
                while (lua.Next(-2)) {
                    var key = lua.ToString(-2);
                    var value = lua.ToSingle(-1);
                    lua.Pop(1);
                    xObj.SetAttr(key, value);
                }
            }
            lua.Pop(1);
        }

        var human = Obj as Human;
        if (human != null) {
            lua.GetField(2, "Weapons");
            if (lua.IsTable(-1)) {
                var majorId = (int)lua.GetNumber(-1, "majorId", -1);
                var minorId = (int)lua.GetNumber(-1, "minorId", -1);
                var swapWeapon = lua.GetBoolean(-1, "switch", false);
                human.SetWeapon(majorId, minorId, swapWeapon);
            }
            lua.Pop(1);
        }

        if (Obj.view == null) return 0;

        var renderView = Obj.view as IRenderView;
        if (renderView != null) {
            lua.GetField(2, "model");
            var list = new List<string>();
            string model;
            var objImage = new L_OBJImage();
            L_OBJView.ToModelData(lua, -1, out model, list, ref objImage);
            lua.Pop(1);

            if (!string.IsNullOrEmpty(model)) {
                // 一般不会。。
                Creator.LoadObjView(renderView, model);
            } else if (list.Count > 0) {
                Creator.LoadObjCombineView(renderView, list, objImage);
            }
        }

        var hView = Obj.view as HumanView;
        if (hView) {
            lua.GetField(2, "Affixes");
            if (lua.IsTable(-1)) {
                lua.PushNil();
                while (lua.Next(-2)) {
                    var index = (int)lua.GetNumber(-1, "index") - 1;
                    var path = lua.GetString(-1, "path");
                    lua.Pop(1);

                    hView.LoadObjAffix(path, index);
                }
            }
            lua.Pop(1);
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UpdateUnitView(ILuaState lua)
    {
        var hView = lua.ToComponent(1, typeof(HumanView)) as HumanView;
        if (hView == null) return 0;
        if (!lua.IsTable(3)) return 0;

        var pose = lua.OptInteger(2, -1);
        if (pose >= 0) {
            hView.SetPose(pose);
        }

        lua.GetField(3, "model");
        var list = new List<string>();
        string model;
        var objImage = new L_OBJImage();
        L_OBJView.ToModelData(lua, -1, out model, list, ref objImage);
        lua.Pop(1);

        if (list.Count > 0) {
            Creator.LoadObjCombineView(hView, list, objImage);
        }

        lua.GetField(3, "Affixes");
        if (lua.IsTable(-1)) {
            lua.PushNil();
            while (lua.Next(-2)) {
                var index = (int)lua.GetNumber(-1, "index") - 1;
                var path = lua.GetString(-1, "path");
                lua.Pop(1);

                hView.LoadObjAffix(path, index);
            }
        }
        lua.Pop(1);

        return 0;
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SwitchUnitMajor(ILuaState lua)
    {
        if (StageCtrl.L != null) {
            var Obj = lua.ToWorldObj(1);
            if (Obj != null) {
                var isActing = Obj.IsActing();
                if (isActing) {
                    var Tmp = StageView.Instance.GetTmpData(Obj, isActing);
                    Tmp.switchMajorWeapon = lua.ToInteger(2);
                }
                lua.PushBoolean(!isActing);
                return 1;
            }
            return 0;
        }

        lua.PushBoolean(true);
        return 1;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetUnitHud(ILuaState lua)
    {
        var obj = lua.ToWorldObj(1);
        if (obj != null) {
            var hud = lua.ToGameObject(2);
            var mono = obj.view as MonoBehaviour;
            var bone = mono ? mono.transform.Find("HUD") : null;
            UIFollowTarget.Follow(hud, bone, StageView.Instance.mainCam);

            var tgl = hud.GetComponent(typeof(UIToggle)) as UIToggle;
            if (Debugger.Instance) {
                var view = obj.view as ObjView;
                if (tgl && view) {
                    tgl.SetValueChanged(view.ShowDebug);
                    view.ShowDebug(view.updateDebug);
                }
            } else {
                var cvGrp = hud.GetComponent(typeof(CanvasGroup)) as CanvasGroup;
                if (cvGrp) {
                    cvGrp.ignoreParentGroups = false;
                }
            }
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetUnitSkin(ILuaState lua)
    {
        string matName = lua.OptString(2, null);
        // 材质为可选参数
        Material unitMat = null;
        if (!string.IsNullOrEmpty(matName)) {
            unitMat = Creator.objL.Get(matName) as Material;
            if (unitMat == null) return 0;
        }
        var propType = lua.Type(3);

        if (lua.Type(1) == LuaTypes.LUA_TUSERDATA) {
            var go = lua.ToGameObject(1);
            if (go == null) return 0;
            var rdrs = ZFrame.ListPool<Component>.Get();
            var skinProp = go.GetComponent(typeof(ISkinProperty)) as ISkinProperty;
            if (skinProp != null) {
                skinProp.GetSkins(rdrs);
            } else {
                var rdr = go.GetComponentInChildren(typeof(Renderer)) as Renderer;
                if (rdr) rdrs.Add(rdr);
            }

            if (propType == LuaTypes.LUA_TNUMBER) {
                var matAlpha = lua.ToSingle(3);
                ObjViewExt.SetViewAlpha(rdrs, matAlpha, unitMat);
            } else if (propType != LuaTypes.LUA_TNIL && propType != LuaTypes.LUA_TNONE) {
                var matColor = lua.ToColor(3);
                ObjViewExt.SetViewColor(rdrs, matColor, unitMat);
            } else {
                if (unitMat == null) {
                    // 不支持的处理方法
                } else {
                    ObjViewExt.SetViewColor(rdrs, unitMat.GetColor(ShaderIDs.Color), unitMat);
                }
            }
            return 0;
        }

        var obj = lua.ToWorldObj(1);
        var rdrView = obj != null ? obj.view as IRenderView : null;
        if (rdrView == null || !rdrView.IsVisible()) return 0;

        if (propType == LuaTypes.LUA_TNUMBER) {
            var matAlpha = lua.ToSingle(3);
            rdrView.SetViewAlpha(matAlpha, unitMat);
        } else if (propType != LuaTypes.LUA_TNIL && propType != LuaTypes.LUA_TNONE) {
            var matColor = lua.ToColor(3);
            rdrView.SetViewColor(matColor, unitMat);
        } else {
            if (unitMat == null) {
                // 重置到默认
                unitMat = Creator.GetMatSet(rdrView as IUnitView).GetNorm();
                rdrView.SetSkinMat(unitMat);
            } else {
                rdrView.SetViewColor(unitMat.GetColor(ShaderIDs.Color), unitMat);
            }
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int AddUnitSkin(ILuaState lua)
    {
        var obj = lua.ToWorldObj(1);
        if (obj != null && obj.view != null) {
            var dySkins = ((EntityView)obj.view).control.GetComponent(typeof(DynamicSkins)) as DynamicSkins;
            if (dySkins) {
                var uObj = lua.ToUnityObject(2);
                var uniformMat = lua.OptBoolean(3, true);
                var rdr = uObj as Renderer;
                if (rdr == null) {
                    var com = uObj as Component;
                    var go = com ? com.gameObject : uObj as GameObject;
                    if (go) rdr = go.GetComponentInChildren(typeof(Renderer)) as Renderer;
                }
                
                if (rdr) dySkins.AddSkin(rdr, uniformMat);
            }
        }
        return 0;
    }
    
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DelUnitSkin(ILuaState lua)
    {
        var obj = lua.ToWorldObj(1);
        if (obj != null && obj.view != null) {
            var dySkins = ((EntityView)obj.view).control.GetComponent(typeof(DynamicSkins)) as DynamicSkins;
            if (dySkins) {
                var uObj = lua.ToUnityObject(2);
                var rdr = uObj as Renderer;
                if (rdr == null) {
                    var com = uObj as Component;
                    var go = com ? com.gameObject : uObj as GameObject;
                    if (go) rdr = go.GetComponentInChildren(typeof(Renderer)) as Renderer;
                }
                
                if (rdr) dySkins.RemoveSkin(rdr);
            }
        }
        return 0;
    }
    
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetViewVisible(ILuaState lua)
    {
        var view = lua.ToObjView(1) as IRenderView;
        if (view != null) {
            view.SetViewEnable(lua.ToBoolean(2));
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetFOWStatus(ILuaState lua)
    {
        var obj = lua.ToWorldObj(1);        
        var view = obj != null ? obj.view as RoleView : null;
        if (view != null) {
            var status = lua.ToInteger(2);
            switch (status) {
                case 0:
                    view.SetFOWStatus<StageFOWStalker>(false);
                    view.SetFOWStatus<StageFOWExplorer>(false);
                    break;
                case 1:
                    view.SetFOWStatus<StageFOWStalker>(false);
                    view.SetFOWStatus<StageFOWExplorer>(true);
                    break;
                case 2:
                    view.SetFOWStatus<StageFOWStalker>(true);
                    view.SetFOWStatus<StageFOWExplorer>(false);
                    break;
            }
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int FindUnitHud(ILuaState lua)
    {
        if (StageView.Instance) {
            var hudName = lua.ToString(1);
            var hud = StageView.Instance.PlateRoot.Find(hudName);
            if (hud != null) {
                var plate = hud.GetComponent(typeof(UnitPlateHud)) as UnitPlateHud;
                if (plate != null && plate.isActiveAndEnabled) {
                    lua.PushX(hud);
                    return 1;
                }
            }
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int AddUnitHud(ILuaState lua)
    {
        if (StageView.Instance) {
            var hudPath = lua.ToString(1);
            int sibling = lua.OptInteger(2, -1);
            var child = AssetsMgr.A.Load<GameObject>(hudPath);
            var hud = ObjectPoolManager.AddChildScenely(StageView.Instance.PlateRoot.gameObject, child, sibling);
            lua.PushX(hud);
            return 1;
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DelUnitHud(ILuaState lua)
    {
        if (StageView.Instance) {
            var hudName = lua.ToString(1);
            var hud = StageView.Instance.PlateRoot.Find(hudName);
            if (hud != null) {
                ObjectPoolManager.DestroyPooledScenely(hud.gameObject);
            }
        }

        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetOverrideVision(ILuaState lua)
    {
        if (DayNightView.Instance) {
            DayNightView.Instance.overrideVision = lua.ToSingle(1);
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int PlayFx(ILuaState lua)
    {
        var self = lua.ToWorldObj(1);

        string fxName = lua.ToString(2);
        var target = lua.ToWorldObj(3) as IEntity;
        var allowRepeat = lua.OptBoolean(4, false);
        if (!allowRepeat && FX.FxInst.HasLoopFx(target, fxName)) return 0;

        GameObject fxPrefab = lua.ToGameObject(5);

        var list = FX.FxTool.GetPool();
        if (fxPrefab) {
            FX.FxTool.PlayFx(self, target, fxName, fxPrefab, ref FX.FxAnchor.Null, list);
        } else {
            FX.FxTool.PlayFx(self, target, fxName, list);
        }

        if (list.Count > 0) {
            lua.CreateTable(list.Count, 0);
            for (int i = 0; i < list.Count; ++i) {
                lua.SetUObjI(-1, i + 1, ((Component)list[i]).transform);
            }
        } else lua.PushNil();

        FX.FxTool.ReleasePool(list);
        return 1;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int StopFx(ILuaState lua)
    {
        var target = lua.ToWorldObj(1) as IEntity;
        if (target != null) {
            string fxName = lua.OptString(2, null);
            bool instantly = lua.OptBoolean(3, false);

            if (string.IsNullOrEmpty(fxName)) {
                FX.FxInst.Stop(target, instantly);
            } else {
                FX.FxInst.Stop(target, fxName, instantly);
            }
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int AddChild(ILuaState lua)
    {
        GameObject parent, child;
        LibUnity.ApplyParentAndChild(lua, out parent, out child);
        if (child != null) {
            string goName = lua.OptString(3, child.name);
            int sibling = lua.OptInteger(4, -1);
            GameObject go = ObjectPoolManager.AddChildScenely(parent, child, sibling);
            if (go != null) {
                go.name = goName;
                lua.PushX(go);
            } else {
                lua.PushNil();
            }
        } else {
            lua.PushNil();
        }

        return 1;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Recycle(ILuaState lua)
    {
        GameObject go = lua.ToGameObject(1);
        var delay = lua.OptSingle(2, 0f);
        if (go != null) {
            if (StageView.Instance) {
                ObjectPoolManager.DestroyPooledScenely(go, delay);
            } else {
                if (delay > 0) {
                    Object.Destroy(go, delay);
                } else {
                    Object.Destroy(go);
                }
            }
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int EnableFOW(ILuaState lua)
    {
        StageCtrl.showFogOfWar = lua.ToBoolean(1);
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetDayNight(ILuaState lua)
    {
        if (DayNightView.Instance == null) {
            GoTools.NewChild(null, "Game/DayNight");
        }
        lua.PushLightUserData(DayNightView.Instance.gameObject);
        return 1;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SyncTimestamp(ILuaState lua)
    {
        var timestamp = lua.Opt(I2V.ToLong, 1, -1);
        if (timestamp >= 0) {
            StageSync.timestamp = timestamp;
        }

        lua.PushLong(StageSync.timestamp);
        return 1;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int NewNetMsg(ILuaState lua)
    {
        var type = lua.ToInteger(1);
        var size = lua.OptInteger(2, 1024);
        var nm = clientlib.net.NetMsg.createMsg(type, size);
        nm.writeU64(StageSync.timestamp);
        lua.PushLightUserData(nm);
        return 1;
    }
    
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int UpdateClosedArea(ILuaState lua)
    {
        if (StageView.Instance) {
            StageCtrl.Instance.roofFinding.Update();
        }
        return 0;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int EnableOutline(ILuaState lua)
    {
        var cacher = StageView.Assets;
        if (cacher == null) return 0;

        if (lua.IsBoolean(1)) {
            cacher.SetOutline(lua.ToBoolean(1));
            return 0;
        }

        lua.PushBoolean(AssetCacher.outline);
        return 1;
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int EnablePointlit(ILuaState lua)
    {
        var cacher = StageView.Assets;
        if (cacher == null) return 0;

        if (lua.IsBoolean(1)) {
            cacher.SetPointlit(lua.ToBoolean(1));
            return 0;
        }

        lua.PushBoolean(AssetCacher.pointlit);
        return 1;
    }
}
