using UnityEngine;
using System.Collections;

public class FxLookAtTarget : MonoBehavior
{

    public Transform source;
    public Transform target;
    public Vector3 position;
    public Vector3 worldUp = Vector3.up;

	// Use this for initialization
	void Start () {
        if (source == null) source = transform;
	}
	
	// Update is called once per frame
	void Update () {
        if (target != null) {
            source.LookAt(target, worldUp);
        } else if (position != Vector3.zero) {
            source.LookAt(position, worldUp);
        }
	}
}
