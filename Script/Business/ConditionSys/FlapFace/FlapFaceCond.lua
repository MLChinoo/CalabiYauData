local FlapFaceCond = {}
local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
function FlapFaceCond:BPGetMatchConditionCount(paramStr)
  local FlapFaceProxy = GameFacade:RetrieveProxy(ProxyNames.FlapFaceProxy)
  local FlapFaceEnum = require("Business/Activities/FlapFace/Proxies/FlapFaceEnum")
  local typeOrder = FlapFaceProxy:GetTypeOrder()
  FlapFaceProxy:SetCurrrentPopPage()
  for i, v in ipairs(typeOrder) do
    if FlapFaceProxy:CheckPopPage(v.indexName) then
      FlapFaceProxy:SetCurrrentPopPage(v.indexName)
      return 1
    end
  end
  return 0
end
return FlapFaceCond
