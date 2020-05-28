using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Net;

namespace ZFrame.NetEngine
{
    public delegate void DelegateHttpResponse(string tag, WWW resp, bool isDone, string error);
    public delegate void DelegateHttpDownload(string url, uint current, uint total, bool isDone, string error);

    public class HttpHandler : MonoBehaviour
    {
        public DelegateHttpResponse onHttpResp;
        public DelegateHttpDownload onHttpDL;
        private HttpRequester m_Http;

        private void OnApplicationQuit()
        {
            if (m_Http != null) {
                m_Http.Reset();
            }
        }

        private HttpRequester GetHttp()
        {
            if (m_Http == null) m_Http = new HttpRequester();
            return m_Http;
        }

        private void HandleHttpResp(WWW www, string tag)
        {
            if (onHttpResp != null) {
                var isDone = www.isDone;
                if (isDone && www.error == null) {
                    onHttpResp.Invoke(tag, www, isDone, null);
                } else {
                    onHttpResp.Invoke(tag, www, isDone, www.error);
                }
            }
        }

        private IEnumerator CoroHttpGet(string tag, string uri, string param, float timeout)
        {
            float time = Time.realtimeSinceStartup + timeout;
            if (!string.IsNullOrEmpty(param)) {
                uri = uri + "?" + param;
            }

            NetworkMgr.Log("WWW Get: {0}", uri);
            using (WWW www = new WWW(uri)) {
                while (www.error == null && !www.isDone) {
                    if (time < Time.realtimeSinceStartup) {
                        break;
                    }
                    yield return null;
                }

                HandleHttpResp(www, tag);
            }
        }

        private IEnumerator CoroHttpPost(string tag, string uri, byte[] postData, Dictionary<string, string> headers, float timeout)
        {
            float time = Time.realtimeSinceStartup + timeout;

            NetworkMgr.Log("WWW Post: {0}\n{1}", uri, System.Text.Encoding.UTF8.GetString(postData));

            var www = headers != null ? new WWW(uri, postData, headers) : new WWW(uri, postData);
            using (www) {
                while (www.error == null && !www.isDone) {
                    if (time < Time.realtimeSinceStartup) {
                        break;
                    }
                    yield return null;
                }

                HandleHttpResp(www, tag);
            }
        }

        private IEnumerator CoroHttpDownload(string url, string savePath, float timeout)
        {
            float time = Time.realtimeSinceStartup + timeout;
            long progress = 0;
            var httpReq = GetHttp();
            httpReq.Download(url, savePath);
            for (;;) {
                yield return null;
                var isDone = httpReq.isDone;
                if (httpReq.error == null) {
                    float realtimeSinceStartup = Time.realtimeSinceStartup;
                    if (!isDone && httpReq.current == progress) {
                        if (time < realtimeSinceStartup) {
                            httpReq.error = HttpStatusCode.RequestTimeout.ToString();
                            httpReq.Stop();
                        } else {
                            continue;
                        }
                    } else {
                        time = realtimeSinceStartup + timeout;
                    }
                }

                if (onHttpDL != null) {
                    onHttpDL.Invoke(url, (uint)httpReq.current, (uint)httpReq.total, isDone, httpReq.error);
                }
                if (isDone) break;
                progress = httpReq.current;
            }            
        }

        public void StartGet(string tag, string url, string param, float timeout)
        {
            StartCoroutine(CoroHttpGet(tag, url, param, timeout));
        }

        public void StartPost(string tag, string url, byte[] postData, Dictionary<string, string> headers, float timeout)
        {
            StartCoroutine(CoroHttpPost(tag, url, postData, headers, timeout));
        }

        public void StartDownload(string url, string savePath, float timeout)
        {
            StartCoroutine(CoroHttpDownload(url, savePath, timeout));
        }
    }
}
