using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace ZFrame.Asset
{
	[System.Serializable]
	public class AssetInf
	{
		public long siz;
		public string md5;
    }

	[System.Serializable]
	public class DownloadInf
	{
		public long siz;
		public int minLevel;
		public int maxLevel;
	}

	[System.Serializable]
	public class ResInf
	{
		public string version;
		public string timeCreated;
		public string whoCreated;
		public Dictionary<string, AssetInf> Assets;
		public Dictionary<string, DownloadInf> Downloads;

		public ResInf()
		{
			timeCreated = "";
			Assets = new Dictionary<string, AssetInf>();
		}
	}
}
