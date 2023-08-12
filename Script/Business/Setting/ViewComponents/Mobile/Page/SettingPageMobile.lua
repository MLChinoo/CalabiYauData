local SuperClass = require("Business/Setting/ViewComponents/Page/SettingPagePC")
local SettingPageMobile = class("SettingPageMobile", SuperClass)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingPageMediatorMobile = require("Business/Setting/Mediators/Mobile/SettingPageMediatorMobile")
local SettingPageApplyChangeMediator = require("Business/Setting/Mediators/SettingPageApplyChangeMediator")
function SettingPageMobile:ListNeededMediators()
  return {SettingPageMediatorMobile, SettingPageApplyChangeMediator}
end
function SettingPageMobile:InitializeLuaEvent()
  SettingHelper.InitMBCfgPath(self)
end
function SettingPageMobile:BindDefaultFunc(func, btn)
  btn = btn or self.Button_Default
  btn.OnClicked:Add(self, func)
end
function SettingPageMobile:BindApplyFunc(func)
  self.Button_Apply.OnClicked:Add(self, func)
end
function SettingPageMobile:BindCloseFunc(func)
  self.WBP_CommonReturnButton_Mobile.OnClickEvent:Add(self, func)
end
function SettingPageMobile:RefreshButtonLayoutByPanelType(curPanelType)
  if curPanelType == SettingEnum.PanelTypeStr.Basic then
    self.Button_Default:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Button_Default:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
function SettingPageMobile:SetDefaultBtnEnabled(bEnabled)
  self.Button_Default:SetIsEnabled(bEnabled)
  if self.defaultButton then
    self.defaultButton:SetIsEnabled(bEnabled)
  end
end
function SettingPageMobile:SetApplyBtnEnabled(bEnabled)
  self.Button_Apply:SetIsEnabled(bEnabled)
end
function SettingPageMobile:SetDefaultButtonEx(defaultBtn)
  self.defaultButton = defaultBtn
end
return SettingPageMobile
