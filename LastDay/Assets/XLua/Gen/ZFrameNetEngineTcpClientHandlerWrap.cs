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
    public class ZFrameNetEngineTcpClientHandlerWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(ZFrame.NetEngine.TcpClientHandler);
			Utils.BeginObjectRegister(type, L, translator, 0, 5, 6, 4);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "AddExtHandler", _m_AddExtHandler);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "DelExtHandler", _m_DelExtHandler);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Connect", _m_Connect);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Disconnect", _m_Disconnect);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Send", _m_Send);
			
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "IsConnected", _g_get_IsConnected);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "Error", _g_get_Error);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "autoRecieve", _g_get_autoRecieve);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "doRecieving", _g_get_doRecieving);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "onConnected", _g_get_onConnected);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "onDisconnected", _g_get_onDisconnected);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "autoRecieve", _s_set_autoRecieve);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "doRecieving", _s_set_doRecieving);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "onConnected", _s_set_onConnected);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "onDisconnected", _s_set_onDisconnected);
            
			
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
					
					ZFrame.NetEngine.TcpClientHandler __cl_gen_ret = new ZFrame.NetEngine.TcpClientHandler();
					translator.Push(L, __cl_gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception __gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to ZFrame.NetEngine.TcpClientHandler constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_AddExtHandler(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.NetEngine.TcpClientHandler __cl_gen_to_be_invoked = (ZFrame.NetEngine.TcpClientHandler)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    ZFrame.NetEngine.NetMsgHandler handler = (ZFrame.NetEngine.NetMsgHandler)translator.GetObject(L, 3, typeof(ZFrame.NetEngine.NetMsgHandler));
                    
                        ZFrame.NetEngine.NetMsgHandler __cl_gen_ret = __cl_gen_to_be_invoked.AddExtHandler( name, handler );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DelExtHandler(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.NetEngine.TcpClientHandler __cl_gen_to_be_invoked = (ZFrame.NetEngine.TcpClientHandler)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    
                    __cl_gen_to_be_invoked.DelExtHandler( name );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Connect(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.NetEngine.TcpClientHandler __cl_gen_to_be_invoked = (ZFrame.NetEngine.TcpClientHandler)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    string host = LuaIndexTo.ToLuaString(L, 2);
                    int port = LuaAPI.xlua_tointeger(L, 3);
                    float timeout = (float)LuaAPI.lua_tonumber(L, 4);
                    
                    __cl_gen_to_be_invoked.Connect( host, port, timeout );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Disconnect(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.NetEngine.TcpClientHandler __cl_gen_to_be_invoked = (ZFrame.NetEngine.TcpClientHandler)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    __cl_gen_to_be_invoked.Disconnect(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Send(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                ZFrame.NetEngine.TcpClientHandler __cl_gen_to_be_invoked = (ZFrame.NetEngine.TcpClientHandler)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    clientlib.net.INetMsg nm = (clientlib.net.INetMsg)translator.GetObject(L, 2, typeof(clientlib.net.INetMsg));
                    
                    __cl_gen_to_be_invoked.Send( nm );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_IsConnected(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.NetEngine.TcpClientHandler __cl_gen_to_be_invoked = (ZFrame.NetEngine.TcpClientHandler)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushboolean(L, __cl_gen_to_be_invoked.IsConnected);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_Error(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.NetEngine.TcpClientHandler __cl_gen_to_be_invoked = (ZFrame.NetEngine.TcpClientHandler)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushstring(L, __cl_gen_to_be_invoked.Error);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_autoRecieve(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.NetEngine.TcpClientHandler __cl_gen_to_be_invoked = (ZFrame.NetEngine.TcpClientHandler)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushboolean(L, __cl_gen_to_be_invoked.autoRecieve);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_doRecieving(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.NetEngine.TcpClientHandler __cl_gen_to_be_invoked = (ZFrame.NetEngine.TcpClientHandler)translator.FastGetCSObj(L, 1);
                translator.Push(L, __cl_gen_to_be_invoked.doRecieving);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_onConnected(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.NetEngine.TcpClientHandler __cl_gen_to_be_invoked = (ZFrame.NetEngine.TcpClientHandler)translator.FastGetCSObj(L, 1);
                translator.Push(L, __cl_gen_to_be_invoked.onConnected);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_onDisconnected(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.NetEngine.TcpClientHandler __cl_gen_to_be_invoked = (ZFrame.NetEngine.TcpClientHandler)translator.FastGetCSObj(L, 1);
                translator.Push(L, __cl_gen_to_be_invoked.onDisconnected);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_autoRecieve(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.NetEngine.TcpClientHandler __cl_gen_to_be_invoked = (ZFrame.NetEngine.TcpClientHandler)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.autoRecieve = LuaAPI.lua_toboolean(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_doRecieving(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.NetEngine.TcpClientHandler __cl_gen_to_be_invoked = (ZFrame.NetEngine.TcpClientHandler)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.doRecieving = translator.GetDelegate<ZFrame.NetEngine.TcpClientHandler.TcpClientMsgEvent>(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_onConnected(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.NetEngine.TcpClientHandler __cl_gen_to_be_invoked = (ZFrame.NetEngine.TcpClientHandler)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.onConnected = translator.GetDelegate<ZFrame.NetEngine.TcpClientHandler.TcpClientEvent>(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_onDisconnected(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                ZFrame.NetEngine.TcpClientHandler __cl_gen_to_be_invoked = (ZFrame.NetEngine.TcpClientHandler)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.onDisconnected = translator.GetDelegate<ZFrame.NetEngine.TcpClientHandler.TcpClientEvent>(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
		
		
		
		
    }
}
