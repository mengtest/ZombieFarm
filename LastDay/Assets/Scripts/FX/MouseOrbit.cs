using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Camera))]
public class MouseOrbit : MonoBehaviour
{

	public Transform target;
	public bool allowRotate = true;
	public bool allowZoom = true;
	public float distanceMin = 5f;
	public float distanceMax = 30f;
	public float fovMin = 25;
	public float fovMax = 60;

	private float distance = 20.0f;

	float xSpeed = 250.0f;
	float ySpeed = 120.0f;

	float yMinLimit = 0f;
	float yMaxLimit = 90f;

	private float x = 0.0f;
	private float y = 0.0f;

	Vector2 oldPosition1, oldPosition2;
	float distFrom, distTo;
	float duration, passDelta;

	[HideInInspector] public bool shouldUpdate = false;

	private Camera m_Cam;
	private Vector3 m_OriginPos;
	private Quaternion m_OriginRot;
	private float m_OriginFov;

	private void Awake()
	{
		m_Cam = (Camera)GetComponent(typeof(Camera));
	}

	// Use this for initialization
	private void Start()
	{
		// Make the rigid body not change rotation
		var rigid = GetComponent(typeof(Rigidbody)) as Rigidbody;
		if (rigid) {
			rigid.freezeRotation = true;
		}
	}

	private void OnEnable()
	{
		if (target != null) {
			m_OriginPos = transform.localPosition;
			m_OriginRot = transform.localRotation;
			m_OriginFov = m_Cam.fieldOfView;
			
			var euler = transform.eulerAngles;
			x = euler.y;
			y = euler.x;
			distance = (transform.position - target.position).magnitude;
		}
	}

	private void OnDisable()
	{
		transform.localPosition = m_OriginPos;
		transform.localRotation = m_OriginRot;
		m_Cam.fieldOfView = m_OriginFov;
	}

	private void Update()
	{
		// 自动移动
		if (duration > 0f) {
			shouldUpdate = true;
			distance = Mathf.Lerp(distFrom, distTo, passDelta / duration);
			passDelta += Time.deltaTime;
			if (passDelta >= duration) {
				duration = 0f;
			}

			return;
		}
#if UNITY_EDITOR || UNITY_STANDALONE
		if (allowRotate) {
			if (Input.GetMouseButton(1)) {
				//if (Input.mousePosition.y < 100) return;

				float mx = Input.GetAxis("Mouse X");
				float my = Input.GetAxis("Mouse Y");
				if (Mathf.Abs(mx) > 5) mx = 0;
				if (Mathf.Abs(my) > 3) mx = 0;
				x += mx * xSpeed * 0.02f;
				y -= my * ySpeed * 0.02f;

				shouldUpdate = true;
			}
		}

		if (allowZoom) {
			float axis = Input.GetAxis("Mouse ScrollWheel") * 10;
			if (axis != 0f) {
				if (Input.GetKey(KeyCode.LeftAlt)) {
					var fov = m_Cam.fieldOfView - axis;
					m_Cam.fieldOfView = Mathf.Clamp(fov, fovMin, fovMax);
				} else {
					shouldUpdate = true;
					distance -= axis;
					distance = Mathf.Clamp(distance, distanceMin, distanceMax);
				}
			}
		}
#elif UNITY_IOS || UNITY_ANDROID
        if (allowRotate) {
		    if (Input.touchCount == 1) {
			    Touch touch = Input.GetTouch(0);
			    if (touch.phase == TouchPhase.Moved) {
				    if (touch.position.y < 100) return;
				    float mx = Input.GetAxis("Mouse X");
				    float my = Input.GetAxis("Mouse Y");
				    if (Mathf.Abs(mx) > 5) mx = 0;
				    if (Mathf.Abs(my) > 3) mx = 0;
				    x += mx * xSpeed * 0.02f;
				    y -= my * ySpeed * 0.02f;

				    //shouldUpdate = true;
			    }
		    }
        }

        if (allowZoom) {
		    if(Input.touchCount > 1 ) {
			    if (Input.GetTouch(0).phase == TouchPhase.Moved || Input.GetTouch(1).phase == TouchPhase.Moved) {   
				    // 计算出当前两点触摸点的位置   
				    var tempPosition1 = Input.GetTouch(0).position;   
				    var tempPosition2 = Input.GetTouch(1).position;
				    if (isEnlarge(oldPosition1,oldPosition2,tempPosition1,tempPosition2)) {
					    if(distance > distanceMin) {   
						    distance -= 0.5f;       
					    }    
				    } else { 
					    if(distance < distanceMax) {   
						    distance += 0.5f;   
					    }   
				    }
				    oldPosition1 = tempPosition1;   
				    oldPosition2 = tempPosition2;

				    shouldUpdate = true;
			    }
		    }
        }
#endif

		UpdateCamera();
	}

	//函数返回真为放大，返回假为缩小   
	private bool isEnlarge(Vector2 oP1, Vector2 oP2, Vector2 nP1, Vector2 nP2)
	{
		//函数传入上一次触摸两点的位置与本次触摸两点的位置计算出用户的手势   
		var leng1 = Mathf.Sqrt((oP1.x - oP2.x) * (oP1.x - oP2.x) + (oP1.y - oP2.y) * (oP1.y - oP2.y));
		var leng2 = Mathf.Sqrt((nP1.x - nP2.x) * (nP1.x - nP2.x) + (nP1.y - nP2.y) * (nP1.y - nP2.y));
		return leng1 < leng2; // 放大手势 || 缩小手势
	}

	private void UpdateCamera()
	{
		if (target && shouldUpdate) {
			// 重置摄像机的位置 
			y = ClampAngle(y, yMinLimit, yMaxLimit);
			Quaternion rotation = Quaternion.Euler(y, x, 0);
			Vector3 position = rotation * new Vector3(0.0f, 0.0f, -distance) + target.position;
			transform.rotation = rotation;
			transform.position = position;

			shouldUpdate = false;
		}
	}

	public void Set(Transform trans)
	{
		target = trans;
		x = transform.rotation.eulerAngles.y;
		y = transform.rotation.eulerAngles.x;
	}

	public void Auto(float from, float to, float dura)
	{
		distFrom = from;
		distTo = to;
		duration = dura;
		passDelta = 0;

		distance = from;
		UpdateCamera();
	}

	static float ClampAngle(float angle, float min, float max)
	{
		if (angle < -360) {
			angle += 360;
		}

		if (angle > 360) {
			angle -= 360;
		}

		return Mathf.Clamp(angle, min, max);
	}
}
