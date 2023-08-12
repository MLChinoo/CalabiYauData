local BattlePassClueRewardPageMobile = class("BattlePassClueRewardPageMobile", PureMVC.ViewComponentPage)
local BattlePassClueRewardMediatorMobile = require("Business/BattlePass/Mediators/Mobile/Clue/BattlePassClueRewardMediatorMobile")
function BattlePassClueRewardPageMobile:ListNeededMediators()
  return {BattlePassClueRewardMediatorMobile}
end
function BattlePassClueRewardPageMobile:OnOpen(luaOpenData, nativeOpenData)
  if self.Btn_Reward then
    self.Btn_Reward.OnClickEvent:Add(self, self.OnBtnReward)
  end
  if self.Img_Close then
    self.Img_Close.OnMouseButtonDownEvent:Bind(self, self.OnBtnClose)
  end
end
function BattlePassClueRewardPageMobile:OnShow(luaOpenData, nativeOpenData)
  if luaOpenData then
    self:SwitchClueContent(luaOpenData)
  end
end
function BattlePassClueRewardPageMobile:OnClose()
  if self.Btn_Reward then
    self.Btn_Reward.OnClickEvent:Remove(self, self.OnBtnReward)
  end
  if self.Img_Close then
    self.Img_Close.OnMouseButtonDownEvent:Unbind()
  end
end
function BattlePassClueRewardPageMobile:OnBtnReward()
  GameFacade:SendNotification(NotificationDefines.BattlePass.ClueRewardCmd, self.clueId)
end
function BattlePassClueRewardPageMobile:OnBtnClose()
  ViewMgr:ClosePage(self)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function BattlePassClueRewardPageMobile:SwitchClueContent(data)
  if data then
    self.clueId = data.clueId
    if self.Txt_ClueTitle then
      self.Txt_ClueTitle:SetText(data.title)
    end
    if self.RichTxt_ClueContent then
      self.RichTxt_ClueContent:SetText(data.content)
    end
    if self.Btn_Reward then
      self.Btn_Reward:SetButtonIsEnabled(not data.isRewardRecevied and true or false)
      self.Btn_Reward:SetRedDotVisible(not data.isRewardRecevied and true or false)
    end
    if self.WidgetSwitcher_Reward then
      self.WidgetSwitcher_Reward:SetActiveWidgetIndex(data.isRewardRecevied and 1 or 0)
    end
    if self.Img_Prize then
      self:SetImageByTexture2D(self.Img_Prize, data.prizeInfo.img)
    end
    if self.Txt_Reward then
      self.Txt_Reward:SetText(data.prizeInfo.name)
    end
  end
end
function BattlePassClueRewardPageMobile:UpdateRewardState(clueId)
  if self.clueId == clueId then
    if self.Btn_Reward then
      self.Btn_Reward:SetButtonIsEnabled(false)
      self.Btn_Reward:SetRedDotVisible(false)
    end
    if self.WidgetSwitcher_Reward then
      self.WidgetSwitcher_Reward:SetActiveWidgetIndex(1)
    end
  end
end
return BattlePassClueRewardPageMobile
