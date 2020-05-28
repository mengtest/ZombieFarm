using System.Collections.Generic;
using ILuaState = System.IntPtr;

namespace World
{
    public class L_OBJData : IDataFromLua
    {
        public string klass;
        public L_OBJInit Init { get; private set; }
        public L_OBJView View { get; private set; }
        public CFG_Attr Attr = new CFG_Attr();
        public readonly List<int> actionIds = new List<int>();
        public int majorId, minorId;
        public int group;
        
        void IDataFromLua.InitFromLua(ILuaState lua, int index)
        {
            if (Init == null) Init = DataUtil.Get<L_OBJInit>();
            if (View == null) View = DataUtil.Get<L_OBJView>();

            Attr.Clear();
            actionIds.Clear();

            klass = lua.GetString(index, "class");

            lua.GetDataValue(index, "View", View);

            lua.GetField(index, "Data");
            if (lua.IsTable(-1)) {
                lua.GetDataValue(-1, "Init", Init);

                lua.GetField(-1, "Attr");
                L_OBJInit.Lua2Attr(lua, -1, Attr);
                lua.Pop(1);

                lua.GetField(-1, "Skills");
                if (lua.IsTable(-1)) {
                    lua.PushNil();
                    while (lua.Next(-2)) {
                        var actionId = lua.ToInteger(-1);
                        lua.Pop(1);
                        actionIds.Add(actionId);
                    }
                }
                lua.Pop(1);

                lua.GetField(-1, "Weapons");
                if (lua.IsTable(-1)) {
                    majorId = (int)lua.GetNumber(-1, "majorId");
                    minorId = (int)lua.GetNumber(-1, "minorId");
                }
                lua.Pop(1);

                group = (int)lua.GetNumber(-1, "group", -1);
            }
            lua.Pop(1);
        }
    }
}