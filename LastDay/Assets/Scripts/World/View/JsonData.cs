//
//  JsonData.cs
//  survive
//
//  Created by xingweizhen on 10/26/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TinyJSON;

namespace World.View
{
    public abstract class JsonData
    {
        public Variant jObj { get; protected set; }
    }

    public class JsonVarChange : JsonData
    {
        private JsonVarChange()
        {
            jObj = new ProxyObject();
            jObj["change"] = new ProxyNumber(0);
            jObj["maker"] = new ProxyNumber(0);
            jObj["value"] = new ProxyNumber(0);
            jObj["limit"] = new ProxyNumber(0);
        }

        public static Variant Get(VarChange change)
        {
            J.jObj["change"].Set(change.change);
            J.jObj["maker"].Set(change.maker != null ? change.maker.id : 0);
            J.jObj["value"].Set(change.value);
            J.jObj["limit"].Set(change.limit);
            return J.jObj;
        }

        private static JsonVarChange J = new JsonVarChange();
    }

    public class JsonDuraChange : JsonData
    {
        private JsonDuraChange()
        {
            jObj = new ProxyObject();
            jObj["change"] = new ProxyNumber(0);
            jObj["pos"] = new ProxyNumber(0);
            jObj["dat"] = new ProxyNumber(0);
            jObj["ammo"] = new ProxyNumber(0);
            jObj["dura"] = new ProxyNumber(0);
        }

        public static Variant Get(DuraChange change)
        {
            J.jObj["change"].Set(change.change);
            J.jObj["pos"].Set(change.pos);
            J.jObj["dat"].Set(change.dat);
            J.jObj["ammo"].Set(change.ammo);
            J.jObj["dura"].Set(change.dura);
            return J.jObj;
        }

        private static JsonDuraChange J = new JsonDuraChange();
    }

    public class JsonSwapWeapon : JsonData
    {
        private JsonSwapWeapon()
        {
            jObj = new ProxyObject();
            jObj["major"] = new ProxyNumber(0);
            jObj["majorCD"] = new ProxyNumber(0);
            jObj["majorCycle"] = new ProxyNumber(0);
            jObj["minor"] = new ProxyNumber(0);
            jObj["minorCD"] = new ProxyNumber(0);
            jObj["minorCycle"] = new ProxyNumber(0);
        }

        public static Variant Get(IObj Obj)
        {
            var human = Obj as Human;
            if (human != null) {
                var frameIndex = Obj.L.frameIndex;
                J.jObj["major"].Set(human.Major.id);
                J.jObj["majorCD"].Set(CVar.F2S(human.Major.readyFrame - frameIndex));
                J.jObj["majorCycle"].Set(CVar.F2S(human.Major.prepare));

                J.jObj["minor"].Set(human.Minor.id);
                J.jObj["minorCD"].Set(CVar.F2S(human.Minor.readyFrame - frameIndex));
                J.jObj["minorCycle"].Set(CVar.F2S(human.Minor.prepare));
            } else {
                J.jObj["major"].Set(-1);
                J.jObj["majorCD"].Set(0);
                J.jObj["majorCycle"].Set(0);
                J.jObj["minor"].Set(-1);
                J.jObj["minorCD"].Set(0);
                J.jObj["minorCycle"].Set(0);
            }

            return J.jObj;
        }

        private static JsonSwapWeapon J = new JsonSwapWeapon();
    }
}