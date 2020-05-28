using System.Collections;
using System.Collections.Generic;
using XLua;
using ILuaState = System.IntPtr;

public class Data2Lua<T> where T : System.IConvertible
{
    protected Data2Lua() { }

    protected T m_Value;

    private static Data2Lua<T> _Data = new Data2Lua<T>();
    public static Data2Lua<T> Get(T value) { _Data.m_Value = value; return _Data; }

    public virtual void Push(ILuaState lua)
    {
        
    }
}

public class Data2Bool : Data2Lua<bool>
{
    public override void Push(ILuaState lua)
    {
        lua.PushBoolean(m_Value);
    }
}

