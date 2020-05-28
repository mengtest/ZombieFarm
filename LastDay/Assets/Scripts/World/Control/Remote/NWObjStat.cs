using System.Collections;
using System.Collections.Generic;
using clientlib.net;
using UnityEngine;

namespace World.Control
{
    using View;

    public class NWObjStat : IFullMsg
    {
        public void Clear() { }

        public bool IsDirty()
        {
            return false;
        }

        public void Read(INetMsg nm)
        {
            var mapId = nm.readU64();
            var maker = StageCtrl.L.FindById(nm.readU32());
            var actionId = nm.readU32();
            var Action = CFG_Action.Load(actionId);

            ReadDataChange(nm, maker, Action);
        }

        public void Write(INetMsg nm) { }

        private static void SyncItemChange(IObj maker, IAction Action, int obj, int pos, int dat, int dura, int ammo)
        {
            var Obj = StageCtrl.L.FindById(obj);
            var human = Obj as Human;
            if (human != null) {
                if (pos == human.Major.id) {
                    var duraCh = dura - human.Major.Dura.cache;
                    var ammoCh = ammo - human.Major.Ammo.cache;
                    var change = duraCh != 0 ? duraCh : ammoCh;

                    human.Major.Dura.SetCache(dura);
                    human.Major.Ammo.SetCache(ammo);

                    if (Action == null || Action.delay == 0 || maker == null || change > 0) {
                        human.ChangeDura(human.Major, change);
                    } else {
                        human.NewTimer(maker, human, Action.delay)
                            .SetParam(Action).SetValue(change).SetEvent(OnMajorDuraChange, null, null);
                    }

                    return;
                }

                if (human.Tool != null && pos == human.Tool.id) {
                    var duraCh = dura - human.Tool.Dura.cache;
                    var ammoCh = ammo - human.Tool.Ammo.cache;
                    var change = duraCh != 0 ? duraCh : ammoCh;

                    human.Tool.Dura.SetCache(dura);
                    human.Tool.Ammo.SetCache(ammo);

                    if (Action == null || Action.delay == 0 || maker == null) {
                        human.ChangeDura(human.Tool, change);
                    } else {
                        human.NewTimer(maker, human, Action.delay)
                            .SetParam(Action).SetValue(change).SetEvent(OnToolDuraChange, null, null);
                    }

                    return;
                }
            }

            if (Obj != null) {
                // Default Behaviour
                Obj.L.DuraChanged(Obj, new DuraChange(pos, dat, dura, ammo, 0));
            }
        }

        public static void ReadDataChange(INetMsg nm, IObj maker, IAction Action)
        {
            using (var itor = new NWHpChange().ReadN(nm)) {
                while (itor.MoveNext()) {
                    var Ch = itor.Current;
                    var obj = StageCtrl.L.FindById(Ch.id, true);
                    var living = obj as ILiving;
                    if (living != null) {
                        var change = Ch.hp - living.Health.cache;
                        living.Health.SetCache(Ch.hp);

                        if (Ch.hp <= 0) {
                            // 目标已死亡
                            var bObj = obj as IBehavior;
                            if (bObj != null) bObj.OnStop();
                            View.Debugger.LogD("{0}已死亡(HP={1})。(被{2}杀死)", obj, Ch.hp, maker);
                        }

                        var changeDelay = 0;
                        if (maker != null && change < 0 && Action != null) {
                            changeDelay += Action.delay;
                            if (Action.speed > 0) {
                                var distance = Vector.Distance(maker.coord, living.coord);
                                changeDelay += CVar.S2F(distance / Action.speed);
                            }
                        }

                        if (changeDelay == 0) {
                            living.ChangeHp(new VarChange(change, Action, maker));
                        } else {
                            living.NewTimer(maker, living, changeDelay)
                                .SetParam(Action).SetValue(change).SetEvent(OnObjHpChange, null, null);
                        }
                    } else {
                        Debugger.LogW("对象不存在{0}={1}", Ch.id, obj);
                    }
                }
            }

            var nItem = nm.readU32();
            for (int i = 0; i < nItem; ++i) {
                var objId = nm.readU32();
                var bag = nm.readU32();
                var pos = nm.readU32();
                var dat = nm.readU32();
                var amount = nm.readU32();

                var itemPos = CVar.Pos2Id(bag, pos);
                int dura = 0, ammo = 0;

                if (objId == StageCtrl.P.id) {
                    // 自己的道具信息同步到数据库
                    var lua = StageCtrl.LT.PushField("update_item");
                    var b = lua.BeginPCall();

                    lua.CreateTable(0, 3);
                    lua.SetDict("pos", itemPos);
                    lua.SetDict("dat", dat);
                    lua.SetDict("amount", amount);

                    lua.PushString("RanAttr");
                    var nAttr = nm.readU32();
                    lua.CreateTable(nAttr, 0);
                    for (int j = 0; j < nAttr; ++j) {
                        var id = nm.readU32();
                        var value = nm.readU32();
                        lua.PushInteger(id);
                        lua.PushInteger(value);
                        lua.SetTable(-3);

                        switch (id) {
                            case 1:
                                dura = value;
                                break;
                            case 2:
                                ammo = value;
                                break;
                            default: break;
                        }
                    }

                    lua.SetTable(-3);
                    lua.ExecPCall(1, 0, b);
                } else {
                    // 仅读出属性值
                    var nAttr = nm.readU32();
                    for (int j = 0; j < nAttr; ++j) {
                        var id = nm.readU32();
                        var value = nm.readU32();
                        switch (id) {
                            case 1:
                                dura = value;
                                break;
                            case 2:
                                ammo = value;
                                break;
                            default: break;
                        }
                    }
                }

                SyncItemChange(maker, Action, objId, itemPos, dat, dura, ammo);
            }

            using (var itor = new NWBuffChange().ReadN(nm)) {
                while (itor.MoveNext()) {
                    var B = itor.Current;
                    var Buff = SimpleBuff.Load(B.buffId);
                    var Obj = StageCtrl.L.FindById(B.id);

                    if (Obj != null) {
                        int duration = B.disappear == 0 ? int.MaxValue : B.disappear - Obj.L.frameIndex;
                        if (duration > 0) {
                            var timerUnique = Buff.Execute(null, Obj, ref duration);
                            if (duration > 0) {
                                Obj.L.Effecting(Obj, SimpleBuff.Effecting.Apply(0, Obj.id, Buff, timerUnique));
                            }
                        }
                    }
                }
            }

            using (var itor = new NWDeadDisplay().ReadN(nm)) {
                while (itor.MoveNext()) {
                    var D = itor.Current;
                    var Obj = StageCtrl.L.FindById(D.id);
                    var xObj = Obj as XObject;
                    if (xObj != null) {
                        xObj.SetDeath(D.type, D.value);
                    }

                    var view = Obj != null ? Obj.view as EntityView : null;
                    if (view != null) {
                        view.SetDeadDisplay(maker, D.type, D.value);
                    }
                }
            }
        }

        private static readonly TimerHandler OnObjHpChange = (Timer tm, int n) => {
            var living = tm.whom as ILiving;
            var Action = tm.param as IAction;
            var change = living.Health.cache - living.Health.GetValue();
            living.ChangeHp(new VarChange(change, Action, tm.who) { display = tm.value });
            return true;
        };

        private static readonly TimerHandler OnMajorDuraChange = (Timer tm, int n) => {
            var human = tm.whom as Human;
            human.ChangeDura(human.Major, tm.value);
            return true;
        };

        private static readonly TimerHandler OnToolDuraChange = (Timer tm, int n) => {
            var human = tm.whom as Human;
            var Tool = human.Tool;
            if (Tool != null) {
                human.ChangeDura(human.Tool, tm.value);
            }

            return true;
        };
    }
}
