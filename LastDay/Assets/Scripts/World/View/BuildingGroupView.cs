using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using World.Control;
using ZFrame;

namespace World.View
{
    public class BuildingGroupView : MonoBehaviour, ISkinProperty
    {
        [Header("建筑群列表")][SerializeField] private GameObject[] m_SubBuildings;

        private List<IRenderView> m_subRenderView = new List<IRenderView>();

        public void InitBuildingGroupView(IUnitView view)
        {
            m_subRenderView.Clear();

            var lua = DataUtil.LuaLoadConfig("get_obj", view.obj.id);
            List<int> subIdList = GetSubbuildingList(lua, -1);
            lua.Pop(1);

            for (int i = 0; i < subIdList.Count; i++) {
                IObj subIObj = StageCtrl.L.FindById(subIdList[i], true);
                if (subIObj == null)
                {
                    Debugger.LogE("[BuildingGroupView]Cannot find subbuilding view info.objID:{0};subObjID:{1}",
                        view.obj.id, subIdList[i]);
                    continue;
                }
                EntityView subOb = subIObj.view as EntityView;
                subOb.transform.SetParent(transform.parent, true);

                GameObject ctrlModel = m_SubBuildings[i];

                ctrlModel.transform.SetParent(subOb.transform, true);
                ctrlModel.name = "Model";

                var rdrView = subIObj.view as IRenderView;
                if (rdrView != null) {
                    m_subRenderView.Add(rdrView);
                    rdrView.skin = subOb.GetComponentInChildren<Renderer>();
                    rdrView.SetSkinMat(Creator.GetMatSet(view).GetNorm());
                    // 初始化渲染
                    subOb.InitRender(ctrlModel);
                }

                IUnitView subIUnitView = subIObj.view as IUnitView;
                subIUnitView.root = ctrlModel;
                ObjAnim objAnim = ctrlModel.GetComponent(typeof(ObjAnim)) as ObjAnim;
                if (objAnim) subIUnitView.SetAction(objAnim, null);

                if (StageView.Instance) {
                    subIUnitView.SetNavMeshBuild();
                }
            }
        }

        public List<IRenderView> GetBuildingGroupRenderViews()
        {
            return m_subRenderView;
        }

        private static List<int> GetSubbuildingList(System.IntPtr lua, int index)
        {
            if (!lua.IsTable(index)) return null;
            if (index < 0) index = lua.GetTop() + 1 + index;

            List<int> subBuildingList = new List<int>();

            lua.GetField(index, "sbObjIds");
            if (lua.IsTable(-1)) {
                lua.PushNil();
                while (lua.Next(-2)) {
                    int subId = (int)lua.ToNumber(-1);
                    subBuildingList.Add(subId);
                    lua.Pop(1);
                }
                lua.Pop(1);
            }

            return subBuildingList;
        }

        void OnRecycle()
        {
            for (int i = 0; i < m_SubBuildings.Length; i++) {
                m_SubBuildings[i].transform.SetParent(transform, true);
            }
        }

        void ISkinProperty.GetSkins(List<Component> skins)
        {
            for (int i = 0; i < m_subRenderView.Count; ++i) {
                var rdr = m_subRenderView[i].skin;
                if (rdr) skins.Add(rdr);
            }
        }
    }
}
