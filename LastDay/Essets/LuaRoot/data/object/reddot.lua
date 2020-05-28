local RedDot = {}

RedDot.__index = RedDot

function RedDot.New(dotName, parentDot,redicon)

    local self = {}

    setmetatable(self, RedDot)

    self.m_dotName = dotName

    self.m_bIsShow = false

    self.m_parentDot = parentDot

    self.m_childDotList = {}

 	self.is_root = parentDot == nil
    self.redicon = redicon

    self.redParent = nil
    self.redPoint = nil

    return self

end

function RedDot:ChangeRedState(state)
    if self.redParent then
        self.redPoint = libunity.FindByName(self.redParent,"RedPoint")
        if self.redPoint == nil then
            self.redPoint  = libunity.NewChild(self.redParent, "UI/RedPoint")
            libugui.SetSprite(self.redPoint, self.redicon or "Common/ico_com_100")
            libugui.SetNativeSize(self.redPoint)
            libugui.AnchorPresets(self.redPoint, 1, 1)
        end

        libunity.SetActive(self.redPoint,state)
    end
end
 
function RedDot:UpdateUI()
	local state = self:GetIsShowRedDot()

	self.m_bIsShow = state

    self:ChangeRedState(state)

	if self.m_parentDot  then

		self.m_parentDot:UpdateUI()

	end
end

-- 从叶节点往根节点递归

function RedDot:GetIsShowRedDot()

    if #self.m_childDotList < 1 then

        return self.m_bIsShow
  
    end

 

    local bIsShow = false

    for childDotName, childDot in ipairs(self.m_childDotList) do

        if childDot:GetIsShowRedDot() then

            bIsShow = true
            break

        end

    end


    return bIsShow

end

 

-- 获取红点数量

function RedDot:GetRedDotNum()

    if  #self.m_childDotList < 1 then

        return 0

    end

 

    local redDotNum = 0

    for childDotName, childDot in ipairs(self.m_childDotList) do

        if childDot:GetIsShowRedDot() then

            redDotNum = redDotNum + 1

        end

    end

    return redDotNum

end

 

--刷新叶节点数据

function RedDot:UpdateLeafData(bIsShow)
	if  #self.m_childDotList < 1 then
		local  needUpdate = self.m_bIsShow ~= bIsShow 
   		self.m_bIsShow = bIsShow
		if needUpdate then
			self:UpdateUI()
		end
	end
end

 

--获取子节点数据

function RedDot:GetChildDot(childDotName)
    for childDotName, childDot in ipairs(self.m_childDotList) do

        if  childDot.m_dotName == childDotName then

            return childDot

        end

    end
    return nil

end

 

--添加子节点数据

function RedDot:AddChildDot(childDot)
    table.insert(self.m_childDotList, childDot )
end



 function RedDot:BuildRedDotUI(redObj)

 	self.redParent = redObj
    local state = self:GetIsShowRedDot()

    self.m_bIsShow = state


    self:ChangeRedState(state)
 end


 function RedDot:UnbuildRedDotUI()

 	self.redParent = nil
    if self.redPoint then
        libunity.Recycle(self.reDPoint)
    end
    self.redPoint = nil
 end

return RedDot