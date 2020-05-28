using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using TinyJSON;
#if ULUA
using LuaInterface;
#else
using XLua;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif
using ILuaState = System.IntPtr;
using Object = UnityEngine.Object;

public static class LuaIndexPush
{
    public static void GetGlobal(this ILuaState self, string key1, object key2)
    {
        self.GetGlobal(key1);
        if (self.IsTable(-1)) {
            self.PushAnyObject(key2);
            self.GetTable(-2);
            self.Replace(-2);
        }
    }

    public static void GetGlobal(this ILuaState self, string key1, object key2, object key3)
    {
        self.GetGlobal(key1, key2);
        if (self.IsTable(-1)) {
            self.PushAnyObject(key3);
            self.GetTable(-2);
            self.Replace(-2);
        }
    }

    public static void Get(this ILuaState self, string gKey, params object[] Keys)
    {
        self.GetGlobal(gKey);
        for (int i = 0; i < Keys.Length; ++i) {
            if (!self.IsTable(-1)) return;
            self.PushAnyObject(Keys[i]);
            self.GetTable(-2);
            self.Replace(-2);
        }
    }

    public static T Get<T>(this ILuaState self, string gKey, params object[] Keys)
    {
        self.Get(gKey, Keys);
        T ret;
        self.ToTranslator().Get(self, -1, out ret);
        self.Pop(1);
        return ret;
    }

    private static string GetErrorFunc(int skip)
    {
        StackFrame sf = null;
        string file;
        var st = new StackTrace(skip, true);
        int pos = 0;

        do {
            sf = st.GetFrame(pos++);
            file = sf.GetFileName();
            file = System.IO.Path.GetFileName(file);
        } while (!file.OrdinalEndsWith("Wrap.cs"));

        if (file != null) {
            int index1 = file.LastIndexOf('\\');
            int index2 = file.LastIndexOf("Wrap.");
            string className = file.Substring(index1 + 1, index2 - index1 - 1);
            return string.Format("{0}.{1}", className, sf.GetMethod().Name);
        }

        return null;
    }

    public static void ChkArgsCount(this ILuaState self, int count)
    {
        int c = self.GetTop();

        if (c != count) {
            string str = string.Format("no overload for method '{0}' takes '{1}' arguments", GetErrorFunc(1), c);
            self.L_Error(str);
        }
    }

    /// <summary>
    /// luanet: 值类型发生变化后，要重新映射
    /// </summary>
    public static void SetValueType(this ILuaState self, int index, System.ValueType value)
    {
        var translator = self.ToTranslator();
        translator.Update(self, index, value);
    }

    /// <summary>
    /// 扩展具体类型
    /// </summary>

    public static void PushX(this ILuaState self, Variant json)
    {
        if (json is ProxyObject) {
            self.NewTable();
            foreach (var kv in (ProxyObject)json) {
                self.SetDict(kv.Key, kv.Value);
            }
        } else if (json is ProxyArray) {
            var array = (ProxyArray)json;
            self.CreateTable(array.Count, 0);
            for (int i = 0; i < array.Count; ++i) {
                self.SetValue(I2V.PushJson, -1, i + 1, array[i]);
            }
        } else if (json is ProxyNumber) {
            var value = (ProxyNumber)json;
            if (value.value is ulong) {
                self.PushULong((ulong)value.value);
            } else if (value.value is long) {
                self.PushLong((long)value.value);
            } else {
                self.PushX((double)value);
            }
        } else if (json is ProxyString) {
            var value = (ProxyString)json;
            self.PushX((string)value);
        } else if (json is ProxyBoolean) {
            var value = (ProxyBoolean)json;
            self.PushX((bool)value);
        } else if (json is ProxyUserdata) {
            self.PushAnyObject(json.ToType(typeof(object), null));
        }
    }

    public static void PushX(this ILuaState self, Object value)
    {
        if (value) {
            self.PushLightUserData(value);
        } else {
            self.PushNil();
        }
    }

    public static void PushByType<T>(this ILuaState self, T value)
    {
        self.ToTranslator().PushByType(self, value);
    }

    public static void PushAnyObject(this ILuaState self, object value)
    {
        if (value == null) {
            self.PushNil();
            return;
        }

        var joValue = value as Variant;
        if (joValue != null) {
            self.PushX(joValue);
            return;
        }

        var en = value as System.Enum;
        if (en != null) {
            self.PushX(en);
            return;
        }

        // 根据类型全名
        string typeName = value.GetType().FullName;
        switch (typeName) {
            case UnityEngine_Vector2.CLASS: self.PushX((Vector2)value); return;
            case UnityEngine_Vector3.CLASS: self.PushX((Vector3)value); return;
            case UnityEngine_Quaternion.CLASS : self.PushX((Quaternion)value); return;
            case UnityEngine_Color.CLASS: self.PushX((Color)value); return;
            case UnityEngine_Bounds.CLASS: self.PushX((Bounds)value); return;
            default: break;
        }

        self.ToTranslator().PushAny(self, value);
    }
}
