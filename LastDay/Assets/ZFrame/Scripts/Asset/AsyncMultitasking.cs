using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ZFrame.Asset
{
	public class AsyncMultitasking
	{
		private static Pool<AsyncMultitasking> m_Pool = new Pool<AsyncMultitasking>(
			null,
			mt => {
				if (mt.m_Loaded != null) {
					var cb = AssetLoadedCallback.New(mt.m_Loaded, string.Empty, null, mt.m_Param);
					AsyncLoadingTask.LoadedCallbacks.Enqueue(cb);
				}
				mt.m_Tasks.Clear();
				mt.m_Loaded = null;
				mt.m_Param = null;
			});

		public static AsyncMultitasking Get(DelegateObjectLoaded onLoaded, object param)
		{
			var mt = m_Pool.Get();
			mt.m_Loaded = onLoaded;
			mt.m_Param = param;
			return mt;
		}

		public AsyncMultitasking()
		{
			m_OnAssetLoaded = (a, o, p) => {
				for (int i = 0; i < m_Tasks.Count; ++i) {
					if (m_Tasks[i] == a) {
						m_Tasks.RemoveAt(i);
						break;
					}
				}

				if (m_Tasks.Count == 0) {
					m_Pool.Release(this);
				}
			};
			
			m_OnTaskCancel = task => {
				if (m_Loaded != null) {
					// 被取消，不会执行回调
					m_Loaded = null;
					m_Pool.Release(this);
				}
			};
		}

		private readonly DelegateObjectLoaded m_OnAssetLoaded;
		private readonly System.Action<AsyncLoadingTask> m_OnTaskCancel;
		
		private List<string> m_Tasks = new List<string>();
		private DelegateObjectLoaded m_Loaded;
		private object m_Param;
		
		public void AddTask(AsyncLoadingTask task)
		{
			if (string.IsNullOrEmpty(task.assetPath)) {
				return;
			}

			for (int i = 0; i < m_Tasks.Count; ++i) {
				if (m_Tasks[i] == task.assetPath) return;
			}

			task.assetLoaded += m_OnAssetLoaded;
			task.onCancel += m_OnTaskCancel;
			m_Tasks.Add(task.assetPath);
		}

		public void ConfirmTask()
		{
			if (m_Tasks.Count == 0) {
				m_Pool.Release(this);
			}
		}
	}
}

