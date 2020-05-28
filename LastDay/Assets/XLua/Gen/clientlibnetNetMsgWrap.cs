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
    public class clientlibnetNetMsgWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(clientlib.net.NetMsg);
			Utils.BeginObjectRegister(type, L, translator, 0, 16, 7, 2);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "deserialization", _m_deserialization);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "reset", _m_reset);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "serialization", _m_serialization);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "read", _m_read);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "readU32", _m_readU32);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "readU32s", _m_readU32s);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "readU64s", _m_readU64s);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "readU64", _m_readU64);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "readDouble", _m_readDouble);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "readFloat", _m_readFloat);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "readString", _m_readString);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "writeFuller", _m_writeFuller);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "write", _m_write);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "writeU32", _m_writeU32);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "writeU64", _m_writeU64);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "writeString", _m_writeString);
			
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "readSize", _g_get_readSize);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "writeSize", _g_get_writeSize);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "type", _g_get_type);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "buffer", _g_get_buffer);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "limit", _g_get_limit);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "posession", _g_get_posession);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "msgSize", _g_get_msgSize);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "type", _s_set_type);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "msgSize", _s_set_msgSize);
            
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 7, 0, 0);
			Utils.RegisterFunc(L, Utils.CLS_IDX, "getVer", _m_getVer_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "GetPoolInfo", _m_GetPoolInfo_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Release", _m_Release_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "Get", _m_Get_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "createReadMsg", _m_createReadMsg_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "createMsg", _m_createMsg_xlua_st_);
            
			
            
			
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            return LuaAPI.luaL_error(L, "clientlib.net.NetMsg does not have a constructor!");
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_getVer_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    
                        int __cl_gen_ret = clientlib.net.NetMsg.getVer(  );
                        LuaAPI.xlua_pushinteger(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetPoolInfo_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    
                        string __cl_gen_ret = clientlib.net.NetMsg.GetPoolInfo(  );
                        LuaAPI.lua_pushstring(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Release_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    clientlib.net.NetMsg nm = (clientlib.net.NetMsg)translator.GetObject(L, 1, typeof(clientlib.net.NetMsg));
                    
                    clientlib.net.NetMsg.Release( nm );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Get_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    int size = LuaAPI.xlua_tointeger(L, 1);
                    
                        clientlib.net.NetMsg __cl_gen_ret = clientlib.net.NetMsg.Get( size );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_createReadMsg_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    int size = LuaAPI.xlua_tointeger(L, 1);
                    
                        clientlib.net.NetMsg __cl_gen_ret = clientlib.net.NetMsg.createReadMsg( size );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_createMsg_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 1&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 1)) 
                {
                    int type = LuaAPI.xlua_tointeger(L, 1);
                    
                        clientlib.net.NetMsg __cl_gen_ret = clientlib.net.NetMsg.createMsg( type );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 1)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    int type = LuaAPI.xlua_tointeger(L, 1);
                    int size = LuaAPI.xlua_tointeger(L, 2);
                    
                        clientlib.net.NetMsg __cl_gen_ret = clientlib.net.NetMsg.createMsg( type, size );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to clientlib.net.NetMsg.createMsg!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_deserialization(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                    __cl_gen_to_be_invoked.deserialization(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_reset(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    int type = LuaAPI.xlua_tointeger(L, 2);
                    
                    __cl_gen_to_be_invoked.reset( type );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 1) 
                {
                    
                    __cl_gen_to_be_invoked.reset(  );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to clientlib.net.NetMsg.reset!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_serialization(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    byte sign = (byte)LuaAPI.xlua_tointeger(L, 2);
                    
                    __cl_gen_to_be_invoked.serialization( sign );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_read(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        byte __cl_gen_ret = __cl_gen_to_be_invoked.read(  );
                        LuaAPI.xlua_pushinteger(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_readU32(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        int __cl_gen_ret = __cl_gen_to_be_invoked.readU32(  );
                        LuaAPI.xlua_pushinteger(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_readU32s(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        int[] __cl_gen_ret = __cl_gen_to_be_invoked.readU32s(  );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_readU64s(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        long[] __cl_gen_ret = __cl_gen_to_be_invoked.readU64s(  );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_readU64(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        long __cl_gen_ret = __cl_gen_to_be_invoked.readU64(  );
                        LuaAPI.lua_pushint64(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_readDouble(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        double __cl_gen_ret = __cl_gen_to_be_invoked.readDouble(  );
                        LuaAPI.lua_pushnumber(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_readFloat(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        float __cl_gen_ret = __cl_gen_to_be_invoked.readFloat(  );
                        LuaAPI.lua_pushnumber(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_readString(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    
                        string __cl_gen_ret = __cl_gen_to_be_invoked.readString(  );
                        LuaAPI.lua_pushstring(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_writeFuller(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& translator.Assignable<clientlib.net.INetMsgFuller>(L, 2)) 
                {
                    clientlib.net.INetMsgFuller fuller = (clientlib.net.INetMsgFuller)translator.GetObject(L, 2, typeof(clientlib.net.INetMsgFuller));
                    
                        clientlib.net.INetMsg __cl_gen_ret = __cl_gen_to_be_invoked.writeFuller( fuller );
                        translator.PushAny(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& translator.Assignable<clientlib.net.INetMsgFuller[]>(L, 2)) 
                {
                    clientlib.net.INetMsgFuller[] fuller = (clientlib.net.INetMsgFuller[])translator.GetObject(L, 2, typeof(clientlib.net.INetMsgFuller[]));
                    
                        clientlib.net.INetMsg __cl_gen_ret = __cl_gen_to_be_invoked.writeFuller( fuller );
                        translator.PushAny(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to clientlib.net.NetMsg.writeFuller!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_write(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    byte value = (byte)LuaAPI.xlua_tointeger(L, 2);
                    
                        clientlib.net.INetMsg __cl_gen_ret = __cl_gen_to_be_invoked.write( value );
                        translator.PushAny(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 4&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 4)) 
                {
                    byte[] buffer = LuaAPI.lua_tobytes(L, 2);
                    int offset = LuaAPI.xlua_tointeger(L, 3);
                    int length = LuaAPI.xlua_tointeger(L, 4);
                    
                        clientlib.net.INetMsg __cl_gen_ret = __cl_gen_to_be_invoked.write( buffer, offset, length );
                        translator.PushAny(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to clientlib.net.NetMsg.write!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_writeU32(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    int value = LuaAPI.xlua_tointeger(L, 2);
                    
                        clientlib.net.INetMsg __cl_gen_ret = __cl_gen_to_be_invoked.writeU32( value );
                        translator.PushAny(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_writeU64(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    long value = LuaAPI.lua_toint64(L, 2);
                    
                        clientlib.net.INetMsg __cl_gen_ret = __cl_gen_to_be_invoked.writeU64( value );
                        translator.PushAny(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_writeString(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    string value = LuaIndexTo.ToLuaString(L, 2);
                    
                        clientlib.net.INetMsg __cl_gen_ret = __cl_gen_to_be_invoked.writeString( value );
                        translator.PushAny(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_readSize(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, __cl_gen_to_be_invoked.readSize);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_writeSize(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, __cl_gen_to_be_invoked.writeSize);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_type(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, __cl_gen_to_be_invoked.type);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_buffer(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
                translator.Push(L, __cl_gen_to_be_invoked.buffer);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_limit(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, __cl_gen_to_be_invoked.limit);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_posession(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, __cl_gen_to_be_invoked.posession);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_msgSize(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, __cl_gen_to_be_invoked.msgSize);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_type(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.type = LuaAPI.xlua_tointeger(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_msgSize(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                clientlib.net.NetMsg __cl_gen_to_be_invoked = (clientlib.net.NetMsg)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.msgSize = LuaAPI.xlua_tointeger(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
		
		
		
		
    }
}
