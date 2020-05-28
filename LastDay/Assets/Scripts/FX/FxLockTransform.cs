using UnityEngine;
using System.Collections;

public class FxLockTransform : MonoBehavior {
    
    public bool lockPosition;
    public bool lockRotation;
    public bool lockScale;

    Vector3 originPosition, originLocalScale;
    Quaternion originRotation;
    Vector3 originLocalPosition;
    Quaternion originLocalRotation;

    private bool m_Dirty;
    
    void OnDisable()
    {
        transform.localPosition = originLocalPosition;
        transform.localRotation = originLocalRotation;
    }

    void OnEnable()
    {
        m_Dirty = true;        
    }

    // Use this for initialization
    void Start()
    {
        originLocalPosition = transform.localPosition;
        originLocalRotation = transform.localRotation;
    }

    void Update()
    {
        if (m_Dirty) {
            m_Dirty = false;
            originPosition = transform.position;
            originRotation = transform.rotation;
            originLocalScale = transform.localScale;
            return;
        }

        if (lockPosition) {
            transform.position = originPosition;
        }
        if (lockRotation) {
            transform.rotation = originRotation;
        }
        if (lockScale) {
            transform.localScale = originLocalScale;
        }
    }

    public void SetLockRotation()
    {
        lockRotation = true;
        originRotation = transform.rotation;
    }

    public void SetLockPosition()
    {
        lockPosition = true;
        originPosition = transform.position;
    }

    public void SetLockScale()
    {
        lockScale = true;
        originLocalScale = transform.localScale;
    }
}
