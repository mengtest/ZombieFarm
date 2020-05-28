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
    public class ZFrameNetEngineNetworkMgrWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(ZFrame.NetEngine.NetworkMgr);
			Utils.BeginObjectRegister(type, L, translator, 0, 2, 2, 1);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetTcpHandler", _m_GetTcpHandler);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetHttpHandler", _m_GetHttpHandler);
			
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "netMsgPool", _g_get_netMsgPool);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "knownHost", _g_get_knownHost);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "knownHost", _s_set_knownHost);
            
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 1, 1, 0);
			
			
            
			Utils.RegisterFunc(L, Utils.CLS_GETTER_IDX, "Inst", _g_get_Inst);
            
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					ZFrame.NetEngine.NetworkMgr __cl_gen_ret = new ZFrame.NetEngine.NetworkMgr();
					translator.Push(L, __cl_gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception __gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to ZFrame.NetEngine.NetworkMgr constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetTcpHandler(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.NetEngine.NetworkMgr __cl_gen_to_be_invoked = (ZFrame.NetEngine.NetworkMgr)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    string tcpName = LuaIndexTo.ToLuaString(L, 2);
                    
                        ZFrame.NetEngine.TcpClientHandler __cl_gen_ret = __cl_gen_to_be_invoked.GetTcpHandler( tcpName );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetHttpHandler(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.NetEngine.NetworkMgr __cl_gen_to_be_invoked = (ZFrame.NetEngine.NetworkMgr)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    string httpName = LuaIndexTo.ToLuaString(L, 2);
                    
                        ZFrame.NetEngine.HttpHandler __cl_gen_ret = __cl_gen_to_be_invoked.GetHttpHandler( httpName );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_netMsgPool(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.NetEngine.NetworkMgr __cl_gen_to_be_invoked = (ZFrame.NetEngine.NetworkMgr)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushstring(L, __cl_gen_to_be_invoked.netMsgPool);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_Inst(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			    translator.Push(L, ZFrame.NetEngine.NetworkMgr.Inst);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_knownHost(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.NetEngine.NetworkMgr __cl_gen_to_be_invoked = (ZFrame.NetEngine.NetworkMgr)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushstring(L, __cl_gen_to_be_invoked.knownHost);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_knownHost(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.NetEngine.NetworkMgr __cl_gen_to_be_invoked = (ZFrame.NetEngine.NetworkMgr)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.knownHost = LuaIndexTo.ToLuaString(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
		
		
		
		
    }
}
