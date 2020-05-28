using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class AddSpurtingEffectEditorWindow : EditorWindow
{
    public readonly static Vector3 s_HeadSpurtingFxPos = new Vector3(0f, 0.04f, 1.573f);
    public readonly static Vector3 s_HeadSpurtingFxRot = new Vector3(-150f, 0f, 0f);

    public readonly static Vector3 s_LArmSpurtingFxPos = new Vector3(-0.23f, 0.099f, 1.272f);
    public readonly static Vector3 s_LArmSpurtingFxRot = new Vector3(2.199f, 25.928f, -0.7450001f);

    public readonly static Vector3 s_RArmSpurtingFxPos = new Vector3(0.183f, 0.112f, 1.343f);
    public readonly static Vector3 s_RArmSpurtingFxRot = new Vector3(5.009f, -19.62f, 8.658f);

    public readonly static Vector3 s_LLegSpurtingFxPos = new Vector3(-0.1f, 0f, 0.759f);
    public readonly static Vector3 s_LLegSpurtingFxRot = Vector3.zero;

    public readonly static Vector3 s_RLegSpurtingFxPos = new Vector3(0.1f, -0.064f, 0.77f);
    public readonly static Vector3 s_RLegSpurtingFxRot = Vector3.zero;

    private static Transform m_Head;
    private static Transform m_LArm;
    private static Transform m_RArm;
    private static Transform m_LLeg;
    private static Transform m_RLeg;

    [MenuItem("GameObject/SpurtingEffectAdder")]
    static void AddWindow()
    {
        m_Head = null;
        m_LArm = null;
        m_RArm = null;
        m_LLeg = null;
        m_RLeg = null;

        //创建窗口
        Rect wr = new Rect(0, 0, 500, 500);
        AddSpurtingEffectEditorWindow window = (AddSpurtingEffectEditorWindow)EditorWindow.GetWindowWithRect(typeof(AddSpurtingEffectEditorWindow), wr, true, "SpurtingWindow");
        window.Show();
    }

    private void OnGUI()
    {
        m_Head = (Transform)EditorGUILayout.ObjectField("头部", m_Head, typeof(Transform), true);
        m_LArm = (Transform)EditorGUILayout.ObjectField("左胳膊", m_LArm, typeof(Transform), true);
        m_RArm = (Transform)EditorGUILayout.ObjectField("右胳膊", m_RArm, typeof(Transform), true);
        m_LLeg = (Transform)EditorGUILayout.ObjectField("左腿", m_LLeg, typeof(Transform), true);
        m_RLeg = (Transform)EditorGUILayout.ObjectField("右腿", m_RLeg, typeof(Transform), true);

        if (GUILayout.Button("生成", GUILayout.Width(200)))
        {
            ProcessingSpurtingEffectAnchor(m_Head, m_LArm, m_RArm, m_LLeg, m_RLeg);
        }
    }

    public static void ProcessingSpurtingEffectAnchor(Transform head, Transform lArm, Transform rArm, Transform lLeg, Transform rLeg)
    {
        if (head)
        {
            CreateEmptyChild(head, s_HeadSpurtingFxPos, s_HeadSpurtingFxRot, "FX");
        }

        if (lArm)
        {
            CreateEmptyChild(lArm, s_LArmSpurtingFxPos, s_LArmSpurtingFxRot, "FX");
        }

        if (rArm)
        {
            CreateEmptyChild(rArm, s_RArmSpurtingFxPos, s_RArmSpurtingFxRot, "FX");
        }

        if (lLeg)
        {
            CreateEmptyChild(lLeg, s_LLegSpurtingFxPos, s_RArmSpurtingFxRot, "FX");
        }

        if (rLeg)
        {
            CreateEmptyChild(rLeg, s_RLegSpurtingFxPos, s_RLegSpurtingFxRot, "FX");
        }
    }

    private static void CreateEmptyChild(Transform parent, Vector3 childPos, Vector3 rot, string childName)
    {
        GameObject child = new GameObject(childName);
        child.transform.parent = parent;
        child.transform.localRotation = Quaternion.Euler(rot);
        child.transform.localPosition = childPos;
    }
}