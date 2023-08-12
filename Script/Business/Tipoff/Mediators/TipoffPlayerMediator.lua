local TipoffPlayerMediator = class("TipoffPlayerMediator", PureMVC.Mediator)
function TipoffPlayerMediator:ListNotificationInterests()
  return {
    NotificationDefines.TipoffPlayer.TipoffPlayerPageInit,
    NotificationDefines.TipoffPlayer.TipoffBehaviorChooseMax,
    NotificationDefines.TipoffPlayer.CloseTipOffPlayerPage,
    NotificationDefines.TipoffPlayer.ResTipoffPlayerInfo,
    NotificationDefines.TipoffPlayer.TipoffCategoryChange,
    NotificationDefines.Setting.SettingCloseNtf
  }
end
function TipoffPlayerMediator:OnViewComponentPagePostOpen(luaData, OriginalOpenData)
  if not luaData then
    return
  end
  if not self.IsOpened then
    GameFacade:SendNotification(NotificationDefines.TipoffPlayer.TipoffPlayerDataInitCmd, luaData)
    GameFacade:SendNotification(NotificationDefines.TipoffPlayer.TipoffPlayerPageInit, luaData)
    self.IsOpened = true
  end
end
function TipoffPlayerMediator:OnRegister()
  TipoffPlayerMediator.super.OnRegister(self)
  if self:GetViewComponent() then
    self:GetViewComponent().ActionCancelEvent:Add(self.OnHandleCancelBtnEvent, self)
    self:GetViewComponent().ActionComfirmEvent:Add(self.OnHandleComfirmEvent, self)
    self:GetViewComponent().ActionEditBoxCommitEvent:Add(self.OnHandleEditorBoxCommit, self)
  end
  self.IsOpened = false
  LogDebug("TipoffPlayerMediator", "TipoffPlayerMediator::OnRegister Finished.")
end
function TipoffPlayerMediator:OnRemove()
  TipoffPlayerMediator.super.OnRemove(self)
  self.IsOpened = false
  if self:GetViewComponent() then
    self:GetViewComponent().ActionCancelEvent:Remove(self.OnHandleCancelBtnEvent, self)
    self:GetViewComponent().ActionComfirmEvent:Remove(self.OnHandleComfirmEvent, self)
    self:GetViewComponent().ActionEditBoxCommitEvent:Remove(self.OnHandleEditorBoxCommit, self)
  end
  LogDebug("TipoffPlayerMediator", "TipoffPlayerMediator::OnRemove Finished.")
end
function TipoffPlayerMediator:HandleNotification(notification)
  if not notification then
    return
  end
  local ntfName = notification:GetName()
  local ntfBody = notification:GetBody()
  if ntfName == NotificationDefines.TipoffPlayer.TipoffPlayerPageInit then
    self:InitView(ntfBody)
  elseif ntfName == NotificationDefines.TipoffPlayer.TipoffBehaviorChooseMax then
    self:OnHandleTipoffBehaviorChooseMax(ntfBody)
  elseif ntfName == NotificationDefines.TipoffPlayer.CloseTipOffPlayerPage then
    self:CloseView()
  elseif ntfName == NotificationDefines.Setting.SettingCloseNtf then
    self:CloseView()
  elseif ntfName == NotificationDefines.TipoffPlayer.ResTipoffPlayerInfo then
    self:ResTipoffPlayerInfo()
  elseif ntfName == NotificationDefines.TipoffPlayer.TipoffCategoryChange then
    self:OnHandleTipoffCategoryChange()
  end
end
function TipoffPlayerMediator:InitView(data)
  LogDebug("radmac Log", "Tipoff Init Start")
  if self:GetViewComponent() == nil or not data then
    return
  end
  local TipoffPlayerDataProxy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy)
  if TipoffPlayerDataProxy then
    local CurCategoryType = TipoffPlayerDataProxy:GetCurCategoryType()
    if self:GetViewComponent().TipoffTabItemList then
      local TipoffCategory = TipoffPlayerDataProxy:GetTipOffTabTableRow(data.EnteranceType)
      if TipoffCategory then
        for i = 1, #self:GetViewComponent().TipoffTabItemList do
          local TabUIItem = self:GetViewComponent().TipoffTabItemList[i]
          local ItemData
          if i <= TipoffCategory.CategoryTypes:Num() then
            ItemData = {
              CategoryType = TipoffCategory.CategoryTypes:Get(i),
              CategoryDescType = TipoffCategory.CategoryDescTypes:Get(i)
            }
          end
          if TabUIItem then
            TabUIItem:InitView(ItemData)
            TabUIItem:OnRefreshItem()
            if ItemData then
              TabUIItem:SetIsChecked(ItemData.CategoryType == CurCategoryType)
            else
              TabUIItem:SetIsChecked(false)
            end
          end
        end
      end
    end
  end
  self:RefreshReasonCheckBox()
  local TipoffConfrm_Btn = self:GetViewComponent().TipoffConfirm_Btn
  if TipoffConfrm_Btn then
    TipoffConfrm_Btn:SetTimerIsShow(false)
    TipoffConfrm_Btn:SetRedDotVisible(false)
    TipoffConfrm_Btn.Tex_NameCN:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Tipoff, "Tipoff"))
    UE4.UPMWidgetBlueprintLibrary.SetWidgetVisible(TipoffConfrm_Btn, UE4.ESlateVisibility.Visible)
  end
  local TipoffCancel_Btn = self:GetViewComponent().TipoffCancel_Btn
  if TipoffCancel_Btn then
    TipoffCancel_Btn:SetTimerIsShow(false)
    TipoffCancel_Btn:SetRedDotVisible(false)
    TipoffCancel_Btn.Tex_NameCN:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Tipoff, "Tipoff_Cancel"))
    UE4.UPMWidgetBlueprintLibrary.SetWidgetVisible(TipoffCancel_Btn, UE4.ESlateVisibility.Visible)
  end
  if self:GetViewComponent().TipoffReason_EditableTextBox then
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Tipoff, "Tipoff_HintFormat")
    local Proxy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy)
    local MaxContentNum = 300
    if Proxy then
      MaxContentNum = Proxy:GetMaxTipoffContentNum()
    end
    LogDebug("rrrrrrr|", tostring(MaxContentNum))
    LogDebug("rrrrrrr|", string.format(formatText, tostring(MaxContentNum)))
    self:GetViewComponent().TipoffReason_EditableTextBox:SetHintText(string.format(formatText, tostring(MaxContentNum)))
  end
  LogDebug("TipoffPlayerMediator", "===============================")
  LogDebug(TableToString(data))
  local tipoffPlayerDataProxy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy)
  if tipoffPlayerDataProxy then
    if data.TargetName then
      self:GetViewComponent().PlayerName:SetText(data.TargetName)
    else
      local playerName = tipoffPlayerDataProxy:GetTipoffPlayerName(data.TargetUID, data.EnteranceType)
      if playerName then
        self:GetViewComponent().PlayerName:SetText(playerName)
      end
    end
  end
end
function TipoffPlayerMediator:OnHandleTipoffBehaviorChooseMax(data)
  LogDebug("TipoffPlayerMediator", "OnHandleTipoffBehaviorChooseMax")
  local ReasonType = data.ReasonType
  if self:GetViewComponent() and self:GetViewComponent().TipoffBehaviorCheckBoxItemList then
    for key, value in pairs(self:GetViewComponent().TipoffBehaviorCheckBoxItemList) do
      if value:GetTipOffReasonType() == ReasonType then
        value:SetIsChecked(false)
      end
    end
  end
  local Text = ConfigMgr:FromStringTable(StringTablePath.ST_Tipoff, "Tipoff_SelectMax")
  ShowCommonTip(Text)
  LogDebug("TipoffPlayerMediator", "OnHandleTipoffBehaviorChooseMax Finished .")
end
function TipoffPlayerMediator:OnHandleCancelBtnEvent()
  LogDebug("TipoffPlayerMediator", "TipoffPlayerMediator OnHandleCancelBtnEvent Call .")
  ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.TipoffPlayerPage)
end
function TipoffPlayerMediator:OnHandleComfirmEvent()
  LogDebug("TipoffPlayerMediator", "TipoffPlayerMediator OnHandleComfirmEvent Call .")
  if self:GetViewComponent() and self:GetViewComponent().TipoffReason_EditableTextBox then
    GameFacade:SendNotification(NotificationDefines.TipoffPlayer.TipoffContentUpdateCmd, self:GetViewComponent().TipoffReason_EditableTextBox:GetText())
  end
  GameFacade:SendNotification(NotificationDefines.TipoffPlayer.TipoffPlayerComfirmCmd)
end
function TipoffPlayerMediator:OnHandleEditorBoxCommit(inText, commitMethod)
  if not inText then
    return
  end
  if commitMethod == UE4.ETextCommit.OnUserMovedFocus then
    local tipoffPlayerDataProxy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy)
    if not tipoffPlayerDataProxy then
      return
    end
    local context = inText
    local maxNum = tipoffPlayerDataProxy:GetMaxTipoffContentNum()
    if maxNum < utf8.len(context) then
      context = self:CommitSub(context, 1, maxNum)
    end
    self:GetViewComponent().TipoffReason_EditableTextBox:SetText(context)
  end
end
function TipoffPlayerMediator:CloseView()
  LogDebug("TipoffPlayerMediator", "CloseViewCloseView")
  if self:GetViewComponent() then
    ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.TipoffPlayerPage)
  end
end
function TipoffPlayerMediator:ResTipoffPlayerInfo()
end
function TipoffPlayerMediator:OnHandleTipoffCategoryChange()
  if not self:GetViewComponent() then
    return
  end
  if not self:GetViewComponent().TipoffTabItemList then
    return
  end
  if #self:GetViewComponent().TipoffTabItemList <= 0 then
    return
  end
  local TipoffPlayerDataProxy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy)
  if not TipoffPlayerDataProxy then
    return
  end
  local CurSelectedCategoryType = TipoffPlayerDataProxy:GetCurCategoryType()
  for i = 1, #self:GetViewComponent().TipoffTabItemList do
    local CategoryTypeItem = self:GetViewComponent().TipoffTabItemList[i]
    if CategoryTypeItem then
      local CategoryType = CategoryTypeItem:GetCurCategoryType()
      CategoryTypeItem:SetIsChecked(CategoryType == CurSelectedCategoryType)
    end
  end
  self:RefreshReasonCheckBox()
end
function TipoffPlayerMediator:RefreshReasonCheckBox()
  local TipoffPlayerDataProxy = GameFacade:RetrieveProxy(ProxyNames.TipoffPlayerDataProxy)
  if not TipoffPlayerDataProxy then
    return
  end
  local CurCategoryType = TipoffPlayerDataProxy:GetCurTipoffData() and TipoffPlayerDataProxy:GetCurTipoffData().CurCategoryType or 0
  if CurCategoryType > 0 and self:GetViewComponent().TipoffBehaviorCheckBoxItemList then
    local TipoffBehaviorData = TipoffPlayerDataProxy:GetTipoffBehaviorTableRow()
    if TipoffBehaviorData then
      local CurCategoryTypeData = TipoffBehaviorData[CurCategoryType]
      if CurCategoryTypeData then
        for i = 1, #self:GetViewComponent().TipoffBehaviorCheckBoxItemList do
          local CheckBoxItemPanel = self:GetViewComponent().TipoffBehaviorCheckBoxItemList[i]
          if CheckBoxItemPanel then
            local ReasonTypeData
            if i <= CurCategoryTypeData.ReasonTypes:Num() and i <= CurCategoryTypeData.ReasonDescTypes:Num() then
              ReasonTypeData = {
                ReasonType = CurCategoryTypeData.ReasonTypes:Get(i),
                ReasonDescType = CurCategoryTypeData.ReasonDescTypes:Get(i)
              }
            end
            if ReasonTypeData and ReasonTypeData.ReasonType > 0 then
              CheckBoxItemPanel:InitView(ReasonTypeData)
              CheckBoxItemPanel:UpdateItemView()
              CheckBoxItemPanel:SetIsChecked(TipoffPlayerDataProxy:IsTipoffReasonDataExist(ReasonTypeData.ReasonType))
              UE4.UPMWidgetBlueprintLibrary.SetWidgetVisible(CheckBoxItemPanel, UE4.ESlateVisibility.Visible)
            else
              UE4.UPMWidgetBlueprintLibrary.SetWidgetVisible(CheckBoxItemPanel, UE4.ESlateVisibility.Collapsed)
            end
          end
        end
      end
    end
  end
end
function TipoffPlayerMediator:CommitSub(s, i, j)
  i = utf8.offset(s, i)
  j = utf8.offset(s, j + 1) - 1
  return string.sub(s, i, j)
end
return TipoffPlayerMediator
