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
    public class ZFrameUGUIUILabelWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(ZFrame.UGUI.UILabel);
			Utils.BeginObjectRegister(type, L, translator, 0, 4, 6, 4);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetFormatArgs", _m_SetFormatArgs);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "UpdateNumber", _m_UpdateNumber);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Tween", _m_Tween);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "onTextChanged", _e_onTextChanged);
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "omited", _g_get_omited);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "localized", _g_get_localized);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "text", _g_get_text);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "rawText", _g_get_rawText);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "omit", _g_get_omit);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "textFormat", _g_get_textFormat);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "localized", _s_set_localized);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "text", _s_set_text);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "omit", _s_set_omit);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "textFormat", _s_set_textFormat);
            
			
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
					
					ZFrame.UGUI.UILabel __cl_gen_ret = new ZFrame.UGUI.UILabel();
					translator.Push(L, __cl_gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception __gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to ZFrame.UGUI.UILabel constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetFormatArgs(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.UGUI.UILabel __cl_gen_to_be_invoked = (ZFrame.UGUI.UILabel)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    object[] args = translator.GetParams<object>(L, 2);
                    
                    __cl_gen_to_be_invoked.SetFormatArgs( args );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_UpdateNumber(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.UGUI.UILabel __cl_gen_to_be_invoked = (ZFrame.UGUI.UILabel)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    float value = (float)LuaAPI.lua_tonumber(L, 2);
                    
                    __cl_gen_to_be_invoked.UpdateNumber( value );
                    
                    
                    
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
            
            
                ZFrame.UGUI.UILabel __cl_gen_to_be_invoked = (ZFrame.UGUI.UILabel)translator.FastGetCSObj(L, 1);
            
            
                
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
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_omited(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UILabel __cl_gen_to_be_invoked = (ZFrame.UGUI.UILabel)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushboolean(L, __cl_gen_to_be_invoked.omited);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_localized(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UILabel __cl_gen_to_be_invoked = (ZFrame.UGUI.UILabel)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushboolean(L, __cl_gen_to_be_invoked.localized);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_text(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UILabel __cl_gen_to_be_invoked = (ZFrame.UGUI.UILabel)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushstring(L, __cl_gen_to_be_invoked.text);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_rawText(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UILabel __cl_gen_to_be_invoked = (ZFrame.UGUI.UILabel)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushstring(L, __cl_gen_to_be_invoked.rawText);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_omit(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UILabel __cl_gen_to_be_invoked = (ZFrame.UGUI.UILabel)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushboolean(L, __cl_gen_to_be_invoked.omit);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_textFormat(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UILabel __cl_gen_to_be_invoked = (ZFrame.UGUI.UILabel)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushstring(L, __cl_gen_to_be_invoked.textFormat);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_localized(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UILabel __cl_gen_to_be_invoked = (ZFrame.UGUI.UILabel)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.localized = LuaAPI.lua_toboolean(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_text(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UILabel __cl_gen_to_be_invoked = (ZFrame.UGUI.UILabel)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.text = LuaIndexTo.ToLuaString(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_omit(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UILabel __cl_gen_to_be_invoked = (ZFrame.UGUI.UILabel)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.omit = LuaAPI.lua_toboolean(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_textFormat(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UILabel __cl_gen_to_be_invoked = (ZFrame.UGUI.UILabel)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.textFormat = LuaIndexTo.ToLuaString(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
		
		
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _e_onTextChanged(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			    int __gen_param_count = LuaAPI.lua_gettop(L);
			ZFrame.UGUI.UILabel __cl_gen_to_be_invoked = (ZFrame.UGUI.UILabel)translator.FastGetCSObj(L, 1);
                ZFrame.UGUI.TextChanged __gen_delegate = translator.GetDelegate<ZFrame.UGUI.TextChanged>(L, 3);
                if (__gen_delegate == null) {
                    return LuaAPI.luaL_error(L, "#3 need ZFrame.UGUI.TextChanged!");
                }
				
				if (__gen_param_count == 3)
				{
					
					if (LuaAPI.xlua_is_eq_str(L, 2, "+")) {
						__cl_gen_to_be_invoked.onTextChanged += __gen_delegate;
						return 0;
					} 
					
					
					if (LuaAPI.xlua_is_eq_str(L, 2, "-")) {
						__cl_gen_to_be_invoked.onTextChanged -= __gen_delegate;
						return 0;
					} 
					
				}
			} catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
			LuaAPI.luaL_error(L, "invalid arguments to ZFrame.UGUI.UILabel.onTextChanged!");
            return 0;
        }
        
		
		
    }
}
