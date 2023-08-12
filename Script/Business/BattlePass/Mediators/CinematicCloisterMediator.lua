local CinematicCloisterMediator = class("CinematicCloisterMediator", PureMVC.Mediator)
local cinematicCloisterProxy
function CinematicCloisterMediator:OnRegister()
  self:GetViewComponent().onPageOpened:Add(self.OnViewComponentOpen, self)
  self:GetViewComponent().onFadeInCompleted:Add(self.OnShowRewardDisplay, self)
  self:GetViewComponent().onItemSelected:Add(self.OnCinematicCloisterItemSelected, self)
  cinematicCloisterProxy = GameFacade:RetrieveProxy(ProxyNames.CinematicCloisterProxy)
end
function CinematicCloisterMediator:OnRemove()
  self:GetViewComponent().onPageOpened:Remove(self.OnViewComponentOpen, self)
  self:GetViewComponent().onItemSelected:Remove(self.OnCinematicCloisterItemSelected, self)
end
function CinematicCloisterMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattlePass.CinematicCloisterCmd
  }
end
function CinematicCloisterMediator:HandleNotification(notification)
  local noteBody = notification:GetBody()
  if notification:GetType() == NotificationDefines.BattlePass.CinematicCloistertype.CinematicPlayStoped then
    self:OnCinematicPlayCompleted(noteBody.sequenceId)
  end
end
function CinematicCloisterMediator:OnViewComponentOpen()
  if cinematicCloisterProxy then
    local cinematicCloisterList = cinematicCloisterProxy:GetCinematicCloisterDatas()
    self:GetViewComponent():UpdateDatas(cinematicCloisterList)
    if cinematicCloisterProxy:GetSelectedIndex() then
      self:GetViewComponent():UpdateCinematicCloisterItemSelectedState(cinematicCloisterProxy:GetSelectedIndex())
    end
  end
end
function CinematicCloisterMediator:OnCinematicCloisterItemSelected(index, chapterId)
  cinematicCloisterProxy:UpdateSelectedIndex(index)
  local pageData = {
    contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Confirm_PlaySequence"),
    confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Play"),
    returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Cancel"),
    cb = function(bConfirm)
      if bConfirm then
        cinematicCloisterProxy:PlayCinematicChapter(cinematicCloisterProxy:GetSelectedIndex())
      else
        ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.MsgDialogPage)
      end
    end
  }
  ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.MsgDialogPage, false, pageData)
end
function CinematicCloisterMediator:OnCinematicPlayCompleted(sequenceId)
  self.viewComponent:OnCinematicCloisterItemCompleted(sequenceId)
end
function CinematicCloisterMediator:OnShowRewardDisplay()
  if cinematicCloisterProxy then
    local CinematicRewards = cinematicCloisterProxy:GetCinematicRewards()
    if CinematicRewards and CinematicRewards.itemList and #CinematicRewards.itemList > 0 then
      ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.RewardDisplayPage, true, CinematicRewards)
      cinematicCloisterProxy:ClearCinematicRewards()
    end
  end
end
return CinematicCloisterMediator
