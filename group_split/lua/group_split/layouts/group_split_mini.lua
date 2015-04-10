
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

function SetLayout()
   -- local controls = import('/mods/group_split/lua/group_split/group_split.lua').controls
   -- 
   -- controls.bgTop:SetTexture(UIUtil.UIFile('/game/bracket-left/bracket_bmp_t.dds'))
   -- controls.bgStretch:SetTexture(UIUtil.UIFile('/game/bracket-left/bracket_bmp_m.dds'))
   -- controls.bgBottom:SetTexture(UIUtil.UIFile('/game/bracket-left/bracket_bmp_b.dds'))
   -- 
   -- LayoutHelpers.AtLeftIn(controls.bgTop, controls.container)
   -- LayoutHelpers.AtLeftIn(controls.bgBottom, controls.container)
   -- 
   -- controls.bgTop.Bottom:Set(function() return controls.container.Top() + 70 end)
   -- controls.bgBottom.Top:Set(function() return math.max(controls.bgTop.Bottom(), controls.container.Bottom()-20) end)
   -- controls.bgStretch.Top:Set(controls.bgTop.Bottom)
   -- controls.bgStretch.Bottom:Set(controls.bgBottom.Top)
   -- controls.bgStretch.Right:Set(function() return controls.bgTop.Right() - 7 end)
   -- 
   -- controls.container.Height:Set(20)
   -- controls.container.Width:Set(60)
   -- LayoutHelpers.AtTopIn(controls.container, controls.parent, 153)
   -- LayoutHelpers.AtLeftIn(controls.container, controls.parent)
   -- 
   -- LayoutHelpers.AtTopIn(controls.collapseArrow, controls.container, 22)
   -- LayoutHelpers.AtLeftIn(controls.collapseArrow, controls.parent, -3)
   -- 
   -- controls.collapseArrow.Depth:Set(function() return controls.bgTop.Depth() + 1 end)
   -- controls.collapseArrow:SetTexture(UIUtil.UIFile('/game/tab-r-btn/tab-close_btn_up.dds'))
   -- controls.collapseArrow:SetNewTextures(UIUtil.UIFile('/game/tab-r-btn/tab-close_btn_up.dds'),
   --     UIUtil.UIFile('/game/tab-r-btn/tab-open_btn_up.dds'),
   --     UIUtil.UIFile('/game/tab-r-btn/tab-close_btn_over.dds'),
   --     UIUtil.UIFile('/game/tab-r-btn/tab-open_btn_over.dds'),
   --     UIUtil.UIFile('/game/tab-r-btn/tab-close_btn_dis.dds'),
   --     UIUtil.UIFile('/game/tab-r-btn/tab-open_btn_dis.dds'))
end

function LayoutGroups()
   -- local controls = import('/mods/group_split/lua/group_split/group_split.lua').controls
   -- local groupOrder = import('/mods/group_split/lua/group_split/group_split.lua').groupOrder
   -- local prevControl = false
   -- local firstControlTop = 0
   -- 
	--for index, key in groupOrder do
   --     local i = key
   --     if not controls.groups[i] then
   --         continue
   --     end
   --     local control = controls.groups[i]
   --     if prevControl then
   --         LayoutHelpers.Below(control, prevControl, -8)
   --     else
   --         LayoutHelpers.AtTopIn(control, controls.container, 12)
   --         LayoutHelpers.AtLeftIn(control, controls.container, 19)
   --         firstControlTop = control.Top()
   --     end
   --     prevControl = control
   -- end
   -- if controls.groups and table.getsize(controls.groups) > 0 then
   --     controls.container.Bottom:Set(prevControl.Bottom)
   --     controls.container:Show()
   --     controls.collapseArrow:Show()
   -- else
   --     controls.container.Height:Set(20)
   --     controls.container:Hide()
   --     controls.collapseArrow:Hide()
   -- end
end
