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
    public class ZFrameUGUIUISpriteWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(ZFrame.UGUI.UISprite);
			Utils.BeginObjectRegister(type, L, translator, 0, 4, 4, 4);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetSprite", _m_SetSprite);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetNativeSize", _m_SetNativeSize);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Tween", _m_Tween);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "IsRaycastLocationValid", _m_IsRaycastLocationValid);
			
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "atlas", _g_get_atlas);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "atlasName", _g_get_atlasName);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "spriteName", _g_get_spriteName);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "grayscale", _g_get_grayscale);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "atlas", _s_set_atlas);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "atlasName", _s_set_atlasName);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "spriteName", _s_set_spriteName);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "grayscale", _s_set_grayscale);
            
			
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
					
					ZFrame.UGUI.UISprite __cl_gen_ret = new ZFrame.UGUI.UISprite();
					translator.Push(L, __cl_gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception __gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to ZFrame.UGUI.UISprite constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetSprite(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.UGUI.UISprite __cl_gen_to_be_invoked = (ZFrame.UGUI.UISprite)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string path = LuaIndexTo.ToLuaString(L, 2);
                    
                    __cl_gen_to_be_invoked.SetSprite( path );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 3)) 
                {
                    string path = LuaIndexTo.ToLuaString(L, 2);
                    bool warnIfMissing = LuaAPI.lua_toboolean(L, 3);
                    
                    __cl_gen_to_be_invoked.SetSprite( path, warnIfMissing );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to ZFrame.UGUI.UISprite.SetSprite!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetNativeSize(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.UGUI.UISprite __cl_gen_to_be_invoked = (ZFrame.UGUI.UISprite)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    __cl_gen_to_be_invoked.SetNativeSize(  );
                    
                    
                    
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
            
            
                ZFrame.UGUI.UISprite __cl_gen_to_be_invoked = (ZFrame.UGUI.UISprite)translator.FastGetCSObj(L, 1);
            
            
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
                if(__gen_param_count == 3&& UnityEngine_Color.IsColor(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    UnityEngine.Color to = UnityEngine_Color.ToColor(L, 2);
                    float duration = (float)LuaAPI.lua_tonumber(L, 3);
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.Tween( to, duration );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 4&& UnityEngine_Color.IsColor(L, 2)&& UnityEngine_Color.IsColor(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    UnityEngine.Color from = UnityEngine_Color.ToColor(L, 2);
                    UnityEngine.Color to = UnityEngine_Color.ToColor(L, 3);
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
            
            return LuaAPI.luaL_error(L, "invalid arguments to ZFrame.UGUI.UISprite.Tween!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_IsRaycastLocationValid(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.UGUI.UISprite __cl_gen_to_be_invoked = (ZFrame.UGUI.UISprite)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Vector2 screenPoint = UnityEngine_Vector2.ToVector2(L, 2);
                    UnityEngine.Camera eventCamera = (UnityEngine.Camera)translator.GetObject(L, 3, typeof(UnityEngine.Camera));
                    
                        bool __cl_gen_ret = __cl_gen_to_be_invoked.IsRaycastLocationValid( screenPoint, eventCamera );
                        LuaAPI.lua_pushboolean(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_atlas(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UISprite __cl_gen_to_be_invoked = (ZFrame.UGUI.UISprite)translator.FastGetCSObj(L, 1);
                translator.Push(L, __cl_gen_to_be_invoked.atlas);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_atlasName(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UISprite __cl_gen_to_be_invoked = (ZFrame.UGUI.UISprite)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushstring(L, __cl_gen_to_be_invoked.atlasName);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_spriteName(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UISprite __cl_gen_to_be_invoked = (ZFrame.UGUI.UISprite)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushstring(L, __cl_gen_to_be_invoked.spriteName);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_grayscale(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UISprite __cl_gen_to_be_invoked = (ZFrame.UGUI.UISprite)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushboolean(L, __cl_gen_to_be_invoked.grayscale);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_atlas(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UISprite __cl_gen_to_be_invoked = (ZFrame.UGUI.UISprite)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.atlas = (UnityEngine.U2D.SpriteAtlas)translator.GetObject(L, 2, typeof(UnityEngine.U2D.SpriteAtlas));
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_atlasName(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UISprite __cl_gen_to_be_invoked = (ZFrame.UGUI.UISprite)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.atlasName = LuaIndexTo.ToLuaString(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_spriteName(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UISprite __cl_gen_to_be_invoked = (ZFrame.UGUI.UISprite)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.spriteName = LuaIndexTo.ToLuaString(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_grayscale(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.UGUI.UISprite __cl_gen_to_be_invoked = (ZFrame.UGUI.UISprite)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.grayscale = LuaAPI.lua_toboolean(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
		
		
		
		
    }
}
