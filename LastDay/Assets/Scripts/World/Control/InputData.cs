using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.Control
{
    using View;

    /// <summary>
    /// 角色更新的数据
    /// </summary>
    public class TmpData
    {
        public IObj Obj;
        public bool rewind, major;
        public int switchMajorWeapon;
        
        public void SetData()
        {
            if (rewind) {
                var view = Obj.view as HumanView;
                if (view) {
                    view.RewindPose();
                    //var roleCtrl = view.control as RoleAnim;
                    //if (roleCtrl) {
                    //    roleCtrl.Rewind();
                    //}
                }
            }
            if (major) {
                var human = Obj as Human;
                var view = Obj.view as HumanView;
                if (human != null && view) {
                    view.EquipTool(human.Major);
                }
            }

            if (switchMajorWeapon > 0) {
                var lua = LuaComponent.lua;
                lua.GetGlobal("NW", "move_item");
                var b = lua.BeginPCall();
                lua.PushInteger(CVar.MAJOR_POS);
                lua.PushInteger(switchMajorWeapon);
                lua.ExecPCall(2, 0, b);
            }
        }

        public static void Reset(TmpData data)
        {            
            data.rewind = false;
            data.switchMajorWeapon = 0;
        }
    }
}