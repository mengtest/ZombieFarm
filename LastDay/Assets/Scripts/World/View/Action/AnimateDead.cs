//
//  AnimateDead.cs
//  survive
//
//  Created by xingweizhen on 11/3/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    public class AnimateDead : MonoBehaviour, IDeadAction
    {
        [SerializeField]
        private int m_Layer = 0;

        public void InitAction(IEntity entity)
        {
        }

        public void ShowAction(IEntity entity, ref DisplayValue Val)
        {
            Animator anim = null;
            var view = entity.view as EntityView;
            if (view) anim = view.anim;
            if (anim == null) anim = GetComponent(typeof(Animator)) as Animator;

            if (anim) {
                anim.Play(AnimState.DEAD, m_Layer);

                if (view) {
                    foreach (var clip in anim.runtimeAnimatorController.animationClips) {
                        if (clip.name == "dead") {
                            view.recycleDelay += clip.length;
                            break;
                        }
                    }
                }
            }
        }
    }
}
