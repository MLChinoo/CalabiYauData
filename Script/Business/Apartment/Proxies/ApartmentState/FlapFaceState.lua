local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local FlapFaceEnum = require("Business/Activities/FlapFace/Proxies/FlapFaceEnum")
local FlapFaceState = class("FlapFaceState", BaseState)
function FlapFaceState:Start()
  self.super.Start(self)
  self:PlayStateSeqence()
  self:JumpPage()
end
function FlapFaceState:JumpPage()
  local FlapFaceProxy = GameFacade:RetrieveProxy(ProxyNames.FlapFaceProxy)
  local indexName = FlapFaceProxy:GetCurrrentPopPage()
  local PageName
  if indexName == FlapFaceEnum.FlapFace then
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.FlapFacePage, false, {
      CloseCallBack = function()
        local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
        if RoleAttrMap.CheckFunc(RoleAttrMap.EnumConditionType.FlapFaceCond) then
          self:JumpPage()
        end
      end
    })
  elseif indexName == FlapFaceEnum.MonthlyCard then
    FlapFaceProxy:SetMonthlyCardJumped(true)
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.MonthlyCardPage, false, {
      CloseCallBack = function()
        local RoleAttrMap = require("Business/Apartment/Proxies/RoleAttrMap")
        if RoleAttrMap.CheckFunc(RoleAttrMap.EnumConditionType.FlapFaceCond) then
          self:JumpPage()
        end
      end
    })
  else
    self:JudgeCond()
  end
end
function FlapFaceState:Tick()
end
function FlapFaceState:Stop()
  self.super.Stop(self)
end
function FlapFaceState:OnSequenceStop(sequenceId, reasonType)
end
return FlapFaceState
