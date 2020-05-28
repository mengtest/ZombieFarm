using UnityEngine;
using System.Collections;

namespace Battle.FX
{
    public class FxAutoDespawn : MonoBehaviour
    {
        public float time;

        // Use this for initialization
        void Start()
        {
            if (time > 0) {
                ObjectPoolManager.DestroyPooledScenely(gameObject, time);
            } else {
                ObjectPoolManager.DestroyPooledScenely(gameObject);
            }
        }
    }
}