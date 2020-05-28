using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Text;
using System.IO;

namespace ZFrame.NetEngine
{
    public class HttpRequester
    {

        static int BYTE_LEN = 1024;

        public delegate void ProcessDelegate(HttpRequester httpReq, long current, long total);

        public delegate void RespDelegate(HttpRequester httpReq, string resp, System.Exception e);

        public string reqUri { get; private set; }
        public string reqMethod { get; private set; }
        public string reqPara { get; private set; }
        public string rspFile { get; private set; }
        public long current { get; private set; }
        public long total { get; private set; }

        /// <summary>
        /// 已完成或者空闲状态
        /// </summary>
        public bool isDone { get; private set; }

        public string error;
        long storageSiz = 0;

        public FileStream file { get; private set; }
        public HttpWebRequest wrq;
        public object param { get; private set; }
        public ProcessDelegate onProcess;
        public RespDelegate onResponse;

        public System.IAsyncResult result { get; private set; }

        public void Start(string uri, string param, string method, string savePath = null,
            ProcessDelegate process = null, RespDelegate resp = null)
        {
            reqUri = uri;
            reqPara = param;
            reqMethod = method;
            rspFile = savePath;
            onProcess = process;
            onResponse = resp;
            storageSiz = 1024 * 1024 * 100;

            current = 0;
            total = 1;
            error = null;

            LogMgr.I("{0} {1}?{2}", reqMethod, reqUri, reqPara);
            switch (reqMethod) {
                case "GET":
                    wrq = (HttpWebRequest)WebRequest.Create(reqUri + "?" + reqPara);
                    break;
                case "POST": {
                    wrq = (HttpWebRequest)WebRequest.Create(reqUri);
                    wrq.Method = "POST";
                    wrq.ContentType = "application/x-www-form-urlencoded";

                    if (reqPara != null) {
                        byte[] SomeBytes = Encoding.UTF8.GetBytes(reqPara);
                        Stream newStream = wrq.GetRequestStream();
                        newStream.Write(SomeBytes, 0, SomeBytes.Length);
                        newStream.Close();
                        wrq.ContentLength = reqPara.Length;
                    } else {
                        wrq.ContentLength = 0;
                    }

                    break;
                }
                case "GETF": {
                    if (File.Exists(rspFile)) {
                        file = File.OpenWrite(rspFile);
                        file.Seek(0, SeekOrigin.End);
                    } else {
                        SystemTools.NeedDirectory(Path.GetDirectoryName(rspFile));
                        file = new FileStream(rspFile, FileMode.Create);
                    }

                    wrq = (HttpWebRequest)WebRequest.Create(reqUri);
                    wrq.AddRange((int)file.Length);
                    break;
                }

                default:
                    return;
            }

            isDone = false;
            result = wrq.BeginGetResponse(f_processHttpResponseAsync, wrq);
        }

        public void Download(string url, string savePath, object param = null, ProcessDelegate onProcess = null,
            RespDelegate onResponse = null)
        {
            this.param = param;
            Start(url, null, "GETF", savePath, onProcess, onResponse);
        }

        public object TakeParam()
        {
            var ret = param;
            param = null;
            return ret;
        }

        public void Stop()
        {
            if (wrq != null) {
                wrq.Abort();
                wrq = null;
            }

            if (file != null) {
                file.Close();
                file = null;
            }
            isDone = true;
        }
        
        public void Reset()
        {
            if (wrq != null) {
                wrq.Abort();
                wrq = null;
            }

            result = null;
            reqUri = null;
            reqPara = null;
            reqMethod = null;
            rspFile = null;
            onProcess = null;
            onResponse = null;
            current = 0;
            total = 0;
        }

        /// <summary>
        /// 异步调用函数
        /// </summary>
        /// <param name="iar"></param>
        private void f_processHttpResponseAsync(System.IAsyncResult iar)
        {
            StringBuilder rsb = new StringBuilder();
            HttpWebRequest req = iar.AsyncState as HttpWebRequest;

            System.Exception ex = null;
            try {
                HttpWebResponse response = req.EndGetResponse(iar) as HttpWebResponse;
                Stream responseStream = response.GetResponseStream();
                if (response.ContentLength / 1000 / 1000 > storageSiz)
                    throw new IOException(string.Format("Disk Full ({0} / {1})", response.ContentLength / 1000 / 1000,
                        storageSiz));

                total = response.ContentLength;
                if (file != null) total += file.Length;

                byte[] buffer = new byte[BYTE_LEN];
                for (; current < total;) {
                    int count = responseStream.Read(buffer, 0, buffer.Length);
                    if (count > 0) {
                        if (wrq == null) {
                            throw new WebException("Request Canceled", WebExceptionStatus.RequestCanceled);
                        }

                        if (file == null) {
                            string str = Encoding.UTF8.GetString(buffer);
                            rsb.Append(str);
                            current = rsb.Length;
                            if (onProcess != null) onProcess(this, rsb.Length, total);
                        } else {
                            file.Write(buffer, 0, count);
                            current = file.Length;
                            if (onProcess != null) onProcess(this, file.Length, total);
                        }
                    } else {
                        break;
                    }
                }

                if (file != null && file.Length != total) {
                    throw new WebException("Request Unfinished", WebExceptionStatus.RequestCanceled);
                }

                if (responseStream != null) {
                    responseStream.Dispose();
                }

                response.Close();
            } catch (WebException e) {
                HttpWebResponse resp = e.Response as HttpWebResponse;
                if (resp != null && resp.StatusCode == HttpStatusCode.RequestedRangeNotSatisfiable) {
                    LogMgr.I("File {0} is done.", rspFile);
                    rsb.Append(rspFile);
                    current = total;
                } else {
                    ex = e;
                    error = resp.StatusCode.ToString();
                }
            } catch (IOException e) {
                ex = e;
                error = "IOException: " + e.Message;
            } catch (System.Exception e) {
                ex = e;
                req.Abort();
                error = e.Message;
            }

            if (file != null) {
                file.Close();
                file = null;
            }

            // GetResponse Success
            if (rsb.Length == 0) {
                rsb.Append(rspFile);
            }

            isDone = true;

            if (onResponse != null) {
                if (ex == null) {
                    onResponse(this, rsb.ToString(), null);
                } else {
                    onResponse(this, null, ex);
                }
            }
#if false
		异步调用例子
			IAsyncResult result = request.BeginGetResponse(new AsyncCallback(f_processHttpResponseAsync), request);
		//处理超时请求
		ThreadPool.RegisterWaitForSingleObject(result.AsyncWaitHandle, 
		                                       new WaitOrTimerCallback(f_asyncTimeout), request, 1000 * 60 * 10, true);
#endif
        }

        // HTTP通讯 异步
        public static HttpRequester Get(string url, string para, string method, ProcessDelegate onProcess = null,
            RespDelegate onResponse = null)
        {
            HttpRequester reqInfo = new HttpRequester();
            reqInfo.Start(url, para, method.ToUpper(), null, onProcess, onResponse);
            return reqInfo;
        }

        // HTTP DOWNLOAD 异步
        public static HttpRequester Get(string url, string savePath, ProcessDelegate onProcess = null,
            RespDelegate onResponse = null)
        {
            HttpRequester reqInfo = new HttpRequester();
            reqInfo.Download(url, savePath, null, onProcess, onResponse);
            return reqInfo;
        }
    }
}