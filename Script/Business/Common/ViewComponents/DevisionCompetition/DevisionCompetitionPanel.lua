local DevisionCompetitionPanel = class("DevisionCompetitionPanel", PureMVC.ViewComponentPanel)
function DevisionCompetitionPanel:Construct()
  DevisionCompetitionPanel.super.Construct(self)
end
function DevisionCompetitionPanel:Destruct()
  DevisionCompetitionPanel.super.Destruct(self)
end
function DevisionCompetitionPanel:UpdateView(datas)
  if self.CP_Parent and datas then
    for index = 1, self.CP_Parent:GetChildrenCount() do
      local img = self.CP_Parent:GetChildAt(index - 1)
      if img then
        local result = datas[index]
        if result then
          img:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          img:SetColorAndOpacity(self.ImageColorArray:Get(result + 1))
        else
          img:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
    end
    local DivisionCnt = 5
    local basicProxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
    if basicProxy then
      DivisionCnt = basicProxy:GetParameterIntValue("5910")
    end
    if self.Text_Toal then
      self.Text_Toal:SetText(#datas .. "/" .. DivisionCnt)
    end
  end
end
return DevisionCompetitionPanel
