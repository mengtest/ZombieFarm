--
-- @file    ui/com/lc_mbmaterialsource.lua
-- @author  xingweizhen
-- @date    2018-05-08 10:38:31
-- @desc    MBMaterialSource
--

local self = ui.new()
local _ENV = self

local Number2Alphabet_Tb = {
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "G", "K", "L", "M", 
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", [0] = "Z",
}

local function Number2Alphabet(num)
	local rst = ""

	while( num ~= 0 ) do
		local cnt = math.floor((num - 1) / 26) + 1
		local v = math.floor(num % 26)
		rst = rst..Number2Alphabet_Tb[v]
		num = cnt - 1
	end
	return string.reverse(rst)
end

local function rfsh_content_view()
	local SubMain = Ref.SubMain
	local Params = _G.UI.MBox.get().Params

	local Mat = Params.Mat

	Mat:show_view(SubMain.SubMat)

	local MatBase = Mat:get_base_data()
	SubMain.lbMatName.text = cfgname(MatBase)
	SubMain.lbMatDesc.text = MatBase.desc
	SubMain.lbSources.text = MatBase.source

	self.Machinings = config("unitlib").get_machinings_for_item(Mat.dat)
	libugui.SetLoopCap(SubMain.SubMachining.SubView.GrpMachinings.go, #Machinings, true)

	libugui.SetVisible(GO(SubMain.SubMachining.go, "lbMachining_"), #Machinings > 0)
end

--!* [开始] 自动生成函数 *--

function on_submain_btnclose_click(btn)
	_G.UI.MBox.on_btncancel_click()
end

function on_machining_ent(go, i)
	local n = i + 1
	local Machining = Machinings[n]
	local Ent = ui.ref(go)
	ui.group("FlexItem=", Ent.GrpMats, nil, "entMat")
	local Sub = ui.gen("FlexItem=", Ent.SubProduct, "SubItem")

	Ent.lbNum.text = Number2Alphabet(n)

	local Formula = Machining.Formula
	local Product = ItemDEF.gen(Formula.Product)
	Product:show_view(Sub)
	Ent.lbTime.text = os.secs2time(nil, Formula.duration)

	Ent.GrpMats:dup(#Formula.Mats, function (i, Ent, isNew)
		ItemDEF.gen(Formula.Mats[i]):show_view(Ent)
	end)

	Ent.SubMachine.lbMachine.text = Machining.Machine.name
end
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubMachining.SubView.GrpMachinings)
	--!* [结束] 自动生成代码 *--

	local flex_itement = _G.PKG["ui/util"].flex_itement
	flex_itement(Ref.SubMain, "SubMat")

	self.ItemDEF = _G.DEF.Item
end

function init_logic()
	rfsh_content_view()
end

function show_view()

end

function on_recycle()

end

return self

