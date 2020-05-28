--
-- @file    guide/api.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-07-17 12:07:19
-- @desc    描述
--

local P = {
	WINDOW_DEPTH = 120
}

local Guiding = {}

function P.save(id, step)
	if id == nil then return end

	id = tostring(id)
	local GuideData = table.need(DY_DATA.CliData, "Guide")
	if GuideData[id] ~= step then
		GuideData[id] = step
		print(string.format("Save Guide: %s=%d", id, step))
		NW.COM.update_clidata()
	end
end

function P.load(id)
	local GuideData = table.need(DY_DATA.CliData, "Guide")
	return GuideData[tostring(id)]
end

function P.launch(group, step, forced)
	local MBox = UI.MBox
	if MBox.is_active() then
		MBox.set_empty(function () P.launch(group, step, forcedd) end)
	return end

	-- 全局引导开关值
	local closed = false
	local function check_guide(Guide)
		local status, ret, fail
		if not closed then
			status, ret, fail = trycall(Guide.chk_cond, Guide, P)
		else
			status = true
		end
		if status then
			if ret == false then
				fail = string.format("<color=#FFD700>引导【#%s %s：%s】启动条件不足</color>",
					tostring(Guide.id), Guide.group, Guide.name)
			elseif ret == nil then
				fail = string.format("<color=#FFD700>引导【#%s %s：%s】已关闭</color>",
					tostring(Guide.id), Guide.group, Guide.name)
			end
		else
			fail = string.format("<color=red>引导【#%s %s：%s】异常：%s</color>",
				tostring(Guide.id), Guide.group, Guide.name, ret)
			ret = false
		end
		return ret, fail
	end

    -- 更新引导数据
    local function update_guide()
    	local GuideList = _G.PKG["guide/list"]
        Guiding.group, Guiding.step = nil, nil
        local GuideData = table.need(DY_DATA.CliData, "Guide")

        local ActiveGuide, dirty, FailMsg = nil, false, {}
        for _,gid in ipairs(GuideList) do
            if GuideData[gid] ~= 0 then
            	-- 该引导尚未完成
                local Guide = MERequire("guide/group"..gid, true)
                if Guide then
                	local ret, fail = check_guide(Guide)
	                if ret then
	                	-- 该引导符合启动条件
	                    Guiding.group = gid
	                    Guiding.step = GuideData[gid] or 1
	                    ActiveGuide = Guide
	                    break
	                else
	                	if ret == nil then
	                		GuideData[gid] = 0
	                        dirty = true
	                    end
	                    if fail then table.insert(FailMsg, fail) end
	                end
	            end
            end
        end

        -- 保存新的数据
        if dirty then P.save() end

        if #FailMsg > 0 then
            print("【引导检查】\n" .. table.concat(FailMsg, "\n"))
        end

        return ActiveGuide
    end

    local LC = ui.find("WNDGuiding")
    if LC and LC.move_next then
        print("正在引导中...")
    return end

    if group == nil then
        group, step = Guiding.group, Guiding.step
        if group == nil then forced = false end
    end

    -- 启动前要先验证一次条件是否符合
    local Guide
    if forced then
        Guide = _G.PKG["guide/"..group]
        if Guide then
        	local ret, fail = check_guide(Guide)
        	if ret then
        		Guiding.group, Guiding.step = group, step
        	else
        		Guide = nil
        		print(fail)
        	end
        else
        	print(string.format("<color=#FFD700>不存在的引导：%s</color>", group))
        end
    else
        Guide = update_guide()
    end

    if Guide then
    	local status, result = trycall(Guide.gen_guider, Guide, P)
    	if status then
	        if result then
	            print(string.format("<color=#FFD700>引导【#%s %s：%s】启动</color>",
	            	tostring(Guide.id), Guide.group, Guide.name))
	            ui.show("UI/WNDGuiding", P.WINDOW_DEPTH, result)
	        else
	            print(string.format("<color=#FFD700>引导【#%s %s：%s】启动失败</color>",
	                tostring(Guide.id), Guide.group, Guide.name))
	        end
	    else
	    	libunity.LogW("引导【#{0}{1}：{2}】异常:\n\t{3}", Guide.id, Guide.group, Guide.name, result)
	    end
    end
end

function P.find_target(tar)
	local typeName = type(tar)
	if typeName == "function" then
		return tar()
	elseif typeName == "table" then
		return libunity.Find(tar.root, tar.path)
	elseif typeName == "string" then
		return libunity.Find(nil, tar)
	elseif typeName == "userdata" then
		return tar
	else
		error("Error Guiding Target = "..tar)
	end
end

function P.focus(tar, Step)
	local LC = ui.find("WNDGuiding")
    if LC and LC.move_next then
        print("正在引导中...")
    return end

    if Step == nil then Step = {} end
    Step.target = tar
    local nStep = 1
    ui.show("UI/WNDGuiding", P.WINDOW_DEPTH, function ()
		if nStep == 1 then
			nStep = nStep + 1
			return Step, nStep
		end
    end)
end

-- 根据路径寻找界面中的控件
function P.finder(wndName, path)
	return function ()
		local Wnd = ui.find(wndName)
		if Wnd and Wnd.go then return libunity.Find(Wnd.go, path) end
	end
end

-- 根据路径和索引寻找界面中Group的Ent
function P.grpfinder(wndName, index, ...)
	local Paths, Grp = {...}
	return function ()
		if Grp == nil then
			local Wnd = ui.find(wndName)
			if Wnd and Wnd.Ref then
				local Sub = Wnd.Ref
				for _,v in ipairs(Paths) do
					Sub = Sub[v]
				end
				Grp = Sub
			end
			if Grp == nil then return end
		end

		local Ent = Grp:find(index)
		if Ent then return Ent.go end
	end
end

return P
