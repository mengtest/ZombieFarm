using UnityEngine;
using System.Collections;

public class FxFollowNode : MonoBehaviour 
{
	public Transform tagetrota = null;
	public Transform taget = null;
	public Transform startposition;
	public float movespeed=1f;


	float xx,yy,zz;
	Quaternion quater;

	void start()
	{
		startposition = transform;
		//quater = Quaternion.Euler (taget.rotation);
	}

	void LateUpdate()
	{
		if(taget!=null)
		{
			xx=Mathf.Lerp(startposition.position.x,taget.position.x,movespeed*Time.deltaTime);
			yy=Mathf.Lerp(startposition.position.y,taget.position.y,movespeed*Time.deltaTime);
			zz=Mathf.Lerp(startposition.position.z,taget.position.z,movespeed*Time.deltaTime);
			//Debug.Log(""+xx+";"+yy+";"+zz);

			transform.transform.position=new Vector3(xx,yy,zz);				
			transform.rotation=Quaternion.Slerp(transform.transform.rotation, tagetrota.rotation, movespeed*Time.deltaTime);


		}
	}
}
 