local DB = {}

local FUNCTION = dofile("config/function_function")
for _,v in ipairs(FUNCTION) do
	local data = {}
	data.ID = v.ID
	data.ui = v.ui
	DB[v.ID] = data
end

local P = {}
function P.get_dat(dat) return DB[dat] end
function P.open(obj, dat)
	local Data = DB[dat]
	if Data then
		ui.open(Data.ui, nil, { obj = obj, })
	else
		_G.UI.Toast.norm(TEXT.BUILDING_FUNCTION_UNOPEN)
		libunity.LogE("function_function表中未包含ID={0}的字段。", dat)
	end
end

return P
