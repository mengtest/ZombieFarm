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
    public class ZFrameTweenZTweenerWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(ZFrame.Tween.ZTweener);
			Utils.BeginObjectRegister(type, L, translator, 0, 19, 6, 2);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "IsTweening", _m_IsTweening);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetTag", _m_SetTag);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetUpdate", _m_SetUpdate);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "StartFrom", _m_StartFrom);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "EndAt", _m_EndAt);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "DelayFor", _m_DelayFor);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "AppendDelay", _m_AppendDelay);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "PrependDelay", _m_PrependDelay);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Insert", _m_Insert);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Join", _m_Join);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "LoopFor", _m_LoopFor);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "EaseBy", _m_EaseBy);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "StartWith", _m_StartWith);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "UpdateWith", _m_UpdateWith);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "CompleteWith", _m_CompleteWith);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Reset", _m_Reset);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Play", _m_Play);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Stop", _m_Stop);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "WaitForCompletion", _m_WaitForCompletion);
			
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "target", _g_get_target);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "tag", _g_get_tag);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "elapsed", _g_get_elapsed);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "lifetime", _g_get_lifetime);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "timeScale", _g_get_timeScale);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "tween", _g_get_tween);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "timeScale", _s_set_timeScale);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "tween", _s_set_tween);
            
			
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
				if(LuaAPI.lua_gettop(L) == 2 && translator.Assignable<DG.Tweening.Tween>(L, 2))
				{
					DG.Tweening.Tween tw = (DG.Tweening.Tween)translator.GetObject(L, 2, typeof(DG.Tweening.Tween));
					
					ZFrame.Tween.ZTweener __cl_gen_ret = new ZFrame.Tween.ZTweener(tw);
					translator.Push(L, __cl_gen_ret);
                    
					return 1;
				}
				if(LuaAPI.lua_gettop(L) == 3 && translator.Assignable<DG.Tweening.Tween>(L, 2) && translator.Assignable<object>(L, 3))
				{
					DG.Tweening.Tween tw = (DG.Tweening.Tween)translator.GetObject(L, 2, typeof(DG.Tweening.Tween));
					object target = translator.GetObject(L, 3, typeof(object));
					
					ZFrame.Tween.ZTweener __cl_gen_ret = new ZFrame.Tween.ZTweener(tw, target);
					translator.Push(L, __cl_gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception __gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to ZFrame.Tween.ZTweener constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_IsTweening(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        bool __cl_gen_ret = __cl_gen_to_be_invoked.IsTweening(  );
                        LuaAPI.lua_pushboolean(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetTag(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    object tag = translator.GetObject(L, 2, typeof(object));
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.SetTag( tag );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetUpdate(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    ZFrame.Tween.UpdateType updateType = (ZFrame.Tween.UpdateType)System_Enum.ToEnumValue(L, 2, typeof(ZFrame.Tween.UpdateType));
                    bool ignoreTimeScale = LuaAPI.lua_toboolean(L, 3);
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.SetUpdate( updateType, ignoreTimeScale );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_StartFrom(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    object from = translator.GetObject(L, 2, typeof(object));
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.StartFrom( from );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_EndAt(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    object at = translator.GetObject(L, 2, typeof(object));
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.EndAt( at );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DelayFor(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    float time = (float)LuaAPI.lua_tonumber(L, 2);
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.DelayFor( time );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_AppendDelay(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    float time = (float)LuaAPI.lua_tonumber(L, 2);
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.AppendDelay( time );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_PrependDelay(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    float time = (float)LuaAPI.lua_tonumber(L, 2);
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.PrependDelay( time );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Insert(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    float pos = (float)LuaAPI.lua_tonumber(L, 2);
                    ZFrame.Tween.ZTweener tw = (ZFrame.Tween.ZTweener)translator.GetObject(L, 3, typeof(ZFrame.Tween.ZTweener));
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.Insert( pos, tw );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Join(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    ZFrame.Tween.ZTweener tw = (ZFrame.Tween.ZTweener)translator.GetObject(L, 2, typeof(ZFrame.Tween.ZTweener));
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.Join( tw );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_LoopFor(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    int loops = LuaAPI.xlua_tointeger(L, 2);
                    ZFrame.Tween.LoopType loopType = (ZFrame.Tween.LoopType)System_Enum.ToEnumValue(L, 3, typeof(ZFrame.Tween.LoopType));
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.LoopFor( loops, loopType );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_EaseBy(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    ZFrame.Tween.Ease ease = (ZFrame.Tween.Ease)System_Enum.ToEnumValue(L, 2, typeof(ZFrame.Tween.Ease));
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.EaseBy( ease );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_StartWith(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    ZFrame.Tween.CallbackOnUpdate onStart = translator.GetDelegate<ZFrame.Tween.CallbackOnUpdate>(L, 2);
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.StartWith( onStart );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_UpdateWith(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    ZFrame.Tween.CallbackOnUpdate onUpdate = translator.GetDelegate<ZFrame.Tween.CallbackOnUpdate>(L, 2);
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.UpdateWith( onUpdate );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CompleteWith(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    ZFrame.Tween.CallbackOnComplete onComplete = translator.GetDelegate<ZFrame.Tween.CallbackOnComplete>(L, 2);
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.CompleteWith( onComplete );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Reset(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.Reset(  );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Play(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    bool forward = LuaAPI.lua_toboolean(L, 2);
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.Play( forward );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Stop(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 2)) 
                {
                    bool complete = LuaAPI.lua_toboolean(L, 2);
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.Stop( complete );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 1) 
                {
                    
                        ZFrame.Tween.ZTweener __cl_gen_ret = __cl_gen_to_be_invoked.Stop(  );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to ZFrame.Tween.ZTweener.Stop!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_WaitForCompletion(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        UnityEngine.YieldInstruction __cl_gen_ret = __cl_gen_to_be_invoked.WaitForCompletion(  );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_target(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
                translator.PushAny(L, __cl_gen_to_be_invoked.target);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_tag(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
                translator.PushAny(L, __cl_gen_to_be_invoked.tag);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_elapsed(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushnumber(L, __cl_gen_to_be_invoked.elapsed);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_lifetime(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushnumber(L, __cl_gen_to_be_invoked.lifetime);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_timeScale(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushnumber(L, __cl_gen_to_be_invoked.timeScale);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_tween(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
                translator.Push(L, __cl_gen_to_be_invoked.tween);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_timeScale(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.timeScale = (float)LuaAPI.lua_tonumber(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_tween(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.Tween.ZTweener __cl_gen_to_be_invoked = (ZFrame.Tween.ZTweener)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.tween = (DG.Tweening.Tween)translator.GetObject(L, 2, typeof(DG.Tweening.Tween));
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
		
		
		
		
    }
}
