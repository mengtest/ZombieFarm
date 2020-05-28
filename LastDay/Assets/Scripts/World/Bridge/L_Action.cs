using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World
{
    public static class L_Action
    {
        public static IAction Creator(int id)
        {
            var lua = DataUtil.LuaLoadConfig("load_action", id);
            var Action = CreateFromLua(lua, -1);
            lua.Pop(1);

            return Action;
        }

        private static IAction CreateFromLua(System.IntPtr lua, int index)
        {
            if (!lua.IsTable(index)) return null;

            if (index < 0) index = lua.GetTop() + 1 + index;

            var id = (int)lua.GetNumber(index, "id");
            var name = lua.GetString(index, "name");

            var Fa = new CFG_Action.FormAct() {
                ready = (int)lua.GetNumber(index, "ready"),
                cast = (int)lua.GetNumber(index, "cast"),
                post = (int)lua.GetNumber(index, "post"),
                minRange = lua.GetNumber(index, "minRange"),
                maxRange = lua.GetNumber(index, "maxRange"),
                startFx = new FxView(
                    lua.GetString(index, "fxC"),
                    lua.GetString(index, "fxCT"),
                    lua.GetString(index, "sfxC")),
                successFx = new FxView(
                    lua.GetString(index, "fxCed"),
                    lua.GetString(index, "fxCTed"),
                    lua.GetString(index, "sfxCed")),
                action = lua.GetString(index, "action"),
                mode = (ACTMode)lua.GetEnum(index, "mode", ACTMode.NONE),
                oper = (ACTOper)lua.GetEnum(index, "oper", ACTOper.OneShot),
            };

            List<CFG_Action.Advanced> Chargeds = null;
            lua.GetField(index, "ChargeIDs");
            if (lua.ObjLen(-1) > 0) {
                Chargeds = new List<CFG_Action.Advanced>();
                lua.PushNil();
                while (lua.Next(-2)) {
                    var cond = (AdvancedCond)lua.GetEnum(-1, "cond", AdvancedCond.NONE);
                    var value = lua.GetNumber(-1, "value");
                    var skill = (int)lua.GetNumber(-1, "skill");
                    if (cond != AdvancedCond.NONE) {
                        switch (cond) {
                            case AdvancedCond.Charge:
                                value = CVar.S2F(value * 0.001f);
                                break;
                            case AdvancedCond.inHpPercent:
                            case AdvancedCond.onHpPercent:
                                value *= CVar.LENGTH_RATE;
                                break;
                        }
                        Chargeds.Add(new CFG_Action.Advanced() { cond = cond, value = value, skill = skill, });
                    } else {
                        LogMgr.W("错误的技能触发条件：{0}@{1}#{2}", lua.GetAny(-1, "cond"), name, id);
                    }
                    lua.Pop(1);
                }
            }
            lua.Pop(1);

            var tarSet = (int)lua.GetNumber(index, "tarSet", -1);
            if (tarSet < 0) {
                var form = new CFG_Interact.Form() {
                    delay = (int)lua.GetNumber(index, "delay"),
                    fx = lua.GetString(index, "fxH"),
                    sfx = lua.GetString(index, "sfxH"),
                };
                var actType = (ACTType)lua.GetEnum(index, "type", ACTType.SKILL);
                if (actType == ACTType.OPEN) {
                    return new CFG_Opening(id, name, Fa, form, Chargeds);
                }

                return new CFG_Interact(id, name,
                    (int)lua.GetNumber(index, "damage"),
                    actType, Fa, form, Chargeds);
            }

            lua.GetField(index, "SubIDs");
            var SubIds = lua.ToArrayNumber<int>(-1);
            lua.Pop(1);

            lua.GetField(index, "acts");
            var acts = lua.ToArrayString(-1);
            lua.Pop(1);

            lua.GetField(index, "Target");
            var Target = L_Target.CreateFromLua(lua, -1);
            lua.Pop(1);

            var Fs = new CFG_Skill.FormSkill() {
                blockLevel = (int)lua.GetNumber(index, "blockLevel"),
                cost = (int)lua.GetNumber(index, "cost"),
                cooldown = (int)lua.GetNumber(index, "cooldown"),
                delay = (int)lua.GetNumber(index, "delay"),
                hurt = (int)lua.GetNumber(index, "hurt"),
                alertRange = (int)lua.GetNumber(index, "alertRange"),
                acts = acts, SubIds = SubIds,
            };
            var Ft = new CFG_Skill.FormTarget() {
                tarSet = tarSet, Target = Target,
                allowNullTar = lua.GetBoolean(index, "allowNullTar"),
                tarType = (TARType)lua.GetEnum(index, "tarType", TARType.None),

            };
            var combo = (int)lua.GetNumber(index, "combo");
            return new CFG_Skill(id, name, ACTType.SKILL, combo, Fa, Fs, Ft, Chargeds);
        }
    }
}
