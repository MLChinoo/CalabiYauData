local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local VoucherJumpMediator = class("VoucherJumpMediator", SuperClass)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local PanelTypeStr = SettingEnum.PanelTypeStr
function VoucherJumpMediator:OnRegister()
  SuperClass.OnRegister(self)
  local view = self:GetViewComponent()
  local oriData = view.oriData
  view.TextBlock_Name:SetText(oriData.Name)
  view.TextBlock_Desc:SetText(oriData.DefaultOption2)
  local handler = function(obj, method)
    return function(...)
      method(obj, ...)
    end
  end
  view.Button_Jump.OnClicked:Add(view, handler(self, self.OnClickedJump))
end
function VoucherJumpMediator:OnClickedJump(_)
  local WebUrlProxy = GameFacade:RetrieveProxy(ProxyNames.WebUrlProxy)
  local WebUrlMap = WebUrlProxy:GetWebUrlMap()
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  local url = WebUrlProxy:GetWebUrlByIndex(WebUrlMap.Enum_WebUrl.ExchangeUrl)
  GCloudSdk:OpenWebView(url, 1, 0.7)
end
return VoucherJumpMediator
