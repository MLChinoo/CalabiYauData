local HonorRankMediator = class("HonorRankMediator", PureMVC.Mediator)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function HonorRankMediator:ListNotificationInterests()
  return {
    NotificationDefines.Career.CareerRank.ReqRankData,
    NotificationDefines.Career.CareerRank.GetHonorRankData
  }
end
function HonorRankMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Career.CareerRank.ReqRankData then
    if 0 == notification:GetBody() then
      self:GetRankData()
    else
      ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.PendingPage)
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, notification:GetBody())
    end
  end
  if notification:GetName() == NotificationDefines.Career.CareerRank.GetHonorRankData then
    local viewComponent = self:GetViewComponent()
    if notification:GetBody() then
      viewComponent.WidgetSwitcher_HasInfo:SetActiveWidgetIndex(0)
      viewComponent:UpdateView(notification:GetBody())
      ViewMgr:ClosePage(viewComponent, UIPageNameDefine.PendingPage)
      local honorRankDataProxy = GameFacade:RetrieveProxy(ProxyNames.HonorRankDataProxy)
      local reqLeaderboardType = honorRankDataProxy:GetCurrentReqLeadboardType()
      if viewComponent.LeadboardTopContentClassification and reqLeaderboardType then
        viewComponent.LeadboardTopContentClassification:UpdateContentClassification(reqLeaderboardType)
      end
    else
      viewComponent.WidgetSwitcher_HasInfo:SetActiveWidgetIndex(1)
    end
  end
end
function HonorRankMediator:OnRegister()
  HonorRankMediator.super.OnRegister(self)
  self.currentPage = 0
  self:GetViewComponent().actionOnNewPage:Add(self.OnCallNewPage, self)
  self:GetViewComponent().actionOnChooseSeason:Add(self.ChooseSeason, self)
  self:GetViewComponent().actionOnChosenRankAll:Add(self.ChooseRankAll, self)
end
function HonorRankMediator:OnRemove()
  self:GetViewComponent().actionOnNewPage:Remove(self.OnCallNewPage, self)
  self:GetViewComponent().actionOnChooseSeason:Remove(self.ChooseSeason, self)
  self:GetViewComponent().actionOnChosenRankAll:Remove(self.ChooseRankAll, self)
  HonorRankMediator.super.OnRemove(self)
end
function HonorRankMediator:OnViewComponentPagePreOpen()
  local reqSeasonId = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetRankInfo().season
  local honorRankDataProxy = GameFacade:RetrieveProxy(ProxyNames.HonorRankDataProxy)
  honorRankDataProxy:SetCurrentReqSeasonId(reqSeasonId)
  honorRankDataProxy:SetLeaderboardRelationshipChain(CareerEnumDefine.LeaderboardRelationshipChain.All)
  GameFacade:SendNotification(NotificationDefines.Career.CareerRank.SelectLeadboardSubTypeBtnCheck, CareerEnumDefine.LeaderboardType.StarsRank)
  self:GetViewComponent():InitPageWidget(reqSeasonId)
end
function HonorRankMediator:ChooseSeason(seasonId)
  local honorRankDataProxy = GameFacade:RetrieveProxy(ProxyNames.HonorRankDataProxy)
  honorRankDataProxy:SetCurrentReqSeasonId(seasonId)
  self:OnCallNewPage(1)
end
function HonorRankMediator:ChooseRankAll(bRankAll)
  local honorRankDataProxy = GameFacade:RetrieveProxy(ProxyNames.HonorRankDataProxy)
  if bRankAll then
    self.noteRankType = NotificationDefines.Career.CareerRank.RankDataType.RankAll
    honorRankDataProxy:SetLeaderboardRelationshipChain(CareerEnumDefine.LeaderboardRelationshipChain.All)
  else
    self.noteRankType = NotificationDefines.Career.CareerRank.RankDataType.RankFriend
    honorRankDataProxy:SetLeaderboardRelationshipChain(CareerEnumDefine.LeaderboardRelationshipChain.Friend)
  end
  self:OnCallNewPage(1)
end
function HonorRankMediator:OnCallNewPage(pageNum)
  local rankReq = {}
  rankReq.inPage = pageNum
  GameFacade:SendNotification(NotificationDefines.Career.CareerRank.ReqRankDataCmd, rankReq)
end
return HonorRankMediator
