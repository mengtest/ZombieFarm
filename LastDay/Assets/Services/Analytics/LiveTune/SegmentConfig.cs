using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Unity.LiveTune {

	// keep this as an immutable object
	[System.Serializable]
	public class SegmentConfig
	{
		public string segment_id;

		public bool is_baseline;
		public string settingsJson;
		public string qs_settingsJson;
        public string config_hash;
		public string segment_name;

        // makes a shallow copy of the dictionary - this is required because we will
        // cast the settings to the right type. qs_settingsJson is initialized to null
        // because QualitySettingsCarrier.Reset() populates it once invoked.
        // The supported types may be different the types in JSON e.g. int vs long
		public SegmentConfig(string segment_id, bool is_baseline, string settingsJson, string config_hash, 
			string segment_name, string qs_settingsJson = null)
		{
			this.segment_id = segment_id;
			this.is_baseline = is_baseline;
			this.settingsJson = settingsJson;
			this.qs_settingsJson = qs_settingsJson;
			this.config_hash = config_hash;
			this.segment_name = segment_name;
		}
	}
}
