//
//  CParams.cs
//  survive
//
//  Created by xingweizhen on 10/14/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public static partial class ShaderIDs
{
    internal static readonly int AlphaTex = Shader.PropertyToID("_AlphaTex");
    internal static readonly int SkinTex = Shader.PropertyToID("_SkinTex");
    internal static readonly int HairUV = Shader.PropertyToID("_HairUV");
    internal static readonly int HairColor = Shader.PropertyToID("_HairColor");
    internal static readonly int AlphaGridTex = Shader.PropertyToID("_AlphaGridTex");
}

public static class MatKWs
{
    public const string NO_ALPHA_CLIP = "NO_ALPHA_CLIP";
    public const string BLEND_SKIN_TEX = "BLEND_SKIN_TEX";
    public const string ADD_HAIR_COLOR = "ADD_HAIR_COLOR";
    public const string TOON_TRANSPARENT = "TOON_TRANSPARENT";
}

namespace World.View
{
    public static class NavMask
    {
        public const int DEFAULT = 1;
        public const int ROCK = 8;
        public const int GRASS = 16;
        public const int METAL = 32;
        public const int WOOD = 64;
        public const int WATER = 128;
        public static int INTERACT = 1 << NavMesh.GetAreaFromName("INTERACT");
    }

    public static class AnimTags
    {
        public static int IDLE = Animator.StringToHash("idle");

    }
    public static class AnimParams
    {
        public static readonly int SPEED = Animator.StringToHash("speed");
        public static readonly int SMOOTH_SPEED = Animator.StringToHash("smoothSpeed");
        public static readonly int SNEAK = Animator.StringToHash("sneak");
        public static readonly int BREAK = Animator.StringToHash("break");
        public static readonly int POST = Animator.StringToHash("post");
        public static readonly int RELEASE = Animator.StringToHash("release");
        public static readonly int STOP = Animator.StringToHash("stop");
        public static readonly int RESET = Animator.StringToHash("reset");
    }


    public enum IdleState
    {
        normal, sneak, stealth, attackidle,
    }

    public static class AnimState
    {
        public const int BASE_LAYER = 0;
        public const int UPPER_LAYER = 1;
        public const int HURT_LAYER = 2;
        public const int CONFINE_LAYER = 3;

        private static readonly string[] StateLayerName = {
            "Base Layer", "Upper Layer", "Hurt Layer",
        };

        private static readonly int[] StateLayers = {
            0, // IdleState.normal
            0, // IdleState.sneak
            0, // IdleState.stealth
            0, // IdleState.attackidle
        };

        public static readonly int INIT = Animator.StringToHash("init");
        public static readonly int BASE_EMPTY = Animator.StringToHash("Base Layer.empty");
        public static readonly int HURT = Animator.StringToHash("hurt");
        public static readonly int DEAD = Animator.StringToHash("dead");

        public static readonly int[] DEADS = {
            DEAD,
            Animator.StringToHash("dead1"),
            Animator.StringToHash("dead2"),
        };

        private static Dictionary<int, Dictionary<int, int>> m_Hashes = new Dictionary<int, Dictionary<int, int>>();

        private static readonly Dictionary<int, string> m_WeaponTypes = new Dictionary<int, string>() {
            {0, "Fist"},
            {2, "Knife"},
            {3, "Spear"},
            {100, "Bow"},
            {101, "Pistol"},
            {102, "Assault"},
            {104, "RPG"},
            {103, "Shotgun"},
            {105, "Flamethrower"},
			{109, "Revolver"},
			{110, "Rifle"},
        };

        public static bool GetStateHash(this Animator self, IdleState state, int wType, out int hash)
        {
            Dictionary<int, int> dict;
            int iState = (int)state;
            if (!m_Hashes.TryGetValue(iState, out dict)) {
                dict = new Dictionary<int, int>();
                m_Hashes.Add(iState, dict);
            }

            var layer = StateLayers[(int)state];
            if (!dict.TryGetValue(wType, out hash)) {
                string typeName;
                if (m_WeaponTypes.TryGetValue(wType, out typeName)) {
                    hash = Animator.StringToHash(
                        string.Format("{0}.{1}.{2}", StateLayerName[layer], typeName, state));
                    dict.Add(wType, hash);
                } else {
                    hash = 0;
                    LogMgr.W("<normal>未定义武器类型：{0}", wType);
                    return false;
                }
            }

            return self.HasState(layer, hash);
        }
    }
}
