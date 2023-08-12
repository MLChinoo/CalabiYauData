local RoleWarmUpClewPage = class("RoleWarmUpClewPage", PureMVC.ViewComponentPage)
function RoleWarmUpClewPage:ListNeededMediators()
  return {}
end
function RoleWarmUpClewPage:InitializeLuaEvent()
end
function RoleWarmUpClewPage:OnOpen(luaOpenData, nativeOpenData)
  self.Button_Blank.OnClicked:Add(self, self.OnClickCloseBtn)
  self:UpdataUI()
  local RoleWarmUpProxy = GameFacade:RetrieveProxy(ProxyNames.RoleWarmUpProxy)
  if RoleWarmUpProxy then
    RoleWarmUpProxy:SendTLOG(RoleWarmUpProxy.ActivityStayTypeEnum.EntryClewPage, 0)
  end
end
function RoleWarmUpClewPage:UpdataUI()
  self.index = 0
  for i = 1, 4 do
    self["ClewItem_" .. i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local RoleWarmUpProxy = GameFacade:RetrieveProxy(ProxyNames.RoleWarmUpProxy)
  if RoleWarmUpProxy then
    self.phaseIndex = RoleWarmUpProxy:GetPhaseIndex()
    for i = 1, 5 do
      if i <= self.phaseIndex then
        local PhaseDesc = RoleWarmUpProxy:GetPhaseDescByID(i)
        if PhaseDesc and "" ~= PhaseDesc then
          if self.index + 1 > 4 then
            self.phaseIndexText:SetText(tostring(self.index))
            return
          end
          self.index = self.index + 1
          self["ClewItem_" .. self.index].PhaseDescText:SetText(PhaseDesc)
          self:SetImageByPaperSprite(self["ClewItem_" .. self.index].PhaseImage, self.PhaseImageList:Get(self.index))
          self["ClewItem_" .. self.index]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        end
      elseif i < 5 then
        self["ClewItem_" .. i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    self.phaseIndexText:SetText(tostring(self.index))
  end
end
function RoleWarmUpClewPage:OnClose()
  self.Button_Blank.OnClicked:Remove(self, self.OnClickCloseBtn)
  local RoleWarmUpProxy = GameFacade:RetrieveProxy(ProxyNames.RoleWarmUpProxy)
  if RoleWarmUpProxy then
    RoleWarmUpProxy:SendTLOG(RoleWarmUpProxy.ActivityStayTypeEnum.QuitClewPage, 0)
  end
end
function RoleWarmUpClewPage:OnClickCloseBtn()
  LogDebug("RoleWarmUpClewPage", "OnClickCloseBtn")
  ViewMgr:ClosePage(self)
end
function RoleWarmUpClewPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName then
    if inputEvent == UE4.EInputEvent.IE_Released then
      self:OnClickCloseBtn()
    end
    return true
  else
    return false
  end
end
return RoleWarmUpClewPage
