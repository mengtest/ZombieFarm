using UnityEngine;
using System.Collections;

public class FxUVdh : MonoBehaviour {

    public int scrollSpeed = 5;
    public int countX = 4;
    public int countY = 4;
 
    private float offsetX = 0.0f;
    private float offsetY = 0.0f;
    private Vector2 singleTexSize;

    float time = 0;

	// Use this for initialization
	void Start () {
        singleTexSize = new Vector2(1.0f / countX, 1.0f / countY);
        GetComponent<Renderer>().material.mainTextureScale = singleTexSize;
        time = 0;
	}
	
	void Update () {
        if (Time.deltaTime > 0) {
            var frame = Mathf.Floor(time * scrollSpeed);
            offsetX = frame / countX;
            offsetY = -(frame - frame % countX) / countY / countX;
            GetComponent<Renderer>().material.SetTextureOffset("_MainTex", new Vector2(offsetX, offsetY));
            time += Time.deltaTime;
        }
	}
}
