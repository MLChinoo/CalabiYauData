require("UnLua")
require("pb")
local PM_UITemplate = Class()
local this = PM_UITemplate
function this:Construct()
  print("Unlua ...Construct")
end
function this:OnInitialized()
  self.TestText:SetText("login")
  print("Unlua ...OnInitialized")
  GetLobbyServiceHandle():SubscribeCmd(2004)
  GetLobbyServiceHandle():SubscribeCmd(2008)
  GetLobbyServiceHandle():SubscribeCmd(2078)
end
function this:OnClickBtnTest()
  print("OnClickBtn " .. tostring(self.TestBtn))
end
return this
