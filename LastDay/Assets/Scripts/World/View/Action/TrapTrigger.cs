using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    public abstract class TrapTrigger : MonoBehaviour
    {
        protected abstract void OnTrapEnter(Collider other);
        protected abstract void OnTrapExit(Collider other);

        private void OnTriggerEnter(Collider other)
        {
            if (other.gameObject.name == "TRAP") {
                if (GetComponentInParent(typeof(IObjView))) {
                    OnTrapEnter(other);
                }
            }
        }

        private void OnTriggerExit(Collider other)
        {
            if (other.gameObject.name == "TRAP") {
                if (GetComponentInParent(typeof(IObjView))) {
                    OnTrapExit(other);
                }
            }
        }
    }
}

