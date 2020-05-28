using System.Collections;
using System.Collections.Generic;

namespace World
{
    public class Human : Role
    {
        public Human() : base()
        {

        }

        public CFG_Weapon Major { get; protected set; }
        public CFG_Weapon Minor { get; protected set; }
        public CFG_Weapon Tool { get; protected set; }
        
        public void InitHuman(int majorId, int minorId)
        {
            Major = new CFG_Weapon(majorId);
            Minor = new CFG_Weapon(minorId);
            Tool = new CFG_Weapon(-1);

            for (int i = 0; i < (int)ATTR._END_; ++i) {
                var value = currentAttrs[i] + Major.attrs[i];
                SetAttr(i, value);
            }

            actionIds.Add(Major.reload);
            actionIds.AddRange(Major.Skills);

            L.SwapWeapon(this, Major);
        }
        
        public void SetWeapon(int major, int minor, bool swap)
        {
            var frame = L.frameIndex;

            if (major >= 0) {
                // 移除原武器的技能加成和属性加成
                actionIds.Clear();
                CFG_Attr.Temp.CopyFrom(Major.attrs);

                var prevDat = Major.dat;
                Major.LoadData(major);
                if (!swap) Major.UpdateCool(frame);
                if (Major.dat != prevDat) actionIndex = 1;

                // 添加新武器的技能
                actionIds.Add(Major.reload);
                actionIds.AddRange(Major.Skills);

                // 属性会触发属性改变回调，放在技能数据后面
                for (int i = 0; i < (int)ATTR._END_; ++i) {
                    SetAttr(i, currentAttrs[i] - CFG_Attr.Temp[i] + Major.attrs[i]);
                }
            }

            if (minor >= 0) {
                Minor.LoadData(minor);
                if (!swap) Minor.UpdateCool(frame);
            }

            if (Major.readyFrame > frame) {
                Content.SetCDFrame(Major.readyFrame);
            }
            
            L.SwapWeapon(this, Major);
        }

        public void SetTool(int pos)
        {
            Tool.LoadData(pos);
        }
    }
}
