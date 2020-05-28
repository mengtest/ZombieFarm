using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEditor;
using World.View;

public static class GenerateBuildingPrefab
{
    private static string Walkable = "Walkable";
    private static string NotWalkable = "Not Walkable";
    private static string Jump = "Jump";
    private static string Rock = "Rock";
    private static string Grass = "Grass";
    private static string Metal = "Metal";
    private static string Wood = "Wood";
    private static string Water = "Water";
    private static string Door = "Door";
    private static string INTERACT = "INTERACT";


    private static void SerializedNavMeshBuildTag(NavMeshBuildTag navTag, NavMeshBuildSourceShape shape, string area)
    {
        var serializedObject = new SerializedObject(navTag);

        var m_Shape = serializedObject.FindProperty("m_Shape");
        m_Shape.enumValueIndex = (int)shape;

        var m_Area = serializedObject.FindProperty("m_Area");
        m_Area.intValue = GameObjectUtility.GetNavMeshAreaFromName(area);

        serializedObject.ApplyModifiedProperties();
    }

    private static void ProcessingObjAni(ObjAnim objAni)
    {
        var serializedObject = new SerializedObject(objAni);

        var m_Obstacle = serializedObject.FindProperty("m_Obstacle");
        m_Obstacle.enumValueIndex = (int)ObjAnim.Obstacle.None;

        serializedObject.ApplyModifiedProperties();
    }

    private static void ProcessingRenderer(Renderer _renderer)
    {
        _renderer.lightProbeUsage = UnityEngine.Rendering.LightProbeUsage.Off;
        _renderer.reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.Off;
        _renderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.On;
        _renderer.receiveShadows = true;
        _renderer.motionVectorGenerationMode = MotionVectorGenerationMode.ForceNoMotion;
        return;
    }

    private static void GenBuildingModel(GameObject go)
    {
        GameObject.DestroyImmediate(go.GetComponent(typeof(Animator)));

        GameObject normalParent = new GameObject(go.name);
        go.transform.SetParent(normalParent.transform, false);
        GeneratePrefabUtil.ForceToZero(go.transform, false);
        ObjAnim objAni = normalParent.AddComponent<ObjAnim>();
        ProcessingObjAni(objAni);

        Renderer rd = go.GetComponentInChildren<Renderer>();
        ProcessingRenderer(rd);
        rd.gameObject.AddComponent<BoxCollider>();

        normalParent.SetLayerRecursively(LAYERS.iBuilding);
    }

    private static GameObject GenNavMeshTag(Transform _parent, PrimitiveType meshFilterType, NavMeshBuildSourceShape shape, string area)
    {
        GameObject navObj = GameObject.CreatePrimitive(meshFilterType);
        GameObject.DestroyImmediate(navObj.GetComponent<MeshRenderer>());
        GameObject.DestroyImmediate(navObj.GetComponent<Collider>());
        navObj.name = "NavMeshTag";
        NavMeshBuildTag navTag = navObj.AddComponent<NavMeshBuildTag>();
        SerializedNavMeshBuildTag(navTag, shape, area);
        navObj.transform.SetParent(_parent, false);
        GeneratePrefabUtil.ForceToZero(navObj.transform);

        navObj.layer = LAYERS.iInvisible;

        navTag.enabled = false;
        return navObj;
    }

    [MenuItem("Assets/生成/建筑/基础")]
    private static void GenPrefabForBuildingModel()
    {
        var selected = Selection.activeGameObject;
        var path = AssetDatabase.GetAssetPath(selected);
        if (!path.ToLower().EndsWith(".fbx") || path.Contains("@")) return;

        GeneratePrefabUtil.ExportMaterialInFbx(path);
        var go = GeneratePrefabUtil.GenPrefabFromSelection(selected);

        GenBuildingModel(go);
    }

    [MenuItem("Assets/生成/建筑/可交互建筑")]
    private static void GenPrefabForInteractModel()
    {
        var selected = Selection.activeGameObject;
        var path = AssetDatabase.GetAssetPath(selected);
        if (!path.ToLower().EndsWith(".fbx") || path.Contains("@")) return;

        GeneratePrefabUtil.ExportMaterialInFbx(path);
        var go = GeneratePrefabUtil.GenPrefabFromSelection(selected);

        GenBuildingModel(go);
        go.layer = LAYERS.iFurniture;
        GameObject navTag = GenNavMeshTag(go.transform.parent, PrimitiveType.Quad, NavMeshBuildSourceShape.Mesh, INTERACT);
        BoxCollider collider = go.GetComponentInChildren<BoxCollider>();
        Vector3 size = collider.size;
        navTag.transform.localRotation = Quaternion.Euler(new Vector3(90, 0, 0));
        navTag.transform.localScale = new Vector3(size.x,1 , size.z);
    }

    [MenuItem("Assets/生成/建筑/地板")]
    private static void GenPrefabForFloorModel()
    {
        var selected = Selection.activeGameObject;
        var path = AssetDatabase.GetAssetPath(selected);
        if (!path.ToLower().EndsWith(".fbx") || path.Contains("@")) return;

        GeneratePrefabUtil.ExportMaterialInFbx(path);
        var go = GeneratePrefabUtil.GenPrefabFromSelection(selected);

        GenBuildingModel(go);
        go.layer = LAYERS.iGround;
        GameObject navTag = GenNavMeshTag(go.transform.parent, PrimitiveType.Cube, NavMeshBuildSourceShape.Mesh, Wood);
        navTag.transform.localScale = new Vector3(2, 0.22f, 2);
    }
}