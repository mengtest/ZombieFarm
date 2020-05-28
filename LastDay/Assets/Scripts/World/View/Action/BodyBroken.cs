using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FX;
using ZFrame;

namespace World.View
{
    using Control;

    [RequireComponent(typeof(SkinnedMeshRenderer))]
    public class BodyBroken : SpecialDeath, IInitRender, ISkinProperty
    {
        private const int BROKEN_NUM = 5;

        [System.Serializable]
        private struct BodyPart
        {
            public Mesh mesh;
            public string[] bones;
            public BodyPart(SkinnedMeshRenderer skin)
            {
                mesh = skin.sharedMesh;
                bones = new string[skin.bones.Length];
                for (int i = 0; i < bones.Length; ++i) {
                    bones[i] = skin.bones[i].name;
                }
            }
        }

        [SerializeField, NamedProperty("唯一名称")]
        private string m_UniqueName;
        public string uniqueName { get { return m_UniqueName; } }

        [SerializeField, NamedProperty("覆盖动作控制器")]
        private RuntimeAnimatorController m_Controller;
        public RuntimeAnimatorController controller { get { return m_Controller; } }

        [SerializeField]
        private Material[] m_Mats;
        public Material[] mats { get { return m_Mats; } }

        [SerializeField, HideInInspector]
        private List<GameObject> m_BrokenJoints;

        [SerializeField, HideInInspector]
        private MeshFilter[] m_Skins;

        [SerializeField, HideInInspector]
        private MeshFilter[] m_Affixes;

        [SerializeField, HideInInspector]
        private List<BodyPart> m_Parts = new List<BodyPart>();

        [SerializeField, HideInInspector]
        private int m_UpperMask;

        private readonly List<Transform> m_Bones = new List<Transform>();

        private readonly List<Renderer> m_Rdrs = new List<Renderer>();
        
        private SkinnedMeshRenderer m_CombinedSkin;

        private GameObject m_LowerPart;
        
        protected override void Awake()
        {
            base.Awake();
            m_CombinedSkin = (SkinnedMeshRenderer)GetComponent(typeof(SkinnedMeshRenderer));
        }

        protected override void Start()
        {
            base.Start();
            m_Bones.Clear();
            m_Rdrs.Clear();
            
            foreach (var filter in m_Skins) {
                if (filter) {
                    filter.transform.localPosition = Vector3.zero;
                    filter.transform.localEulerAngles = new Vector3(-90, 0, 0);
                    filter.gameObject.SetActive(false);
                }
            }

            foreach (var filter in m_Affixes) {
                if (filter) {
                    filter.transform.localPosition = Vector3.zero;
                    filter.transform.localEulerAngles = new Vector3(-90, 0, 0);
                    filter.gameObject.SetActive(false);
                }
            }

            foreach (var go in m_BrokenJoints) {
                go.transform.localScale = Vector3.one;
            }
        }

        private void InitMeshRender(MeshFilter filter, Material mat, Color color)
        {
            var rdr = filter.GetComponent(typeof(Renderer)) as Renderer;
            if (rdr) {
                var props = MaterialPropertyTool.Begin(rdr);
                props.TryCopyTexture(ShaderIDs.MainTex, rdr.sharedMaterial);
                props.SetColor(ShaderIDs.Color, color);
                MaterialPropertyTool.Finish();

                rdr.sharedMaterial = mat;
            }
        }

        void IInitRender.InitRender()
        {
            // 合并全身
            var skin = Combined(mats);
            var anim = gameObject.GetComponent(typeof(Animator)) as Animator;
            if (anim) anim.runtimeAnimatorController = controller;

            var mat = skin.sharedMaterial;
            var color = skin.sharedMaterial.GetColor(ShaderIDs.Color);
            foreach (var filter in m_Skins) {
                InitMeshRender(filter, mat, color);
            }

            foreach (var affix in m_Affixes) {
                InitMeshRender(affix, mat, color);
            }
        }
        
        public void GetSkins(List<Component> skins)
        {
            skins.Add(m_CombinedSkin);
            foreach (Renderer rdr in m_Rdrs) if (rdr != null) skins.Add(rdr);
        }

        public void AddBrokenJoints(Joint joint)
        {
            m_BrokenJoints.Add(joint.gameObject);
        }

        public void PushSkins(MeshFilter[] meshFilters)
        {
            m_Skins = meshFilters;
        }

        public void PushAffixes(MeshFilter[] meshFilters)
        {
            m_Affixes = meshFilters;
        }

        public void AddPart(SkinnedMeshRenderer skin)
        {
            m_Parts.Add(new BodyPart(skin));
        }

        public SkinnedMeshRenderer Combined(Material[] mats = null, int mask = -1)
        {
            var meshName = mask == -1 ? uniqueName : uniqueName + mask;
            var smr = m_CombinedSkin;
            m_CombinedSkin.enabled = true;
            var cache = StageView.Assets.GetCombined(meshName);
            var smrCombiner = SkinnedMeshCombiner.Instance;
            if (cache == null) {
                smr.sharedMesh = null;
                smrCombiner.Begin(smr);
                for (int i = 0; i < m_Parts.Count; ++i) {
                    var part = m_Parts[i];
                    if (((mask & (1 << i)) != 0) && part.mesh) {
                        smrCombiner.AddMesh(part.mesh, null, null);
                        smrCombiner.AddBones(part.bones);
                    }
                }
                smrCombiner.Finish(null, mats ?? m_Mats, meshName);
                StageView.Assets.CacheCombined(meshName, smr.sharedMesh);
            } else {
                smr.sharedMesh = cache;
                smrCombiner.Begin(smr);
                for (int i = 0; i < m_Parts.Count; ++i) {
                    var part = m_Parts[i];
                    if (((mask & (1 << i)) != 0) && part.mesh) {
                        smrCombiner.AddBones(part.bones);
                    }
                }
                smrCombiner.Finish(null, mats ?? m_Mats, meshName);
            }

            if (mask != -1) {
                m_Bones.Clear();
                m_Bones.AddRange(smr.bones);
            }
            return smr;
        }

        protected override bool HasBone(Transform bone)
        {
            return base.HasBone(bone) && (m_Bones.Count == 0 || m_Bones.Contains(bone));
        }

        protected override void ShowBroken(IEntity entity, ref DisplayValue Val)
        {
            var broken = Val.value;
            if (broken > 0) {
                Val.overrideFx = true;
                var normForce = Vector3.zero;
                // 肢解特效
                var caster = Val.source;
                Vector3 direction = Vector3.zero, headForce = Vector3.zero;
                if (caster != null) {
                    caster.PlayFx(entity, "common/dead_red_crit");

                    direction = StageView.Local2World(entity.coord) - StageView.Local2World(caster.pos);
                    var hurt = Val.hurt;
                    headForce = (direction + Vector3.up).normalized;
                    normForce = direction;
                    if (hurt != null) {
                        headForce *= hurt.force;
                        normForce *= hurt.force;
                    }
                }

                const string brokenFx = "common/dead_dismemberment_red";

                for (int i = 0; i < m_Skins.Length; ++i) {
                    var filter = m_Skins[i];
                    if (filter == null || (broken & (1 << i)) == 0) continue;

                    m_HiddenBones.Add(m_BrokenJoints[i].transform);
                    if (caster != null) {
                        filter.gameObject.SetActive(true);
                        var meshRdr = filter.GetComponent(typeof(MeshRenderer)) as MeshRenderer;
                        m_Rdrs.Add(meshRdr);

                        var cld = filter.GetComponent(typeof(Collider)) as Collider;
                        if (cld) cld.enabled = true;

                        var rigid = filter.GetComponent(typeof(Rigidbody)) as Rigidbody;
                        if (rigid) {
                            var force = i == 0 ? headForce : normForce;
                            rigid.isKinematic = false;
                            rigid.AddForce(force, ForceMode.Impulse);
                        }


                        // 断肢处的喷血特效
                        var anchor = new FxAnchor() {
                            anchor = filter.transform.GetChild(0),
                            forward = false,
                        };
                        entity.PlayFx(entity, brokenFx, ref anchor);
                    }
                }
            }

            DropAffixes(ref Val, false);
        }

        protected override void ShowDeath(IEntity entity, ref DisplayValue Val)
        {
            var force = Vector3.zero;
            var addBone = false;
            if (Val.type == 2) {
                var caster = Val.source;
                Val.overrideFx = true;
                var deadType = (DeadType)Val.value;
                switch (deadType) {
                    case DeadType.WaistCut:

                        var smr = m_CombinedSkin;
                        var props = MaterialPropertyTool.Begin(smr);
                        var mainTex = props.GetTexture(ShaderIDs.MainTex);
                        MaterialPropertyTool.Finish();

                        var mats = smr.sharedMaterials;
                        // 合成上半身
                        Combined(mats, m_UpperMask);
                        m_Force = Vector3.up * Val.force;

                        // 合成下半身
                        m_LowerPart = ObjectPoolManager.DupChildScenely(transform.parent.gameObject, gameObject);
                        m_LowerPart.Attach(transform.parent.parent);

                        var lower = m_LowerPart.GetComponent(typeof(BodyBroken)) as BodyBroken;
                        var lowerSmr = lower.Combined(mats, ~lower.m_UpperMask);
                        props = MaterialPropertyTool.Begin(lowerSmr);
                        props.SetTexture(ShaderIDs.MainTex, mainTex);
                        MaterialPropertyTool.Finish();
                        Creator.InitObjSkin(lowerSmr, smr.sharedMaterial, 1);
                        m_Rdrs.Add(lowerSmr);

                        if (Val.valid) {
                            lower.ShowRagdoll(entity, Val.source, Val.force);
                        } else {
                            entity.ShowDeadPose(m_LowerPart.GetComponent(typeof(Animator)) as Animator, 1);
                            m_LowerPart.transform.position = transform.position + transform.forward * 0.1f;
                        }

                        if (caster != null) {
                            caster.PlayFx(entity, "common/dead_waistchop");
                            force = StageView.Local2World(entity.coord) - StageView.Local2World(caster.pos);
                        }
                        if (Val.hurt != null) force *= Val.hurt.force;
                        addBone = true;

                        break;
                    default:
                        base.ShowDeath(entity, ref Val);
                        break;
                }
            }

            DropAffixes(ref Val, addBone);
        }

        private void HideAffixes()
        {
            // 断肢的骨骼点数量=5
            for (int i = BROKEN_NUM; i < m_BrokenJoints.Count; ++i) {
                m_HiddenBones.Add(m_BrokenJoints[i].transform);
            }
        }
        
        private void DropAffixes(ref DisplayValue value, bool addBone)
        {
            HideAffixes();
            if (value.source == null) return;

            for (int i = 0; i < m_Affixes.Length; ++i) {
                var filter = m_Affixes[i];
                if (addBone) m_Bones.Add(filter.transform);
                
                filter.gameObject.SetActive(true);                
                var meshRdr = filter.GetComponent(typeof(MeshRenderer)) as MeshRenderer;
                m_Rdrs.Add(meshRdr);

                var cld = filter.GetComponent(typeof(Collider)) as Collider;
                if (cld) {
                    cld.enabled = true;
                }

                var rigid = filter.GetComponent(typeof(Rigidbody)) as Rigidbody;
                if (rigid) {
                    rigid.isKinematic = false;
                    rigid.AddForce(Random.onUnitSphere, ForceMode.Impulse);
                }
            }
        }

        public override void OnRecycle()
        {
            base.OnRecycle();

            if (m_LowerPart) {
                GoTools.DestroyPooledScenely(m_LowerPart);
                m_LowerPart = null;
            }
        }        
    }
}
