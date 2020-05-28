using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ILuaState = System.IntPtr;

namespace World
{
    public class L_OBJInit : IDataFromLua
    {
        // Base
        public int id, dat;
        public int camp;
        public long master;
        public Vector pos;
        public int status;
        public int disappear;

        // Entity
        public Vector size;
        public Vector forward;
        public int operLimit, operId;
        public bool obstacle;
        public int blockLevel;
        public int layer;
        public bool offensive;

        // Role
        public int state;
        public Vector tarCoord;
        public float tarAngle;
        public bool stealth;

        // Death
        public int deathType, deathValue;

        public CFG_Attr Attr { get; private set; }

        void IDataFromLua.InitFromLua(ILuaState lua, int index)
        {
            if (index < 0) index = lua.GetTop() + 1 + index;

            id = (int)lua.GetNumber(index, "id");
            dat = (int)lua.GetNumber(index, "dat");
            camp = (int)lua.GetNumber(index, "camp");
            master = lua.GetValue(I2V.ToLong, index, "master");
            status = (int)lua.GetNumber(index, "status");
            lua.GetField(index, "coord");
            pos = lua.ToVector3(-1);
            lua.Pop(1);

            operLimit = (int)lua.GetNumber(index, "operLimit", 0);
            operId = (int)lua.GetNumber(index, "operId", -1);
            obstacle = lua.GetBoolean(index, "obstacle");
            blockLevel = (int)lua.GetNumber(index, "blockLevel");
            forward = Quaternion.Euler(0, lua.GetNumber(index, "angle"), 0) * Vector3.forward;
            layer = (int)lua.GetNumber(index, "layer");
            offensive = lua.GetBoolean(index, "offensive");

            lua.GetField(index, "size");
            size = lua.ToVector3(-1);
            lua.Pop(1);

            stealth = lua.GetBoolean(index, "stealth");
            state = (int)lua.GetNumber(index, "state");
            tarAngle = lua.GetNumber(index, "tarAngle");

            lua.GetField(index, "tarCoord");
            tarCoord = lua.ToVector3(-1);
            lua.Pop(1);

            var disappear = lua.GetValue(I2V.ToLong, -1, "disappear", -1);
            this.disappear = Control.StageCtrl.Timestamp2Frame(disappear);

            if (Attr == null) Attr = new CFG_Attr(); else Attr.Clear();
            lua.GetField(index, "Attr");
            Lua2Attr(lua, -1, Attr);
            lua.Pop(1);

            lua.GetField(index, "Death");
            if (lua.IsTable(-1)) {
                deathType = (int)lua.GetNumber(-1, "type");
                deathValue = (int)lua.GetNumber(-1, "value");
            }
            lua.Pop(1);
        }

        public static void Lua2Attr(ILuaState lua, int index, CFG_Attr Attr)
        {
            if (index < 0) index = lua.GetTop() + 1 + index;
            if (lua.IsTable(index)) {
                lua.PushNil();
                while (lua.Next(index)) {
                    var key = lua.ToString(-2);
                    var value = lua.ToSingle(-1);
                    lua.Pop(1);
                    Attr[key] = value;
                }
            }
        }

        public static explicit operator BaseData(L_OBJInit Init)
        {
            return new BaseData() {
                id = Init.id, dat = Init.dat, camp = Init.camp, master = Init.master,
                pos = Init.pos, status = Init.status,
            };
        }

        public static explicit operator EntityData(L_OBJInit Init)
        {
            return new EntityData() {
                operLimit = Init.operLimit,
                operId = Init.operId,
                obstacle = Init.obstacle,
                blockLevel = Init.blockLevel,
                size = Init.size,
                forward = Init.forward,
                layer = Init.layer,
                offensive = Init.offensive,
                deadType = Init.deathType,
                deadValue = Init.deathValue,
            };
        }
    }
}