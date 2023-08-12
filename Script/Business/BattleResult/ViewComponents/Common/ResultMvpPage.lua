local ResultMvpPage = class("ResultMvpPage", PureMVC.ViewComponentPage)
local BattleResultDefine = require("Business/BattleResult/Proxies/BattleResultDefine")
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function ResultMvpPage:OnOpen(luaOpenData, nativeOpenData)
  ViewMgr:ClosePage(self, UIPageNameDefine.GameFinishPage)
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  local AudioEvent
  local MyPlayerInfo = BattleResultProxy:GetMyPlayerInfo()
  if not MyPlayerInfo then
    LogDebug("ResultMvpPage", "MyPlayerInfo = nil")
    return
  end
  if BattleResultProxy:IsDraw() then
    AudioEvent = self.AudioEvent_Draw
  elseif BattleResultProxy:IsWinnerTeam(MyPlayerInfo.team_id) then
    AudioEvent = self.AudioEvent_Win
  else
    AudioEvent = self.AudioEvent_Fail
  end
  if AudioEvent then
    self:K2_PostAkEvent(self.AudioEvent_MusicPlay, false)
    self:K2_PostAkEvent(AudioEvent, false)
  end
  if 1 == MyPlayerInfo.RealMvp then
    self.CanvasPanel_Mvp:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "MatchBest")
    self.Text_Mvp:SetText(str)
    self.Image_Mvp:SetBrush(self.SlateMVP)
  elseif 2 == MyPlayerInfo.RealMvp then
    self.CanvasPanel_Mvp:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local str = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "TeamBest")
    self.Text_Mvp:SetText(str)
    self.Image_Mvp:SetBrush(self.SlateSVP)
  else
    self.CanvasPanel_Mvp:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  local PlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0)
  if PlayerController then
    if BattleResultProxy:IsWinnerTeam(MyPlayerInfo.team_id) then
      PlayerController:PlayGameWinOrFailCV(true, 1 == MyPlayerInfo.RealMvp)
    else
      PlayerController:PlayGameWinOrFailCV(false, 2 == MyPlayerInfo.RealMvp)
    end
  end
  ViewMgr:ClosePage(self, UIPageNameDefine.BattleDataPage)
  self.openShare = false
  local basicProxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
  if basicProxy then
    self.openShare = basicProxy:IsShareOpen()
  end
  local GameState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if GameState and GameState.GetModeType and GameState:GetModeType() == UE4.EPMGameModeType.TeamGuide then
    self.openShare = false
  end
  if self.Btn_Share then
    if self.openShare then
      self.Btn_Share.OnClickEvent:Add(self, self.OnClickShare)
      self.OnCaptureScreenshotSuccessHandler = DelegateMgr:AddDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self, "OnCaptureScreenshotSuccess")
    else
      self.Btn_Share:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function ResultMvpPage:OnClose()
  if self.Btn_Share and self.openShare then
    self.Btn_Share.OnClickEvent:Remove(self, self.OnClickShare)
  end
  if self.OnCaptureScreenshotSuccessHandler then
    DelegateMgr:RemoveDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self.OnCaptureScreenshotSuccessHandler)
    self.OnCaptureScreenshotSuccessHandler = nil
  end
end
function ResultMvpPage:OnClickShare()
  if self.Btn_Share then
    self.Btn_Share:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ShareBigImagePage, nil, UE4.EShareBigImageType.Settlement)
end
function ResultMvpPage:OnCaptureScreenshotSuccess()
  if self.Btn_Share then
    self.Btn_Share:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
return ResultMvpPage
