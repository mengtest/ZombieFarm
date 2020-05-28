using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    public class AnimateHurt : MonoBehaviour, IHurtAction
    {
        [SerializeField]
        private int m_Layer = 0;

        void IHurtAction.ShowAction(ILiving living, ref VarChange Ch)
        {
            var entity = living as IEntity;
            if (entity != null && Ch.change < 0) {
                Animator anim = null;
                var view = entity.view as IUnitView;
                if (view != null) anim = view.anim;
                if (anim == null) anim = GetComponent(typeof(Animator)) as Animator;

                if (anim) anim.Play(AnimState.HURT, m_Layer);
            }
        }
    }
}
