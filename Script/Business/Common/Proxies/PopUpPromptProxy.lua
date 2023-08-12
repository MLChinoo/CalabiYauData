local PopUpPromptProxy = class("PopUpPromptProxy", PureMVC.Proxy)
function PopUpPromptProxy:OnRegister()
  PopUpPromptProxy.super.OnRegister(self)
  self.bExist = false
end
function PopUpPromptProxy:SetPrompUIExistFlag(bFlag)
  self.bExist = bFlag
end
function PopUpPromptProxy:GetPrompUIExistFlag()
  return self.bExist
end
return PopUpPromptProxy
