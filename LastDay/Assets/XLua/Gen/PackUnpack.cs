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


namespace XLua
{
    public static partial class CopyByValue
    {
        
		
		public static void UnPack(ObjectTranslator translator, RealStatePtr L, int idx, out UnityEngine.Ray val)
		{
		    val = new UnityEngine.Ray();
            int top = LuaAPI.lua_gettop(L);
			
			if (Utils.LoadField(L, idx, "origin"))
            {
			    
				var origin = val.origin;
				translator.Get(L, top + 1, out origin);
				val.origin = origin;
				
            }
            LuaAPI.lua_pop(L, 1);
			
			if (Utils.LoadField(L, idx, "direction"))
            {
			    
				var direction = val.direction;
				translator.Get(L, top + 1, out direction);
				val.direction = direction;
				
            }
            LuaAPI.lua_pop(L, 1);
			
		}
		
        public static bool Pack(IntPtr buff, int offset, UnityEngine.Ray field)
        {
            
            if(!Pack(buff, offset, field.origin))
            {
                return false;
            }
            
            if(!Pack(buff, offset + 12, field.direction))
            {
                return false;
            }
            
            return true;
        }
        public static bool UnPack(IntPtr buff, int offset, out UnityEngine.Ray field)
        {
            field = default(UnityEngine.Ray);
            
            var origin = field.origin;
            if(!UnPack(buff, offset, out origin))
            {
                return false;
            }
            field.origin = origin;
            
            var direction = field.direction;
            if(!UnPack(buff, offset + 12, out direction))
            {
                return false;
            }
            field.direction = direction;
            
            return true;
        }
        
		
        public static bool Pack(IntPtr buff, int offset, UnityEngine.Vector3 field)
        {
            
            if(!LuaAPI.xlua_pack_float3(buff, offset, field.x, field.y, field.z))
            {
                return false;
            }
            
            return true;
        }
        public static bool UnPack(IntPtr buff, int offset, out UnityEngine.Vector3 field)
        {
            field = default(UnityEngine.Vector3);
            
            float x = default(float);
            float y = default(float);
            float z = default(float);
            
            if(!LuaAPI.xlua_unpack_float3(buff, offset, out x, out y, out z))
            {
                return false;
            }
            field.x = x;
            field.y = y;
            field.z = z;
            
            
            return true;
        }
        
		
		public static void UnPack(ObjectTranslator translator, RealStatePtr L, int idx, out UnityEngine.Ray2D val)
		{
		    val = new UnityEngine.Ray2D();
            int top = LuaAPI.lua_gettop(L);
			
			if (Utils.LoadField(L, idx, "origin"))
            {
			    
				var origin = val.origin;
				translator.Get(L, top + 1, out origin);
				val.origin = origin;
				
            }
            LuaAPI.lua_pop(L, 1);
			
			if (Utils.LoadField(L, idx, "direction"))
            {
			    
				var direction = val.direction;
				translator.Get(L, top + 1, out direction);
				val.direction = direction;
				
            }
            LuaAPI.lua_pop(L, 1);
			
		}
		
        public static bool Pack(IntPtr buff, int offset, UnityEngine.Ray2D field)
        {
            
            if(!Pack(buff, offset, field.origin))
            {
                return false;
            }
            
            if(!Pack(buff, offset + 8, field.direction))
            {
                return false;
            }
            
            return true;
        }
        public static bool UnPack(IntPtr buff, int offset, out UnityEngine.Ray2D field)
        {
            field = default(UnityEngine.Ray2D);
            
            var origin = field.origin;
            if(!UnPack(buff, offset, out origin))
            {
                return false;
            }
            field.origin = origin;
            
            var direction = field.direction;
            if(!UnPack(buff, offset + 8, out direction))
            {
                return false;
            }
            field.direction = direction;
            
            return true;
        }
        
		
        public static bool Pack(IntPtr buff, int offset, UnityEngine.Vector2 field)
        {
            
            if(!LuaAPI.xlua_pack_float2(buff, offset, field.x, field.y))
            {
                return false;
            }
            
            return true;
        }
        public static bool UnPack(IntPtr buff, int offset, out UnityEngine.Vector2 field)
        {
            field = default(UnityEngine.Vector2);
            
            float x = default(float);
            float y = default(float);
            
            if(!LuaAPI.xlua_unpack_float2(buff, offset, out x, out y))
            {
                return false;
            }
            field.x = x;
            field.y = y;
            
            
            return true;
        }
        
    }
}