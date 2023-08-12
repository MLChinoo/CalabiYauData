local SettingOperationMainPage = class("SettingOperationMainPage", PureMVC.ViewComponentPage)
local SettingOperationMainPageMediator = require("Business/Setting/Mediators/Mobile/SettingOperationMainPageMediator")
function SettingOperationMainPage:ListNeededMediators()
  return {SettingOperationMainPageMediator}
end
function SettingOperationMainPage:InitializeLuaEvent()
  self.WBP_SettingDragPanel_MB:InitView(self)
  self.WBP_OperationControllerSetting_MB:InitView(self)
  self.WBP_SettingDragPanel_MB:SetScaleProgressBar(self.WBP_OperationControllerSetting_MB.WBP_SettingSlider_Size)
  self:SetDragItemByDragIndex("LeftFire")
  TimerMgr:AddTimeTask(1, 0, 1, function()
    local geometry = self.Image_53:GetCachedGeometry()
    local lsize1 = UE4.USlateBlueprintLibrary.GetLocalSize(geometry)
    geometry = self.CanvasPanel_1:GetCachedGeometry()
    local lsize2 = UE4.USlateBlueprintLibrary.GetLocalSize(geometry)
    self.WBP_SettingDragPanel_MB:SetAdaptionValue((lsize1.X - lsize2.X) / 2)
  end)
end
function SettingOperationMainPage:SetDragItemByDragIndex(dragIndex)
  if self.WBP_SettingDragPanel_MB.m_FigureCnt == nil or 0 == self.WBP_SettingDragPanel_MB.m_FigureCnt then
    local dragItem = self.WBP_SettingDragPanel_MB:GetDragItemByIndex(dragIndex)
    self.WBP_SettingDragPanel_MB:SetDragItem(dragItem)
    self.WBP_OperationControllerSetting_MB:SetDragItem(dragItem)
  end
end
function SettingOperationMainPage:OnClose()
  GameFacade:SendNotification(NotificationDefines.Setting.CustomLayoutCloseNtf)
end
function SettingOperationMainPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "A" == keyName then
    self.WBP_SettingDragPanel_MB:RecordIndex()
  elseif "B" == keyName then
    self.WBP_SettingDragPanel_MB:SetFigureIndex()
  end
  return false
end
function SettingOperationMainPage:SetLayout(pageIndex)
  self.WBP_SettingDragPanel_MB:SetLayout(pageIndex)
  local dragIndex = self.WBP_SettingDragPanel_MB.DragItem.indexName
  self:SetDragItemByDragIndex(dragIndex)
end
return SettingOperationMainPage
