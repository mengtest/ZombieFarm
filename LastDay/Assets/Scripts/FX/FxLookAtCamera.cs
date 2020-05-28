using UnityEngine;
using System.Collections;

public class FxLookAtCamera : MonoBehaviour
{

    Transform transCam;
    Transform mTrans;

    public Transform cachedTransform {
        get {
            if (mTrans == null) mTrans = transform;
            return mTrans;
        }
    }

    public enum LookMode
    {
        Billboard,
        Stretched,
        Horizontal,
        Vertical,
    }

    public LookMode mode = LookMode.Billboard;

    // Use this for initialization
    void Start() { }

    // Update is called once per frame
    void Update()
    {
        if (transCam) {
            switch (mode) {
                case LookMode.Billboard: {
                    // 完全面向摄像机
                    cachedTransform.rotation = transCam.rotation;
                }
                    break;
                case LookMode.Stretched: {
                    // 垂直面向摄像机
                    Vector3 camDrt = transCam.forward;
                    Vector3 toDrt = new Vector3(camDrt.x, 0, camDrt.z).normalized;
                    cachedTransform.forward = toDrt;
                }
                    break;
                case LookMode.Horizontal: {
                    // 保持水平
                    if (cachedTransform.forward != Vector3.up) {
                        cachedTransform.forward = Vector3.up;
                    }
                }
                    break;
                case LookMode.Vertical: {
                    // 保持垂直
                    if (cachedTransform.right != Vector3.up) {
                        cachedTransform.LookAt(mTrans);
                        cachedTransform.right = Vector3.up;
                    }
                }
                    break;
            }
        } else {
            if (Camera.main != null) {
                transCam = Camera.main.transform;
            }
        }
    }
}
