//
//  GeneratePrefab.cs
//  survive
//
//  Created by xingweizhen on 10/25/2017.
//
//

using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public static class GenerateRolePrefab
{
    static string s_DefaultJointSettingsFolderPath = "Assets/Editor/DefaultJointSettings/";

    private static Animator FindAnimatorForDummy(GameObject go)
    {
        Object.DestroyImmediate(go.GetComponent(typeof(Animator)));
        GameObject goAni = null;
        foreach (Transform t in go.transform)
        {
            if (t.name.Substring(0, 5) == "Dummy")
            {
                goAni = t.gameObject;
                break;
            }
        }

        return goAni ? goAni.AddComponent(typeof(Animator)) as Animator : null;
    }

    private static Animator FindAnimatorForBip(GameObject go)
    {
        return go.GetComponent(typeof(Animator)) as Animator;
    }

    private static void SerializedRoleAni(World.View.RoleAnim roleAnim, Animator anim)
    {
        var serializedObject = new SerializedObject(roleAnim);

        var m_Anim = serializedObject.FindProperty("m_Anim");
        m_Anim.objectReferenceValue = anim;

        var m_Head = serializedObject.FindProperty("m_Head");
        m_Head.objectReferenceValue = anim.transform.FindByName("Bip001 Head");

        var m_Body = serializedObject.FindProperty("m_Body");
        m_Body.objectReferenceValue = anim.transform.FindByName("Bip001 Spine1");

        var m_Foot = serializedObject.FindProperty("m_Foot");
        m_Foot.objectReferenceValue = anim.transform;

        var m_Feet = serializedObject.FindProperty("m_Feet");
        m_Feet.InsertArrayElementAtIndex(0);
        m_Feet.InsertArrayElementAtIndex(1);
        m_Feet.GetArrayElementAtIndex(0).objectReferenceValue = anim.transform.FindByName("Bip001 L Foot");
        m_Feet.GetArrayElementAtIndex(1).objectReferenceValue = anim.transform.FindByName("Bip001 R Foot");

        serializedObject.ApplyModifiedProperties();
    }

    private static MeshFilter ProcessingMeshPart(Transform part, List<MeshFilter> mfList = null)
    {
        if (part == null)
            return null;
        SkinnedMeshRenderer childPartElem = part.GetComponent<SkinnedMeshRenderer>();
        if (childPartElem == null)
            return null;

        //处理子物件
        Mesh mesh = childPartElem.sharedMesh;
        Material[] mats = childPartElem.sharedMaterials;
        MeshFilter mf = childPartElem.gameObject.AddComponent<MeshFilter>();
        mf.sharedMesh = mesh;
        MeshRenderer mr = childPartElem.gameObject.AddComponent<MeshRenderer>();
        mr.sharedMaterials = mats;
        childPartElem.gameObject.AddComponent<Rigidbody>();
        childPartElem.gameObject.AddComponent<CapsuleCollider>();
        GameObject.DestroyImmediate(childPartElem);

        if (mfList != null)
        {
            mfList.Add(mf);
        }

        return mf;
    }

    private static void SerializedBodyBroken(World.View.BodyBroken bodyBroken, Animator anim, string path)
    {
        var serializedObject = new SerializedObject(bodyBroken);

        var m_Head = serializedObject.FindProperty("m_Head");
        m_Head.objectReferenceValue = anim.transform.FindByName("Bip001 Head");

        var m_UniqueName = serializedObject.FindProperty("m_UniqueName");
        m_UniqueName.stringValue = anim.gameObject.name;

        var m_Controller = serializedObject.FindProperty("m_Controller");
        m_Controller.objectReferenceValue = anim.runtimeAnimatorController;

        string animDir = Path.GetDirectoryName(path);
        string objName = Path.GetFileNameWithoutExtension(path);
        string materialPath = animDir + "/Materials/" + objName + ".mat";
        Material meterial = AssetDatabase.LoadAssetAtPath<Material>(materialPath);
        var m_Mats = serializedObject.FindProperty("m_Mats");
        m_Mats.InsertArrayElementAtIndex(0);
        m_Mats.GetArrayElementAtIndex(0).objectReferenceValue = meterial;

        serializedObject.ApplyModifiedProperties();

        var target = serializedObject.targetObject as World.View.BodyBroken;

        //处理断肢节点
        target.AddBrokenJoints(anim.transform.FindByName("Bip001 Head").GetComponent<CharacterJoint>());
        target.AddBrokenJoints(anim.transform.FindByName("Bip001 L Forearm").GetComponent<CharacterJoint>());
        target.AddBrokenJoints(anim.transform.FindByName("Bip001 R Forearm").GetComponent<CharacterJoint>());
        target.AddBrokenJoints(anim.transform.FindByName("Bip001 L Calf").GetComponent<CharacterJoint>());
        target.AddBrokenJoints(anim.transform.FindByName("Bip001 R Calf").GetComponent<CharacterJoint>());

        //保存所有SkinnedMesh骨骼信息
        SkinnedMeshRenderer[] childParts = target.GetComponentsInChildren<SkinnedMeshRenderer>();
        for (int i = 0; i < childParts.Length; i++)
        {
            SkinnedMeshRenderer childPartElem = childParts[i];
            if (childPartElem.gameObject == anim.gameObject)
                continue;
            target.AddPart(childParts[i]);
        }

        List<MeshFilter> mfList = new List<MeshFilter>();
        //处理独立部位
        MeshFilter head = ProcessingMeshPart(anim.transform.FindByName("Head"), mfList);
        MeshFilter lArm = ProcessingMeshPart(anim.transform.FindByName("L_Arm"), mfList);
        MeshFilter rArm = ProcessingMeshPart(anim.transform.FindByName("R_Arm"), mfList);
        MeshFilter lLeg = ProcessingMeshPart(anim.transform.FindByName("L_Leg"), mfList);
        MeshFilter rLeg = ProcessingMeshPart(anim.transform.FindByName("R_Leg"), mfList);
        ProcessingMeshPart(anim.transform.FindByName("Chest"), mfList);
        ProcessingMeshPart(anim.transform.FindByName("Pelvis"), mfList);

        Transform tnsHead = head ? head.transform : null;
        Transform tnslArm = lArm ? lArm.transform : null;
        Transform tnsrArm = rArm ? rArm.transform : null;
        Transform tnslLeg = lLeg ? lLeg.transform : null;
        Transform tnsrLeg = rLeg ? rLeg.transform : null;

        AddSpurtingEffectEditorWindow.ProcessingSpurtingEffectAnchor(
            tnsHead, tnslArm, tnsrArm, tnslLeg, tnsrLeg);
        Transform TnsOther;

        int otherIndex = 1;
        while (true)
        {
            TnsOther = anim.transform.FindByName("Other" + otherIndex);
            if (TnsOther == null)
                break;
            ProcessingMeshPart(TnsOther, mfList);
            otherIndex++;
        }
        bodyBroken.PushSkins(mfList.ToArray());

        //处理附加部件
        mfList.Clear();
        Transform TnsAttach;
        int attachIndex = 1;
        while (true)
        {
            TnsAttach = anim.transform.FindByName("Attach" + attachIndex);
            if (TnsAttach == null)
                break;
            ProcessingMeshPart(TnsAttach, mfList);
            attachIndex++;
        }
        bodyBroken.PushAffixes(mfList.ToArray());
    }

    //Old Method.
    /*
    private static void SetJointInfo(CharacterJoint joint, DefaultJointSetting settings)
    {
        joint.anchor = settings.anchor;
        joint.axis = settings.axis;
        joint.autoConfigureConnectedAnchor = settings.autoConfigureConnectedAnchor;
        joint.swingAxis = settings.swingAxis;
        SoftJointLimitSpring twistLimitSpring = joint.twistLimitSpring;
        twistLimitSpring.spring = settings.swingLimitSpring.spring;
        twistLimitSpring.damper = settings.swingLimitSpring.damper;
        joint.twistLimitSpring = twistLimitSpring;
        SoftJointLimit lowTwistLimit = joint.lowTwistLimit;
        lowTwistLimit.limit = settings.lowTwistLimit.limit;
        lowTwistLimit.bounciness = settings.lowTwistLimit.bounciness;
        lowTwistLimit.contactDistance = settings.lowTwistLimit.contactDistance;
        joint.lowTwistLimit = lowTwistLimit;
        SoftJointLimit highTwistLimit = joint.highTwistLimit;
        highTwistLimit.limit = settings.highTwistLimit.limit;
        highTwistLimit.bounciness = settings.highTwistLimit.bounciness;
        highTwistLimit.contactDistance = settings.highTwistLimit.contactDistance;
        joint.highTwistLimit = highTwistLimit;
        SoftJointLimitSpring swingLimitSpring = joint.swingLimitSpring;
        swingLimitSpring.spring = settings.swingLimitSpring.spring;
        swingLimitSpring.damper = settings.swingLimitSpring.damper;
        joint.swingLimitSpring = swingLimitSpring;
        SoftJointLimit swing1Limit = joint.swing1Limit;
        swing1Limit.limit = settings.swing1Limit.limit;
        swing1Limit.bounciness = settings.swing1Limit.bounciness;
        swing1Limit.contactDistance = settings.swing1Limit.contactDistance;
        joint.swing1Limit = swing1Limit;
        SoftJointLimit swing2Limit = joint.swing2Limit;
        swing2Limit.limit = settings.swing2Limit.limit;
        swing2Limit.bounciness = settings.swing2Limit.bounciness;
        swing2Limit.contactDistance = settings.swing2Limit.contactDistance;
        joint.swing2Limit = swing2Limit;
        joint.enableProjection = settings.enableProjection;
        joint.projectionDistance = settings.projectionDistance;
        joint.projectionAngle = settings.projectionAngle;
        joint.breakForce = settings.breakForce;
        joint.breakTorque = settings.breakTorque;
        joint.enableCollision = settings.enableCollision;
        joint.enablePreprocessing = settings.enablePreprocessing;
        joint.massScale = settings.massScale;
        joint.connectedMassScale = settings.connectedMassScale;
    }
    */

    private static void ProcessingRagdoll(Transform bone)
    {
        Transform pelvis = bone.FindByName("Bip001 Pelvis");

        Transform l_thigh = bone.FindByName("Bip001 L Thigh");
        Transform l_calf = bone.FindByName("Bip001 L Calf");

        Transform r_thigh = bone.FindByName("Bip001 R Thigh");
        Transform r_calf = bone.FindByName("Bip001 R Calf");

        Transform spine1 = bone.FindByName("Bip001 Spine1");
        Transform head = bone.FindByName("Bip001 Head");

        Transform l_upperArm = bone.FindByName("Bip001 L UpperArm");
        Transform l_forearm = bone.FindByName("Bip001 L Forearm");

        Transform r_upperArm = bone.FindByName("Bip001 R UpperArm");
        Transform r_forearm = bone.FindByName("Bip001 R Forearm");

        RagdollBuilders.RagdollBuilderInfo ragdollInfo = new RagdollBuilders.RagdollBuilderInfo();
        ragdollInfo.pelvis = pelvis;
        ragdollInfo.leftHips = l_thigh;
        ragdollInfo.leftKnee = l_calf;
        ragdollInfo.rightHips = r_thigh;
        ragdollInfo.rightKnee = r_calf;
        ragdollInfo.leftArm = l_upperArm;
        ragdollInfo.leftElbow = l_forearm;
        ragdollInfo.rightArm = r_upperArm;
        ragdollInfo.rightElbow = r_forearm;
        ragdollInfo.middleSpine = spine1;
        ragdollInfo.head = head;
        RagdollBuilders.GenerateRagdall(ragdollInfo);

        //Old Method.
        /*
         pelvis.gameObject.AddComponent<BoxCollider>();
        Rigidbody rbPelvis = pelvis.gameObject.AddComponent<Rigidbody>();
        rbPelvis.mass = 3.125f;

        l_thigh.gameObject.AddComponent<CapsuleCollider>();
        Rigidbody rb_lThigh = l_thigh.gameObject.AddComponent<Rigidbody>();
        CharacterJoint lThignJoint = l_thigh.gameObject.AddComponent<CharacterJoint>();
        lThignJoint.connectedBody = rbPelvis;
        DefaultJointSetting lThignJointSetting = 
            AssetDatabase.LoadAssetAtPath<DefaultJointSetting>(s_DefaultJointSettingsFolderPath + "LThignJointSetting.asset");
        rb_lThigh.mass = lThignJointSetting.mass;
        SetJointInfo(lThignJoint, lThignJointSetting);

        l_calf.gameObject.AddComponent<CapsuleCollider>();
        Rigidbody rb_lCalf = l_calf.gameObject.AddComponent<Rigidbody>();
        CharacterJoint lCalfJoint = l_calf.gameObject.AddComponent<CharacterJoint>();
        lCalfJoint.connectedBody = rb_lThigh;
        DefaultJointSetting lCalfJointSetting =
            AssetDatabase.LoadAssetAtPath<DefaultJointSetting>(s_DefaultJointSettingsFolderPath + "LCalfJointSetting.asset");
        rb_lCalf.mass = lCalfJointSetting.mass;
        SetJointInfo(lCalfJoint, lCalfJointSetting);

        r_thigh.gameObject.AddComponent<CapsuleCollider>();
        Rigidbody rb_rThigh = r_thigh.gameObject.AddComponent<Rigidbody>();
        CharacterJoint rThighJoint = r_thigh.gameObject.AddComponent<CharacterJoint>();
        rThighJoint.connectedBody = rbPelvis;
        DefaultJointSetting rThighJointSetting =
            AssetDatabase.LoadAssetAtPath<DefaultJointSetting>(s_DefaultJointSettingsFolderPath + "RThignJointSetting.asset");
        rb_rThigh.mass = rThighJointSetting.mass;
        SetJointInfo(rThighJoint, rThighJointSetting);

        r_calf.gameObject.AddComponent<CapsuleCollider>();
        Rigidbody rb_rCalf = r_calf.gameObject.AddComponent<Rigidbody>();
        CharacterJoint rCalfJoint = r_calf.gameObject.AddComponent<CharacterJoint>();
        rCalfJoint.connectedBody = rb_rThigh;
        DefaultJointSetting rCalfJointSetting =
           AssetDatabase.LoadAssetAtPath<DefaultJointSetting>(s_DefaultJointSettingsFolderPath + "RCalfJointSetting.asset");
        rb_rCalf.mass = rCalfJointSetting.mass;
        SetJointInfo(rCalfJoint, rCalfJointSetting);

        spine1.gameObject.AddComponent<BoxCollider>();
        Rigidbody rb_spine1 = spine1.gameObject.AddComponent<Rigidbody>();
        CharacterJoint spineJoint = spine1.gameObject.AddComponent<CharacterJoint>();
        spineJoint.connectedBody = rbPelvis;
        DefaultJointSetting spineJointSetting =
           AssetDatabase.LoadAssetAtPath<DefaultJointSetting>(s_DefaultJointSettingsFolderPath + "SpineJointSetting.asset");
        rb_spine1.mass = spineJointSetting.mass;
        SetJointInfo(spineJoint, spineJointSetting);

        head.gameObject.AddComponent<CapsuleCollider>();
        Rigidbody rb_head = head.gameObject.AddComponent<Rigidbody>();
        CharacterJoint headJoint = head.gameObject.AddComponent<CharacterJoint>();
        headJoint.connectedBody = rb_spine1;
        DefaultJointSetting headJointSetting =
           AssetDatabase.LoadAssetAtPath<DefaultJointSetting>(s_DefaultJointSettingsFolderPath + "HeadJointSetting.asset");
        rb_head.mass = headJointSetting.mass;
        SetJointInfo(headJoint, headJointSetting);

        l_upperArm.gameObject.AddComponent<CapsuleCollider>();
        Rigidbody rb_lUpperArm = l_upperArm.gameObject.AddComponent<Rigidbody>();
        CharacterJoint lUpperArmJoint = l_upperArm.gameObject.AddComponent<CharacterJoint>();
        lUpperArmJoint.connectedBody = rb_spine1;
        DefaultJointSetting lUpperArmJointSetting =
           AssetDatabase.LoadAssetAtPath<DefaultJointSetting>(s_DefaultJointSettingsFolderPath + "LUpperArmJointSetting.asset");
        rb_lUpperArm.mass = lUpperArmJointSetting.mass;
        SetJointInfo(lUpperArmJoint, lUpperArmJointSetting);

        l_forearm.gameObject.AddComponent<CapsuleCollider>();
        Rigidbody rb_lForeArm = l_forearm.gameObject.AddComponent<Rigidbody>();
        CharacterJoint lForearmJoint = l_forearm.gameObject.AddComponent<CharacterJoint>();
        lForearmJoint.connectedBody = rb_lUpperArm;
        DefaultJointSetting lForearmJointSetting =
           AssetDatabase.LoadAssetAtPath<DefaultJointSetting>(s_DefaultJointSettingsFolderPath + "LForearmJointSetting.asset");
        rb_lForeArm.mass = lForearmJointSetting.mass;
        SetJointInfo(lForearmJoint, lForearmJointSetting);

        r_upperArm.gameObject.AddComponent<CapsuleCollider>();
        Rigidbody rb_rUpperArm = r_upperArm.gameObject.AddComponent<Rigidbody>();
        CharacterJoint rUpperArmJoint = r_upperArm.gameObject.AddComponent<CharacterJoint>();
        rUpperArmJoint.connectedBody = rb_spine1;
        DefaultJointSetting rUpperArmJointSetting =
           AssetDatabase.LoadAssetAtPath<DefaultJointSetting>(s_DefaultJointSettingsFolderPath + "RUpperArmJointSetting.asset");
        rb_rUpperArm.mass = rUpperArmJointSetting.mass;
        SetJointInfo(rUpperArmJoint, rUpperArmJointSetting);

        r_forearm.gameObject.AddComponent<CapsuleCollider>();
        Rigidbody rb_rForeAram = r_forearm.gameObject.AddComponent<Rigidbody>();
        CharacterJoint rForearmJoint = r_forearm.gameObject.AddComponent<CharacterJoint>();
        rForearmJoint.connectedBody = rb_rUpperArm;
        DefaultJointSetting rForarmJointSetting =
           AssetDatabase.LoadAssetAtPath<DefaultJointSetting>(s_DefaultJointSettingsFolderPath + "RUpperArmJointSetting.asset");
        rb_rForeAram.mass = rForarmJointSetting.mass;
        SetJointInfo(rForearmJoint, rForarmJointSetting);
        */
    }

    private static void GenHumamModel(string path, Animator anim)
    {
        ProcessingRagdoll(anim.transform);

        var roleAnim = anim.gameObject.AddComponent<World.View.RoleAnim>();
        SerializedRoleAni(roleAnim, anim);

        var bodyBroken = anim.gameObject.AddComponent<World.View.BodyBroken>();
        SerializedBodyBroken(bodyBroken, anim, path);

        var skin = anim.gameObject.NeedComponent<SkinnedMeshRenderer>();
        skin.sharedMaterials = bodyBroken.mats;

        var animateHurt = anim.gameObject.AddComponent<World.View.AnimateHurt>();
        var slAnimateHurt = new SerializedObject(animateHurt);
        var aniHurtLayer = slAnimateHurt.FindProperty("m_Layer");
        aniHurtLayer.intValue = 2;
        slAnimateHurt.ApplyModifiedProperties();
    }

    private static void GenRoleAnimatorController(string path, Animator anim)
    {
        var overrideController = GeneratePrefabUtil.GenOverrideController(path, anim, GeneratePrefabUtil.EPrefabType.Role);

        GeneratePrefabUtil.SetOverrideClip(overrideController, path, "attack1");
        GeneratePrefabUtil.SetOverrideClip(overrideController, path, "attack2");
        GeneratePrefabUtil.SetOverrideClip(overrideController, path, "born");
        GeneratePrefabUtil.SetOverrideClip(overrideController, path, "bornidle1");
        GeneratePrefabUtil.SetOverrideClip(overrideController, path, "dead");
        GeneratePrefabUtil.SetOverrideClip(overrideController, path, "hurt");
        GeneratePrefabUtil.SetOverrideClip(overrideController, path, "idle");
        GeneratePrefabUtil.SetOverrideClip(overrideController, path, "run");
        GeneratePrefabUtil.SetOverrideClip(overrideController, path, "skill1");
    }

    [MenuItem("Assets/生成/人形")]
    private static void GenPrefabForBipModel()
    {
        var selected = Selection.activeGameObject;
        var path = AssetDatabase.GetAssetPath(selected);
        if (!path.ToLower().EndsWith(".fbx") || path.Contains("@")) return;

        GeneratePrefabUtil.ExportMaterialInFbx(path);
        var go = GeneratePrefabUtil.GenPrefabFromSelection(selected);
        var anim = FindAnimatorForBip(go);
        if (anim)
        {
            GenRoleAnimatorController(path, anim);
            GenHumamModel(path, anim);
        }
    }

    [MenuItem("Assets/生成/非人形")]
    private static void GenPrefabForDummyModel()
    {
        var selected = Selection.activeGameObject;
        var path = AssetDatabase.GetAssetPath(selected);
        if (!path.ToLower().EndsWith(".fbx") || path.Contains("@")) return;

        GeneratePrefabUtil.ExportMaterialInFbx(path);
        var go = GeneratePrefabUtil.GenPrefabFromSelection(selected);
        var anim = FindAnimatorForDummy(go);
        if (anim)
        {
            GenRoleAnimatorController(path, anim);
            //非人形怪物手动处理模型
        }
    }
}
