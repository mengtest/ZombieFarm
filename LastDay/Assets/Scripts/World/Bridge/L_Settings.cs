using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace World
{
	[System.Serializable]
	public class L_Settings : IDataFromLua
	{
		public TARFilter targetFilter;

		public bool focus_preferredHp {
			get { return targetFilter == TARFilter.Thinnest; }
			set { targetFilter = value ? TARFilter.Thinnest : TARFilter.Nearest; }
		}

		public bool focus_lockOnHit { get; private set; }
		public int focus_showNearby { get; private set; }

		public void InitFromLua(System.IntPtr lua, int index)
		{
			focus_preferredHp = lua.GetBoolean(index, "battle.focus.preferredHp");
			focus_lockOnHit = lua.GetBoolean(index, "battle.focus.lockOnHit");
			focus_showNearby = (int)lua.GetNumber(index, "battle.focus.showNearby");
		}
	}
}
