local OperationControllerSettingMB = class("OperationControllerSettingMB", PureMVC.ViewComponentPanel)
function OperationControllerSettingMB:InitView()
end
function OperationControllerSettingMB:InitializeLuaEvent()
  self.Btn_Close.OnClicked:Add(self, OperationControllerSettingMB.CloseFunc)
  self.Btn_Reset.OnClicked:Add(self, OperationControllerSettingMB.ResetFunc)
  self.Btn_Reset_Current.OnClicked:Add(self, OperationControllerSettingMB.ResetCurrentFunc)
  self.Btn_Save.OnClicked:Add(self, OperationControllerSettingMB.SaveFunc)
  self.Button_DropDown.OnClicked:Add(self, OperationControllerSettingMB.DropDownFunc)
  self.Btn_Up.OnClicked:Add(self, OperationControllerSettingMB.UpFunc)
  self.Btn_Down.OnClicked:Add(self, OperationControllerSettingMB.DownFunc)
  self.Btn_Left.OnClicked:Add(self, OperationControllerSettingMB.LeftUp)
  self.Btn_Right.OnClicked:Add(self, OperationControllerSettingMB.RightFunc)
  self:SetOperateSubPanelVis(false)
  self.WBP_SettingSlider_Alpha:InitView(self)
  self.WBP_SettingSlider_Size:InitView(self)
  local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local Map = SettingConfigProxy:GetCommonConfigMap()
  self.commonConfigMap = Map
  self.moveDis = self.commonConfigMap.moveDistance
  self:SetOperateSubPanelVis(true)
  self.WBP_SettingIndexItem_MB:InitView(self)
end
function OperationControllerSettingMB:CloseFunc()
  LogInfo("OperationControllerSettingMB", "CloseFunc")
  local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
  if SettingOperationProxy:CheckTemplateDataChanged() then
    local pageData = {
      contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "3"),
      confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "4"),
      returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "5"),
      source = self,
      cb = self.OnSaveSetting
    }
    ViewMgr:OpenPage(self, UIPageNameDefine.MsgDialogPage, false, pageData)
  else
    self:OnSaveSetting(false)
  end
end
function OperationControllerSettingMB:OnSaveSetting(bSave)
  local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
  if bSave then
    SettingOperationProxy:SaveAllData()
  else
    SettingOperationProxy:NotSaveData()
  end
  ViewMgr:ClosePage(self, UIPageNameDefine.SettingOperatePage)
end
function OperationControllerSettingMB:ResetFunc()
  LogInfo("OperationControllerSettingMB", "ResetFunc")
  GameFacade:SendNotification(NotificationDefines.Setting.MBResetLayout)
  self:RefreshView()
end
function OperationControllerSettingMB:ResetCurrentFunc()
  GameFacade:SendNotification(NotificationDefines.Setting.MBResetLayout, {
    indexName = self.DragItem.indexName
  })
  self:RefreshView()
end
function OperationControllerSettingMB:SaveFunc()
  LogInfo("OperationControllerSettingMB", "SaveFunc2233332")
  local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
  SettingOperationProxy:SaveAllData()
  GameFacade:SendNotification(NotificationDefines.Setting.MBSaveLayout)
  ViewMgr:ClosePage(self, UIPageNameDefine.SettingOperatePage)
end
function OperationControllerSettingMB:DropDownFunc()
  LogInfo("OperationControllerSettingMB", "DropDownFunc")
  self:SetOperateSubPanelVis(not self.bShowSubPanelVis)
end
function OperationControllerSettingMB:UpFunc()
  local ox, oy = self.DragItem:CorrectMoveOffset(0, -self.moveDis)
  self.DragItem:MoveByOffset(ox, oy)
end
function OperationControllerSettingMB:DownFunc()
  local ox, oy = self.DragItem:CorrectMoveOffset(0, self.moveDis)
  self.DragItem:MoveByOffset(ox, oy)
end
function OperationControllerSettingMB:LeftUp()
  local ox, oy = self.DragItem:CorrectMoveOffset(-self.moveDis, 0)
  self.DragItem:MoveByOffset(ox, oy)
end
function OperationControllerSettingMB:RightFunc()
  local ox, oy = self.DragItem:CorrectMoveOffset(self.moveDis, 0)
  self.DragItem:MoveByOffset(ox, oy)
end
function OperationControllerSettingMB:SetOperateSubPanelVis(bVis)
  self.bShowSubPanelVis = bVis
  if bVis then
    self.CanvasPanel_114:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SizeBox_4:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SizeBox_SubPanel:SetHeightOverride(502)
    self.Img_Arrow:SetRenderScale(UE4.FVector2D(1, 1))
  else
    self.CanvasPanel_114:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SizeBox_4:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SizeBox_SubPanel:SetHeightOverride(113)
    self.Img_Arrow:SetRenderScale(UE4.FVector2D(1, -1))
  end
end
function OperationControllerSettingMB:SetDragItem(dragItem)
  self.DragItem = dragItem
  self:RefreshView()
end
function OperationControllerSettingMB:RefreshView()
  if self.DragItem then
    if self.DragItem.indexName == "MoveLine" then
      self.WBP_SettingSlider_Alpha:SetIsEnabled(false)
      self.WBP_SettingSlider_Size:SetIsEnabled(false)
      self.WBP_SettingSlider_Alpha:SetCurrentValue(100)
      self.WBP_SettingSlider_Size:SetCurrentValue(100)
    else
      local currentData = self.DragItem.currentData
      local opa = currentData.opa
      local scale = currentData.scale
      local initScale = self.DragItem.InitScale
      self.WBP_SettingSlider_Alpha:SetIsEnabled(true)
      self.WBP_SettingSlider_Size:SetIsEnabled(true)
      self.WBP_SettingSlider_Alpha:SetCurrentValue(opa * 100)
      self.WBP_SettingSlider_Size:SetCurrentValue(scale * 100)
    end
  end
end
return OperationControllerSettingMB
