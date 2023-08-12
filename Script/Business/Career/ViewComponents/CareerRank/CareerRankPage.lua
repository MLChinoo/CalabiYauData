local CareerRankPage = class("CareerRankPage", PureMVC.ViewComponentPage)
local CareerRankMediator = require("Business/Career/Mediators/CareerRank/CareerRankMediator")
function CareerRankPage:ListNeededMediators()
  return {CareerRankMediator}
end
function CareerRankPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("CareerRankPage", "Lua implement OnOpen")
  self.isMenuOpen = false
  self.buttonPressed = false
  if self.Button_ChooseSeason then
    self.Button_ChooseSeason.OnPressed:Add(self, self.OnButtonChooseSeasonPressed)
    self.Button_ChooseSeason.OnReleased:Add(self, self.OnButtonChooseSeasonReleased)
  end
  if self.MenuAnchor_ChooseSeason then
    self.MenuAnchor_ChooseSeason.OnMenuOpenChanged:Add(self, self.OnMenuOpen)
    self.MenuAnchor_ChooseSeason.OnGetMenuContentEvent:Bind(self, self.OnGetMenuContent)
  end
  if self.CheckBox_FinalDivision and self.CheckBox_TopDivision then
    self.CheckBox_FinalDivision.OnCheckStateChanged:Add(self, self.ChooseFinal)
    self.CheckBox_TopDivision.OnCheckStateChanged:Add(self, self.ChooseTop)
  end
  if self.Button_RankIntro then
    self.Button_RankIntro.OnClicked:Add(self, self.ShowRankIntro)
  end
  if self.Button_DivisionList then
    self.Button_DivisionList.OnClicked:Add(self, self.OnClickDivisionList)
  end
  if self.Button_HonorRank then
    self.Button_HonorRank.OnClicked:Add(self, self.OnClickHonorRank)
  end
  if self.Button_More then
    self.Button_More.OnClicked:Add(self, self.OnClickMoreInfo)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.actionOnReturn:Add(self.OnEscHotKeyClick, self)
  end
  if self.HotKeyShare then
    self.HotKeyShare.OnClickEvent:Add(self, self.OnClickedShare)
  end
  self.ScreenPrintSuccessHandler = DelegateMgr:AddDelegate(UE4.UPMShareSubSystem.GetInst(LuaGetWorld()).OnCaptureScreenshotSuccess, self, "OnScreenPrintSuccess")
  RedDotTree:Bind(RedDotModuleDef.ModuleName.CareerRankReward, function(cnt)
    self:UpdateRedDotReward(cnt)
  end)
  self:UpdateRedDotReward(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.CareerRankReward))
  local levelLimit = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy):GetParameterIntValue("5908")
  local level = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emLevel)
  if self.WidgetSwitcher_LevelMeet then
    if levelLimit > level then
      self.WidgetSwitcher_LevelMeet:SetActiveWidgetIndex(1)
      local hintWidget = self.WidgetSwitcher_LevelMeet:GetActiveWidget()
      if hintWidget then
        hintWidget:PlayOpenAnim()
      end
      return
    else
      self.WidgetSwitcher_LevelMeet:SetActiveWidgetIndex(0)
    end
  end
  self.seasonId = 0
  self.currentSeason = 0
  self.seasonTimeLeft = 0
  self.formerSeasonStars = {}
  self.dataProxy = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy)
  self.seasonNameTable = {}
  if self.Opening then
    self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
  GameFacade:SendNotification(NotificationDefines.Career.CareerRank.GetCareerRankDataCmd)
end
function CareerRankPage:OnClose()
  ViewMgr:ClosePage(self, UIPageNameDefine.CareerRankIntro)
  ViewMgr:ClosePage(self, UIPageNameDefine.CareerRankIcon)
  ViewMgr:ClosePage(self, UIPageNameDefine.CareerHonorRank)
  ViewMgr:ClosePage(self, UIPageNameDefine.CareerSeasonPrize)
  if self.Button_ChooseSeason then
    self.Button_ChooseSeason.OnPressed:Remove(self, self.OnButtonChooseSeasonPressed)
    self.Button_ChooseSeason.OnReleased:Remove(self, self.OnButtonChooseSeasonReleased)
  end
  if self.MenuAnchor_ChooseSeason then
    self.MenuAnchor_ChooseSeason.OnMenuOpenChanged:Remove(self, self.OnMenuOpen)
    self.MenuAnchor_ChooseSeason.OnGetMenuContentEvent:Unbind()
  end
  if self.CheckBox_FinalDivision and self.CheckBox_TopDivision then
    self.CheckBox_FinalDivision.OnCheckStateChanged:Remove(self, self.ChooseFinal)
    self.CheckBox_TopDivision.OnCheckStateChanged:Remove(self, self.ChooseTop)
  end
  if self.Button_RankIntro then
    self.Button_RankIntro.OnClicked:Remove(self, self.ShowRankIntro)
  end
  if self.Button_DivisionList then
    self.Button_DivisionList.OnClicked:Remove(self, self.OnClickDivisionList)
  end
  if self.Button_HonorRank then
    self.Button_HonorRank.OnClicked:Remove(self, self.OnClickHonorRank)
  end
  if self.Button_More then
    self.Button_More.OnClicked:Remove(self, self.OnClickMoreInfo)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.actionOnReturn:Remove(self.OnEscHotKeyClick, self)
  end
  if self.HotKeyShare then
    self.HotKeyShare.OnClickEvent:Remove(self, self.OnClickedShare)
  end
  if self.ScreenPrintSuccessHandler then
    DelegateMgr:RemoveDelegate(UE4.UPMShareSubSystem.GetInst(LuaGetWorld()).OnCaptureScreenshotSuccess, self.ScreenPrintSuccessHandler)
    self.ScreenPrintSuccessHandler = nil
  end
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.CareerRankReward)
end
function CareerRankPage:InitView(seasonRank)
  local rankInfo = seasonRank.careerRankData
  local seasonInfo = seasonRank.seasonInfo
  self.seasonId = rankInfo.season
  self.currentSeason = seasonInfo.season_id
  self.formerSeasonStars = rankInfo.divisionOfSeasons
  local count = 0
  for key, value in pairsByKeys(ConfigMgr:GetBattlePassSeasonTableRows():ToLuaTable(), function(a, b)
    return a < b
  end) do
    if count >= self.seasonId then
      break
    end
    table.insert(self.seasonNameTable, value.Name)
    count = count + 1
  end
  self.seasonTimeLeft = seasonInfo.season_finish_time
  self:UpdateSeasonInfo(self.currentSeason)
  self:UpdateDivision(rankInfo.stars, rankInfo.scores)
  if rankInfo.isGrading then
    local gradingBattleRlt = {}
    for i = 1, 5 do
      if rankInfo.gradingInfo and rankInfo.gradingInfo[i] then
        gradingBattleRlt[i] = rankInfo.gradingInfo[i]
      end
    end
    self.DivisionCompetitionPanel:UpdateView(gradingBattleRlt)
    self.WidgetSwitcherGrade:SetActiveWidgetIndex(1)
  end
end
function CareerRankPage:UpdateDivision(stars, score)
  local _, divisionCfg = self.dataProxy:GetDivision(stars)
  if self.Text_RankName then
    self.Text_RankName:SetText(divisionCfg.Name)
  end
  if stars > 0 and self.RankBadge then
    self.RankBadge:ShowRankDivision(stars)
  end
  if self.Text_RankPercent then
    local text = divisionCfg.Ratio .. "%"
    self.Text_RankPercent:SetText(text)
  end
  if score then
    if self.Text_Fraction and self.Text_Denominator then
      self.Text_Fraction:SetText(score)
      self.Text_Denominator:SetText(divisionCfg.ScoreMax)
    end
    if self.Text_ScoreProtect then
      local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Career, "ScoreProtect")
      local stringMap = {
        [0] = divisionCfg.ScoreProtect
      }
      local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      self.Text_ScoreProtect:SetText(text)
    end
    if self.RankScoreProgress then
      self.RankScoreProgress:InitView(math.ceil(divisionCfg.ScoreMax / divisionCfg.ScoreProtect))
      self.RankScoreProgress:SetPercent(score / divisionCfg.ScoreMax)
    end
  end
end
function CareerRankPage:UpdatePrize(seasonId)
  local seasonReward = self.dataProxy:GetRewardInfo(seasonId)
  if nil == seasonReward then
    if self.WidgetSwitcher_LevelMeet then
      self.WidgetSwitcher_LevelMeet:SetActiveWidgetIndex(2)
    end
    return
  end
  local seasonBestPrize = seasonReward[seasonReward.firstId].config
  if self.Image_Prize then
    self:SetImageByTexture2D(self.Image_Prize, seasonBestPrize.DivisionBigReward)
  end
  if self.Text_SeasonRewardName then
    self.Text_SeasonRewardName:SetText(seasonBestPrize.RewardName)
  end
  if self.Text_SeasonRewardCondition then
    self.Text_SeasonRewardCondition:SetText(seasonBestPrize.ConditionDesc)
  end
  local prizeQualityCfg = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemQualityConfig(seasonBestPrize.Quality)
  if self.Text_Quality then
    self.Text_Quality:SetText(prizeQualityCfg.Desc)
  end
  if self.Image_Quality then
    self.Image_Quality:SetColorandOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(prizeQualityCfg.color)))
  end
end
function CareerRankPage:OnSelectSeason(selectedItem)
  LogDebug("CareerRankPage", selectedItem)
  if self.isMenuOpen then
    self.MenuAnchor_ChooseSeason:ToggleOpen(true)
  end
  if self.TextBlock_SeasonChosen then
    self.TextBlock_SeasonChosen:SetText(selectedItem)
  end
  self.seasonId = table.index(self.seasonNameTable, selectedItem)
  self:UpdateSeasonInfo(self.seasonId)
end
function CareerRankPage:OnMenuOpen(isOpen)
  if isOpen == self.isMenuOpen then
    return
  end
  if self.Image_Arrow then
    if isOpen then
      self.Image_Arrow:SetRenderScale(UE4.FVector2D(1, 1))
    else
      self.Image_Arrow:SetRenderScale(UE4.FVector2D(1, -1))
      self.buttonPressed = false
    end
  end
  self.isMenuOpen = isOpen
end
function CareerRankPage:OnGetMenuContent()
  local seasonList = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_ChooseSeason.MenuClass)
  if seasonList then
    seasonList:SetContent(self.seasonNameTable, self.seasonId)
    seasonList.actionOnSelectionChanged:Add(self.OnSelectSeason, self)
    return seasonList
  else
    LogDebug("CareerRankPage", "Menu create failed")
    return nil
  end
end
function CareerRankPage:OnButtonChooseSeasonPressed()
  self.buttonPressed = true
end
function CareerRankPage:OnButtonChooseSeasonReleased()
  if self.buttonPressed and self.MenuAnchor_ChooseSeason then
    self.MenuAnchor_ChooseSeason:Open(true)
  end
  self.buttonPressed = false
end
function CareerRankPage:OnClickDivisionList()
  ViewMgr:OpenPage(self, UIPageNameDefine.CareerRankIcon, false, self)
end
function CareerRankPage:OnClickHonorRank()
  ViewMgr:OpenPage(self, UIPageNameDefine.CareerHonorRank, false, self)
end
function CareerRankPage:OnClickMoreInfo()
  ViewMgr:OpenPage(self, UIPageNameDefine.CareerSeasonPrize, false, self)
end
function CareerRankPage:UpdateSeasonInfo(inSeasonId)
  if self.Text_EndTime then
    if inSeasonId == self.currentSeason then
      local currentTime = os.time()
      local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Career, "SeasonRestTime")
      local stringMap = {
        [0] = math.floor((self.seasonTimeLeft - currentTime) / 3600 / 24)
      }
      local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      self.Text_EndTime:SetText(text)
    else
      self.Text_EndTime:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Career, "SeasonHasEnd"))
    end
  end
  self:UpdatePrize(inSeasonId)
  self:ChooseDivision(false)
  if self.SizeBox_RedDotReward then
    self.SizeBox_RedDotReward:SetVisibility(inSeasonId == self.currentSeason and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function CareerRankPage:ChooseFinal(isChosen)
  if not isChosen then
    self.CheckBox_FinalDivision:SetIsChecked(true)
    return
  end
  self:ChooseDivision(false)
end
function CareerRankPage:ChooseTop(isChosen)
  if not isChosen then
    self.CheckBox_TopDivision:SetIsChecked(true)
    return
  end
  self:ChooseDivision(true)
end
function CareerRankPage:ChooseDivision(isTopDivision)
  if self.CheckBox_FinalDivision and self.CheckBox_TopDivision then
    if isTopDivision then
      self.CheckBox_FinalDivision:SetIsChecked(false)
      self.CheckBox_TopDivision:SetIsChecked(true)
    else
      self.CheckBox_FinalDivision:SetIsChecked(true)
      self.CheckBox_TopDivision:SetIsChecked(false)
    end
  end
  local divisionStar = 0
  if self.formerSeasonStars[tonumber(self.seasonId)] then
    local division = self.formerSeasonStars[tonumber(self.seasonId)]
    divisionStar = isTopDivision and division.topStar or division.finalStar
  end
  self:UpdateDivision(divisionStar)
end
function CareerRankPage:OnEscHotKeyClick()
  LogInfo("CareerRankPage", "OnEscHotKeyClick")
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
end
function CareerRankPage:ShowRankIntro()
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    ViewMgr:PushPage(self, UIPageNameDefine.CareerRankIntro, self)
  else
    ViewMgr:OpenPage(self, UIPageNameDefine.CareerRankIntro, false, self)
  end
end
function CareerRankPage:LuaHandleKeyEvent(key, inputEvent)
  local ret = false
  if self.HotKeyShare and self.HotKeyShare:IsVisible() and not ret then
    ret = self.HotKeyShare:MonitorKeyDown(key, inputEvent)
  end
  if self.HotKeyButton_Esc and not ret then
    ret = self.HotKeyButton_Esc:LuaHandleKeyEvent(key, inputEvent)
  end
  return ret
end
function CareerRankPage:UpdateRedDotReward(cnt)
  if self.RedDot_RankReward then
    self.RedDot_RankReward:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function CareerRankPage:OnClickedShare()
  if self.Button_DivisionList then
    self.Button_DivisionList:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Button_HonorRank then
    self.Button_HonorRank:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.SizeBoxRankTab then
    self.SizeBoxRankTab:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.HotKeyShare then
    self.HotKeyShare:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.SizeBoxMore then
    self.SizeBoxMore:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = false, pageHide = true})
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ShareBigImagePage, nil, UE4.EShareBigImageType.CareerTier)
end
function CareerRankPage:OnScreenPrintSuccess()
  if self.Button_DivisionList then
    self.Button_DivisionList:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if self.Button_HonorRank then
    self.Button_HonorRank:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if self.SizeBoxRankTab then
    self.SizeBoxRankTab:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.HotKeyShare then
    self.HotKeyShare:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.SizeBoxMore then
    self.SizeBoxMore:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayNavBar, {isDisplay = true, pageHide = true})
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
end
return CareerRankPage
