using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World 
{
    public class ConfigLib<T> : object where T : IConfig
    {
        private System.Func<int, T> m_Loader;
        private System.Action<T, IEnumerable<T>> m_Unloader;
        private int m_Capacity;
        private List<T> m_Datas;

        public ConfigLib(int capacity, System.Func<int, T> loader, System.Action<T, IEnumerable<T>> unloader = null)
        {
            m_Capacity = capacity;
            m_Loader = loader;
            m_Unloader = unloader;
            m_Datas = new List<T>();
        }

        public T Get(int id)
        {
            T ret = default(T);
            for (int i = 0; i < m_Datas.Count; ++i) {
                var data = m_Datas[i];
                if (data.id == id) {
                    m_Datas.RemoveAt(i);
                    m_Datas.Add(data);
                    ret = data;
                    break;
                }
            }

            if (ret == null) {
                ret = m_Loader.Invoke(id);
                if (ret != null) {
                    m_Datas.Add(ret);
                    if (m_Datas.Count > m_Capacity) {
                        var Data = m_Datas[0];
                        m_Datas.RemoveAt(0);

                        if (m_Unloader != null) {
                            m_Unloader.Invoke(Data, m_Datas);
                        }
                    }
                }
            }

            return ret;
        }
    }
}
