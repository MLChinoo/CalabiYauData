return {
  viewClassPath = "/Game/PaperMan/UI/BP/PC/Frontend/Apartment/Promise/WBP_ApartmentPromiseGridItem_PC.WBP_ApartmentPromiseGridItem_PC_C",
  widgetName = "Button_Clicked",
  clickfunc = function(view)
    view:OnClickButton()
  end,
  selectFunc = function(Arr)
    for i = 1, Arr:Num() do
      local ref = Arr:GetRef(i)
      local index = ref.Index
      if index and 1 == index then
        return ref
      end
    end
  end,
  continue = false
}
