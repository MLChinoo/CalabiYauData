local LoadingAssetPage = class("LoadingAssetPage", PureMVC.ViewComponentPage)
local LoadingAssetMediator = require("Business/Common/Mediators/Pending/LoadingAssetMediator")
function LoadingAssetPage:ListNeededMediators()
  return {LoadingAssetMediator}
end
function LoadingAssetPage:OnOpen(luaOpenData, nativeOpenData)
  if nativeOpenData then
    if self.Img_MapBg_Default then
      self.Img_MapBg_Default:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    if nativeOpenData.AssetLoadingStyle == UE4.ECyLoadingStyle.Login then
      local GlobalSM = UE4.UPMGlobalStateMachine.Get(LuaGetWorld())
      if GlobalSM and GlobalSM:GetCurrentGlobalStateType() == UE4.EPMGlobalStateType.Playing then
        self:K2_PostAkEvent(self.PlayingLoginMusicStart)
      end
      self:PlayBgVideo()
      if self.CanvasPanel_Info then
        self.CanvasPanel_Info:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    else
      if self.CanvasPanel_Info then
        self.CanvasPanel_Info:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      if nativeOpenData.AssetLoadingStyle == UE4.ECyLoadingStyle.Map then
        self:K2_PostAkEvent(self.LoadingMusicStart)
        if not nativeOpenData.AssetBg:IsNull() then
          if self.Img_MapBg then
            self.Img_MapBg:SetBrushFromTexture(UE4.UKismetSystemLibrary.LoadAsset_Blocking(nativeOpenData.AssetBg))
          end
        elseif self.Img_MapBg_Default then
          self.Img_MapBg_Default:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        end
      else
        self:PlayBgVideo()
      end
      if self.Text_Name then
        if nativeOpenData.AssetName then
          self.Text_Name:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.Text_Name:SetText(nativeOpenData.AssetName)
        else
          self.Text_Name:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
      if self.Text_Desc then
        if nativeOpenData.AssetDesc then
          self.Text_Desc:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.Text_Desc:SetText(nativeOpenData.AssetDesc)
        else
          self.Text_Desc:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
      if self.Text_LoadingPercent and self.Text_LoadingPercentSign then
        if nativeOpenData.bAssetProgress then
          self.Text_LoadingPercent:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.Text_LoadingPercent:SetText("0")
          self.Text_LoadingPercentSign:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        else
          self.Text_LoadingPercent:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.Text_LoadingPercentSign:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
      if self.Text_RandomTip then
        if nativeOpenData.AssetRadomTip then
          self.Text_RandomTip:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          self.Text_RandomTip:SetText(nativeOpenData.AssetRadomTip)
        else
          self.Text_RandomTip:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
    end
  end
  self:PlayAnimation(self.Anim_Rotate, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function LoadingAssetPage:PlayBgVideo()
  if not self.LoadingMediaPlayer or not self.VideoPlayList then
    return
  end
  if self.VideoPlayList then
    self.VideoPlayList:RemoveAt(0)
  end
  self.VideoPlayList:AddFile(self.LoadingVideoFile.FilePath)
  self.LoadingMediaPlayer:OpenPlaylist(self.VideoPlayList)
  self.LoadingMediaPlayer:SetLooping(true)
  self.LoadingMediaPlayer:Play()
end
function LoadingAssetPage:OnClose()
  if self.LoadingMediaPlayer then
    self.LoadingMediaPlayer:Close()
  end
  self:K2_PostAkEvent(self.LoadingMusicStop)
  local LoginSubSystem = UE4.UPMLoginSubSystem.GetInstance(LuaGetWorld())
  local GlobalSM = UE4.UPMGlobalStateMachine.Get(LuaGetWorld())
  local IsLobbyState = GlobalSM and GlobalSM:GetCurrentGlobalStateType() == UE4.EPMGlobalStateType.Lobby or false
  if IsLobbyState and LoginSubSystem and LoginSubSystem:IsJuvenilesTimeOut() then
    LoginSubSystem:ShowJuvenilesTimeOutMsg()
  end
end
function LoadingAssetPage:SetPercent(percent)
  if self.Text_LoadingPercent then
    self.Text_LoadingPercent:SetText(math.modf(percent))
  end
end
function LoadingAssetPage:SetTip(tip)
  if self.Text_RandomTip then
    self.Text_RandomTip:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Text_RandomTip:SetText(tip)
  end
end
function LoadingAssetPage:LuaHandleKeyEvent(key, inputEvent)
  if GameUtil:IsBuildShipingOrTest() then
    return true
  else
    return false
  end
end
return LoadingAssetPage
