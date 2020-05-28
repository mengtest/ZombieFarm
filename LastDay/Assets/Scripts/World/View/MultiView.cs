using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
    public class MultiView : MonoBehaviour
    {
        public GameObject Get(int index = -1)
        {
            if (index < 0 || index >= transform.childCount) {
                index = Random.Range(0, transform.childCount);
            }

            return transform.GetChild(index).gameObject;
        }

        public GameObject Get(string objName)
        {
            foreach (Transform t in transform) {
                if (t.name == objName) return t.gameObject;
            }

            return null;
        }
    }
}
