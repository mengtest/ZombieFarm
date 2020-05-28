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
    public class CMD5Wrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(CMD5);
			Utils.BeginObjectRegister(type, L, translator, 0, 0, 0, 0);
			
			
			
			
			
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 8, 0, 0);
			Utils.RegisterFunc(L, Utils.CLS_IDX, "MD5File", _m_MD5File_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "MD5String", _m_MD5String_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "MD5Data", _m_MD5Data_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "MD5Stream", _m_MD5Stream_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "HashFile", _m_HashFile_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "HashData", _m_HashData_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ByteArrayToHexString", _m_ByteArrayToHexString_xlua_st_);
            
			
            
			
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					CMD5 __cl_gen_ret = new CMD5();
					translator.Push(L, __cl_gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception __gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to CMD5 constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_MD5File_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string fileName = LuaIndexTo.ToLuaString(L, 1);
                    
                        string __cl_gen_ret = CMD5.MD5File( fileName );
                        LuaAPI.lua_pushstring(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_MD5String_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string str = LuaIndexTo.ToLuaString(L, 1);
                    
                        string __cl_gen_ret = CMD5.MD5String( str );
                        LuaAPI.lua_pushstring(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_MD5Data_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    byte[] data = LuaAPI.lua_tobytes(L, 1);
                    
                        string __cl_gen_ret = CMD5.MD5Data( data );
                        LuaAPI.lua_pushstring(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_MD5Stream_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    System.IO.Stream stream = (System.IO.Stream)translator.GetObject(L, 1, typeof(System.IO.Stream));
                    
                        string __cl_gen_ret = CMD5.MD5Stream( stream );
                        LuaAPI.lua_pushstring(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_HashFile_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string fileName = LuaIndexTo.ToLuaString(L, 1);
                    string algName = LuaIndexTo.ToLuaString(L, 2);
                    
                        string __cl_gen_ret = CMD5.HashFile( fileName, algName );
                        LuaAPI.lua_pushstring(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_HashData_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& translator.Assignable<System.IO.Stream>(L, 1)&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    System.IO.Stream stream = (System.IO.Stream)translator.GetObject(L, 1, typeof(System.IO.Stream));
                    string algName = LuaIndexTo.ToLuaString(L, 2);
                    
                        byte[] __cl_gen_ret = CMD5.HashData( stream, algName );
                        LuaAPI.lua_pushstring(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& (LuaAPI.lua_isnil(L, 1) || LuaAPI.lua_type(L, 1) == LuaTypes.LUA_TSTRING)&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    byte[] data = LuaAPI.lua_tobytes(L, 1);
                    string algName = LuaIndexTo.ToLuaString(L, 2);
                    
                        byte[] __cl_gen_ret = CMD5.HashData( data, algName );
                        LuaAPI.lua_pushstring(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to CMD5.HashData!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ByteArrayToHexString_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    byte[] nbytes = LuaAPI.lua_tobytes(L, 1);
                    
                        string __cl_gen_ret = CMD5.ByteArrayToHexString( nbytes );
                        LuaAPI.lua_pushstring(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        
        
        
        
        
		
		
		
		
    }
}
