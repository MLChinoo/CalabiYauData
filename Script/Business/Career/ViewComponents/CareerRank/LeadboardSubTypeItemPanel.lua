local LeadboardSubTypeItemPanel = class("LeadboardSubTypeItemPanel", PureMVC.ViewComponentPanel)
local LeadboardSubTypeItemPanelMediator = require("Business/Career/Mediators/CareerRank/LeadboardSubTypeItemPanelMediator")
function LeadboardSubTypeItemPanel:ListNeededMediators()
  return {LeadboardSubTypeItemPanelMediator}
end
function LeadboardSubTypeItemPanel:Construct()
  LeadboardSubTypeItemPanel.super.Construct(self)
  local leaderboardContentDisplayControlCfg = ConfigMgr:GetLeaderboardContentDisplayControl()
  if leaderboardContentDisplayControlCfg then
    leaderboardContentDisplayControlCfg = leaderboardContentDisplayControlCfg:ToLuaTable()
    for row, value in pairs(leaderboardContentDisplayControlCfg) do
      if value.LeaderboardType == self.bp_leaderboardType then
        self.TextBlock_Template:SetText(value.LeaderboardName)
      end
    end
  end
  self.bIsChecked = false
  if self.CheckBox_Choose then
    self.CheckBox_Choose.OnCheckStateChanged:Add(self, self.OnCheckStateChanged)
  end
end
function LeadboardSubTypeItemPanel:Destruct()
  LeadboardSubTypeItemPanel.super.Destruct(self)
  if self.CheckBox_Choose then
    self.CheckBox_Choose.OnCheckStateChanged:Remove(self, self.OnCheckStateChanged)
  end
end
function LeadboardSubTypeItemPanel:OnCheckStateChanged(bIsChecked)
  local honorRankDataProxy = GameFacade:RetrieveProxy(ProxyNames.HonorRankDataProxy)
  if honorRankDataProxy:GetIsInLoadingData() then
    local tips = ConfigMgr:FromStringTable(StringTablePath.ST_Career, "RequestLeadboardTooFrequently")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tips)
    if self.CheckBox_Choose then
      self.CheckBox_Choose:SetIsChecked(false)
    end
    return
  end
  if not self.bIsChecked then
    self:SetBtnStyle(true)
  end
  if self.CheckBox_Choose then
    self.CheckBox_Choose:SetIsChecked(true)
  end
end
function LeadboardSubTypeItemPanel:SetBtnStyle(bIsChecked)
  self.bIsChecked = bIsChecked
  if bIsChecked then
    local ignoreLeadboardType = self.bp_leaderboardType
    GameFacade:SendNotification(NotificationDefines.Career.CareerRank.ClearAllLeadboardSubTypeBtnCheck, ignoreLeadboardType)
    local honorRankDataProxy = GameFacade:RetrieveProxy(ProxyNames.HonorRankDataProxy)
    honorRankDataProxy:SetCurrentReqLeadboardType(self.bp_leaderboardType)
    local rankReq = {}
    rankReq.inPage = 1
    GameFacade:SendNotification(NotificationDefines.Career.CareerRank.ReqRankDataCmd, rankReq)
  end
end
function LeadboardSubTypeItemPanel:OnClearBtnStyle()
  self.bIsChecked = false
  if self.CheckBox_Choose then
    self.CheckBox_Choose:SetIsChecked(self.bIsChecked)
  end
end
return LeadboardSubTypeItemPanel
