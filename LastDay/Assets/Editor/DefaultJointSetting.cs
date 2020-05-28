using System;
using UnityEngine;
using UnityEditor;

[CreateAssetMenu(menuName = "JointSetting")]
public class DefaultJointSetting : ScriptableObject
{
    public float mass = 1f;
    public Vector3 anchor = Vector3.zero;
    public Vector3 axis = Vector3.zero;
    public bool autoConfigureConnectedAnchor = true;
    public Vector3 swingAxis = Vector3.zero;
    public SoftJointLimitSpring twistLimitSpring;
    public SoftJointLimit lowTwistLimit;
    public SoftJointLimit highTwistLimit;
    public SoftJointLimitSpring swingLimitSpring;
    public SoftJointLimit swing1Limit;
    public SoftJointLimit swing2Limit;
    public bool enableProjection = false;
    public float projectionDistance = 0.1f;
    public float projectionAngle = 180f;
    public float breakForce = float.PositiveInfinity;
    public float breakTorque = float.PositiveInfinity;
    public bool enableCollision = false;
    public bool enablePreprocessing = false;
    public float massScale = 1;
    public float connectedMassScale = 1;

    [Serializable]
    public struct SoftJointLimitSpring
    {
        public float spring;
        public float damper;
    }

    [Serializable]
    public struct SoftJointLimit
    {
        public float limit;
        public float bounciness;
        public float contactDistance;
    }
}