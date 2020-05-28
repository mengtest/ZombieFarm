using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ZFrame;

public class CurvedWorldUIIndicator : MonoBehaviour, ILateTick
{
    [SerializeField] private RectTransform m_RectBorder;
    [SerializeField] private RectTransform m_RectCtrl;
    [SerializeField] private GameObject m_ObjCtrlRender;
    [SerializeField] private Transform m_TnsIcon;

    private Vector2 m_BorderOffset;
    private float[] m_fBorders = new float[4];

    private Camera m_TarCam, m_SelfCam;
    private Transform m_Target;

    private void ProcessingBorder()
    {
        m_BorderOffset = m_RectBorder.anchoredPosition;
        Vector2 size = new Vector2(m_RectBorder.rect.width, m_RectBorder.rect.height);
        size = size / 2;
        m_fBorders[0] = size.y + m_BorderOffset.y;
        m_fBorders[1] = size.x + m_BorderOffset.x;
        m_fBorders[2] = -size.y + m_BorderOffset.y;
        m_fBorders[3] = -size.x + m_BorderOffset.x;
    }

    public void SetTarget(Transform target)
    {
        ProcessingBorder();
        m_Target = target;

        enabled = target != null;
        if (enabled) {
            if (m_SelfCam == null) m_SelfCam = gameObject.FindCameraForLayer();
            m_TarCam = target.gameObject.FindCameraForLayer();
            TickManager.Add(this);
        }
    }

    private bool IsInBorder(Vector2 targetPos)
    {
        return (targetPos.y < m_fBorders[0] && targetPos.y > m_fBorders[2] &&
            targetPos.x < m_fBorders[1] && targetPos.x > m_fBorders[3]);
    }

    private Vector2 GenerateIndicatorPos(Vector2 targetPos)
    {
        if (targetPos.x == 0) {
            return targetPos.y > 0 ? new Vector2(m_fBorders[1], 0) : new Vector2(m_fBorders[3], 0);
        }

        float k = targetPos.y / targetPos.x;

        float xInBorder = (targetPos.x > 0 ? m_fBorders[1] : m_fBorders[3]);
        float yInBorder = k * xInBorder;
        if (yInBorder < m_fBorders[0] && yInBorder > m_fBorders[2]) {
            return new Vector2(xInBorder, yInBorder);
        }

        yInBorder = targetPos.y > 0 ? m_fBorders[0] : m_fBorders[2];
        xInBorder = yInBorder / k;
        return new Vector2(xInBorder, yInBorder);
    }

    private void OnEnable()
    {
        if (m_Target != null) {
            TickManager.Add(this);
        }
    }

    private void OnDisable()
    {
        TickManager.Remove(this);
    }

    protected virtual Vector2 GetTargetAnchoredPos()
    {
        var screenPos = m_TarCam.WorldToScreenPoint(m_Target.position);
        if (screenPos.z < 0) screenPos = -1 * screenPos;
        Vector2 anchoredPos;
        if (RectTransformUtility.ScreenPointToLocalPointInRectangle(
            (RectTransform)transform.parent, screenPos, m_SelfCam, out anchoredPos)) {
            return anchoredPos;
        }

        return Vector2.zero;
    }

    bool ITickBase.ignoreTimeScale { get { return true; } }

    void ILateTick.LateTick(float deltaTime)
    {
        if (m_SelfCam && m_TarCam) {
            Vector2 targetPos = GetTargetAnchoredPos();
            if (IsInBorder(targetPos)) {
                if (m_ObjCtrlRender.gameObject.activeSelf) {
                    m_ObjCtrlRender.gameObject.SetActive(false);
                }
            } else {
                if (!m_ObjCtrlRender.gameObject.activeSelf) {
                    m_ObjCtrlRender.gameObject.SetActive(true);
                }
                Vector2 pos = GenerateIndicatorPos(targetPos);
                m_RectCtrl.anchoredPosition = pos;

                float angle = Vector3.Angle(Vector2.down, pos.normalized);
                Vector3 cross = Vector3.Cross(Vector2.down, pos.normalized);
                if (cross.z < 0) {
                    angle = 360 - angle;
                }

                m_ObjCtrlRender.transform.localRotation = Quaternion.Euler(0, 0, angle);
                m_TnsIcon.transform.localRotation = Quaternion.Euler(0, 0, -angle);
            }
        }
    }
}
