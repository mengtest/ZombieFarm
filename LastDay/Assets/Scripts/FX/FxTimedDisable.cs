using UnityEngine;
using System.Collections;

public class FxTimedDisable : MonoBehaviour {
	public float time;
	float instTime;

	public void Reset(){
		instTime = time;
	}

	// Use this for initialization
	void FixedUpdate () {
		if (instTime <= 0)
			return;

		instTime -= Time.fixedDeltaTime;
		if (instTime <= 0) {
			gameObject.SetActive(false);
		}
	}
}
