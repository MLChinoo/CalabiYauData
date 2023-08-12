local ApartmentInformationPage = class("ApartmentInformationPage", PureMVC.ViewComponentPage)
local ApartmentInformationMediator = require("Business/Apartment/Mediators/ApartmentInformationMediator")
local Valid
function ApartmentInformationPage:ListNeededMediators()
  return {ApartmentInformationMediator}
end
function ApartmentInformationPage:SetPageActive(bIsActive)
  self.bIsActivePage = bIsActive
end
function ApartmentInformationPage:GetPageIsActive()
  return self.bIsActivePage
end
function ApartmentInformationPage:Init(PageData)
  if not self.bIsActivePage then
    return
  end
  Valid = self.TextBlock_CnName and self.TextBlock_CnName:SetText(PageData.CnName)
  Valid = self.TextBlock_EnName and self.TextBlock_EnName:SetText(PageData.EnName)
  Valid = self.TextBlock_CnCVName and self.TextBlock_CnCVName:SetText(PageData.CnCVName)
  Valid = self.TextBlock_EnCVName and self.TextBlock_EnCVName:SetText(PageData.EnCVName)
  Valid = self.TextBlock_Sex and self.TextBlock_Sex:SetText(PageData.Sex)
  Valid = self.TextBlock_Height and self.TextBlock_Height:SetText(PageData.Height)
  Valid = self.TextBlock_Age and self.TextBlock_Age:SetText(PageData.Age)
  Valid = self.TextBlock_Birthday and self.TextBlock_Birthday:SetText(PageData.Birthday)
  Valid = self.TextBlock_Weight and self.TextBlock_Weight:SetText(PageData.Weight)
  Valid = self.TextBlock_Team and self.TextBlock_Team:SetText(PageData.Team)
  Valid = self.TextBlock_BornPlace and self.TextBlock_BornPlace:SetText(PageData.BornPlace)
  Valid = self.TextBlock_Apartment and self.TextBlock_Apartment:SetText(PageData.Apartment)
  Valid = self.ScrollBox and self.ScrollBox:ScrollToStart()
  self.SizeBox_Button:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.VerticalBox_Biography:ClearChildren()
  self.FixedSizeMap = {}
  local TempMap = {}
  local TempSize = self:GetFixedSize()
  local ItemClass = ObjectUtil:LoadClass(self.ApartmentInformationItemClass)
  local ProductPanel
  for index, BiographyData in pairs(PageData.BiographyList or {}) do
    ProductPanel = UE4.UWidgetBlueprintLibrary.Create(self, ItemClass)
    if ProductPanel then
      ProductPanel.Parent = self
      ProductPanel:Init(BiographyData)
      Valid = self.VerticalBox_Biography and self.VerticalBox_Biography:AddChildToVerticalBox(ProductPanel)
      TempMap = {Panel = ProductPanel, FixedSize = TempSize}
      table.insert(self.FixedSizeMap, TempMap)
      TempSize = TempSize + ProductPanel:GetDesiredSize().Y
    end
  end
end
function ApartmentInformationPage:GetFixedSize()
  if self.FixedSize and 0 ~= self.FixedSize then
    return self.FixedSize
  end
  self.FixedSize = 0
  local AllChildren = self.ScrollBox:GetAllChildren()
  local AllChildrenTable = AllChildren:ToTable()
  for i = 1, AllChildren:Num() - 1 do
    local Child = AllChildren:Get(i)
    self.FixedSize = self.FixedSize + Child:GetDesiredSize().Y
  end
  return self.FixedSize
end
function ApartmentInformationPage:RefreshFixedMap()
  local TempSize = self:GetFixedSize()
  for index, value in pairs(self.FixedSizeMap or {}) do
    value.FixedSize = TempSize
    TempSize = TempSize + value.Panel:GetDesiredSize().Y
  end
end
function ApartmentInformationPage:InitializeLuaEvent()
end
function ApartmentInformationPage:LuaHandleKeyEvent(key, inputEvent)
  return false
end
function ApartmentInformationPage:Construct()
  ApartmentInformationPage.super.Construct(self)
  Valid = self.ScrollBox and self.ScrollBox.OnUserScrolled:Add(self, self.OnUserScrolled)
  Valid = self.Button and self.Button.OnClicked:Add(self, self.OnClickedButton)
end
function ApartmentInformationPage:Destruct()
  Valid = self.ScrollBox and self.ScrollBox.OnUserScrolled:Remove(self, self.OnUserScrolled)
  Valid = self.Button and self.Button.OnClicked:Remove(self, self.OnClickedButton)
  ApartmentInformationPage.super.Destruct(self)
end
function ApartmentInformationPage:OnUserScrolled(CurrentOffset)
  self:RefreshFixedMap()
  local bIsSeted = false
  local NewPanel
  for index, value in pairs(self.FixedSizeMap or {}) do
    local Panel = value.Panel
    local FixedSize = Panel:GetTitleSize()
    if CurrentOffset >= value.FixedSize then
      NewPanel = Panel
    end
    local Min = math.max(value.FixedSize - FixedSize, 0)
    local Max = math.max(value.FixedSize, 0)
    if CurrentOffset >= Min and CurrentOffset <= Max then
      Valid = self.Overlay_0 and self.Overlay_0:SetRenderTranslation(UE4.FVector2D(0, Min - CurrentOffset))
      bIsSeted = true
    end
  end
  if not bIsSeted then
    Valid = self.Overlay_0 and self.Overlay_0:SetRenderTranslation(UE4.FVector2D(0, 0))
  end
  if self.RecordPanel ~= NewPanel then
    Valid = self.RecordPanel and self.RecordPanel:IsValid() and self.Button and self.Button.OnClicked:Remove(self.RecordPanel, self.RecordPanel.ClickedButton)
    Valid = NewPanel and NewPanel:IsValid() and self.Button and self.Button.OnClicked:Add(NewPanel, NewPanel.ClickedButton)
    Valid = NewPanel and NewPanel:IsValid() and self.Button and self.Button:SetIsEnabled(true)
    Valid = NewPanel and NewPanel:IsValid() and self.Image_DownArrow and self.Image_DownArrow:SetRenderTransformAngle(NewPanel.ButtonClicked and 0 or 180)
    Valid = self.TextBlock_Title and self.TextBlock_Title:SetText(NewPanel and NewPanel.Title or "")
    Valid = self.SizeBox_Button and self.SizeBox_Button:SetVisibility(NewPanel and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self.RecordPanel = NewPanel
  end
  local Cliping = UE.EWidgetClipping.Inherit
  if NewPanel and NewPanel:IsValid() then
    Cliping = UE.EWidgetClipping.ClipToBoundsAlways
  end
  if bIsSeted then
    Cliping = UE.EWidgetClipping.Inherit
  end
  Valid = self.SizeBox_Scroll and self.SizeBox_Scroll:SetClipping(Cliping)
end
function ApartmentInformationPage:OnClickedButton()
  Valid = self.Button and self.Button:SetIsEnabled(false)
  Valid = self.SizeBox_Button and self.SizeBox_Button:SetVisibility(UE4.ESlateVisibility.Collapsed)
  Valid = self.RecordPanel:IsValid() and self.ScrollBox and self.ScrollBox:ScrollWidgetIntoView(self.RecordPanel, false)
end
return ApartmentInformationPage
