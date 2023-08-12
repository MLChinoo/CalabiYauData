local GuideSubTaskTipsMediator = class("GuideSubTaskTipsMediator", PureMVC.Mediator)
function GuideSubTaskTipsMediator:OnRegister()
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  viewComponent.OnInitPanelEvent:Add(self.GuideSubTaskTipsInit, self)
end
function GuideSubTaskTipsMediator:GuideSubTaskTipsInit(InData)
  local viewComponent = self.viewComponent
  if not (InData and InData.TipData and viewComponent) or self.bInit then
    return
  end
  LogInfo("GuideSubTaskTipsMediator", "GuideSubTaskTipsInit")
  self.bInit = true
  if viewComponent.TextBlock_Name then
    viewComponent.TextBlock_Name:SetText(InData.TipData)
  end
end
return GuideSubTaskTipsMediator
