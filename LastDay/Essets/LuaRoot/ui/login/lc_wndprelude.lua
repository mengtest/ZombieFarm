--
-- @file    ui/login/lc_wndprelude.lua
-- @author  xingweizhen
-- @date    2018-08-22 16:51:25
-- @desc    WNDPrelude
--

local self = ui.new()
local _ENV = self

function on_close_action()
	libugui.KillTween(Ref.go)
	libugui.DOTween("Alpha", Ref.go, 1, 0, {
		            duration = 1,
					complete = function()
						self:close()
					end
				})

end

local function on_stopall_tween()
	for i,v in ipairs(self.picList) do
		libugui.KillTween(v)
		libunity.Recycle(v)
	end
end

local function allow_load_scene()
	on_stopall_tween()
	local loadingwnd = ui.find("WNDLoading")
	if loadingwnd then
		libunity.SendMessage(loadingwnd.go, "AllowLoadScene", true)
	end

	libasset.Unload("atlas/OpeninAni/")
end


local function show_opening_anim(picture,data,ind)

    coroutine.yield(data.starttime/1000)
	local posxy = string.split(data.pos, "|")
	local x,y,z = 0,0,0
	for i,v in ipairs(posxy) do
		if i == 1 then
			x = tonumber(v)
		elseif i == 2 then
			y = tonumber(v)
		else
			z = tonumber(v)
		end
	end
	libunity.SetPos(picture,x,y,z)
	local picScale = data.scale/1000
	libunity.SetScale(picture,picScale,picScale,picScale)
	libugui.SetSprite(picture,data.path)
	libugui.SetNativeSize(picture)

	libugui.DOTween("Alpha", picture, 0, 1, { duration = data.startspeed/1000})

    coroutine.yield(data.startspeed/1000)
	libugui.SetNativeSize(picture)

    coroutine.yield(data.showtime/1000)
	libugui.SetNativeSize(picture)

	libugui.DOTween("Alpha", picture, 1, 0, { duration = data.endspeed/1000})

    coroutine.yield(data.endspeed/1000)
	libugui.SetNativeSize(picture)
	libugui.SetAlpha(picture,0)
	if self.closeindex == ind and not self.skip then
		allow_load_scene()
	end
end

--!* [开始] 自动生成函数 *--

function on_btnskip_click(btn)
	self.skip = true

	allow_load_scene()
end
--!* [结束] 自动生成函数  *--

function init_view()
	--!* [结束] 自动生成代码 *--
	libugui.SetAlpha(Ref.go,1)
	self.openinaniData = config("openinanilib").get_dat()
	self.openinAniPic = Ref.spOpeninAinPic
	self.picList = {}
end

function init_logic()
	--ui.moveout(Ref.spBack, 1)
	Ref.lbStory.text = " "
	local totalTime = 0
	for k,v in pairs(self.openinaniData) do
		local indexTime = v.starttime/1000 + v.showtime/1000 + v.startspeed/1000 + v.endspeed/1000
		if indexTime > totalTime then
			totalTime = indexTime
			self.closeindex = k
		end

		local picture

		if #self.picList < k then
  			picture = libunity.AddChild(Ref.lbStory, self.openinAniPic)
  			picture.name = self.openinAniPic.name..k
			table.insert(self.picList,picture)
  		else
  			picture =	self.picList[k]
		end
		libugui.DOTween("Alpha", picture, 0, 0, { duration = v.starttime/1000})

		libunity.StartCoroutine(picture, show_opening_anim,picture,v,k)
	end
	libunity.SetActive(Ref.btnSkip, _G.ENV.development)

	libasset.LoadAsync(nil, "fmod/CG/", "Cache",function ()
		AUD.new("CG/CloseBeta_CG")
		end)
end

function show_view()
	local mainPlayer = DY_DATA:get_player()
	local mapId = mainPlayer.map
	if mapId then
		-- 存在地图，进入地图
		NW.apply_map(1, mapId)
	else
		-- 进入世界地图
		SCENE.load_main()
	end
end

function on_recycle()
	--ui.putback(Ref.spBack, Ref.go)
	--on_stopall_tween()
	--libasset.Unload("atlas/OpeninAni/")
end

return self

