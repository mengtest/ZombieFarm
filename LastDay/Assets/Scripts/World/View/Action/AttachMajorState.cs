using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    [SharedBetweenAnimators]
    public class AttachMajorState : StateMachineBehaviour
    {

        // OnStateEnter is called when a transition starts and the state machine starts to evaluate this state
        override public void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        {
            var view = animator.GetComponentInParent(typeof(HumanView)) as HumanView;
            if (view) {
                var human = view.obj as Human;
                if (human != null) {
                    view.SetAffixActive(HumanView.AFFIX_RHAND, true);
                    view.SetAffixActive(HumanView.AFFIX_LHAND, true);
                }
            }
        }

        // OnStateUpdate is called on each Update frame between OnStateEnter and OnStateExit callbacks
        //override public void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
        //
        //}

        // OnStateExit is called when a transition ends and the state machine finishes evaluating this state
        //override public void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
        //{
        //
        //}

        // OnStateMove is called right after Animator.OnAnimatorMove(). Code that processes and affects root motion should be implemented here
        //override public void OnStateMove(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
        //
        //}

        // OnStateIK is called right after Animator.OnAnimatorIK(). Code that sets up animation IK (inverse kinematics) should be implemented here.
        //override public void OnStateIK(Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
        //
        //}
    }
}
