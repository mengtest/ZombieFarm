using System.Collections;
using System.Collections.Generic;
using System.Threading;
using System.IO;
using System.Net;
using UnityEngine;

namespace ZFrame.Asset
{
    using NetEngine;

    public class AssetDownload : MonoSingleton<AssetDownload>
    {
        public event System.Action<string, long> onDownloaded;
        public string baseUrl;
        public string savePath;

        private HttpRequester[] m_Downloaders;
        private readonly Queue<AsyncLoadingTask> m_Queue = new Queue<AsyncLoadingTask>();

        protected override void Awaking()
        {
            base.Awaking();
            m_Downloaders = new[] {
                new HttpRequester(),
                new HttpRequester(),
                new HttpRequester(),
                new HttpRequester(),
                new HttpRequester(),
            };
        }

        private void Download(HttpRequester dl, AsyncLoadingTask task)
        {
            dl.Download(baseUrl + task.bundleName, savePath + task.bundleName + ".tmp", task);
        }

        private void Update()
        {
            var downloading = false;
            for (int i = 0; i < m_Downloaders.Length; ++i) {
                var dl = m_Downloaders[i];
                if (dl.isDone) {
                    if (dl.total > 0) {
                        var saveFile = dl.rspFile.Substring(0, dl.rspFile.Length - 4);
                        File.Move(dl.rspFile, saveFile);
                        var bundleName = saveFile.Substring(savePath.Length);
                        if (AssetBundleLoader.I) {
                            AssetBundleLoader.I.allAssetBundles.Add(bundleName);
                        }
                        if (onDownloaded != null) onDownloaded.Invoke(bundleName, dl.total);

                        var task = dl.TakeParam() as AsyncLoadingTask;
                        if (task != null) {
                            AssetsMgr.A.Loader.ScheduleTask(task);
                        }

                        dl.Reset();
                    }

                    if (m_Queue.Count == 0) continue;
                    Download(dl, m_Queue.Dequeue());
                }

                downloading = true;
            }

            if (!downloading) enabled = false;
        }

        public void Download(AsyncLoadingTask task)
        {
            for (int i = 0; i < m_Downloaders.Length; ++i) {
                var dl = m_Downloaders[i];
                if (dl.isDone) {
                    Download(dl, task);
                    enabled = true;
                    return;
                }
            }

            m_Queue.Enqueue(task);
        }

        public void StopLoading(string assetPath = null)
        {
            if (assetPath == null) {
                for (int i = 0; i < m_Downloaders.Length; ++i) {
                    var task = m_Downloaders[i].TakeParam() as AsyncLoadingTask;
                    if (task != null) AsyncLoadingTask.Cancel(task);
                }
            } else {
                if (assetPath[assetPath.Length - 1] == '/') {
                    // 停止加载队列中指定名字的资源包
                    string assetBundleName, assetName;
                    AssetLoader.GetAssetpath(assetPath, out assetBundleName, out assetName);
                    for (int i = 0; i < m_Downloaders.Length; ++i) {
                        var task = m_Downloaders[i].param as AsyncLoadingTask;
                        if (task != null && task.bundleName == assetBundleName) {
                            m_Downloaders[i].TakeParam();
                            AsyncLoadingTask.Cancel(task);
                        }
                    }
                } else {
                    // 停止加载队列中属于指定组的资源包
                    assetPath = assetPath.ToLower();
                    for (int i = 0; i < m_Downloaders.Length; ++i) {
                        var task = m_Downloaders[i].param as AsyncLoadingTask;
                        if (task != null) {
                            var group = Path.GetFileName(SystemTools.GetDirPath(task.bundleName));
                            if (group == assetPath) {
                                m_Downloaders[i].TakeParam();
                                AsyncLoadingTask.Cancel(task);
                            }
                        }
                    }
                }
            }
        }

    }
}