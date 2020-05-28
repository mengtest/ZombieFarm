--
-- @file    ui/item/lc_wndlootbag.lua
-- @author  xingweizhen
-- @date    2018-01-03 16:38:42
-- @desc    WNDLootBag
--

local self = ui.new()
setfenv(1, self)

local API = _G.PKG["game/api"]

local function rfsh_loot_view()
	libugui.SetLoopCap(Ref.SubLoot.SubScroll.SubView.GrpLoots.go, Context.cap, true)

	local scroll = Ref.SubLoot.SubScroll.go:GetComponent("ScrollRect")
	local contentSize = libugui.GetRectSize(scroll.content)
	local viewportSize = libugui.GetRectSize(scroll.viewport)
	local clamp = true
	if scroll.vertical and contentSize.y > viewportSize.y
		or scroll.horizontal and contentSize.x > viewportSize.x then
		clamp = false
	end
	scroll.movementType = clamp and "Clamped" or "Elastic"
end

function iget_entitem(index)
    return Ref.SubLoot.SubScroll.SubView.GrpLoots:find(index)
end

function item_dual_click(index)
	local obj, _, idx = _G.CVar.split_item_idx(index)
	local tarObj = obj == 0 and Context.obj or 0
	local Item = DY_DATA:iget_item(index)
	NW.put_item(Item, obj, idx, tarObj)
end

local function item_drag_drop(Items,dragindex,dropindex)
	local dragid = CVar.gen_item_pos(Context.obj, 0, dragindex)

	local dropid = CVar.gen_item_pos(Context.obj, 0, dropindex)
	
	local dragitem = Items[dragindex]
	local dropitem = Items[dropindex]

	if NW.move_item(dragid, dropid) then
		if dropitem and dragitem.dat == dropitem.dat then
			local maxamount = dragitem:get_base_data().nStack
			local dropA = dropitem.amount
			local dragA = dragitem.amount
			if dropA + dragA > maxamount then
				dropitem.amount = maxamount
				Items[dropindex] = dropitem
				dragitem.amount = dropA + dragA - maxamount
				Items[dragindex] = dragitem
			else
				dropitem.amount = dropA + dragA
				Items[dropindex] = dropitem
				Items[dragindex] = nil
			end
		else
            Items[dragindex] = dropitem;
            Items[dropindex] = dragitem;
		end
	end
	return Items[dropindex]
end

local function item_find_drag(Items,templist,i)
	local dragindex = -1
    local dragdat = nil
    for j=1,#templist do
    	local tempind = templist[j]
    	local tempitem = Items[tempind]
    	if tempind >i-1 and tempitem then
    		local tempdat = tempitem.dat
    		local tempamount = tempitem.amount
    		local tempdura = tempitem:get_durability()
    			--先判断id
    		if dragdat == nil or dragdat.dat > tempdat then
        		dragindex = tempind
        		dragdat = tempitem
        	elseif dragdat.dat == tempdat then
        			--id相同，优先耐久
        		if tempdura then
        			if dragdat:get_durability() < tempdura then
        				dragindex = tempind
        				dragdat = tempitem
        			end
        		else
        				--耐久不存在，数量
					if dragdat.amount < tempamount then
        				dragindex = tempind
        				dragdat = tempitem
					end
        		end
        	end
    	end
    end

    return dragindex , dragdat
end

local function items_sort() 
	local Items = DY_DATA:get_obj_items(Context.obj)
	
	local  templist = {}
    for k,v in pairs(Items) do
    	table.insert(templist,1,k)
    end
    local lastdat = nil

    for i=1,#templist do
    	
    	local  dragindex ,dragdat = item_find_drag(Items,templist,i)
    	if lastdat and dragdat and lastdat.dat == dragdat.dat then 
    		
			while lastdat.amount < lastdat:get_base_data().nStack do
        		--合并相同物品
        		lastdat = item_drag_drop(Items,dragindex,i-1)
        		dragindex , dragdat = item_find_drag(Items,templist,i)
        		if lastdat and dragdat and lastdat.dat == dragdat.dat then 
    				else
    					break
    			end
			end
    	end
        
		if  dragdat then

			lastdat = dragdat
			
			if dragindex > i then
				lastdat = item_drag_drop(Items,dragindex,i)
			end
		else
			break
		end
    end 
end

local function rfsh_building_info()
    local Focus = CTRL.get_obj(Context.obj)

	if Focus.master ~= DY_DATA:get_player().id then return end

	local Hud = API.get_obj_hud(Context.obj)
	if Hud == nil then return end
	local Items = DY_DATA:get_obj_items(Context.obj)
	local  templist = {}
    for k,v in pairs(Items) do
    	table.insert(templist,1,k)
    end
    if Focus then
    	Focus.remainingCap = Context.cap - #templist
    	Focus.totalCap = Context.cap
    end
	Hud.SubPlate.lbName.text = #templist .."/"..Context.cap
end 

local function rfsh_lock_state(Items)
	if Items then
		for _,v in pairs(Items) do
			if v.pos >= CVar.OBJ_ITEM_LIMIT then

				local Ent = self.GrpLoots:find(v.pos)
				
				if Context.canPutIn then
					libunity.SetActive(Ent.spLock, false)
				else
					libunity.SetActive(Ent.spLock, v.amount == 0)
				end
			end
		end
	end

end

--!* [开始] 自动生成函数 *--

function on_item_selected(evt, data)
	Primary.on_item_selected(evt, data)
end

function on_begindrag_item(evt, data)
	Primary.on_begindrag_item(evt, data)
end

function on_drag_item(evt, data)
	Primary.on_drag_item(evt, data)
end

function on_enddrag_item(evt, data)
	Primary.on_enddrag_item(evt, data)
end

function on_drop_item(evt, data)
	Primary.on_drop_item(evt, data)
end

function on_item_pressed(evt, data)
	Primary.on_item_pressed(evt, data)
end

function on_item_dualclick(evt, data)
	Primary.on_item_dualclick(evt, data)
end

function on_grploots_ent(go, i)
	local index = CVar.gen_item_pos(Context.obj, 0, i + 1)
	self.GrpLoots:setindex(go, index)
	Primary.show_grpent_view(go, index, not Context.canPutIn)
end

function on_subloot_subop_btnpick_click(btn)
	if NW.connected() then
		NW.send(NW.gamemsg("PACKAGE.CS.PACKAGE_PICKUP"):writeU32(Context.obj))
	else
		NW.broadcast("PACKAGE.SC.PACKAGE_PICKUP", {})
		self.Primary:close()
	end
end

function on_subloot_subop_btnsort_click(btn)
	if NW.connected() then
		NW.send(NW.gamemsg("PACKAGE.CS.NEATEN_PACKET"):writeU32(Context.obj))
	else
		items_sort()
	end
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubLoot.SubScroll.SubView.GrpLoots)
	--!* [结束] 自动生成代码 *--
	self.GrpLoots = Ref.SubLoot.SubScroll.SubView.GrpLoots

	local UTIL = _G.PKG["ui/util"]
	local flex_itemgrp = UTIL.flex_itemgrp
	flex_itemgrp(self.GrpLoots)

	libugui.RebuildLayout(Ref.SubLoot.go)
end

function init_logic()
	ui.moveout(Ref.spBack, 1)
	self.Primary = Context.Primary
	self.Primary.Secondary = self

	rfsh_loot_view()
	local scroll = Ref.SubLoot.SubScroll.go:GetComponent("ScrollRect")
	scroll.verticalNormalizedPosition = 1
	Ref.lbTitle.text = Context.title

	local Obj = CTRL.get_obj(Context.obj)
				
	local ObjBase = Obj:get_base_data()

	libunity.SetActive(Ref.SubLoot.SubOp.btnSort,ObjBase.building)
	
end

function show_view()

end

function on_recycle()
	ui.putback(Ref.spBack, Ref.go)
	rfsh_building_info()
	-- libgame.UnitBreak(0)
	-- NW.send(NW.gamemsg("PACKAGE.CS.PACKAGE_CLOSE"):writeU32(Context.obj))

	-- -- 清空缓存
	-- DY_DATA:del_obj_items(Context.obj)
end

Handlers = {
	["PACKAGE.SC.PACKAGE_PICKUP"] = function(Package)
		local Obj = _G.PKG["game/ctrl"].get_obj(Context.obj)
		local items = DY_DATA:get_obj_items(Context.obj)
		if table.void(items) and Obj.disappear ~= 0 then
			self.Primary:close(true)
			return
		end
		rfsh_loot_view()
	end,
	["PACKAGE.SC.SYNC_PACKAGE"] = function (Package)
		if Package.obj == Context.obj then
			rfsh_loot_view()
		end
	end,
	["PACKAGE.SC.SYNC_ITEM"] = rfsh_loot_view,
	
	["PACKAGE.SC.ITEM_USE"] = rfsh_lock_state,
	["PACKAGE.SC.ITEM_MOVE"] = rfsh_lock_state,
	["PACKAGE.SC.ITEM_DEL"] = rfsh_lock_state,
	
}

return self

