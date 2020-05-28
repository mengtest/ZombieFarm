﻿#if USE_UNI_LUA
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
    public class UnityEngineMaterialWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(UnityEngine.Material);
			Utils.BeginObjectRegister(type, L, translator, 0, 40, 11, 10);
			
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetTexturePropertyNames", _m_GetTexturePropertyNames);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetTexturePropertyNameIDs", _m_GetTexturePropertyNameIDs);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "HasProperty", _m_HasProperty);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "EnableKeyword", _m_EnableKeyword);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "DisableKeyword", _m_DisableKeyword);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "IsKeywordEnabled", _m_IsKeywordEnabled);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetShaderPassEnabled", _m_SetShaderPassEnabled);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetShaderPassEnabled", _m_GetShaderPassEnabled);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetPassName", _m_GetPassName);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "FindPass", _m_FindPass);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetOverrideTag", _m_SetOverrideTag);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetTag", _m_GetTag);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "Lerp", _m_Lerp);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetPass", _m_SetPass);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "CopyPropertiesFromMaterial", _m_CopyPropertiesFromMaterial);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetFloat", _m_SetFloat);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetInt", _m_SetInt);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetColor", _m_SetColor);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetVector", _m_SetVector);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetMatrix", _m_SetMatrix);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetTexture", _m_SetTexture);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetBuffer", _m_SetBuffer);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetFloatArray", _m_SetFloatArray);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetColorArray", _m_SetColorArray);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetVectorArray", _m_SetVectorArray);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetMatrixArray", _m_SetMatrixArray);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetFloat", _m_GetFloat);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetInt", _m_GetInt);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetColor", _m_GetColor);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetVector", _m_GetVector);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetMatrix", _m_GetMatrix);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetTexture", _m_GetTexture);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetFloatArray", _m_GetFloatArray);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetColorArray", _m_GetColorArray);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetVectorArray", _m_GetVectorArray);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetMatrixArray", _m_GetMatrixArray);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetTextureOffset", _m_SetTextureOffset);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "SetTextureScale", _m_SetTextureScale);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetTextureOffset", _m_GetTextureOffset);
			Utils.RegisterFunc(L, Utils.METHOD_IDX, "GetTextureScale", _m_GetTextureScale);
			
			
			Utils.RegisterFunc(L, Utils.GETTER_IDX, "shader", _g_get_shader);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "color", _g_get_color);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "mainTexture", _g_get_mainTexture);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "mainTextureOffset", _g_get_mainTextureOffset);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "mainTextureScale", _g_get_mainTextureScale);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "renderQueue", _g_get_renderQueue);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "globalIlluminationFlags", _g_get_globalIlluminationFlags);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "doubleSidedGI", _g_get_doubleSidedGI);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "enableInstancing", _g_get_enableInstancing);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "passCount", _g_get_passCount);
            Utils.RegisterFunc(L, Utils.GETTER_IDX, "shaderKeywords", _g_get_shaderKeywords);
            
			Utils.RegisterFunc(L, Utils.SETTER_IDX, "shader", _s_set_shader);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "color", _s_set_color);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "mainTexture", _s_set_mainTexture);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "mainTextureOffset", _s_set_mainTextureOffset);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "mainTextureScale", _s_set_mainTextureScale);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "renderQueue", _s_set_renderQueue);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "globalIlluminationFlags", _s_set_globalIlluminationFlags);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "doubleSidedGI", _s_set_doubleSidedGI);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "enableInstancing", _s_set_enableInstancing);
            Utils.RegisterFunc(L, Utils.SETTER_IDX, "shaderKeywords", _s_set_shaderKeywords);
            
			
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
				if(LuaAPI.lua_gettop(L) == 2 && translator.Assignable<UnityEngine.Shader>(L, 2))
				{
					UnityEngine.Shader shader = (UnityEngine.Shader)translator.GetObject(L, 2, typeof(UnityEngine.Shader));
					
					UnityEngine.Material __cl_gen_ret = new UnityEngine.Material(shader);
					translator.Push(L, __cl_gen_ret);
                    
					return 1;
				}
				if(LuaAPI.lua_gettop(L) == 2 && translator.Assignable<UnityEngine.Material>(L, 2))
				{
					UnityEngine.Material source = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
					
					UnityEngine.Material __cl_gen_ret = new UnityEngine.Material(source);
					translator.Push(L, __cl_gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception __gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetTexturePropertyNames(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 1) 
                {
                    
                        string[] __cl_gen_ret = __cl_gen_to_be_invoked.GetTexturePropertyNames(  );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& translator.Assignable<System.Collections.Generic.List<string>>(L, 2)) 
                {
                    System.Collections.Generic.List<string> outNames = (System.Collections.Generic.List<string>)translator.GetObject(L, 2, typeof(System.Collections.Generic.List<string>));
                    
                    __cl_gen_to_be_invoked.GetTexturePropertyNames( outNames );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.GetTexturePropertyNames!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetTexturePropertyNameIDs(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 1) 
                {
                    
                        int[] __cl_gen_ret = __cl_gen_to_be_invoked.GetTexturePropertyNameIDs(  );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& translator.Assignable<System.Collections.Generic.List<int>>(L, 2)) 
                {
                    System.Collections.Generic.List<int> outNames = (System.Collections.Generic.List<int>)translator.GetObject(L, 2, typeof(System.Collections.Generic.List<int>));
                    
                    __cl_gen_to_be_invoked.GetTexturePropertyNameIDs( outNames );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.GetTexturePropertyNameIDs!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_HasProperty(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    
                        bool __cl_gen_ret = __cl_gen_to_be_invoked.HasProperty( nameID );
                        LuaAPI.lua_pushboolean(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    
                        bool __cl_gen_ret = __cl_gen_to_be_invoked.HasProperty( name );
                        LuaAPI.lua_pushboolean(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.HasProperty!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_EnableKeyword(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    string keyword = LuaIndexTo.ToLuaString(L, 2);
                    
                    __cl_gen_to_be_invoked.EnableKeyword( keyword );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_DisableKeyword(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    string keyword = LuaIndexTo.ToLuaString(L, 2);
                    
                    __cl_gen_to_be_invoked.DisableKeyword( keyword );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_IsKeywordEnabled(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    string keyword = LuaIndexTo.ToLuaString(L, 2);
                    
                        bool __cl_gen_ret = __cl_gen_to_be_invoked.IsKeywordEnabled( keyword );
                        LuaAPI.lua_pushboolean(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetShaderPassEnabled(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    string passName = LuaIndexTo.ToLuaString(L, 2);
                    bool enabled = LuaAPI.lua_toboolean(L, 3);
                    
                    __cl_gen_to_be_invoked.SetShaderPassEnabled( passName, enabled );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetShaderPassEnabled(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    string passName = LuaIndexTo.ToLuaString(L, 2);
                    
                        bool __cl_gen_ret = __cl_gen_to_be_invoked.GetShaderPassEnabled( passName );
                        LuaAPI.lua_pushboolean(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetPassName(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    int pass = LuaAPI.xlua_tointeger(L, 2);
                    
                        string __cl_gen_ret = __cl_gen_to_be_invoked.GetPassName( pass );
                        LuaAPI.lua_pushstring(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_FindPass(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    string passName = LuaIndexTo.ToLuaString(L, 2);
                    
                        int __cl_gen_ret = __cl_gen_to_be_invoked.FindPass( passName );
                        LuaAPI.xlua_pushinteger(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetOverrideTag(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    string tag = LuaIndexTo.ToLuaString(L, 2);
                    string val = LuaIndexTo.ToLuaString(L, 3);
                    
                    __cl_gen_to_be_invoked.SetOverrideTag( tag, val );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetTag(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 3)) 
                {
                    string tag = LuaIndexTo.ToLuaString(L, 2);
                    bool searchFallbacks = LuaAPI.lua_toboolean(L, 3);
                    
                        string __cl_gen_ret = __cl_gen_to_be_invoked.GetTag( tag, searchFallbacks );
                        LuaAPI.lua_pushstring(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 4&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& LuaTypes.LUA_TBOOLEAN == LuaAPI.lua_type(L, 3)&& (LuaAPI.lua_isnil(L, 4) || LuaAPI.lua_type(L, 4) == LuaTypes.LUA_TSTRING)) 
                {
                    string tag = LuaIndexTo.ToLuaString(L, 2);
                    bool searchFallbacks = LuaAPI.lua_toboolean(L, 3);
                    string defaultValue = LuaIndexTo.ToLuaString(L, 4);
                    
                        string __cl_gen_ret = __cl_gen_to_be_invoked.GetTag( tag, searchFallbacks, defaultValue );
                        LuaAPI.lua_pushstring(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.GetTag!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_Lerp(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Material start = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    UnityEngine.Material end = (UnityEngine.Material)translator.GetObject(L, 3, typeof(UnityEngine.Material));
                    float t = (float)LuaAPI.lua_tonumber(L, 4);
                    
                    __cl_gen_to_be_invoked.Lerp( start, end, t );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetPass(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    int pass = LuaAPI.xlua_tointeger(L, 2);
                    
                        bool __cl_gen_ret = __cl_gen_to_be_invoked.SetPass( pass );
                        LuaAPI.lua_pushboolean(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_CopyPropertiesFromMaterial(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
                
                {
                    UnityEngine.Material mat = (UnityEngine.Material)translator.GetObject(L, 2, typeof(UnityEngine.Material));
                    
                    __cl_gen_to_be_invoked.CopyPropertiesFromMaterial( mat );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetFloat(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    float value = (float)LuaAPI.lua_tonumber(L, 3);
                    
                    __cl_gen_to_be_invoked.SetFloat( nameID, value );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    float value = (float)LuaAPI.lua_tonumber(L, 3);
                    
                    __cl_gen_to_be_invoked.SetFloat( name, value );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.SetFloat!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetInt(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    int value = LuaAPI.xlua_tointeger(L, 3);
                    
                    __cl_gen_to_be_invoked.SetInt( nameID, value );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    int value = LuaAPI.xlua_tointeger(L, 3);
                    
                    __cl_gen_to_be_invoked.SetInt( name, value );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.SetInt!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetColor(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& UnityEngine_Color.IsColor(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    UnityEngine.Color value = UnityEngine_Color.ToColor(L, 3);
                    
                    __cl_gen_to_be_invoked.SetColor( nameID, value );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& UnityEngine_Color.IsColor(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    UnityEngine.Color value = UnityEngine_Color.ToColor(L, 3);
                    
                    __cl_gen_to_be_invoked.SetColor( name, value );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.SetColor!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetVector(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& UnityEngine_Vector4.IsVector4(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    UnityEngine.Vector4 value = UnityEngine_Vector4.ToVector4(L, 3);
                    
                    __cl_gen_to_be_invoked.SetVector( nameID, value );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& UnityEngine_Vector4.IsVector4(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    UnityEngine.Vector4 value = UnityEngine_Vector4.ToVector4(L, 3);
                    
                    __cl_gen_to_be_invoked.SetVector( name, value );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.SetVector!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetMatrix(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<UnityEngine.Matrix4x4>(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    UnityEngine.Matrix4x4 value;translator.Get(L, 3, out value);
                    
                    __cl_gen_to_be_invoked.SetMatrix( nameID, value );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& translator.Assignable<UnityEngine.Matrix4x4>(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    UnityEngine.Matrix4x4 value;translator.Get(L, 3, out value);
                    
                    __cl_gen_to_be_invoked.SetMatrix( name, value );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.SetMatrix!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetTexture(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<UnityEngine.Texture>(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    UnityEngine.Texture value = (UnityEngine.Texture)translator.GetObject(L, 3, typeof(UnityEngine.Texture));
                    
                    __cl_gen_to_be_invoked.SetTexture( nameID, value );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& translator.Assignable<UnityEngine.Texture>(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    UnityEngine.Texture value = (UnityEngine.Texture)translator.GetObject(L, 3, typeof(UnityEngine.Texture));
                    
                    __cl_gen_to_be_invoked.SetTexture( name, value );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.SetTexture!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetBuffer(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<UnityEngine.ComputeBuffer>(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    UnityEngine.ComputeBuffer value = (UnityEngine.ComputeBuffer)translator.GetObject(L, 3, typeof(UnityEngine.ComputeBuffer));
                    
                    __cl_gen_to_be_invoked.SetBuffer( nameID, value );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& translator.Assignable<UnityEngine.ComputeBuffer>(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    UnityEngine.ComputeBuffer value = (UnityEngine.ComputeBuffer)translator.GetObject(L, 3, typeof(UnityEngine.ComputeBuffer));
                    
                    __cl_gen_to_be_invoked.SetBuffer( name, value );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.SetBuffer!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetFloatArray(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<System.Collections.Generic.List<float>>(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    System.Collections.Generic.List<float> values = (System.Collections.Generic.List<float>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<float>));
                    
                    __cl_gen_to_be_invoked.SetFloatArray( nameID, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<float[]>(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    float[] values = (float[])translator.GetObject(L, 3, typeof(float[]));
                    
                    __cl_gen_to_be_invoked.SetFloatArray( nameID, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& translator.Assignable<System.Collections.Generic.List<float>>(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    System.Collections.Generic.List<float> values = (System.Collections.Generic.List<float>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<float>));
                    
                    __cl_gen_to_be_invoked.SetFloatArray( name, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& translator.Assignable<float[]>(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    float[] values = (float[])translator.GetObject(L, 3, typeof(float[]));
                    
                    __cl_gen_to_be_invoked.SetFloatArray( name, values );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.SetFloatArray!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetColorArray(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<System.Collections.Generic.List<UnityEngine.Color>>(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    System.Collections.Generic.List<UnityEngine.Color> values = (System.Collections.Generic.List<UnityEngine.Color>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<UnityEngine.Color>));
                    
                    __cl_gen_to_be_invoked.SetColorArray( nameID, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<UnityEngine.Color[]>(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    UnityEngine.Color[] values = (UnityEngine.Color[])translator.GetObject(L, 3, typeof(UnityEngine.Color[]));
                    
                    __cl_gen_to_be_invoked.SetColorArray( nameID, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& translator.Assignable<System.Collections.Generic.List<UnityEngine.Color>>(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    System.Collections.Generic.List<UnityEngine.Color> values = (System.Collections.Generic.List<UnityEngine.Color>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<UnityEngine.Color>));
                    
                    __cl_gen_to_be_invoked.SetColorArray( name, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& translator.Assignable<UnityEngine.Color[]>(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    UnityEngine.Color[] values = (UnityEngine.Color[])translator.GetObject(L, 3, typeof(UnityEngine.Color[]));
                    
                    __cl_gen_to_be_invoked.SetColorArray( name, values );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.SetColorArray!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetVectorArray(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<System.Collections.Generic.List<UnityEngine.Vector4>>(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    System.Collections.Generic.List<UnityEngine.Vector4> values = (System.Collections.Generic.List<UnityEngine.Vector4>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<UnityEngine.Vector4>));
                    
                    __cl_gen_to_be_invoked.SetVectorArray( nameID, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<UnityEngine.Vector4[]>(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    UnityEngine.Vector4[] values = (UnityEngine.Vector4[])translator.GetObject(L, 3, typeof(UnityEngine.Vector4[]));
                    
                    __cl_gen_to_be_invoked.SetVectorArray( nameID, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& translator.Assignable<System.Collections.Generic.List<UnityEngine.Vector4>>(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    System.Collections.Generic.List<UnityEngine.Vector4> values = (System.Collections.Generic.List<UnityEngine.Vector4>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<UnityEngine.Vector4>));
                    
                    __cl_gen_to_be_invoked.SetVectorArray( name, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& translator.Assignable<UnityEngine.Vector4[]>(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    UnityEngine.Vector4[] values = (UnityEngine.Vector4[])translator.GetObject(L, 3, typeof(UnityEngine.Vector4[]));
                    
                    __cl_gen_to_be_invoked.SetVectorArray( name, values );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.SetVectorArray!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetMatrixArray(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<System.Collections.Generic.List<UnityEngine.Matrix4x4>>(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    System.Collections.Generic.List<UnityEngine.Matrix4x4> values = (System.Collections.Generic.List<UnityEngine.Matrix4x4>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<UnityEngine.Matrix4x4>));
                    
                    __cl_gen_to_be_invoked.SetMatrixArray( nameID, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<UnityEngine.Matrix4x4[]>(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    UnityEngine.Matrix4x4[] values = (UnityEngine.Matrix4x4[])translator.GetObject(L, 3, typeof(UnityEngine.Matrix4x4[]));
                    
                    __cl_gen_to_be_invoked.SetMatrixArray( nameID, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& translator.Assignable<System.Collections.Generic.List<UnityEngine.Matrix4x4>>(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    System.Collections.Generic.List<UnityEngine.Matrix4x4> values = (System.Collections.Generic.List<UnityEngine.Matrix4x4>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<UnityEngine.Matrix4x4>));
                    
                    __cl_gen_to_be_invoked.SetMatrixArray( name, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& translator.Assignable<UnityEngine.Matrix4x4[]>(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    UnityEngine.Matrix4x4[] values = (UnityEngine.Matrix4x4[])translator.GetObject(L, 3, typeof(UnityEngine.Matrix4x4[]));
                    
                    __cl_gen_to_be_invoked.SetMatrixArray( name, values );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.SetMatrixArray!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetFloat(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    
                        float __cl_gen_ret = __cl_gen_to_be_invoked.GetFloat( nameID );
                        LuaAPI.lua_pushnumber(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    
                        float __cl_gen_ret = __cl_gen_to_be_invoked.GetFloat( name );
                        LuaAPI.lua_pushnumber(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.GetFloat!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetInt(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    
                        int __cl_gen_ret = __cl_gen_to_be_invoked.GetInt( nameID );
                        LuaAPI.xlua_pushinteger(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    
                        int __cl_gen_ret = __cl_gen_to_be_invoked.GetInt( name );
                        LuaAPI.xlua_pushinteger(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.GetInt!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetColor(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    
                        UnityEngine.Color __cl_gen_ret = __cl_gen_to_be_invoked.GetColor( nameID );
                        UnityEngine_Color.PushX(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    
                        UnityEngine.Color __cl_gen_ret = __cl_gen_to_be_invoked.GetColor( name );
                        UnityEngine_Color.PushX(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.GetColor!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetVector(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    
                        UnityEngine.Vector4 __cl_gen_ret = __cl_gen_to_be_invoked.GetVector( nameID );
                        UnityEngine_Vector4.PushX(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    
                        UnityEngine.Vector4 __cl_gen_ret = __cl_gen_to_be_invoked.GetVector( name );
                        UnityEngine_Vector4.PushX(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.GetVector!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetMatrix(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    
                        UnityEngine.Matrix4x4 __cl_gen_ret = __cl_gen_to_be_invoked.GetMatrix( nameID );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    
                        UnityEngine.Matrix4x4 __cl_gen_ret = __cl_gen_to_be_invoked.GetMatrix( name );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.GetMatrix!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetTexture(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    
                        UnityEngine.Texture __cl_gen_ret = __cl_gen_to_be_invoked.GetTexture( nameID );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    
                        UnityEngine.Texture __cl_gen_ret = __cl_gen_to_be_invoked.GetTexture( name );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.GetTexture!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetFloatArray(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    
                        float[] __cl_gen_ret = __cl_gen_to_be_invoked.GetFloatArray( nameID );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    
                        float[] __cl_gen_ret = __cl_gen_to_be_invoked.GetFloatArray( name );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<System.Collections.Generic.List<float>>(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    System.Collections.Generic.List<float> values = (System.Collections.Generic.List<float>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<float>));
                    
                    __cl_gen_to_be_invoked.GetFloatArray( nameID, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& translator.Assignable<System.Collections.Generic.List<float>>(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    System.Collections.Generic.List<float> values = (System.Collections.Generic.List<float>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<float>));
                    
                    __cl_gen_to_be_invoked.GetFloatArray( name, values );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.GetFloatArray!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetColorArray(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    
                        UnityEngine.Color[] __cl_gen_ret = __cl_gen_to_be_invoked.GetColorArray( nameID );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    
                        UnityEngine.Color[] __cl_gen_ret = __cl_gen_to_be_invoked.GetColorArray( name );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<System.Collections.Generic.List<UnityEngine.Color>>(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    System.Collections.Generic.List<UnityEngine.Color> values = (System.Collections.Generic.List<UnityEngine.Color>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<UnityEngine.Color>));
                    
                    __cl_gen_to_be_invoked.GetColorArray( nameID, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& translator.Assignable<System.Collections.Generic.List<UnityEngine.Color>>(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    System.Collections.Generic.List<UnityEngine.Color> values = (System.Collections.Generic.List<UnityEngine.Color>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<UnityEngine.Color>));
                    
                    __cl_gen_to_be_invoked.GetColorArray( name, values );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.GetColorArray!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetVectorArray(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    
                        UnityEngine.Vector4[] __cl_gen_ret = __cl_gen_to_be_invoked.GetVectorArray( nameID );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    
                        UnityEngine.Vector4[] __cl_gen_ret = __cl_gen_to_be_invoked.GetVectorArray( name );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<System.Collections.Generic.List<UnityEngine.Vector4>>(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    System.Collections.Generic.List<UnityEngine.Vector4> values = (System.Collections.Generic.List<UnityEngine.Vector4>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<UnityEngine.Vector4>));
                    
                    __cl_gen_to_be_invoked.GetVectorArray( nameID, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& translator.Assignable<System.Collections.Generic.List<UnityEngine.Vector4>>(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    System.Collections.Generic.List<UnityEngine.Vector4> values = (System.Collections.Generic.List<UnityEngine.Vector4>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<UnityEngine.Vector4>));
                    
                    __cl_gen_to_be_invoked.GetVectorArray( name, values );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.GetVectorArray!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetMatrixArray(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    
                        UnityEngine.Matrix4x4[] __cl_gen_ret = __cl_gen_to_be_invoked.GetMatrixArray( nameID );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    
                        UnityEngine.Matrix4x4[] __cl_gen_ret = __cl_gen_to_be_invoked.GetMatrixArray( name );
                        translator.Push(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& translator.Assignable<System.Collections.Generic.List<UnityEngine.Matrix4x4>>(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    System.Collections.Generic.List<UnityEngine.Matrix4x4> values = (System.Collections.Generic.List<UnityEngine.Matrix4x4>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<UnityEngine.Matrix4x4>));
                    
                    __cl_gen_to_be_invoked.GetMatrixArray( nameID, values );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& translator.Assignable<System.Collections.Generic.List<UnityEngine.Matrix4x4>>(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    System.Collections.Generic.List<UnityEngine.Matrix4x4> values = (System.Collections.Generic.List<UnityEngine.Matrix4x4>)translator.GetObject(L, 3, typeof(System.Collections.Generic.List<UnityEngine.Matrix4x4>));
                    
                    __cl_gen_to_be_invoked.GetMatrixArray( name, values );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.GetMatrixArray!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetTextureOffset(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& UnityEngine_Vector2.IsVector2(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    UnityEngine.Vector2 value = UnityEngine_Vector2.ToVector2(L, 3);
                    
                    __cl_gen_to_be_invoked.SetTextureOffset( nameID, value );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& UnityEngine_Vector2.IsVector2(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    UnityEngine.Vector2 value = UnityEngine_Vector2.ToVector2(L, 3);
                    
                    __cl_gen_to_be_invoked.SetTextureOffset( name, value );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.SetTextureOffset!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetTextureScale(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 3&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)&& UnityEngine_Vector2.IsVector2(L, 3)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    UnityEngine.Vector2 value = UnityEngine_Vector2.ToVector2(L, 3);
                    
                    __cl_gen_to_be_invoked.SetTextureScale( nameID, value );
                    
                    
                    
                    return 0;
                }
                if(__gen_param_count == 3&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)&& UnityEngine_Vector2.IsVector2(L, 3)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    UnityEngine.Vector2 value = UnityEngine_Vector2.ToVector2(L, 3);
                    
                    __cl_gen_to_be_invoked.SetTextureScale( name, value );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.SetTextureScale!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetTextureOffset(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    
                        UnityEngine.Vector2 __cl_gen_ret = __cl_gen_to_be_invoked.GetTextureOffset( nameID );
                        UnityEngine_Vector2.PushX(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    
                        UnityEngine.Vector2 __cl_gen_ret = __cl_gen_to_be_invoked.GetTextureOffset( name );
                        UnityEngine_Vector2.PushX(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.GetTextureOffset!");
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_GetTextureScale(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
            
            
			    int __gen_param_count = LuaAPI.lua_gettop(L);
            
                if(__gen_param_count == 2&& LuaTypes.LUA_TNUMBER == LuaAPI.lua_type(L, 2)) 
                {
                    int nameID = LuaAPI.xlua_tointeger(L, 2);
                    
                        UnityEngine.Vector2 __cl_gen_ret = __cl_gen_to_be_invoked.GetTextureScale( nameID );
                        UnityEngine_Vector2.PushX(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                if(__gen_param_count == 2&& (LuaAPI.lua_isnil(L, 2) || LuaAPI.lua_type(L, 2) == LuaTypes.LUA_TSTRING)) 
                {
                    string name = LuaIndexTo.ToLuaString(L, 2);
                    
                        UnityEngine.Vector2 __cl_gen_ret = __cl_gen_to_be_invoked.GetTextureScale( name );
                        UnityEngine_Vector2.PushX(L, __cl_gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            
            return LuaAPI.luaL_error(L, "invalid arguments to UnityEngine.Material.GetTextureScale!");
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_shader(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                translator.Push(L, __cl_gen_to_be_invoked.shader);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_color(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                UnityEngine_Color.PushX(L, __cl_gen_to_be_invoked.color);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_mainTexture(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                translator.Push(L, __cl_gen_to_be_invoked.mainTexture);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_mainTextureOffset(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                UnityEngine_Vector2.PushX(L, __cl_gen_to_be_invoked.mainTextureOffset);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_mainTextureScale(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                UnityEngine_Vector2.PushX(L, __cl_gen_to_be_invoked.mainTextureScale);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_renderQueue(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, __cl_gen_to_be_invoked.renderQueue);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_globalIlluminationFlags(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                System_Enum.PushX(L, __cl_gen_to_be_invoked.globalIlluminationFlags);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_doubleSidedGI(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushboolean(L, __cl_gen_to_be_invoked.doubleSidedGI);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_enableInstancing(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                LuaAPI.lua_pushboolean(L, __cl_gen_to_be_invoked.enableInstancing);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_passCount(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                LuaAPI.xlua_pushinteger(L, __cl_gen_to_be_invoked.passCount);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_shaderKeywords(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                translator.Push(L, __cl_gen_to_be_invoked.shaderKeywords);
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 1;
        }
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_shader(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.shader = (UnityEngine.Shader)translator.GetObject(L, 2, typeof(UnityEngine.Shader));
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_color(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                UnityEngine.Color __cl_gen_value = UnityEngine_Color.ToColor(L, 2);
				__cl_gen_to_be_invoked.color = __cl_gen_value;
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_mainTexture(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.mainTexture = (UnityEngine.Texture)translator.GetObject(L, 2, typeof(UnityEngine.Texture));
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_mainTextureOffset(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                UnityEngine.Vector2 __cl_gen_value = UnityEngine_Vector2.ToVector2(L, 2);
				__cl_gen_to_be_invoked.mainTextureOffset = __cl_gen_value;
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_mainTextureScale(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                UnityEngine.Vector2 __cl_gen_value = UnityEngine_Vector2.ToVector2(L, 2);
				__cl_gen_to_be_invoked.mainTextureScale = __cl_gen_value;
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_renderQueue(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.renderQueue = LuaAPI.xlua_tointeger(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_globalIlluminationFlags(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                UnityEngine.MaterialGlobalIlluminationFlags __cl_gen_value = (UnityEngine.MaterialGlobalIlluminationFlags)System_Enum.ToEnumValue(L, 2, typeof(UnityEngine.MaterialGlobalIlluminationFlags));
				__cl_gen_to_be_invoked.globalIlluminationFlags = __cl_gen_value;
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_doubleSidedGI(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.doubleSidedGI = LuaAPI.lua_toboolean(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_enableInstancing(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.enableInstancing = LuaAPI.lua_toboolean(L, 2);
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _s_set_shaderKeywords(RealStatePtr L)
        {
		    try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			
                UnityEngine.Material __cl_gen_to_be_invoked = (UnityEngine.Material)translator.FastGetCSObj(L, 1);
                __cl_gen_to_be_invoked.shaderKeywords = (string[])translator.GetObject(L, 2, typeof(string[]));
            
            } catch(System.Exception __gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + __gen_e);
            }
            return 0;
        }
        
		
		
		
		
    }
}
