local AchievementIcon = class("AchievementIcon", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function AchievementIcon:InitView(achievementId, isNormalImage, isShowName)
  if achievementId then
    local achievementCfg = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetCardIdConfig(achievementId)
    if achievementCfg then
      if self.Text_Achivement then
        self.Text_Achivement:SetText(achievementCfg.Name)
        if not isShowName then
          self.Text_Achivement:SetVisibility(UE4.ESlateVisibility.Collapsed)
          self.isNameShown = false
        end
      end
      if isNormalImage and self.Image_Icon then
        self:SetImageByTexture2D(self.Image_Icon, achievementCfg.IconItem)
        self.Image_Icon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        if self.DynamicIcon then
          self.DynamicIcon:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
    else
      LogError("AchievementIcon", "Do not have achievement %d config", achievementId)
    end
    if not isNormalImage and self.DynamicIcon then
      self.DynamicIcon:InitView(achievementId)
      self.DynamicIcon:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if self.Image_Icon then
        self.Image_Icon:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    if self.Button_Achieve and not isShowName then
      local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
      if platform == GlobalEnumDefine.EPlatformType.Mobile then
        self.Button_Achieve.OnClicked:Add(self, self.SetAchievementNameShown)
      else
        self.Button_Achieve.OnHovered:Add(self, self.SetAchievementNameShown)
        self.Button_Achieve.OnUnHovered:Add(self, self.SetAchievementNameShown)
      end
    end
  end
end
function AchievementIcon:SetOpacity(opacity)
  if self.DynamicIcon then
    self.DynamicIcon:SetRenderOpacity(opacity)
  end
  if self.Image_Icon then
    self.Image_Icon:SetRenderOpacity(opacity)
  end
end
function AchievementIcon:SetTextSize(textSize)
  if self.Text_Achivement then
    local font = self.Text_Achivement.Font
    if textSize == CareerEnumDefine.textSize.small then
      font.size = 22
    end
    if textSize == CareerEnumDefine.textSize.medium then
      font.size = 26
    end
    if textSize == CareerEnumDefine.textSize.large then
      font.size = 30
    end
    self.Text_Achivement:SetFont(font)
  end
end
function AchievementIcon:ForbidNameInteraction()
  if self.Button_Achieve and not self.isNameShown then
    local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
    if platform == GlobalEnumDefine.EPlatformType.Mobile then
      self.Button_Achieve.OnClicked:Remove(self, self.SetAchievementNameShown)
    else
      self.Button_Achieve.OnHovered:Remove(self, self.SetAchievementNameShown)
      self.Button_Achieve.OnUnHovered:Remove(self, self.SetAchievementNameShown)
    end
  end
end
function AchievementIcon:SetAchievementNameShown()
  self.isNameShown = not self.isNameShown
  if self.Text_Achivement then
    self.Text_Achivement:SetVisibility(self.isNameShown and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return AchievementIcon
