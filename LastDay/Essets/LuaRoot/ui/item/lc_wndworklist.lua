--
-- @file    ui/item/lc_wndworklist.lua
-- @author  xingweizhen
-- @date    2018-01-04 15:58:02
-- @desc    WNDWorkList
--

local self = ui.new()
setfenv(1, self)
--!* [开始] 自动生成函数 *--
--!* [结束] 自动生成函数  *--

function init_view()
	ui.group(Ref.SubMain.SubScroll.SubView.GrpFormulas)
	--!* [结束] 自动生成代码 *--
end

function init_logic()
	local Obj = CTRL.get_obj(Context.obj)
	local ObjBase = Obj:get_base_data()
	local SubName = Ref.SubMain.SubName
	SubName.lbName.text = ObjBase.name

	local ItemDEF = _G.DEF.Item
	local WorkingLIB = config("workinglib")
	local Formulas = Context.Data.Formulas
	Ref.SubMain.SubScroll.SubView.GrpFormulas:dup(#Formulas, function (i, Ent, isNew)
		local Formula = WorkingLIB.get_dat(Formulas[i])
		ui.group(Ent.GrpMats)

		local Mats = Formula.Mats
		Ent.GrpMats:dup_combine(#Mats, "FlexItem=", function (i, Ent, isNew)
			local Mat = Mats[i]
			local Item = ItemDEF.new(Mat.id, Mat.amount)
			Item:show_view(Ent)
		end)

		local Product = Formula.Product
		local Item = ItemDEF.new(Product.id, Product.amount)
		ui.gen("FlexItem=", Ent.SubProduct, "SubItem")
		Item:show_view(Ent.SubProduct.SubItem)

		Ent.lbDura.text = os.last2string(Formula.duration, 4)
	end)
end

function show_view()
	
end

function on_recycle()
	
end

return self

