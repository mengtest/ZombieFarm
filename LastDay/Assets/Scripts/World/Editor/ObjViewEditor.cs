//
//  ObjViewEditor.cs
//  survive
//
//  Created by xingweizhen on 10/20/2017.
//
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using World.Control;
using ZFrame.HFSM;

namespace World.View
{
    [CustomEditor(typeof(EntityView), true)]
    public class ObjViewEditor : MonoBehaviorEditor
    {
        private enum OPER
        {
            拾取 = 1, 打开 = 2, 工作 = 3, 机关 = 4,
        }
        
        private static bool m_HFSM, m_FxPoint, m_Weapons, m_Attrs, m_Extends, m_Actions, m_Timers;

        private void ShowHFSM()
        {
            if (Application.isPlaying) {
                var entity = (target as EntityView).obj;
                m_HFSM = EditorGUILayout.ToggleLeft("状态机", m_HFSM);
                if (!m_HFSM) return;

                EditorGUI.indentLevel++;
                var context = entity as IFSMContext;
                if (context != null && context.fsm.activated) {
                    var fsm = context.fsm;
                    fsm.debug = EditorGUILayout.Toggle("调试", fsm.debug);
                    EditorGUILayout.LabelField("当前状态：", fsm.ToString());
                }
                EditorGUI.indentLevel--;

                EditorGUILayout.Separator();
            }
        }

        private void ShowFxPoint()
        {
            if (Application.isPlaying) {
                var view = target as EntityView;
                if (view.control != null) {
                    m_FxPoint = EditorGUILayout.ToggleLeft("特效点", m_FxPoint);
                    if (!m_FxPoint) return;

                    EditorGUI.BeginDisabledGroup(true);
                    EditorGUI.indentLevel++;

                    EditorGUILayout.ObjectField("头部", view.headPoint, typeof(Transform), false);
                    EditorGUILayout.ObjectField("身体", view.bodyPoint, typeof(Transform), false);
                    EditorGUILayout.ObjectField("脚底", view.footPoint, typeof(Transform), false);
                    EditorGUILayout.ObjectField("火点", view.firePoint, typeof(Transform), false);
                    EditorGUI.indentLevel--;
                    EditorGUI.EndDisabledGroup();

                    EditorGUILayout.Separator();
                }
            }
        }

        private void ShowWeapons()
        {
            if (Application.isPlaying) {
                var view = target as HumanView;
                if (view) {
                    var human = view.obj as Human;
                    if (human != null && human.Major != null) {
                        m_Weapons = EditorGUILayout.ToggleLeft("武器", m_Weapons);
                        if (!m_Weapons) return;

                        EditorGUI.indentLevel++;
                        EditorGUILayout.LabelField("主武器：", SystemTools.ToString(human.Major));
                        EditorGUILayout.LabelField("副武器：", SystemTools.ToString(human.Minor));
                        EditorGUILayout.LabelField("着装：", view.dressing.ToString());
                        EditorGUI.indentLevel--;

                        EditorGUILayout.Separator();
                    }
                }
            }
        }

        private void ShowAttr()
        {
            if (Application.isPlaying) {
                var view = target as EntityView;
                if (view && view.obj != null) {
                    m_Attrs = EditorGUILayout.ToggleLeft("属性", m_Attrs);
                    if (!m_Attrs) return;

                    EditorGUI.indentLevel++;
                    bool hasValue = false;
                    var living = view.obj as ILiving;
                    if (living != null) {
                        EditorGUILayout.LabelField("生命值",
                            string.Format("{0}/{1}", living.Health.GetValue(), living.Health.GetLimit()));
                        hasValue = true;
                    }

                    var human = view.obj as Human;
                    if (human != null) {
                        var Equip = human.Major;
                        EditorGUILayout.LabelField("耐久",
                            string.Format("{0}/{1}", Equip.Dura.GetValue(), Equip.Dura.GetLimit()));
                        EditorGUILayout.LabelField("弹夹",
                            string.Format("{0}/{1}", Equip.Ammo.GetValue(), Equip.Ammo.GetLimit()));
                        hasValue = true;
                    }

                    var ent = view.obj as IEntity;
                    if (ent != null && ent.operId > 0) {
                        EditorGUILayout.LabelField("交互类型", ((OPER)ent.operId).ToString());
                        hasValue = true;
                    }

                    var vol = view.obj as IVolume;
                    if (vol != null && vol.blockLevel > 0) {
                        EditorGUILayout.LabelField("阻挡等级", ((StageEdit.BlockLevel)vol.blockLevel).ToString());
                        hasValue = true;
                    }

                    if (hasValue) EditorGUILayout.Separator();

                    var Values = ((XObject)view.obj).currentAttrs;
                    if (Values != null) {
                        var attrType = typeof(ATTR);
                        var descType = typeof(DescriptionAttribute);
                        var fields = attrType.GetFields();
                        for (int i = 0; i < fields.Length; ++i) {
                            var desc = System.Attribute.GetCustomAttribute(fields[i], descType) as DescriptionAttribute;
                            if (desc != null) {
                                var attr = (ATTR)fields[i].GetValue(attrType);
                                var Val = Values[(int)attr];
                                EditorGUILayout.LabelField(desc.description, Val.ToString());
                            }
                        }
                    }
                    EditorGUI.indentLevel--;

                    EditorGUILayout.Separator();
                }
            }
        }

        private void ShowData()
        {
            if (Application.isPlaying) {
                var view = target as EntityView;
                if (view && view.obj != null) {
                    m_Extends = EditorGUILayout.ToggleLeft("扩展数据", m_Extends);
                    if (!m_Extends) return;
                    
                    EditorGUI.indentLevel++;
                    var data = ((XObject)view.obj).Data;
                    foreach (var ext in data.Extends) {
                        EditorGUILayout.LabelField(ext.Key, ext.Value);
                    }
                    EditorGUI.indentLevel--;

                    EditorGUILayout.Separator();
                }
                
            }
        }

        private void ShowActions()
        {
            if (Application.isPlaying) {
                var view = target as ObjView;
                var actor = view.obj as IActor;
                if (actor != null) {
                    m_Actions = EditorGUILayout.ToggleLeft("技能", m_Actions);
                    if (!m_Actions) return;

                    EditorGUI.indentLevel++;
                    for (int i = -1; ; ++i) {
                        var Action = actor.IGetAction(i);
                        if (Action != null) {
                            EditorGUILayout.LabelField(string.Format("动作#{0}", i + 1), Action.ToString());
                        } else if (i >= 0) break;
                    }

                    EditorGUI.indentLevel--;

                    EditorGUILayout.Separator();
                }
            }
        }

        private void ShowTimer()
        {
            if (Application.isPlaying) {
                var view = target as EntityView;
                if (view.obj != null) {
                    m_Timers = EditorGUILayout.ToggleLeft("定时器", m_Timers);
                    if (!m_Timers) return;

                    EditorGUI.indentLevel++;
                    var timers = view.obj.GetTimersOf(null);
                    foreach (var tm in timers) {
                        EditorGUILayout.LabelField(string.Format("{0}", tm.ToString()));
                    }
                    TimerManager.ReleasePool(timers);
                    EditorGUI.indentLevel--;
                }
            }
        }

        private void TargetField(string name, IObj target)
        {
            if (target == null) return;

            var tarEntity = target as IEntity;
            if (tarEntity != null && tarEntity.view != null) {
                EditorGUI.BeginDisabledGroup(true);
                EditorGUILayout.ObjectField(name, tarEntity.view as MonoBehaviour, typeof(MonoBehaviour), false);
                EditorGUI.EndDisabledGroup();
            } else {
                EditorGUILayout.LabelField(name, SystemTools.ToString(target));
            }
        }

        public void ShowBase()
        {
            if (Application.isPlaying) {
                var view = target as EntityView;
                if (view.obj != null) {
                    EditorGUILayout.LabelField("名称", view.obj.ToString());
                    EditorGUILayout.LabelField("坐标：", view.obj.pos.ToXZ());
                    EditorGUILayout.LabelField("位置：", view.obj.coord.ToXZ());
                    EditorGUILayout.LabelField("视距：", view.obj.Dist.ToString());
                    var vol = view.obj as IVolume;
                    if (vol != null) EditorGUILayout.LabelField("大小：", vol.size.ToXZ());
                    var xObj = view.obj as XObject;
                    if (xObj != null) EditorGUILayout.LabelField("状态：", xObj.status.ToString());

                    var actor = view.obj as IActor;
                    if (actor != null) {
                        var Content = actor.Content;
                        EditorGUILayout.LabelField("动作：", SystemTools.ToString(Content.action ?? Content.prefab));
                        TargetField("目标：", Content.target);
                    }

                    var playerView = view as PlayerView;
                    if (playerView) {
                        TargetField("锁定：", playerView.autoTarget);
                        TargetField("焦点：", StageCtrl.focus);
                    }
                    EditorGUILayout.Separator();
                }
            }
        }

        public override void OnInspectorGUI()
        {
            DefaultInspector();
            EditorGUILayout.Separator();

            ShowBase();
            ShowAttr();
            ShowActions();
            ShowHFSM();
            ShowTimer();
            ShowWeapons();
            ShowFxPoint();
            ShowData();

            ShowDescFields();
        }
    }
}
