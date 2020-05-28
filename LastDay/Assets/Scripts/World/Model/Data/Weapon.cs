using System.Collections;
using System.Collections.Generic;

namespace World
{
    public class CFG_Weapon : FxBundle, IConfig, IEventParam
    {
        public struct FormCfg
        {
            public int id, dat, hand, prepare;
            public string model, fxBundle, sfxBank;
        }

        public struct FormDura
        {
            public int dura, maxDura;
            public int ammo, maxAmmo;
        }

        public static System.Action<CFG_Weapon> Loader;
        public int id { get; private set; }
        public int bag { get { return id / CVar.BAG_CAP; } }
        public int idx { get { return id % CVar.BAG_CAP - 1; } }

        public int dat { get; private set; }
        public int hand { get; private set; }
        public int prepare { get; private set; }
        public CFG_Attr attrs { get; private set; }
        public readonly List<int> Skills = new List<int>();
        public int reload { get; private set; }
        public readonly List<int> Passive = new List<int>();

        public string model { get; private set; }

        public int readyFrame { get; private set; }

        public VarData Dura { get; private set; }
        public VarData Ammo { get; private set; }
        
        public bool usable { get { return !Dura.IsEmpty() && !Ammo.IsEmpty(); } }

        public CFG_Weapon(int id)
        {
            attrs = new CFG_Attr();
            Dura = new VarData();
            Ammo = new VarData();

            LoadData(id);
        }

        /// <summary>
        /// 加载武器数据
        /// </summary>
        /// <param name="id">大于0时表示武器在背包的位置；小于0表示配置id取负的值</param>
        public void LoadData(int id)
        {
            Reset(this);
            this.id = id;
            Loader(this);
        }
        
        public void SetData(FormCfg fc, FormDura fd, int reload)
        {
            SetBundle(fc.fxBundle, fc.sfxBank);

            id = fc.id;
            this.dat = fc.dat;
            this.model = fc.model;
            this.hand = fc.hand;
            this.prepare = fc.prepare;
            this.reload = reload;

            this.Dura.Set(fd.dura, fd.maxDura);
            this.Ammo.Set(fd.ammo, fd.maxAmmo);
        }
                
        public void ChangeDura(int change)
        {
            int final = 0;
            Ammo.Add(change, out final);
            if (change < 0) {
                Dura.Add(change, out final);
            }
        }

        public void UpdateCool(int frame)
        {
            readyFrame = frame + prepare;
        }

        public override string ToString()
        {
            var dura = Dura.GetValue();
            var maxDura = Dura.GetLimit();
            var maxAmmo = Ammo.GetLimit();
            if (maxAmmo > 0) {
                return string.Format("#{0}:{1}[{2}/{3}:{4}]", id, model, dura, maxDura, Ammo.GetValue());
            } else {
                return string.Format("#{0}:{1}[{2}/{3}]", id, model, dura, maxDura);
            }
        }

        public static void Reset(CFG_Weapon Weapon)
        {
            Weapon.id = -1;
            Weapon.attrs.Clear();
            Weapon.Skills.Clear();
            Weapon.Passive.Clear();
        }

    }
}
