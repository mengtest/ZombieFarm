using System.Collections;
using System.Collections.Generic;
using ILuaState = System.IntPtr;

namespace World
{
    public static class DataUtil
    {
        private static Dictionary<System.Type, IDataFromLua> DataSets = new Dictionary<System.Type, IDataFromLua>();

        public static T Get<T>() where T : IDataFromLua, new()
        {
            var type = typeof(T);
            IDataFromLua Data = null;
            if (!DataSets.TryGetValue(type, out Data)) {
                Data = new T();
                DataSets.Add(type, Data);
            }
            return (T)Data;
        }

        public static T Get<T>(ILuaState lua, int index) where T : IDataFromLua, new()
        {
            T Data = Get<T>();
            Data.InitFromLua(lua, index);
            return Data;
        }

        public static ILuaState LuaLoadConfig(string method, int id)
        {
            return Control.StageCtrl.LoadLuaData(method, id);
        }

        public static T LuaCallUnitField<T>(int id, string method, I2V.Index2Value<T> indexTo)
        {
            T ret = default(T);
            var lua = LuaLoadConfig("get_obj", id);
            var top = lua.GetTop();
            if (lua.IsTable(top)) {
                lua.GetField(top, method);
                if (lua.IsFunction(-1)) {
                    var b = lua.BeginPCall();
                    lua.PushValue(top);
                    lua.ExecPCall(1, 1, b);
                    indexTo(lua, -1, out ret);
                }
                lua.Pop(1);
            }
            lua.Pop(1);

            return ret;
        }
    }
}
