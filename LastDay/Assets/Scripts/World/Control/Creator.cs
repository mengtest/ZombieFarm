//
//  Creator.cs
//  survive
//
//  Created by xingweizhen on 10/13/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TinyJSON;
using ZFrame;
using ZFrame.Asset;

namespace World.Control
{
    using View;

    public static partial class Creator
    {
        private static ObjectLibrary m_ObjL;

        public static ObjectLibrary objL {
            get {
                if (m_ObjL == null) {
                    m_ObjL = ObjectLibrary.Load("Game/SharedObjs");
                }

                return m_ObjL;
            }
        }

        private class ViewCombiner
        {
            public L_OBJImage objImage { get; private set; }
            public List<string> Dresses { get; private set; }
            public IRenderView view { get; private set; }
            public System.Action<IRenderView> onViewLoaded { get; private set; }

            public ViewCombiner(IRenderView view, L_OBJImage objImage, IEnumerable Dresses, 
                System.Action<IRenderView> onViewLoaded)
            {
                this.objImage = objImage;
                this.Dresses = new List<string>();
                this.view = view;
                foreach (var obj in Dresses) {
                    var dress = obj as System.IConvertible;
                    this.Dresses.Add(dress.ToString(null));
                }
                
                this.onViewLoaded = onViewLoaded;
            }
        }

        public class AffixAttach
        {
            public HumanView view { get; private set; }
            public int index { get; private set; }

            public AffixAttach Apply(HumanView view, int index)
            {
                this.view = view;
                this.index = index;
                return this;
            }
        }

        public static readonly Pool<AffixAttach> AffixAttachPool = new Pool<AffixAttach>(null, null);

        public static MaterialSet GetDefaultMatSet(GameObject go)
        {
            if (go.CompareTag(TAGS.Wall)) return  StageView.Assets.WallMats;
            if (go.CompareTag(TAGS.Tree)) return  StageView.Assets.TreeMats;
            
            var layer = go.layer; 
            if (layer == LAYERS.iDefault) return StageView.Assets.UnitMats;
            if (layer == LAYERS.iPlant) return StageView.Assets.PlantMats;

            var buildingLayer = layer == LAYERS.iBuilding || 
                                layer == LAYERS.iFurniture ||
                                layer == LAYERS.iGround;
            return buildingLayer ? StageView.Assets.BuildMats : StageView.Assets.RoleMats;
        }

        public static MaterialSet GetMatSet(IUnitView view, GameObject root = null)
        {
            if (view is PlayerView) return StageView.Assets.SelfMats;
            if (view is HumanView) return StageView.Assets.HumanMats;

            var skinRoot = root ? root : view.root;
            if (skinRoot) {
                var skinMat = skinRoot.GetComponent(typeof(ISkinMaterial)) as ISkinMaterial;
                if (skinMat != null) {
                    var matSet = skinMat.materialSet;
                    if (matSet == null) {
                        matSet = StageView.Assets.UnitMats;
                        LogMgr.W("{0} MaterialSet = NULL! Fallback to UnitMats", view);
                    }

                    return matSet;
                }
                
                return GetDefaultMatSet(skinRoot);;
            }
            return null;
        }

        public static void InitObjSkin(Renderer skin, Material roleMat, float matAlpha)
        {
            if (roleMat == null) return;

            skin.enabled = true;

            if (skin.gameObject.layer == LAYERS.iOverUI) {
                skin.lightProbeUsage = UnityEngine.Rendering.LightProbeUsage.Off;
                foreach (var mat in skin.materials) {
                    var mainTex = mat.GetTexture(ShaderIDs.MainTex);
                    var skinTex = mat.GetTexture(ShaderIDs.SkinTex);

                    mat.shader = roleMat.shader;
                    mat.CopyPropertiesFromMaterial(roleMat);
                    mat.SetTexture(ShaderIDs.MainTex, mainTex);
                    mat.SetTexture(ShaderIDs.SkinTex, skinTex);

                    var color = mat.GetColor(ShaderIDs.Color);
                    color.a = matAlpha;
                    mat.SetColor(ShaderIDs.Color, color);

                    mat.SetKeyword(MatKWs.BLEND_SKIN_TEX, skinTex && skinTex != mainTex);
                }
            } else {
                skin.lightProbeUsage = StageView.lightProbeUsage;
                skin.sharedMaterial = roleMat;
                if (matAlpha < 1) {
                    var color = roleMat.GetColor(ShaderIDs.Color);
                    color.a = matAlpha;
                    skin.SetColor(ShaderIDs.Color, color);
                }
                //skin.SetAlpha(ShaderIDs.Color, matAlpha);
            }
        }

        public static void InitObjSkin(IObjView view, Renderer skin, MaterialSet set)
        {
            var role = view.obj as Role;
            var matAlpha = 1f;
            if (role != null) {
                matAlpha = role.stealth ? (role.IsLocal() ? 0.5f : 0f) : 1f;
            }

            InitObjSkin(skin, matAlpha < 1f ? set.GetFade() : set.GetNorm(), matAlpha);
        }
                
#if UNITY_EDITOR
        private static HashSet<string> m_NoExistUnits = new HashSet<string>();
        public static bool Exists(string path, string name)
        {
            return !(m_NoExistUnits.Contains(path) || m_NoExistUnits.Contains(name));
        }
#endif
        private static readonly DelegateObjectLoaded OnUnitLoaded = (a, o, p) => {
            var view = p as EntityView;
            if (view == null || !StageView.Enabled) return;
            view.loading = false;

            if (view.IsNull()) return;

            var prefab = o as GameObject;
            if (!prefab) {
#if UNITY_EDITOR
                m_NoExistUnits.Add(a);
#endif
                return;
            }

            var mono = p as MonoBehaviour;

            string unitName = prefab.name;
            var multi = prefab.GetComponent(typeof(MultiView)) as MultiView;
            if (multi) {
                var viewModel = view.model;
                prefab = multi.Get(viewModel);
                if (prefab) {
                    unitName = unitName + "+" + prefab.name;
                } else {
                    Debugger.LogE("资源不存在：{0}", viewModel);
#if UNITY_EDITOR
                    m_NoExistUnits.Add(viewModel);
#endif
                    return;
                }
            }
            
            UnityEngine.Profiling.Profiler.BeginSample("OnUnitLoaded");
            var go = GoTools.AddChild(mono.gameObject, prefab, true);
            mono.name = unitName;
            go.name = "Model";
            go.layer = prefab.layer;
            view.root = go;

            BuildingGroupView buildingGroupView = go.GetComponent(typeof(BuildingGroupView)) as BuildingGroupView;
            if (buildingGroupView) {
                buildingGroupView.InitBuildingGroupView(view);
            } else {
                var rdrView = view as IRenderView;
                if (rdrView != null) {
                    rdrView.skin = go.GetComponentInChildren(typeof(Renderer), true) as Renderer;
                    rdrView.SetSkinMat(GetMatSet(view).GetNorm());
                    // 初始化渲染
                    view.InitRender(go);
                }
            }

            var objAnim = go.GetComponent(typeof(ObjAnim)) as ObjAnim;
            if (objAnim == null) {
                objAnim = go.AddComponent(typeof(ObjAnim)) as ObjAnim;
                LogMgr.W("{0} 缺少<ObjAnim>", prefab);
            }
            view.SetAction(objAnim, null);

            if (StageView.Instance) {
                view.SetNavMeshBuild();
            }
            UnityEngine.Profiling.Profiler.EndSample();
        };

        /// <summary>
        /// 使用公共的皮肤图集
        /// </summary>
        private static readonly DelegateObjectLoaded OnSkinLoadV2 = (a, o, p) => {
            if (!StageView.Enabled) return;

            var combiner = (ViewCombiner)p;
            if (combiner.view.IsNull()) return;
            var objImage = combiner.objImage;

            var SMRCombiner = SkinnedMeshCombiner.Instance;
            var skinned = (SkinnedMeshRenderer)combiner.view.skin;
            SMRCombiner.Begin(skinned);

            var goType = typeof(GameObject);

            var atlasPath = string.Format("atlas/{0}/{0}", "Skin_" + objImage.skin[0]);
            var atlas = (SkinAtlas)AssetsMgr.A.Load(typeof(SkinAtlas), atlasPath);
            var mainUVs = new Rect[combiner.Dresses.Count];
            var skinUVs = new Rect[combiner.Dresses.Count];
            Rect hairUV = Rect.zero, headUV = Rect.zero;
            bool headWithHair = false;
            for (var i = 0; i < combiner.Dresses.Count; ++i) {
                var m = combiner.Dresses[i];
                var prefab = AssetsMgr.A.Load(goType, m) as GameObject;
                if (prefab) {
                    var dress = prefab.GetComponentInChildren(typeof(SkinnedMeshRenderer)) as SkinnedMeshRenderer;
                    if (dress) {
                        var part = m.Substring(0, m.IndexOf('/')).ToLower();
                        var isHead = string.CompareOrdinal(part, "head") == 0;
                        var isHair = string.CompareOrdinal(part, "hair") == 0;

                        var name = prefab.name;
                        if (name[0] == 'C' && !isHead && !isHair) {
                            name = string.Concat(objImage.skin, "_", part);
                        }

                        bool subhair;
                        atlas.FindSkinUV(name, out mainUVs[i], out subhair);
                        if (isHair) hairUV = mainUVs[i];

                        if (isHead && subhair) {
                            headUV = mainUVs[i];
                            headWithHair = true;
                        }

                        var skinName = isHead ? objImage.face : string.Concat(objImage.skin, "_", part);
                        atlas.FindSkinUV(skinName, out skinUVs[i], out subhair);

                        SMRCombiner.AddMesh(dress.sharedMesh, null, dress.bones);
                    }
                }
            }

            SMRCombiner.AddUV(mainUVs, skinUVs);

            var isSelf = combiner.view is PlayerView;
            var matSet = isSelf ? StageView.Assets.SelfMats : StageView.Assets.HumanMats;
            SMRCombiner.Finish(matSet.GetNorm(), null, null);

            combiner.view.SetDress(objImage.dress);

            var props = MaterialPropertyTool.Begin(skinned);
            props.Clear();
            props.SetTexture(ShaderIDs.MainTex, atlas.skinTex);
            props.SetTexture(ShaderIDs.SkinTex, atlas.skinTex);
            Vector4 hair = Vector4.zero;
            if (combiner.view.IsDress(DressType.Head)) {
                if (headWithHair) {
                    hair = new Vector4(headUV.x, headUV.y, headUV.x + headUV.width / 2, headUV.y + headUV.height / 2);
                }
            } else {
                hair = new Vector4(hairUV.x, hairUV.y, hairUV.x + hairUV.width, hairUV.y + hairUV.height);
            }

            props.SetVector(ShaderIDs.HairUV, hair);
            props.SetColor(ShaderIDs.HairColor, objImage.haircolor);
            MaterialPropertyTool.Finish();

            InitObjSkin(combiner.view, skinned, matSet);

            var view = (IUnitView)combiner.view;
            view.root = skinned.gameObject;
            var objAnim = skinned.GetComponent(typeof(ObjAnim)) as ObjAnim;
            if (objAnim) {
                var nwObjAction = DataUtil.LuaCallUnitField<NWObjAction>(view.obj.id, "get_action", DataAPI.ToData);
                view.SetAction(objAnim, nwObjAction);
            }
        };

        /// <summary>
        /// 在界面加载模型
        /// </summary>
        private static readonly DelegateObjectLoaded OnSkinLoaded = (a, o, p) => {
            var combiner = (ViewCombiner)p;
            if (combiner.view.IsNull()) return;
            var objImage = combiner.objImage;

            var SMRCombiner = SkinnedMeshCombiner.Instance;
            var skinned = (SkinnedMeshRenderer)combiner.view.skin;
            SMRCombiner.Begin(skinned);

            var goType = typeof(GameObject);
            var texType = typeof(Texture);
            string hairMat = null;
            bool headWithHair = false;
            foreach (var m in combiner.Dresses) {
                var prefab = AssetsMgr.A.Load(goType, m) as GameObject;
                if (prefab) {
                    var dress = prefab.GetComponentInChildren(typeof(SkinnedMeshRenderer)) as SkinnedMeshRenderer;
                    if (dress) {
                        var mat = new Material(dress.sharedMaterial);
                        Texture skin = null;
                        if (mat.HasProperty(ShaderIDs.SkinTex)) {
                            skin = mat.GetTexture(ShaderIDs.SkinTex);
                        } else {
                            LogMgr.W("{0} doesn't have a texture property '_SkinTex'", dress);
                        }

                        var part = m.Substring(0, m.IndexOf('/')).ToLower();
                        var isHead = string.CompareOrdinal(part, "head") == 0;
                        var isHair = string.CompareOrdinal(part, "hair") == 0;
                        if (skin == null) {
                            string skinPath = null;
                            if (isHead) {
                                skinPath = string.Format("Face/{0}/{1}", objImage.face, objImage.face);
                            } else {
                                skinPath = string.Format("Skin/{0}/{1}", objImage.skin, part);
                            }

                            skin = AssetsMgr.A.Load(texType, skinPath, false) as Texture;
                            if (skin) {
                                if (mat.mainTexture == null) {
                                    mat.mainTexture = skin;
                                } else {
                                    mat.SetTexture(ShaderIDs.SkinTex, skin);
                                }
                            }
                        }

                        var matName = mat.name;
                        if (isHair) {
                            hairMat = matName;
                        }

                        if (hairMat == null && isHead && matName.OrdinalEndsWith(SkinAtlas.HairTAG)) {
                            hairMat = matName;
                            headWithHair = true;
                        }

                        SMRCombiner.AddMesh(dress.sharedMesh, mat, dress.bones);
                    }
                }
            }

            SMRCombiner.Finish(null, null, null);

            /*
            if (combiner.view.obj == null) {                
                SMRCombiner.Finish(null, null, null);
            } else {
                // 合并贴图（手机设备上贴图合并后格式强制转为ARGB32）
                var uvs = CombinedSkin.Combine(skinned, SMRCombiner.skinnedMats);
                SMRCombiner.AddUV(uvs);
                SMRCombiner.Finish(skinned.material, null, null);
            }
            //*/
            combiner.view.SetDress(objImage.dress);

            InitObjSkin(skinned, AssetCacher.HumanUIMats.GetNorm(), 1);

            if (hairMat != null) {
                foreach (var mat in skinned.materials) {
                    if (mat.name.OrdinalStartsWith(hairMat)) {
                        mat.EnableKeyword(MatKWs.ADD_HAIR_COLOR);
                        mat.SetColor(ShaderIDs.HairColor, objImage.haircolor);
                        // 发色
                        mat.SetVector(ShaderIDs.HairUV,
                            headWithHair ? new Vector4(0, 0, 0.5f, 0.5f) : new Vector4(0, 0, 1f, 1f));
                    } else {
                        mat.DisableKeyword(MatKWs.ADD_HAIR_COLOR);
                    }
                }
            }

            var view = (IUnitView)combiner.view;
            view.root = skinned.gameObject;
            var objAnim = skinned.GetComponent(typeof(ObjAnim)) as ObjAnim;
            if (objAnim) view.SetAction(objAnim, null);
            if (combiner.onViewLoaded != null)
                combiner.onViewLoaded.Invoke(combiner.view);
        };


        private static readonly DelegateObjectLoaded OnAffixLoaded = (a, o, p) => {
            var attach = p as AffixAttach;
            if (attach.view) {
                attach.view.AttachAffix(o as GameObject, attach.index, a);
            }

            AffixAttachPool.Release(attach);
        };

        private static readonly DelegateObjectLoaded OnObjectViewLoaded = (a, o, p) => {
            (p as IObjView).UpdateFirePoint();
        };

        public static string Model2PrefabPath(string model)
        {
            var ul = model.LastIndexOf('_');
            var bundle = ul > 3 ? model.Substring(0, ul) : model;
            return string.Format("Units/{0}/{0}", bundle);
        }

        public static bool LoadObjView(IObjView view, string model)
        {
            var entView = view as EntityView;
            if (entView == null) return false;

            if (entView.root) {
                entView.DestroyView(ObjCtrl.FADING_DURA, entView.root);
            }
            entView.loading = true;

            if (string.IsNullOrEmpty(model)) {
                entView.loading = false;
                return false;
            }

            var modelPath = Model2PrefabPath(model);
#if UNITY_EDITOR
            if (!Exists(modelPath, model.Substring(model.LastIndexOf('_') + 1))) {
                entView.loading = false;
                return false;
            }
#endif
            var loading = false;
            if (view.obj != null) PreloadBundle(view.obj, ref loading);
            
            if (AssetsMgr.A.LoadAsync(typeof(GameObject), modelPath, LoadMethod.Cache, OnUnitLoaded, view)) {
                AssetsMgr.A.Loader.LimitAssetBundle("Units", AssetCacher.GRP_ASSET_LIMIT);
                return true;
            }

            return false;
        }

        public static void LoadObjCombineView(IRenderView view, IEnumerable models, L_OBJImage objImage,
            System.Action<IRenderView> onViewLoaded = null)
        {
            if (view != null) {
                var loading = false;
                if (view.obj != null) PreloadBundle(view.obj, ref loading);
                if (!string.IsNullOrEmpty(objImage.skin)) {
                    AssetsMgr.A.LoadAsync(null, string.Format("Skin/{0}/", objImage.skin), LoadMethod.Cache, ref loading);
                }
                if (!string.IsNullOrEmpty(objImage.face)) {
                    AssetsMgr.A.LoadAsync(null, string.Format("Face/{0}/", objImage.face), LoadMethod.Cache, ref loading);
                }

                foreach (System.IConvertible obj in models) {
                    AssetsMgr.A.LoadAsync(null, obj.ToString(null), LoadMethod.Cache, ref loading);
                }

                DelegateObjectLoaded onLoaded;
                if (view.obj == null) {
                    onLoaded = OnSkinLoaded;
                } else {
                    var atlasPath = string.Format("atlas/{0}/", "Skin_" + objImage.skin[0]);
                    AssetsMgr.A.LoadAsync(null, atlasPath, LoadMethod.Cache, ref loading);
                    onLoaded = OnSkinLoadV2;
                }

                var combiner = new ViewCombiner(view, objImage, models, onViewLoaded);
                if (loading) {
                    AssetsMgr.A.FinishLoadAsync(onLoaded, combiner);
                } else {
                    onLoaded(null, null, combiner);
                }
            }
        }

        public static void LoadObjAffix(string path, AffixAttach affix)
        {
            if (string.IsNullOrEmpty(path) || path[path.Length - 1] == '/') {
                OnAffixLoaded(path, null, affix);
            } else {
                AssetsMgr.A.LoadAsync(typeof(GameObject), path, LoadMethod.Cache, OnAffixLoaded, affix);
            }
        }

        public static ObjView CreateView(GameObject root, int pose, ref L_OBJView viewData, 
            IObj obj = null, System.Action<IRenderView> onViewLoaded = null)
        {
            var assetPath = string.Format("Game/{0}", viewData.prefab);
            var go = StageView.Instance ?
                GoTools.AddChild(root, assetPath, true) : GoTools.NewChild(root, assetPath);
            var view = (ObjView)go.GetComponent(typeof(ObjView));
            view.enabled = false;
            if (obj != null) {
                view.Subscribe(obj);
                var entView = view as EntityView;
                if (entView) entView.OnCampChange(obj.camp);
            }

            if (viewData.Dresses.Count > 0) {
                LoadObjCombineView(view as IRenderView, viewData.Dresses, viewData.objImage, onViewLoaded);

                var hView = view as HumanView;
                if (hView) {
                    hView.OnSwapWeapon(null);
                    if (pose >= 0) hView.SetPose(pose);
                    foreach (var kv in viewData.Affixes) {
                        hView.LoadObjAffix(kv.Value, kv.Key);
                    }
                }

                AssetsMgr.A.FinishLoadAsync(OnObjectViewLoaded, view);
            } else {
                var xObj = obj as XObject;
                if (xObj != null) {
                    xObj.Data.SetExtend("model", viewData.model);
                }
            }

            return view;
        }

        public static void PreloadBundle(IObj self, ref bool loading)
        {
            var Ent = self as IEntity;
            if (Ent != null) {
                Ent.Data.LoadFx(ref loading);
                var human = Ent as Human;
                if (human != null) {
                    if (human.visible) MiniMap.Instance.Enter(human);

                    human.Major.LoadFx(ref loading);
                    human.Minor.LoadFx(ref loading);
                    if (human.Tool != null) human.Tool.LoadFx(ref loading);
                }
            }
        }

        public static void CreateView(this IObj self, ref L_OBJView viewData)
        {
            if (self.id != StageCtrl.P.id && StageCtrl.P.view == null) return;

            if (!string.IsNullOrEmpty(viewData.prefab)) {
                CreateView(StageView.Instance.gameObject, -1, ref viewData, self);                
            } else {
                var reedObj = self as ReedObj;
                if (reedObj != null && reedObj.status == 1) {
                    StageView.M.LoadReedView(self.L, reedObj, -StageView.Instance.origin);
                    MiniMap.Instance.Enter(reedObj);
                }
            }
        }

        #region Entity Objects Initialization
        private static void InitEntity(Entity obj, ref L_OBJData Data)
        {
            var Init = Data.Init;
            var View = Data.View;
            obj.InitBase(StageCtrl.L, (BaseData)Init, View.ToData(), true);
            obj.InitEntity((EntityData)Init, Init.disappear);
        }
        #endregion

        #region Living Objects Initialization
        private static void InitLivingEntity(LivingEntity obj, ref L_OBJData Data)
        {
            var Init = Data.Init;
            var View = Data.View;

            obj.InitBase(StageCtrl.L, (BaseData)Init, View.ToData(), true);
            obj.InitLiving(new CFG_Attr(Init.Attr), new CFG_Attr(Data.Attr));
            obj.InitEntity((EntityData)Init, Init.disappear);
        }

        private static void InitActor(CActor obj, ref L_OBJData Data)
        {
            InitLivingEntity(obj, ref Data);

            var Init = Data.Init;
            obj.InitTurner();
            obj.InitActor(Init.state);
            obj.actionIds.AddRange(Data.actionIds);

            switch ((ObjAction)Init.state) {
                case ObjAction.Move:
                case ObjAction.Sneak: {
                        obj.turnForward = Quaternion.Euler(0, Init.tarAngle, 0) * Vector3.forward;
                    }
                    break;
                default: break;
            }
        }

        private static void InitRole(Role obj, ref L_OBJData Data)
        {
            InitActor(obj, ref Data);
            obj.InitRole();

            var Init = Data.Init;

            obj.moveTarget = Init.tarCoord;
            switch ((ObjAction)obj.state) {
                case ObjAction.Move:
                    obj.MoveTo(obj.moveTarget, 1);
                    goto case ObjAction.Stand;
                case ObjAction.Stand:
                    obj.shiftingRate = 1;
                    break;
                case ObjAction.SneakMove:
                    obj.MoveTo(obj.moveTarget, 1);
                    goto case ObjAction.Sneak;
                case ObjAction.Sneak:
                    obj.shiftingRate = obj.GetAttr(ATTR.Sneak) / obj.GetAttr(ATTR.Move);
                    break;
                default: break;
            }
            obj.stealth = Init.stealth;
        }

        private static void InitHuman(Human obj, ref L_OBJData Data)
        {
            InitRole(obj, ref Data);
            obj.InitHuman(Data.majorId, Data.minorId);
        }
        #endregion

        public static IObj CreateObj(IObj obj, ref L_OBJData Data)
        {
            switch (Data.klass) {
                case "Entity": {
                        var ent = (obj as Entity) ?? new Entity();
                        InitEntity(ent, ref Data);
                        obj = ent;
                    }
                    break;
                //=============================//
                case "LivingEntity": {
                        var living = (obj as LivingEntity) ?? new LivingEntity();
                        InitLivingEntity(living, ref Data);
                        obj = living;
                    }
                    break;
                case "Actor": {
                        var actor = (obj as CActor) ?? new CActor();
                        InitActor(actor, ref Data);
                        obj = actor;
                    }
                    break;
                case "Role": {
                        var role = (obj as Role) ?? new Role();
                        InitRole(role, ref Data);
                        obj = role;
                    }
                    break;
                case "Pet": {
                        var pet = (obj as Pet) ?? new Pet();
                        InitRole(pet, ref Data);
                        obj = pet;
                    }
                    break;
                case "Human": {
                        var human = (obj as Human) ?? new Human();
                        InitHuman(human, ref Data);
                        obj = human;
                    }
                    break;
                case "Player": {
                        var player = (obj as Player) ?? new Player();
                        InitHuman(player, ref Data);
                        obj = player;
                    }
                    break;
                case "Reedbed": {
                        var reedbed = (obj as ReedObj) ?? new ReedObj();
                        reedbed.InitBase(StageCtrl.L, (BaseData)Data.Init, ObjData.Empty, true);
                        reedbed.InitReedbed(Data.group);
                        obj = reedbed;
                    }
                    break;
                default:
                    break;
            }

            return obj;
        }
    }
}
