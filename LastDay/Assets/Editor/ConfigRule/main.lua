return {
	{
		name = "角色", file = "object_object", key = "ID",
		Loc = { file = "loc/text_text", index = "nameTextID", key = "ID", name = "text", },
		Subs = {
			object_npc = "ID", object_mine = "ID", object_mapitem = "ID",
			building_building = "objectID",
		},

		Indexes = {
			tempID = { object_template = "ID", },
			combatID = { combatstats_stats = "ID", },
		},

		Fields = {
			object_object = {
				{ key = "ID", name = "数据编号", desc = "唯一编号", },
				{ key = "type", name = "类型", desc = "", },
				{ key = "building", name = "是否建筑", desc = "", },
			},
			object_template = {
				{ key = "ID", name = "模版编号", desc = "数据模版", }
			},
			["loc/object_object"] = {
				{ key = "name", name = "名称", },
				{ key = "describtion", name = "描述", },
			},
		},
	},
	{
		name = "道具", file = "item_item", key = "ID",
		Loc = { file = "loc/text_text", index = "nameTextID", key = "ID", name = "text", },
		Subs = {
			item_equip = "ID", item_weapon = "ID", item_throw = "ID", item_use = "ID",
		},

		Indexes = {
			combatID = { combatstats_stats = "ID", },
			skill = { skill_skill = "ID", }
		},

		Fields = {

		},
	},
	{
		name = "技能", file = "skill_skill", key = "ID",
		Loc = { file = "skill_text", key = "ID", name = "name", },
		Subs = {
			skill_resource = "ID",
		},

		Indexes = {
			subIndexes = { skill_sub = "ID" },
		},

		Fields = {

		},
	},
	{
		name = "子技能", file = "skill_sub", key = "ID",
		Subs = {
			skill_subresource = "ID",
		},

		Indexes = {
			buff = { skill_buff = "ID", },
			effect = { skill_effect = "ID" },
			missileID = { skill_missile = "ID" },
		},

		Fields = {

		},
	},
	{
		name = "地图入口", file = "mapgroup_mapgrouptemplate", key = "ID",
		Subs = {
			mapgroup_mapgroupresource = "ID",
		},

		Indexes = {
			mapID = { map_map = "mapID", },
		},

		Fields = {

		},
	},
	{
		name = "关卡", file = "map_map", key = "mapID",
		Loc = { file = "loc/text_text", index = "nameTextID", key = "ID", name = "text", },
		Subs = {

		},

		Indexes = {
			tempID = { map_maptemplate = "ID", },
		},

		Fields = {

		},
	},
	{
		name = "关卡模板", file = "map_maptemplate", key = "ID",
		Subs = {

		},

		Indexes = {

		},

		Fields = {

		},
	},
}