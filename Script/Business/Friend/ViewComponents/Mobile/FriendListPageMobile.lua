local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local FriendListPageMediatorMobile = require("Business/Friend/Mediators/Mobile/FriendListPageMediatorMobile")
local FriendListPageMobile = class("FriendListPageMobile", PureMVC.ViewComponentPage)
function FriendListPageMobile:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendListPageMobile:ListNeededMediators()
  return {FriendListPageMediatorMobile}
end
function FriendListPageMobile:InitializeLuaEvent()
  self.actionOnRecentPlayerBtnClick = LuaEvent.new()
  self.actionOnSearchBtnClick = LuaEvent.new()
  self.actionOnClearTextBtnClick = LuaEvent.new()
  self.actionOnSearchTextChange = LuaEvent.new()
end
function FriendListPageMobile:Construct()
  FriendListPageMobile.super.Construct(self)
  self.RecentPlayerBtn.OnClicked:Add(self, self.OnRecentPlayerBtnClick)
  self.searchBtn.OnClicked:Add(self, self.OnSearchBtnClick)
  self.ClearTextBtn.OnClicked:Add(self, self.OnClearTextBtnClick)
  self.WBP_CommonReturnButton_Mobile.OnClickEvent:Add(self, self.OnClickBackBtn)
  self.searchText.OnTextChanged:Add(self, self.OnSearchTextChange)
  self.searchBtn:SetIsEnabled(false)
  self:BindRedDot()
  self.OpenShareTestPageBtn.OnClicked:Add(self, self.OnClickOpenShareTestPageBtn)
  local ShareIndex = 8401
  local bIsShareEnable = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetAnyParameterCfg(ShareIndex).ParaValue
  if bIsShareEnable == tostring(1) then
    self.TestBtnsRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.TestBtnsRoot:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  for i = 1, 9 do
    self["ShareBtn_" .. i].OnClicked:Add(self, function()
      self:OnShareBtnClick(i - 1)
    end)
  end
  self.OnCaptureScreenshotSuccessHandler = DelegateMgr:AddDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self, "OnCaptureScreenshotSuccess")
end
function FriendListPageMobile:OnCaptureScreenshotSuccess(texture)
  self.TestBtnsRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end
function FriendListPageMobile:OnShareBtnClick(type)
  LogDebug("FriendListPageMobile", "OnShareBtnClick type = " .. type)
  self.TestBtnsRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.ShareBigImagePage, nil, type)
end
function FriendListPageMobile:Destruct()
  FriendListPageMobile.super.Destruct(self)
  self.RecentPlayerBtn.OnClicked:Remove(self, self.OnRecentPlayerBtnClick)
  self.searchBtn.OnClicked:Remove(self, self.OnSearchBtnClick)
  self.ClearTextBtn.OnClicked:Remove(self, self.OnClearTextBtnClick)
  self.WBP_CommonReturnButton_Mobile.OnClickEvent:Remove(self, self.OnClickBackBtn)
  self.searchText.OnTextChanged:Remove(self, self.OnSearchTextChange)
  self:UnbindRedDot()
  self.OpenShareTestPageBtn.OnClicked:Remove(self, self.OnClickOpenShareTestPageBtn)
  if self.OnCaptureScreenshotSuccessHandler then
    DelegateMgr:RemoveDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self.OnCaptureScreenshotSuccessHandler)
    self.OnCaptureScreenshotSuccessHandler = nil
  end
end
function FriendListPageMobile:OnClickBackBtn()
  ViewMgr:PopPage(self, UIPageNameDefine.FriendList)
end
function FriendListPageMobile:OnRecentPlayerBtnClick()
  self.actionOnRecentPlayerBtnClick()
end
function FriendListPageMobile:OnSearchBtnClick()
  self.actionOnSearchBtnClick()
end
function FriendListPageMobile:OnSearchTextChange(text)
  self.actionOnSearchTextChange(text)
end
function FriendListPageMobile:OnClearTextBtnClick()
  self.actionOnClearTextBtnClick()
end
function FriendListPageMobile:BindRedDot()
  RedDotTree:Bind(RedDotModuleDef.ModuleName.FriendReq, function(cnt)
    self:UpdateRedDotFriend(cnt)
  end)
  self:UpdateRedDotFriend(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.FriendReq))
end
function FriendListPageMobile:UnbindRedDot()
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.FriendReq)
end
function FriendListPageMobile:OnClickOpenShareTestPageBtn()
  ViewMgr:PushPage(LuaGetWorld(), UIPageNameDefine.ShareTestPage)
end
function FriendListPageMobile:UpdateRedDotFriend(cnt)
  self.NavigationBar:SetRedDot(FriendEnum.SelectCheckStatus.ViewReq, cnt)
end
return FriendListPageMobile
