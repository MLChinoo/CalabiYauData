local PlayerNameMediator = require("Business/Apartment/Mediators/PlayerNameMediator")
local PlayerNamePage = class("PlayerNamePage", PureMVC.ViewComponentPage)
function PlayerNamePage:ListNeededMediators()
  return {PlayerNameMediator}
end
function PlayerNamePage:InitializeLuaEvent()
  self.InitPageEvent = LuaEvent.new()
end
function PlayerNamePage:OnOpen(luaOpenData, nativeOpenData)
  self:BindEvent()
  self.InitPageEvent()
  self:BindToAnimationFinished(self.Animation1, {
    self,
    self.CardAppearAniEnd
  })
  self:PlayAnimation(self.Animation1, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function PlayerNamePage:BindEvent()
  if self.Btn_RandomNick then
    self.Btn_RandomNick.OnClicked:Add(self, self.OnClickRandomNick)
  end
  if self.Btn_EnsureName_2 then
    self.Btn_EnsureName_2.OnClicked:Add(self, self.OnClickCreatePlayer)
  end
end
function PlayerNamePage:CardAppearAniEnd()
  self.Border_NickName:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_NickName:SetVisibility(UE4.ESlateVisibility.Visible)
  self:PlayAnimation(self.Animation3, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function PlayerNamePage:OnClose()
  self:ClearEnsureTimer()
  if self.Btn_RandomNick then
    self.Btn_RandomNick.OnClicked:Remove(self, self.OnClickRandomNick)
  end
  if self.Btn_EnsureName_2 then
    self.Btn_EnsureName_2.OnClicked:Remove(self, self.OnClickCreatePlayer)
  end
end
function PlayerNamePage:OnClickRandomNick()
  GameFacade:SendNotification(NotificationDefines.Login.NtfReqRandomName)
end
function PlayerNamePage:ShowInputName(RandomName)
  self.Txt_NickName:SetText(RandomName)
end
function PlayerNamePage:OnClickCreatePlayer()
  self:EnableAllInput(false)
  self.EnsureNameTimer = TimerMgr:AddTimeTask(5, 0, 1, function()
    self:EnableAllInput(true)
    self.EnsureNameTimer = nil
  end)
  GameFacade:SendNotification(NotificationDefines.Login.NtfDoCreatPlayer, self.Txt_NickName:GetText())
end
function PlayerNamePage:EnableAllInput(isEnable)
  self.Txt_NickName:SetIsReadOnly(not isEnable)
  self.Btn_EnsureName_2:SetIsEnabled(isEnable)
  self.Btn_RandomNick:SetIsEnabled(isEnable)
end
function PlayerNamePage:ClearEnsureTimer()
  if self.EnsureNameTimer then
    self.EnsureNameTimer:EndTask()
    self.EnsureNameTimer = nil
  end
end
function PlayerNamePage:PlayNamedAniAndClose()
  self:StopAnimation(self.Animation3)
  self:BindToAnimationFinished(self.Animation2, {
    self,
    self.ClosePage
  })
  self:PlayAnimation(self.Animation2, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function PlayerNamePage:ClosePage()
  local NewGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
  NewGuideProxy:SetCurComplete()
  ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.PlayerNamePage)
end
return PlayerNamePage
