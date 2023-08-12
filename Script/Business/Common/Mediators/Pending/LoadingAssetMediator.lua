local LoadingAssetMediator = class("LoadingAssetMediator", PureMVC.Mediator)
function LoadingAssetMediator:ListNotificationInterests()
  return {}
end
function LoadingAssetMediator:HandleNotification(notification)
end
function LoadingAssetMediator:OnRegister()
  local GlobalDelegateMgr = GetGlobalDelegateManager()
  if GlobalDelegateMgr then
    self.OnLoadingAssetHandle = DelegateMgr:AddDelegate(GlobalDelegateMgr.OnLoadingAssetDelegate, self, "OnLoadingAsset")
    self.OnLoadingAssetTipHandle = DelegateMgr:AddDelegate(GlobalDelegateMgr.OnLoadingAssetTipDelegate, self, "OnLoadingAssetTip")
  end
end
function LoadingAssetMediator:OnRemove()
  local GlobalDelegateMgr = GetGlobalDelegateManager()
  if GlobalDelegateMgr then
    DelegateMgr:RemoveDelegate(GlobalDelegateMgr.OnLoadingAssetDelegate, self.OnLoadingAssetHandle)
    DelegateMgr:RemoveDelegate(GlobalDelegateMgr.OnLoadingAssetTipDelegate, self.OnLoadingAssetTipHandle)
  end
end
function LoadingAssetMediator:OnLoadingAsset(percent)
  print("^^^^^^^^^^^^^^^^^^^^^^^^^^^ percnet = %s", percent)
  self:GetViewComponent():SetPercent(percent)
end
function LoadingAssetMediator:OnLoadingAssetTip(tip)
  print("^^^^^^^^^^^^^^^^^^^^^^^^^^^ Tip = %s", tip)
  self:GetViewComponent():SetTip(tip)
end
function LoadingAssetMediator:UpdateView(data)
end
return LoadingAssetMediator
