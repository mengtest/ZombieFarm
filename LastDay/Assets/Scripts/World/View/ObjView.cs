using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{

    public abstract class ObjView : MonoBehavior, IObjView
    {
        public virtual bool alwaysView { get { return CompareTag(TAGS.AlwaysView); } }

        public bool IsNull() { return this == null; }
        
        public virtual bool IsVisible()
        {
            return !IsNull();
        }

        public abstract IObj obj { get; }

        public abstract void Subscribe(IObj o);

        public abstract void Unsubscribe();

        public virtual void UnloadView() { }

        public virtual void Destruct(float delay)
        {
            Destroy(gameObject, delay);
        }
        
        private bool m_UpdateDebug;
        public bool updateDebug { get { return m_UpdateDebug; } }
        public virtual void ShowDebug(bool value)
        {
            m_UpdateDebug = value;
        }

        public virtual void OnStatusChange(int value)
        {
           
        }
    }
}
