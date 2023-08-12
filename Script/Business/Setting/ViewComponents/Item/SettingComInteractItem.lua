local SettingComInteractItem = class("SettingComInteractItem", PureMVC.ViewComponentPanel)
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local ItemType = SettingEnum.ItemType
local MediatorName = "Mediator"
local getMediatorPath = function(name)
  if "ButtonStyle_OpenAimMode" == name or "ButtonStyle_ShoulderMode" == name or "SettingAiming" == name or "SettingShoulder" == name then
    return name
  end
  return string.format("Business/Setting/Mediators/Interact/%s", name) .. MediatorName
end
local requireMediators = function(oriData)
  local indexKey = oriData.indexKey
  local indexKeyPath = getMediatorPath(indexKey)
  local mediatorPath = indexKeyPath
  xpcall(function()
    require(indexKeyPath)
  end, function(err)
    local SettingSensitivityProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSensitivityProxy)
    if SettingHelper.CheckIsGraphicQuality(oriData.indexKey) then
      mediatorPath = getMediatorPath("ScalabilityQuality")
      package.loaded[indexKeyPath] = require(getMediatorPath("ScalabilityQuality"))
    elseif oriData.UiType == ItemType.OperateItem then
      mediatorPath = getMediatorPath("KeyChange")
      package.loaded[indexKeyPath] = require(getMediatorPath("KeyChange"))
    else
      mediatorPath = getMediatorPath("DefaultCommon")
      package.loaded[indexKeyPath] = require(getMediatorPath("DefaultCommon"))
    end
  end)
  return package.loaded[indexKeyPath]
end
function SettingComInteractItem:ListNeededMediators()
  local oriData = self.oriData
  return {
    requireMediators(oriData)
  }
end
function SettingComInteractItem:RefreshView()
end
function SettingComInteractItem:SetCurrentValue(currentValue)
end
function SettingComInteractItem:InitView()
end
return SettingComInteractItem
