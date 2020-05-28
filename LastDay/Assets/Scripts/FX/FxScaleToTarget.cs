using UnityEngine;
using System.Collections;

public class FxScaleToTarget : MonoBehavior {

    public Transform source;
    public Transform target;
    public Vector3 position;
    public Vector3 scale;
    Vector3 rawScale;

    void Awake()
    {
        if (source == null) source = transform;
        rawScale = source.localScale;
    }
	// Use this for initialization
	void Start () {
        
	}
	
	// Update is called once per frame
	void Update () {
        float distance = 0f;
        if (target != null) {
            distance = Vector3.Distance(source.position, target.position);
        } else if (position != Vector3.zero) {
            distance = Vector3.Distance(source.position, position);
        }
        if (distance != 0f) {
            Vector3 scaleTo = scale * distance;
            float x = scaleTo.x == 0 ? rawScale.x : scaleTo.x;
            float y = scaleTo.y == 0 ? rawScale.x : scaleTo.y;
            float z = scaleTo.z == 0 ? rawScale.x : scaleTo.z;
            source.transform.localScale = new Vector3(x, y, z); 
        }
	}
}
