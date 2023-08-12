local HonorRankItem = class("HonorRankItem", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
local distinctNum = 3
HonorRankItem.ClassificationStatusEnum = {Close = 0, Open = 1}
HonorRankItem.LeaderboardClassificationType = {
  None = 0,
  RankPos = 1,
  Icon = 2,
  Name = 3,
  RankStar = 4,
  Area = 5,
  Count = 6,
  RoleUse = 7,
  TotalKill = 8
}
function HonorRankItem:ListNeededMediators()
  return {}
end
function HonorRankItem:UpdateView(rankRowInfo, rankPos)
  self:SetContentClassificationVisibility()
  if self.WS_RankColor then
    if nil == rankPos or rankPos < 1 then
      self.WS_RankColor:SetVisibility(UE4.ESlateVisibility.Collapsed)
    elseif rankPos <= distinctNum then
      self.WS_RankColor:SetActiveWidgetIndex(rankPos)
      self.WS_RankColor:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.WS_RankColor:SetActiveWidgetIndex(0)
      self.WS_RankColor:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.WS_RankPos then
    if nil == rankPos or rankPos < 1 then
      self.WS_RankPos:SetActiveWidgetIndex(4)
    elseif rankPos <= distinctNum then
      self.WS_RankPos:SetActiveWidgetIndex(rankPos)
    else
      self.WS_RankPos:SetActiveWidgetIndex(0)
      if self.Text_RankPos then
        self.Text_RankPos:SetText(rankPos)
      end
    end
  end
  GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):SetHeadIcon(self, self.Image_Icon, rankRowInfo.icon, self.Image_BorderIcon, rankRowInfo.vcBorderId)
  local isSelf = rankRowInfo.playerId == GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId()
  if isSelf then
    if self.Text_NameSelf then
      self.Text_NameSelf:SetText(rankRowInfo.nick)
    end
    if self.WS_Name then
      self.WS_Name:SetActiveWidgetIndex(1)
    end
  else
    if self.Text_Name then
      self.Text_Name:SetText(rankRowInfo.nick)
    end
    if self.WS_Name then
      self.WS_Name:SetActiveWidgetIndex(0)
    end
  end
  if self.PrivilegeGCLaunch then
    self.PrivilegeGCLaunch:UpdateDisplay(rankRowInfo, 2)
  end
  if rankRowInfo.cityCode and rankRowInfo.cityCode > 0 and self.AreaTextItem then
    local cityCodeCfg = ConfigMgr:GetCityCode()
    if cityCodeCfg then
      cityCodeCfg = cityCodeCfg:ToLuaTable()
      if cityCodeCfg[tostring(rankRowInfo.cityCode)] then
        local cityStr = cityCodeCfg[tostring(rankRowInfo.cityCode)].Fullname
        if cityStr then
          local finalCityStr = ""
          local searchStartPos = 0
          for index = 1, 3 do
            local findPos = string.find(cityStr, ",", searchStartPos)
            if findPos then
              if 3 == index then
                finalCityStr = finalCityStr .. string.sub(cityStr, searchStartPos, findPos - 1)
              end
              searchStartPos = findPos + 1
            else
              break
            end
          end
          self.TextBlock_Display:SetText(finalCityStr)
        end
      end
    end
    self.AreaTextItem:SetScrollText(self.TextBlock_Display)
  end
  if self.HB_Rank then
    self.HB_Rank:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if rankRowInfo.rankDivisionData then
    local starsNum = rankRowInfo.rankDivisionData.stars
    if starsNum and starsNum >= 0 then
      local starsShow, division = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivision(starsNum or 0)
      if self.Text_RankName and division then
        self.Text_RankName:SetText(division.Name)
      end
      if self.Text_Stars then
        self.Text_Stars:SetText(starsShow)
      end
      if division and division.Gradation and division.Gradation > 0 and division.IconGradation and not division.IconGradation:IsNull() and self.Image_RankStar then
        self:SetImageByPaperSprite_MatchSize(self.Image_RankStar, division.IconGradation)
      end
      if starsNum > 0 and self.HB_Rank then
        self.HB_Rank:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
    local winGames = rankRowInfo.rankDivisionData.win_games
    if winGames and winGames >= 0 and self.Text_Total then
      self.Text_Total:SetText(winGames or 0)
    end
  end
  if rankRowInfo.rankTeamData then
    local kills = rankRowInfo.rankTeamData.kills
    if kills and kills >= 0 and self.Canvas_TotalKill then
      self.Canvas_TotalKill:SetText(kills or 0)
    end
    local winGames = rankRowInfo.rankTeamData.win_games
    if winGames and winGames >= 0 and self.Text_Total then
      self.Text_Total:SetText(winGames or 0)
    end
  end
  if rankRowInfo.freqRoles and self.HB_FreqRoles then
    local rolesIcon = self.HB_FreqRoles:GetAllChildren()
    for index = 1, rolesIcon:Length() do
      if rankRowInfo.freqRoles[index] then
        local skinShowId = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleCurrentWearSkinID(rankRowInfo.freqRoles[index])
        if nil == skinShowId then
          rolesIcon:Get(index):UpdateView()
          return
        end
        local texture = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleSkin(skinShowId).IconRoleHud
        rolesIcon:Get(index):UpdateView(texture)
      else
        rolesIcon:Get(index):UpdateView()
      end
    end
  end
end
function HonorRankItem:Construct()
  if self.bp_bIsSelf and self.WS_Background then
    self.WS_Background:SetActiveWidgetIndex(1)
  end
end
function HonorRankItem:SetContentClassificationVisibility()
  local honorRankDataProxy = GameFacade:RetrieveProxy(ProxyNames.HonorRankDataProxy)
  local curReqLeaderboardType = honorRankDataProxy:GetCurrentReqLeadboardType()
  local leaderboardContentDisplayControlCfg = ConfigMgr:GetLeaderboardContentDisplayControl()
  if leaderboardContentDisplayControlCfg then
    leaderboardContentDisplayControlCfg = leaderboardContentDisplayControlCfg:ToLuaTable()
    for row, value in pairs(leaderboardContentDisplayControlCfg) do
      if value.LeaderboardType == curReqLeaderboardType then
        local itemVisibility = UE4.ESlateVisibility.Collapsed
        if value.RankNumber == self.ClassificationStatusEnum.Open then
          itemVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
        end
        if self.SizeBox_RankPos then
          self.SizeBox_RankPos:SetVisibility(itemVisibility)
          self:SetContentClassificationPadding(curReqLeaderboardType, HonorRankItem.LeaderboardClassificationType.RankPos, self.SizeBox_RankPos)
        end
        itemVisibility = UE4.ESlateVisibility.Collapsed
        if value.PlayerName == self.ClassificationStatusEnum.Open then
          itemVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
        end
        if self.SizeBox_Name then
          self.SizeBox_Name:SetVisibility(itemVisibility)
          self:SetContentClassificationPadding(curReqLeaderboardType, HonorRankItem.LeaderboardClassificationType.Name, self.SizeBox_Name)
        end
        itemVisibility = UE4.ESlateVisibility.Collapsed
        if value.RankLevel == self.ClassificationStatusEnum.Open then
          itemVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
        end
        if self.SizeBox_Rank then
          self.SizeBox_Rank:SetVisibility(itemVisibility)
          self:SetContentClassificationPadding(curReqLeaderboardType, HonorRankItem.LeaderboardClassificationType.RankStar, self.SizeBox_Rank)
        end
        if self.SizeBox_Area then
          self:SetContentClassificationPadding(curReqLeaderboardType, HonorRankItem.LeaderboardClassificationType.Area, self.SizeBox_Area)
        end
        itemVisibility = UE4.ESlateVisibility.Collapsed
        if value.Wins == self.ClassificationStatusEnum.Open then
          itemVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
        end
        if self.SizeBox_Count then
          self.SizeBox_Count:SetVisibility(itemVisibility)
          self:SetContentClassificationPadding(curReqLeaderboardType, HonorRankItem.LeaderboardClassificationType.Count, self.SizeBox_Count)
        end
        itemVisibility = UE4.ESlateVisibility.Collapsed
        if value.CommonUsedHeros == self.ClassificationStatusEnum.Open then
          itemVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
        end
        if self.SizeBox_RoleUse then
          self.SizeBox_RoleUse:SetVisibility(itemVisibility)
          self:SetContentClassificationPadding(curReqLeaderboardType, HonorRankItem.LeaderboardClassificationType.RoleUse, self.SizeBox_RoleUse)
        end
        itemVisibility = UE4.ESlateVisibility.Collapsed
        if value.TotalKiller == self.ClassificationStatusEnum.Open then
          itemVisibility = UE4.ESlateVisibility.SelfHitTestInvisible
        end
        if self.SizeBox_TotalKill then
          self.SizeBox_TotalKill:SetVisibility(itemVisibility)
          self:SetContentClassificationPadding(curReqLeaderboardType, HonorRankItem.LeaderboardClassificationType.TotalKill, self.SizeBox_TotalKill)
        end
        return
      end
    end
  end
end
function HonorRankItem:SetContentClassificationPadding(leaderboardType, ClassificationType, adjustWidget)
  local layoutMapDatas
  if leaderboardType == CareerEnumDefine.LeaderboardType.StarsRank then
    layoutMapDatas = self.bp_starsRankLayoutParameter
  elseif leaderboardType == CareerEnumDefine.LeaderboardType.TeamRank then
    layoutMapDatas = self.bp_teamRankLayoutParameter
  end
  if layoutMapDatas then
    local leftPaddingValue = layoutMapDatas:Find(ClassificationType)
    local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(adjustWidget)
    if canvasSlot then
      local marginT = UE4.FMargin()
      marginT.Bottom = 0
      marginT.Top = 0
      marginT.Left = leftPaddingValue
      marginT.Right = 0
      canvasSlot:SetPadding(marginT)
    end
  end
end
return HonorRankItem
