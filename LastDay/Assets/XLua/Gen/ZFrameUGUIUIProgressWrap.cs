#if USE_UNI_LUA
using LuaAPI = UniLua.Lua;
using RealStatePtr = UniLua.ILuaState;
using LuaCSFunction = UniLua.CSharpFunctionDelegate;
#else
using LuaAPI = XLua.LuaDLL.Lua;
using RealStatePtr = System.IntPtr;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif

using XLua;
using System.Collections.Generic;


namespace XLua.CSObjectWrap
{
    using Utils = XLua.Utils;
    public class ZFrameUGUIUIProgressWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(ZFrame.UGUI.UIProgress);
			Utils.BeginObjectRegister(type, L, translator, 0, 3, 11, 8);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetLayerColor", _m_SetLayerColor);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "InitValue", _m_InitValue);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Tween", _m_Tween);
			
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "direction", _g_get_direction);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "onValueChanged", _g_get_onValueChanged);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "value", _g_get_value);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "rectTransform", _g_get_rectTransform);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "minValue", _g_get_minValue);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "maxValue", _g_get_maxValue);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "maxLayer", _g_get_maxLayer);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_PrevBar", _g_get_m_PrevBar);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_FadeBar", _g_get_m_FadeBar);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_CurrBar", _g_get_m_CurrBar);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "m_Thumb", _g_get_m_Thumb);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "direction", _s_set_direction);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "onValueChanged", _s_set_onValueChanged);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "value", _s_set_value);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "maxLayer", _s_set_maxLayer);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_PrevBar", _s_set_m_PrevBar);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_FadeBar", _s_set_m_FadeBar);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_CurrBar", _s_set_m_CurrBar);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "m_Thumb", _s_set_m_Thumb);
            
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 1, 0, 0);
			
			
            
			
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					ZFrame.UGUI.UIProgress __cl_gen_ret = new ZFrame.UGUI.UIProgress();
					translator.Push(L, __cl_gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception __gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to ZFrame.UGUI.UIProgress constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetLayerColor(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    int layer = LuaAPI.xlua_tointeger(L, 2);
                    UnityEngine.Color color = UnityEngine_Color.ToColor(L, 3);
                    
                    __cl_gen_to_be_invoked.SetLayerColor( layer, color );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_InitValue(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    float input = (float)LuaAPI.lua_tonumber(L, 2);
                    
                    __cl_gen_to_be_invoked.InitValue( input );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Tween(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    float to = (float)LuaAPI.lua_tonumber(L, 2);
                    float duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.Tween( to, duration );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 4&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    float from = (float)LuaAPI.lua_tonumber(L, 2);
                    float to = (float)LuaAPI.lua_tonumber(L, 3);
                    float duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.Tween( from, to, duration );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 4&& translator.Assignable<object>(L, 2)&& translator.Assignable<object>(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    object from = translator.GetObject(L, 2, typeof(object));
                    object to = translator.GetObject(L, 3, typeof(object));
                    float duration = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.Tween( from, to, duration );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to ZFrame.UGUI.UIProgress.Tween!");
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_direction(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                System_Enum.PushX(L, __cl_gen_to_be_invoked.direction);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_onValueChanged(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                translator.Push(L, __cl_gen_to_be_invoked.onValueChanged);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_value(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushnumber(L, __cl_gen_to_be_invoked.value);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_rectTransform(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                translator.Push(L, __cl_gen_to_be_invoked.rectTransform);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_minValue(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushnumber(L, __cl_gen_to_be_invoked.minValue);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_maxValue(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushnumber(L, __cl_gen_to_be_invoked.maxValue);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_maxLayer(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, __cl_gen_to_be_invoked.maxLayer);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_PrevBar(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                translator.Push(L, __cl_gen_to_be_invoked.m_PrevBar);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_FadeBar(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                translator.Push(L, __cl_gen_to_be_invoked.m_FadeBar);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_CurrBar(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                translator.Push(L, __cl_gen_to_be_invoked.m_CurrBar);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_m_Thumb(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                translator.Push(L, __cl_gen_to_be_invoked.m_Thumb);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_direction(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                UnityEngine.UI.Slider.Direction __cl_gen_value = (UnityEngine.UI.Slider.Direction)System_Enum.ToEnumValue(L, 2, typeof(UnityEngine.UI.Slider.Direction));
				__cl_gen_to_be_invoked.direction = __cl_gen_value;
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_onValueChanged(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.onValueChanged = (UnityEngine.UI.Slider.SliderEvent)translator.GetObject(L, 2, typeof(UnityEngine.UI.Slider.SliderEvent));
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_value(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.value = (float)LuaAPI.lua_tonumber(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_maxLayer(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.maxLayer = LuaAPI.xlua_tointeger(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_PrevBar(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.m_PrevBar = (UnityEngine.UI.Image)translator.GetObject(L, 2, typeof(UnityEngine.UI.Image));
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_FadeBar(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.m_FadeBar = (UnityEngine.UI.Image)translator.GetObject(L, 2, typeof(UnityEngine.UI.Image));
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_CurrBar(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.m_CurrBar = (UnityEngine.UI.Image)translator.GetObject(L, 2, typeof(UnityEngine.UI.Image));
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_m_Thumb(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UIProgress __cl_gen_to_be_invoked = (ZFrame.UGUI.UIProgress)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.m_Thumb = (UnityEngine.RectTransform)translator.GetObject(L, 2, typeof(UnityEngine.RectTransform));
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
		
		
		
		
    }
}
