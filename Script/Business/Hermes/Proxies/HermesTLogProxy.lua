local HermesTLogProxy = class("HermesTLogProxy", PureMVC.Proxy)
function HermesTLogProxy:OnRegister()
end
function HermesTLogProxy:OnRemove()
end
function HermesTLogProxy:SendTLogData(StoreId, IsOwned, IsOwnedPart)
  local EStoreState = {
    NotOwned = 0,
    AllOwned = 1,
    PartOwned = 2
  }
  local StoreState
  if IsOwned then
    StoreState = EStoreState.AllOwned
  elseif IsOwnedPart then
    StoreState = EStoreState.PartOwned
  else
    StoreState = EStoreState.NotOwned
  end
  LogDebug("HermesTLogProxy:SendTLogData", "StoreId is :" .. StoreId .. ", StoreState is :" .. StoreState)
  UE4.UCyClientEventTrackSubsystem.Get(LuaGetWorld()):UploadHermesClickData(StoreId, StoreState)
end
return HermesTLogProxy
