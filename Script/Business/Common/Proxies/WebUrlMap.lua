local WebUrlMap = {}
local Enum_WebUrl = {
  UserAgreement = 1,
  PrivacyPolicy = 2,
  ChildrenPrivacyPolicy = 3,
  ExchangeUrl = 4,
  ThirdPartyList = 5
}
local Enum_ReverseWebUrl = {}
local reverseMap = function()
  for k, v in pairs(Enum_WebUrl) do
    Enum_ReverseWebUrl[v] = k
  end
end
reverseMap()
WebUrlMap.Enum_WebUrl = Enum_WebUrl
WebUrlMap.Enum_ReverseWebUrl = Enum_ReverseWebUrl
return WebUrlMap
