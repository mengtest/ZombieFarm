using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World.View
{
	public interface IDynamicAsset
	{
		string assetPath { get; }
		void OnAssetLoaded(Object asset);
	}
}
