//
//  GatherData.cs
//  survive
//
//  Created by xingweizhen on 11/3/2017.
//
//

using System.Collections;
using System.Collections.Generic;

namespace World
{
    public class CFG_Interact : CFG_Action, IAction, IHitData
    {
        public struct Form
        {
            public int delay;
            public string fx, sfx;
        }

        public int cooldown { get { return 0; } }
        public int speed { get { return 0; } }
        public readonly int m_Delay;
        public virtual int delay { get { return m_Delay; } }

        public readonly int damage;

        public IAction Action { get { return this; } }

        private readonly string m_HitFx;
        public string fxH { get { return m_HitFx; } }

        private readonly string m_HitSfx;
        public string sfxH { get { return m_HitSfx; } }

        public CFG_Interact(int id, string name, int damage, ACTType type,
            FormAct fa, Form form, List<Advanced> Chargeds)
            : base(id, name, type, fa, Chargeds)
        {
            this.damage = damage;

            m_Delay = form.delay;
            m_HitFx = form.fx;
            m_HitSfx = form.sfx;
        }


        public bool UsableFor(IActor bObj) { return true; }
        public IObj TargetFor(IActor bObj) { return null; }
        public void ClampTarget(IActor bObj, ref IObj target)
        {

        }

        public void OnStart(IActor bObj) { }
        public virtual void OnSuccess(IObj Who, IObj Whom)
        {
            if (delay > 0) {
                Who.NewTimer(Who, Whom, delay).SetParam(this)
                    .SetEvent(OnGatherSuccess, null, null);
            } else {
                GatherSuccess(Who, Whom, this);
            }
        }
        public virtual void OnFinish(IObj Who, IObj Whom)
        {
            if (!ObjectExt.IsAlive(Whom)) {
                (Who as IActor).Content.Uninit();
            }
        }

        public static void GatherSuccess(IObj Who, IObj Whom, CFG_Interact Gather)
        {
            var hitEvent = HitEvent.Apply(Who, Whom, Gather, HitResult.Hit);
            Who.L.HitTarget(Who, hitEvent);
            if (Whom != null) {
                Whom.L.BeingHit(Whom, hitEvent);
            }

            if (Gather.type == ACTType.SKILL) {
                var living = Whom as ILiving;
                if (Who.L.localMode && living != null) {
                    living.ChangeHp(new VarChange(-Gather.damage, Gather, Who));
                    if (!living.IsAlive()) living.Destroy();

                    var human = Who as Human;
                    var Tool = human.Tool;
                    if (Tool != null) {
                        human.ChangeDura(Tool, -1);
                    }
                }
            } else if (Gather.type == ACTType.PICK) {
                if (Whom != null && Whom.L.localMode) {
                    Whom.Destroy();
                }
            }

            if (!ObjectExt.IsAlive(Whom)) {
                (Who as IActor).Content.Uninit();
            }
        }

        private readonly static TimerHandler OnGatherSuccess = new TimerHandler(__GatherSuccess);
        private static bool __GatherSuccess(Timer tm, int n)
        {
            GatherSuccess(tm.who, tm.whom, tm.param as CFG_Interact);
            return true;
        }
    }

    /// <summary>
    /// 开箱动作：动作时间是可变的
    /// </summary>
    public class CFG_Opening : CFG_Interact
    {
        public CFG_Opening(int id, string name, FormAct fa, Form form, List<Advanced> Chargeds)
            : base(id, name, 0, ACTType.OPEN, fa, form, Chargeds)
        {

        }

        public override int cast { get { return m_Cast; } }
        public override int delay { get { return 0; } }

        public override void OnSuccess(IObj Who, IObj Whom)
        {

        }

        public void SetCastTime(int cast)
        {
            m_Cast = cast;
        }
    }

}
