#if USE_UNI_LUA
using LuaAPI = UniLua.Lua;
using RealStatePtr = UniLua.ILuaState;
using LuaCSFunction = UniLua.CSharpFunctionDelegate;
#else
using LuaAPI = XLua.LuaDLL.Lua;
using RealStatePtr = System.IntPtr;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif

using System;
using System.Collections.Generic;
using System.Reflection;


namespace XLua.CSObjectWrap
{
    public class XLua_Gen_Initer_Register__
	{
	    static XLua_Gen_Initer_Register__()
        {
		    XLua.LuaEnv.AddIniter((luaenv, translator) => {
			    
				translator.DelayWrapLoader(typeof(object), SystemObjectWrap.__Register);
				
				translator.DelayWrapLoader(typeof(System.Type), SystemTypeWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.WWW), UnityEngineWWWWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Object), UnityEngineObjectWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Shader), UnityEngineShaderWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Renderer), UnityEngineRendererWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Collider), UnityEngineColliderWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Texture), UnityEngineTextureWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.GameObject), UnityEngineGameObjectWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Transform), UnityEngineTransformWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.RectTransform), UnityEngineRectTransformWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Component), UnityEngineComponentWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Behaviour), UnityEngineBehaviourWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.MonoBehaviour), UnityEngineMonoBehaviourWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Camera), UnityEngineCameraWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Animator), UnityEngineAnimatorWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Animation), UnityEngineAnimationWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Material), UnityEngineMaterialWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Projector), UnityEngineProjectorWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.AI.NavMeshAgent), UnityEngineAINavMeshAgentWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.AI.NavMeshObstacle), UnityEngineAINavMeshObstacleWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Time), UnityEngineTimeWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Application), UnityEngineApplicationWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.PlayerPrefs), UnityEnginePlayerPrefsWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.SystemInfo), UnityEngineSystemInfoWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Screen), UnityEngineScreenWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.RenderSettings), UnityEngineRenderSettingsWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.QualitySettings), UnityEngineQualitySettingsWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.NetEngine.NetworkMgr), ZFrameNetEngineNetworkMgrWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.NetEngine.TcpClientHandler), ZFrameNetEngineTcpClientHandlerWrap.__Register);
				
				translator.DelayWrapLoader(typeof(clientlib.net.NetMsg), clientlibnetNetMsgWrap.__Register);
				
				translator.DelayWrapLoader(typeof(GTime), GTimeWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.Canvas), UnityEngineCanvasWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.CanvasGroup), UnityEngineCanvasGroupWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.EventSystems.UIBehaviour), UnityEngineEventSystemsUIBehaviourWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.EventSystems.BaseEventData), UnityEngineEventSystemsBaseEventDataWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.EventSystems.PointerEventData), UnityEngineEventSystemsPointerEventDataWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.UI.Graphic), UnityEngineUIGraphicWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.UI.MaskableGraphic), UnityEngineUIMaskableGraphicWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.UI.Image), UnityEngineUIImageWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.UI.RawImage), UnityEngineUIRawImageWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.UI.Selectable), UnityEngineUISelectableWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.UI.Button), UnityEngineUIButtonWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.UI.Toggle), UnityEngineUIToggleWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.UI.Slider), UnityEngineUISliderWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.UI.Dropdown), UnityEngineUIDropdownWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.UI.Dropdown.OptionData), UnityEngineUIDropdownOptionDataWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.UI.Scrollbar), UnityEngineUIScrollbarWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.UI.ScrollRect), UnityEngineUIScrollRectWrap.__Register);
				
				translator.DelayWrapLoader(typeof(UnityEngine.UI.InputField), UnityEngineUIInputFieldWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.UGUI.UILabel), ZFrameUGUIUILabelWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.UGUI.UISprite), ZFrameUGUIUISpriteWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.UGUI.UITexture), ZFrameUGUIUITextureWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.UGUI.UIButton), ZFrameUGUIUIButtonWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.UGUI.UIToggle), ZFrameUGUIUIToggleWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.UGUI.UISlider), ZFrameUGUIUISliderWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.UGUI.UIDropdown), ZFrameUGUIUIDropdownWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.UGUI.UIDragged), ZFrameUGUIUIDraggedWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.UGUI.UIProgress), ZFrameUGUIUIProgressWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.UGUI.UISliding), ZFrameUGUIUISlidingWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.UGUI.UIText), ZFrameUGUIUITextWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.UGUI.UISelectable), ZFrameUGUIUISelectableWrap.__Register);
				
				translator.DelayWrapLoader(typeof(TMPro.TMP_InputField), TMProTMP_InputFieldWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.UGUI.UIGroup), ZFrameUGUIUIGroupWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.Tween.ZTweener), ZFrameTweenZTweenerWrap.__Register);
				
				translator.DelayWrapLoader(typeof(ZFrame.Tween.BaseTweener), ZFrameTweenBaseTweenerWrap.__Register);
				
				translator.DelayWrapLoader(typeof(CMD5), CMD5Wrap.__Register);
				
				translator.DelayWrapLoader(typeof(RadioWave), RadioWaveWrap.__Register);
				
				
				
			});
		}
		
		
	}
	
}
namespace XLua
{
	public partial class ObjectTranslator
	{
		static XLua.CSObjectWrap.XLua_Gen_Initer_Register__ s_gen_reg_dumb_obj = new XLua.CSObjectWrap.XLua_Gen_Initer_Register__();
		static XLua.CSObjectWrap.XLua_Gen_Initer_Register__ gen_reg_dumb_obj {get{return s_gen_reg_dumb_obj;}}
	}
	
	internal partial class InternalGlobals
    {
	    
	    static InternalGlobals()
		{
		    extensionMethodMap = new Dictionary<Type, IEnumerable<MethodInfo>>()
			{
			    
			};
			
			genTryArrayGetPtr = StaticLuaCallbacks.__tryArrayGet;
            genTryArraySetPtr = StaticLuaCallbacks.__tryArraySet;
		}
	}
}
