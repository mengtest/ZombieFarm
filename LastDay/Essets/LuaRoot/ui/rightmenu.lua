--
-- @file    ui/rightmenu.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-09-20 17:38:06
-- @desc    描述
--

return {
	-- 私聊
	Whisper = { name = "RightMenu.PrivateChat", action = NW.FRIEND.OnPrivateChat, },

	-- 查看信息
	ViewProfile = { name = "RightMenu.ViewProfile", action = NW.ROLE.OnPlayerInfo, },

	-- 添加好友
	AddFriend = { name = "RightMenu.AddFriend", action = NW.FRIEND.OnAddFriend },
	-- 删除好友
	DelFriend = { name = "RightMenu.RemoveFriend", action = NW.FRIEND.RequestRemoveFriend, },

	-- 拉入黑名单
	AddBlack = { name = "RightMenu.AddBlack", action = NW.FRIEND.OnRemoveFriAddBlack, },
	-- 拉入黑名单
	RemoveBlack = { name = "RightMenu.RemoveBlack", action = NW.FRIEND.RequestRemoveBlackList, },

}

