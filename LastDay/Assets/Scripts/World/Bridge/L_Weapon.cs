using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World
{
    using View;

    public static class L_Weapon
    {
        private static void LoadFromLua(CFG_Weapon Weapon, System.IntPtr lua, int index)
        {
            if (index < 0) index = lua.GetTop() + 1 + index;

            var fc = new CFG_Weapon.FormCfg() {
                id = (int)lua.GetNumber(index, "pos"),
                dat = (int)lua.GetNumber(index, "dat"),
                hand = (int)lua.GetNumber(index, "index", 1) - 1,
                prepare = (int)lua.GetNumber(index, "prepare"),
                model = lua.GetString(index, "model"),
                fxBundle = lua.GetString(index, "fxBundle"),
                sfxBank = lua.GetString(index, "sfxBank"),
            };

            var fd = new CFG_Weapon.FormDura() {
                dura = (int)lua.GetNumber(index, "dura"),
                maxDura = (int)lua.GetNumber(index, "maxDura"),
                ammo = (int)lua.GetNumber(index, "ammo"),
                maxAmmo = (int)lua.GetNumber(index, "maxAmmo"),
            };

            lua.GetField(index, "Skills");
            if (lua.IsTable(-1)) {
                lua.PushNil();
                while (lua.Next(-2)) {
                    var skill = lua.ToInteger(-1);
                    lua.Pop(1);
                    Weapon.Skills.Add(skill);
                }
            }
            lua.Pop(1);

            lua.GetField(index, "Passive");
            if (lua.IsTable(-1)) {
                lua.PushNil();
                while (lua.Next(-2)) {
                    var passive = lua.ToInteger(-1);
                    lua.Pop(1);
                    Weapon.Passive.Add(passive);
                }
            }
            lua.Pop(1);

            var reload = (int)lua.GetNumber(index, "reload");
            Weapon.SetData(fc, fd, reload);
                        
            lua.GetField(index, "Attr");
            L_OBJInit.Lua2Attr(lua, -1, Weapon.attrs);
            lua.Pop(1);
        }

        public static void Loader(CFG_Weapon Weapon)
        {
            var lua = DataUtil.LuaLoadConfig("load_weapon", Weapon.id);

            if (lua.IsTable(-1)) {
                LoadFromLua(Weapon, lua, -1);
                Weapon.LoadFx();
            }
            lua.Pop(1);
        }
    }
}
