using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;
using UnityEngine.AI;
using ZFrame.Asset;
using MEC;
using FMODUnity;
using World;
using World.View;
using World.Control;
using ZFrame;

public static class ObjViewExt
{
    public static bool LoadFx(this FxBundle self)
    {
        var loading = false;
        if (StageView.Enabled) {
            string fxBundle = self.fxBundle;
            if (!string.IsNullOrEmpty(fxBundle)) {
                AssetsMgr.A.LoadAsync(null, "FX/" + fxBundle + "/", LoadMethod.Cache, ref loading);
                AssetsMgr.A.Loader.LimitAssetBundle("FX", AssetCacher.GRP_ASSET_LIMIT);
            }
            var sfxBank = self.sfxBank;
            if (!string.IsNullOrEmpty(sfxBank)) {
                var path = "FMOD/" + sfxBank + "/";
                if (!AssetsMgr.A.Loader.IsLoaded(path)) {
                    AssetsMgr.A.LoadAsync(null, path, LoadMethod.Cache, ref loading);
                    //AssetsMgr.A.Loader.LimitAssetBundle("FMOD", AssetCacher.GRP_ASSET_LIMIT);
                }
            }
        }
        return loading;
    }

    public static void LoadFx(this FxBundle self, ref bool loading)
    {
        loading = self.LoadFx() | loading;
    }


    public static void UpdateFirePoint(this IObjView view)
    {
        var holder = view as FX.IFxHolder;
        var mono = view as MonoBehaviour;
        if (holder != null && mono != null) {
            holder.firePoint = mono.transform.FindByName("WFIRE", false);
            if (holder.firePoint == null) {
                holder.firePoint = mono.transform.FindByName("FIRE", false);
            }
        }
    }

    public static void SetGender(this FMODAudioEmitter emitter, IObj obj)
    {
        var ent = obj as IEntity;
        if (ent != null && ent.Data.gender != 0) {
            emitter.SetParam("female", ent.Data.gender == 1 ? 0 : 1);
        }
    }

    public static void SetNavMeshBuild(this IUnitView self)
    {
        if (self.root == null) return;

        if (!StageView.Instance.IsNewNavMeshBuild(self)) return;

        var list = ListPool<Component>.Get();
        self.root.GetComponentsInChildren(typeof(NavMeshBuildTag), list);
        if (list.Count > 0) {
            foreach (NavMeshBuildTag tag in list) {
                tag.enabled = false;
                var source = new NavMeshBuildSource();
                if (tag.GenBuildSource(ref source)) {
                    StageView.Instance.AddNavMeshBuild(self, source);
                }
            }
        }
        ListPool<Component>.Release(list);
    }

    public static void InitAgentDoor(this NavMeshAgent self, int camp)
    {
        var trap = self.transform.Find("TRAP");
        var area = 1 << NavMesh.GetAreaFromName("Door");
        if (camp == CVar.HOME_CAMP) {
            self.areaMask |= area;
            if (trap) trap.gameObject.SetActive(true);
        } else {
            self.areaMask &= ~area;
            if (trap) trap.gameObject.SetActive(false);
        }
    }

    public static void InitRender(this IUnitView self, GameObject root)
    {
        // 初始化渲染
        var list = ListPool<Component>.Get();
        root.GetComponents(typeof(IInitRender), list);
        foreach (IInitRender ini in list) ini.InitRender();
        ListPool<Component>.Release(list);
    }

    public static Material GetDeadFading(this MaterialSet self)
    {
        return self.GetGrid();
    }

    public static void SetFOWStatus<T>(this EntityView self) where T : Behaviour, IFOWStatus
    {
        var status = self.GetComponent(typeof(T)) as T;
        if (status != null) status.enabled = status.active;
    }

    public static void SetFOWStatus<T>(this EntityView self, bool enabled) where T : Behaviour, IFOWStatus
    {
        var status = self.GetComponent(typeof(T)) as T;
        if(status == null && enabled) {
            status = self.gameObject.AddComponent(typeof(T)) as T;
        }
        if (status != null) {
            status.active = enabled;
            status.enabled = enabled && self.enabled;
        }
    }

    #region Skin Fading

    public static bool SetViewColor(Color color, List<Component> skins)
    {
        var set = false;
        for (int i = 0; i < skins.Count; ++i) {
            var skin = skins[i] as Renderer;
            if (skin) {
                skin.SetColor(ShaderIDs.Color, color);
                set = true;
            }
        }
        return set;
    }

    public static void SetViewColor(List<Component> skins, Color color, Material mat)
    {
        if (mat != null) {
            for (int i = 0; i < skins.Count; ++i) {
                var skin = skins[i] as Renderer;
                if (skin) skin.sharedMaterial = mat;
            }
        }
        SetViewColor(color, skins);
    }

    public static bool SetViewAlpha(float alpha, List<Component> skins)
    {
        var set = false;
        for (int i = 0; i < skins.Count; ++i) {
            var skin = skins[i] as Renderer;
            if (skin) {
                var color = skin.sharedMaterial.GetColor(ShaderIDs.Color);
                color.a = alpha;
                skin.SetColor(ShaderIDs.Color, color);
                set = true;
            }
        }
        return set;
    }

    public static void SetViewAlpha(List<Component> skins, float alpha, Material mat)
    {
        if (mat != null) {
            for (int i = 0; i < skins.Count; ++i) {
                var skin = skins[i] as Renderer;
                if (skin) skin.sharedMaterial = mat;
            }
            var color = mat.GetColor(ShaderIDs.Color);
            color.a = alpha;
            SetViewColor(color, skins);
        } else {
            SetViewAlpha(alpha, skins);
        }
    }

    public static void SetSkinMat(this IRenderView self, Material mat)
    {
        var skins = ListPool<Component>.Get();
        self.GetSkins(skins);
        for (int i = 0; i < skins.Count; ++i) {
            var skin = skins[i] as Renderer;
            if (skin) {
                var props = MaterialPropertyTool.Begin(skin);
                var mainTex = skin.sharedMaterial.GetTexture(ShaderIDs.MainTex);
                if (mainTex == null) mainTex = props.GetTexture(ShaderIDs.MainTex);

                props.Clear();
                if (mainTex != null)
                    props.SetTexture(ShaderIDs.MainTex, mainTex);
                MaterialPropertyTool.Finish();
                skin.sharedMaterial = mat;
                skin.lightProbeUsage = StageView.lightProbeUsage;
            }
        }
        ListPool<Component>.Release(skins);
    }
    
    public static void SetViewEnable(this IRenderView self, bool enable)
    {
        var skins = ListPool<Component>.Get();
        self.GetSkins(skins);
        for (int i = 0; i < skins.Count; ++i) {
            var skin = skins[i] as Renderer;
            if (skin) skin.enabled = enable;
        }
        ListPool<Component>.Release(skins);

        var uView = self as IUnitView;
        if(uView != null) {          
            if (uView.agent) {
                uView.agent.enabled = enable;
            }
        }
    }

    public static void SetViewAlpha(this IRenderView self, float alpha, Material mat)
    {
        var skins = ListPool<Component>.Get();
        self.GetSkins(skins);
        SetViewAlpha(skins, alpha, mat);        
        ListPool<Component>.Release(skins);
        self.SetViewEnable(alpha > 0);        
    }
    
    public static void SetViewColor(this IRenderView self, Color color, Material mat)
    {
        var skins = ListPool<Component>.Get();
        self.GetSkins(skins);
        SetViewColor(skins, color, mat);
        ListPool<Component>.Release(skins);
        self.SetViewEnable(color.a > 0);
    }

    public static IEnumerator<float> FadingView(this EntityView self, float from, float to, float duration, Material mat)
    {
        self.SetViewEnable(true);

        var skins = ListPool<Component>.Get();
        self.GetSkins(skins);
        yield return Timing.WaitUntilDone(FadingView(skins, from, to, duration, mat));
        ListPool<Component>.Release(skins);
        if (self != null && self.root != null) {
            self.SetViewAlpha(to, to < 1 ? null : Creator.GetMatSet(self).GetNorm());
        }
    }

    public static IEnumerator<float> FadingView(List<Component> skins, float from, float to, float duration, Material mat)
    {
        if (mat != null) {
            for (int i = 0; i < skins.Count; ++i) {
                var skin = skins[i] as Renderer;
                if (skin) skin.sharedMaterial = mat;
            }
        }

        var color = mat.GetColor(ShaderIDs.Color);
        for (var time = 0f; time < duration; time += Time.deltaTime) {
            color.a = Mathf.Lerp(from, to, time / duration);
            if (SetViewColor(color, skins)) {
                yield return Timing.WaitForOneFrame;
            } else yield break;
        }

        color.a = to;
        SetViewColor(color, skins);
        yield return Timing.WaitForOneFrame;
    }
    #endregion
}
