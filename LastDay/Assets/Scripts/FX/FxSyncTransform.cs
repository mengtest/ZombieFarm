using UnityEngine;
using System.Collections;

public class FxSyncTransform : MonoBehaviour {

    Transform mTrans;
    public Transform cachedTransform { get { if (mTrans == null) mTrans = transform; return mTrans; } }

    public Transform target;
    public bool syncPosition;
    public bool syncRotation;
    public bool syncScale;

	// Use this for initialization
	void Start () {
        Sync();
	}
	
	void Update () {
        Sync();
	}

    [ContextMenu("Sync")]
    public void Sync()
    {
        if (target != null) {
            if (syncPosition) {
                cachedTransform.position = target.position;
            }
            if (syncRotation) {
                cachedTransform.rotation = target.rotation;
            }
            if (syncScale) {
                cachedTransform.localScale = target.localScale;
            }
        }
    }
}
