local MichellePlaytimeTaskPage = class("MichellePlaytimeTaskPage", PureMVC.ViewComponentPage)
local MichellePlaytimeTaskPageMediator = require("Business/Activities/MichellePlaytime/Mediators/MichellePlaytimeTaskPageMediator")
function MichellePlaytimeTaskPage:ListNeededMediators()
  return {MichellePlaytimeTaskPageMediator}
end
function MichellePlaytimeTaskPage:Construct()
  MichellePlaytimeTaskPage.super.Construct(self)
  self.Btn_OneClickClaim.OnClicked:Add(self, self.OnClickOneClickClaim)
  self.Img_Background.OnMouseButtonDownEvent:Bind(self, self.OnClickClosePage)
  self.HotKeyButton_ClosePage.OnClickEvent:Add(self, self.OnClickClosePage)
  self.HotKeyButton_ClosePage:SetHotKeyIsEnable(true)
  self:UpdateConsumeNum()
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local staytype = MichellePlaytimeProxy.ActivityStayTypeEnum.EntryTaskPage
  MichellePlaytimeProxy:SetActivityEventInfoOfTLOG(staytype, 0)
  self.opentime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  self:SetOneClickClaimVisible()
  local taskIdList = MichellePlaytimeProxy:GetMPTaskIdList()
  if taskIdList and #taskIdList > 0 then
    table.sort(taskIdList, function(a, b)
      return a < b
    end)
    local taskItemListNum = self.VB_TaskList:GetChildrenCount()
    for index = 0, taskItemListNum - 1 do
      local taskItem = self.VB_TaskList:GetChildAt(index)
      if taskItem then
        local taskNum = taskItem:GetTaskNumber()
        local taskId = taskIdList[taskNum]
        if taskId then
          taskItem:SetTaskId(taskId)
          taskItem:InitTaskItemData()
        end
      end
    end
  else
    LogInfo("MichellePlaytimeTaskPage Construct:", "taskIdList is nil")
  end
end
function MichellePlaytimeTaskPage:Destruct()
  MichellePlaytimeTaskPage.super.Destruct(self)
  self.Btn_OneClickClaim.OnClicked:Remove(self, self.OnClickOneClickClaim)
  self.Img_Background.OnMouseButtonDownEvent:Unbind()
  self.HotKeyButton_ClosePage.OnClickEvent:Remove(self, self.OnClickClosePage)
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local timeStr = MichellePlaytimeProxy:GetRemainingTimeStrFromTimeStamp(UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime() - self.opentime)
  local staytype = MichellePlaytimeProxy.ActivityStayTypeEnum.EntryTaskPage
  MichellePlaytimeProxy:SetActivityEventInfoOfTLOG(staytype, timeStr)
end
function MichellePlaytimeTaskPage:OnClickClosePage()
  ViewMgr:ClosePage(self)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function MichellePlaytimeTaskPage:OnClickOneClickClaim()
  GameFacade:SendNotification(NotificationDefines.Activities.MichellePlaytime.OneClickClaim)
end
function MichellePlaytimeTaskPage:UpdateConsumeNum()
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  local consumId = MichellePlaytimeProxy:GetConsumeId()
  local warehouseProxy = GameFacade:RetrieveProxy(ProxyNames.WareHouseProxy)
  local itemCnt = warehouseProxy:GetItemCnt(consumId)
  self.Txt_GamePointNum:SetText(itemCnt)
end
function MichellePlaytimeTaskPage:SetOneClickClaimVisible()
  local MichellePlaytimeProxy = GameFacade:RetrieveProxy(ProxyNames.MichellePlaytimeProxy)
  if MichellePlaytimeProxy:HasTaskRewardPendingReceive() then
    self.Btn_OneClickClaim:SetIsEnabled(true)
  else
    self.Btn_OneClickClaim:SetIsEnabled(false)
  end
end
function MichellePlaytimeTaskPage:LuaHandleKeyEvent(key, inputEvent)
  return self.HotKeyButton_ClosePage:MonitorKeyDown(key, inputEvent)
end
return MichellePlaytimeTaskPage
