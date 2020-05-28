--
-- @file    data/parser/formulalib.lua
-- @anthor  xingweizhen (weizhen.xing@funplus.com)
-- @date    2018-01-20 11:51:06
-- @desc    描述
--

local text_obj = config("textlib").text_obj

local DB = {}
local FORMULA = dofile("config/formula_formula")
for _,v in ipairs(FORMULA) do
	local Item = v.normalProduct:splitn(":")
	DB[v.formulaID] = {
		id = v.formulaID,
		group = v.formulaGroup, sort = v.sort,
		reqPlayerLevel = v.level,
		Item = { id = Item[1], amount = Item[2], },
		Mats = v.material:splitgn(":"),
		time = v.time / 1000,

		icon = v.icon,
	}
end
local AllFormulaArray = table.toarray(DB, function (a, b)
	if a.reqPlayerLevel ~= b.reqPlayerLevel then return a.reqPlayerLevel < b.reqPlayerLevel end
	if a.group ~= b.group then return a.group < b.group end
	if a.sort ~= b.sort then return a.sort < b.sort end
	return a.id < b.id
end)
local GrpFormulaArray = setmetatable({}, _G.MT.AutoGen)
for _,v in ipairs(AllFormulaArray) do
	table.insert(GrpFormulaArray[v.group], v)
end
setmetatable(GrpFormulaArray, nil)

local FORMULA_GRP = dofile("config/formula_formulagroup")
local GroupDB = {}
for _,v in ipairs(FORMULA_GRP) do
	table.insert(GroupDB, { id = v.ID, icon = v.icon, name = text_obj("formula_formulagroup", "groupName", v), })
end
table.sort(GroupDB, function (a, b) return a.id < b.id end)

local P = { }
function P.pairs() return pairs(DB) end
function P.get_dat(id) return DB[id] end

function P.groups() return ipairs(GroupDB) end

local FormulasFromMat = {}
function P.get_formulas_from_mat(dat)
	local Formulas = FormulasFromMat[dat]
	if Formulas == nil then
		local Formulas = {}
		for k,v in pairs(DB) do
			for _,Mat in ipairs(v.Mats) do
				if Mat.id == dat then
					table.insert(Formulas, k)
				break end
			end
		end
		FormulasFromMat[dat] = Formulas
	end

	return Formulas
end

function P.get_formula_list(group)
	return group and GrpFormulaArray[group] or AllFormulaArray
end

function P.get_formula_list_levelrang(maxlevel,minlevel)
	local Formulas = {}
	for _,v in pairs(AllFormulaArray) do
		if v.reqPlayerLevel and v.reqPlayerLevel <= maxlevel and v.reqPlayerLevel > minlevel then
			table.insert(Formulas, v)
		end
	end
	return Formulas
end

return P
