--
-- @file    data/parser/avatarlib.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-05-14 17:44:59
-- @desc    描述
--

local FaceDB = setmetatable({}, _G.MT.AutoGen)
local AVATAR = dofile("config/avatar_avatar")
for i,v in ipairs(AVATAR) do
	table.insert(FaceDB[v.gender], {
			id = v.faceShape,
			gender = v.gender, color = v.skinColor,
			icon = v.avatarFace,
			avatarFace = v.avatarFace,
		})
end
setmetatable(FaceDB, nil)

local HairDB = setmetatable({}, _G.MT.AutoGen)
local HAIR = dofile("config/avatar_hair")
for i,v in ipairs(HAIR) do
	table.insert(HairDB[v.gender], {
			id = v.hairStyle,
			gender = v.gender,
			icon = v.icon,
			avatarHair = v.avatarHair,
		})
end
setmetatable(HairDB, nil)

local P = {
	Faces = FaceDB,
	Hairs = HairDB,
}
function P.get_player_head(gender,face,hair,haircolor)
	local human = DY_DATA:get_self()
	if gender == nil then gender = human.gender end
	if face == nil then face = human.face end
	if hair == nil then hair = human.hair end
	if haircolor == nil then haircolor = human.haircolor end

	local GenderFaces = FaceDB[gender]
	local playerface ="avatarfaceM1"
	if GenderFaces then
		for i,v in ipairs(GenderFaces) do
			if face == v.id then
				playerface = v.avatarFace
				break
			end
		end
	end

	local GenderHairs = HairDB[gender]
	local playerhair ="avatarhairM2"
	if GenderHairs then
		for i,v in ipairs(GenderHairs) do
			if hair == v.id then
				playerhair = v.avatarHair
				break
			end
		end
	end

	return playerface,playerhair.."_"..haircolor
end

return P
