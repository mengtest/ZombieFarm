



local RedDot = _G.DEF.RedDot


local RedDotMgr = {}

RedDotMgr.__index = RedDotMgr


function RedDotMgr.new()
	local self = {}

    setmetatable(self, RedDotMgr)

    self.m_DotDataList = {}

	return self
end

function RedDotMgr:init()
    --红点根节点
	local rootDot = RedDot.New(CVar.RedDotName.Root)
	self.m_DotDataList[CVar.RedDotName.Root] = rootDot
    --聊天通知节点
	local chatNewDot = RedDot.New(CVar.RedDotName.ChatNew,rootDot)
	self.m_DotDataList[CVar.RedDotName.ChatNew] = chatNewDot
	rootDot:AddChildDot(chatNewDot)
    --好友申请节点
    local friendApplyDot = RedDot.New(CVar.RedDotName.FriendApply,chatNewDot)
    self.m_DotDataList[CVar.RedDotName.FriendApply] = friendApplyDot
    chatNewDot:AddChildDot(friendApplyDot)
    --好友消息节点
	local friendNewDot = RedDot.New(CVar.RedDotName.FriendNew,chatNewDot)
	self.m_DotDataList[CVar.RedDotName.FriendNew] = friendNewDot
 	chatNewDot:AddChildDot(friendNewDot)
    --陌生人消息节点
	local strangerNewDot = RedDot.New(CVar.RedDotName.StrangerNew,chatNewDot)
	self.m_DotDataList[CVar.RedDotName.StrangerNew] = strangerNewDot
 	chatNewDot:AddChildDot(strangerNewDot)
    --新建筑节点
    local buildNewDot = RedDot.New(CVar.RedDotName.BuildNew,rootDot,"Common/ico_com_102")
    self.m_DotDataList[CVar.RedDotName.BuildNew] = buildNewDot
    rootDot:AddChildDot(buildNewDot)
    --新建筑房屋节点
    local buildHouse = RedDot.New(CVar.RedDotName.BuildHouse,buildNewDot,"Common/ico_com_102")
    self.m_DotDataList[CVar.RedDotName.BuildHouse] = buildHouse
    buildNewDot:AddChildDot(buildHouse)
    --新建筑设备节点
    local buildDevice = RedDot.New(CVar.RedDotName.BuildDevice,buildNewDot,"Common/ico_com_102")
    self.m_DotDataList[CVar.RedDotName.BuildDevice] = buildDevice
    buildNewDot:AddChildDot(buildDevice)
    --新建筑家具节点
    local buildFurniture = RedDot.New(CVar.RedDotName.BuildFurniture,buildNewDot,"Common/ico_com_102")
    self.m_DotDataList[CVar.RedDotName.BuildFurniture] = buildFurniture
    buildNewDot:AddChildDot(buildFurniture)
    --新建筑特殊建筑节点
    local buildSpecial = RedDot.New(CVar.RedDotName.BuildSpecial,buildNewDot,"Common/ico_com_102")
    self.m_DotDataList[CVar.RedDotName.BuildSpecial] = buildSpecial
    buildNewDot:AddChildDot(buildSpecial)
    --新工艺节点
    local craftNewDot = RedDot.New(CVar.RedDotName.CraftNew,rootDot,"Common/ico_com_102")
    self.m_DotDataList[CVar.RedDotName.CraftNew] = craftNewDot
    rootDot:AddChildDot(craftNewDot)
    --邮件节点
    local mailNewDot = RedDot.New(CVar.RedDotName.MailNew,rootDot)
    self.m_DotDataList[CVar.RedDotName.MailNew] = mailNewDot 
    rootDot:AddChildDot(mailNewDot)
    --任务节点
    local taskRecodeDot = RedDot.New(CVar.RedDotName.TaskRecode,rootDot)
    self.m_DotDataList[CVar.RedDotName.TaskRecode] = taskRecodeDot 
    rootDot:AddChildDot(taskRecodeDot) 
    self.inited = true
end

--设置红点状态，树结构

--childDotName:子节点,parentDotName:根节点

--bIsShow:只需要设置叶节点状态

function RedDotMgr:SetRedDotState(dotName, bIsShow)
    local childDot = self:GetRedDot(dotName)

    if bIsShow ~= nil and childDot then

        childDot:UpdateLeafData(bIsShow)

    end

end



function RedDotMgr:BuildRedDotUI(dotName, redObj)

    local redDot = self:GetRedDot(dotName)

    if redDot then

    	redDot:BuildRedDotUI(redObj)
		
	end
end



function RedDotMgr:UnbuildRedDotUI(dotName)

    local redDot = self:GetRedDot(dotName)

	if redDot then

    	redDot:UnbuildRedDotUI()
	
	end
end

 

function RedDotMgr:GetRedDot(dotName)

    if dotName == nil then return end

    if self.m_DotDataList[dotName] == nil then

        local tempDot = RedDot.New()

        self.m_DotDataList[dotName] = tempDot

    end

 

    return self.m_DotDataList[dotName]

end

 

--获取红点状态：true：显示  false：不显示

function RedDotMgr:GetRedDotIsShow(dotName)

    local dot = self:GetRedDot(dotName)

    return dot:GetIsShowRedDot()

end

 

--获取子节点红点数量

function RedDotMgr:GetChildRedDotNum(dotName)

    local dot = self:GetRedDot(dotName)

    return dot:GetRedDotNum()

end



return RedDotMgr