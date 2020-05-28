--
-- @file    game/timers.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2017-10-31 20:53:46
-- @desc    描述
--

local P = {}

local function on_battery_timer(Tm) return false end
function P.launch_battery_timer()
	DY_TIMER.replace_timer("BATTERY", 0, 1, on_battery_timer)
end

local function on_asset_timer(Tm)
	local Assets = DY_DATA:get_player().Assets
	local Asset = Assets and Assets[Tm.param]
	if Asset then
		Asset.amount = Asset.amount + 1
		if Asset.amount < Asset.limit then return false end
	end

	return true
end

local function on_stageclose_timer(Tm)
	return true
end

function P.launch_asset_timer(Asset, count, cycle)
	local Tm = DY_TIMER.replace_timer("Asset#" .. Asset.dat, count, cycle, on_asset_timer)
	Tm.param = Asset.dat
end

function P.launch_chname_timer(count)
	DY_TIMER.replace_timer("ChName", count, _G.CVar.GAME.ChangeNameCD)
end

function P.launch_stageclose_timer(stageID, dura)
	local Tm = DY_TIMER.replace_timer("StageClose#"..stageID , dura, dura , on_stageclose_timer)
	Tm.param = stageID
end

function P.launch_unitworking_timer(objId, dura)
	local Stage = DY_DATA:get_stage()
	if Stage then
		local tmKey = "UnitWorking#"..objId
		local Tm = DY_TIMER.replace_timer(tmKey, dura, dura , function(Tm)
			return true
		end)
		Tm.param = objId
		local WorkingUnits = table.need(Stage, "WorkingUnits")
		table.insert(WorkingUnits, tmKey)
	end
end

function P.launch_worldtime_timer(worldTime, cycle)
	local Tm = DY_TIMER.replace_timer("WorldTime" , worldTime, cycle , function(Tm)
		return false
	end)
end

return P
