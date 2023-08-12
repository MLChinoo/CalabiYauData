local OpenTipOffPlayerCmd = class("OpenTipOffPlayerCmd", PureMVC.Command)
function OpenTipOffPlayerCmd:Execute(notification)
  if notification:GetName() == NotificationDefines.TipoffPlayer.OpenTipOffPlayerCmd then
    LogDebug("OpenTipOffPlayerCmd", "Cmd Executed .")
    local TipoffPageParam = notification:GetBody()
    local bBlock, RetCode = self:CmdSpecialFilter(TipoffPageParam)
    if bBlock then
      if "FunctionBlock" == RetCode then
        ShowCommonTip("暂未开放，敬请期待")
      end
      return
    end
    local TargetUID = TipoffPageParam.TargetUID
    local EnteranceType = TipoffPageParam.EnteranceType
    local bNeedLimitCheck = EnteranceType == UE4.ECyTipoffEntranceType.ENTERANCE_INGAME
    if bNeedLimitCheck then
      local inGameTipoffPlayerDataProxy = GameFacade:RetrieveProxy(ProxyNames.InGameTipoffPlayerDataProxy)
      if inGameTipoffPlayerDataProxy then
        local bMaxTipoff = inGameTipoffPlayerDataProxy:CheckPlayerTipoffMax(TargetUID, EnteranceType)
        if bMaxTipoff then
          ShowCommonTip(ConfigMgr:FromStringTable(StringTablePath.ST_Tipoff, "Tipoff_Limit"))
          return
        end
      end
    end
    LogDebug(TableToString(TipoffPageParam))
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.TipoffPlayerPage, false, TipoffPageParam)
  end
end
function OpenTipOffPlayerCmd:CmdSpecialFilter(Param)
  if not Param then
    return true, "Param_Invaild"
  end
  if not Param.TargetUID or Param.TargetUID <= 0 then
    return true, "ParamTarget_Invaild"
  end
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    return true, "FunctionBlock"
  end
  return false
end
return OpenTipOffPlayerCmd
