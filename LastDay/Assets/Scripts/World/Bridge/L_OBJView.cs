using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ILuaState = System.IntPtr;

namespace World
{
    using View;

    public struct L_OBJImage
    {
        public string skin, face;
        public Color haircolor;
        public DressType dress;
    }

    public class L_OBJView : IDataFromLua
    {
        public string prefab;
        public string model;
        public string fxBundle, sfxBank;
        public int bodyMat, gender;
        private L_OBJImage m_ObjImage = new L_OBJImage();
        public L_OBJImage objImage { get { return m_ObjImage; } }

        public List<string> Dresses { get; private set; }
        public Dictionary<int, string> Affixes { get; private set; }
        public Dictionary<string, string> Fxes { get; private set; }
        public Dictionary<string, float> Numbers { get; private set; }

        void IDataFromLua.InitFromLua(ILuaState lua, int index)
        {
            if (index < 0) index = lua.GetTop() + 1 + index;

            model = null;
            if (Dresses == null) Dresses = new List<string>(); else Dresses.Clear();
            if (Affixes == null) Affixes = new Dictionary<int, string>(); else Affixes.Clear();
            if (Fxes == null) Fxes = new Dictionary<string, string>(); else Fxes.Clear();
            if (Numbers == null) Numbers = new Dictionary<string, float>(); else Numbers.Clear();

            prefab = lua.GetString(index, "prefab");
            bodyMat = (int)lua.GetNumber(index, "bodyMat");
            gender = (int)lua.GetNumber(index, "gender");
            fxBundle = lua.GetString(index, "fxBundle");
            sfxBank = lua.GetString(index, "sfxBank");

            lua.GetField(index, "Fxes");
            if (lua.IsTable(-1)) {
                lua.PushNil();
                while (lua.Next(-2)) {
                    var key = lua.ToString(-2);
                    var vType = lua.Type(-1);
                    switch (vType) {
                        case XLua.LuaTypes.LUA_TSTRING:
                            Fxes.Add(key, lua.ToString(-1));
                            break;
                        case XLua.LuaTypes.LUA_TNUMBER:
                            Numbers.Add(key, lua.ToSingle(-1));
                            break;
                    }                    
                    lua.Pop(1);
                }
            }
            lua.Pop(1);

            lua.GetField(index, "Affixes");
            if (lua.IsTable(-1)) {
                lua.PushNil();
                while (lua.Next(-2)) {
                    var path = lua.GetString(-1, "path");
                    var hand = (int)lua.GetNumber(-1, "index") - 1;
                    lua.Pop(1);

                    Affixes.Add(hand, path);
                }
            }
            lua.Pop(1);

            lua.GetField(index, "model");
            ToModelData(lua, -1, out model, Dresses, ref m_ObjImage);
            lua.Pop(1);
        }
        
        public ObjData ToData()
        {
            return new ObjData(bodyMat, gender, fxBundle, sfxBank, Fxes, Numbers);
        }


        public static void ToModelData(ILuaState lua, int index, 
            out string model, List<string> Dresses, ref L_OBJImage objImage)
        {
            if (index < 0) index = lua.GetTop() + 1 + index;

            model = null;
            objImage.skin = null;
            objImage.face = null;
            objImage.haircolor = Color.gray;
            objImage.dress = 0;

            var type = lua.Type(index);
            if (type == XLua.LuaTypes.LUA_TSTRING) {
                model = lua.ToString(index);
            } else if (type == XLua.LuaTypes.LUA_TTABLE) {
                objImage.skin = lua.GetString(index, "skin");
                objImage.face = lua.GetString(index, "face");
                objImage.haircolor = lua.GetValue(I2V.ToColor, index, "haircolor", objImage.haircolor);
                objImage.dress = (DressType)lua.GetValue(I2V.ToInteger, index, "dress");
                
                lua.GetField(index, "Dresses");
                if (lua.IsTable(-1)) {
                    lua.PushNil();
                    while (lua.Next(-2)) {
                        var dress = lua.ToString(-1);
                        lua.Pop(1);
                        Dresses.Add(dress);
                    }
                }
                lua.Pop(1);
            }
        }
    }
}
