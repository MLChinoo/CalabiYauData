local ApartmentTLogProxy = class("ApartmentTLogProxy", PureMVC.Proxy)
function ApartmentTLogProxy:OnRegister()
end
function ApartmentTLogProxy:OnRemove()
end
function ApartmentTLogProxy:ApartmentPlayFrequency()
end
function ApartmentTLogProxy:ApartmentTouchFrequency()
end
function ApartmentTLogProxy:NightgownDownloadsFrequency()
  local data = UE4.FApartmentClickEventFlowData()
  data.Apartmentclickevent = 2
  self:HandleCommonData(data)
  local str = UE4.UPMCliTLogApi.Make_Apartmentclickeventflow_Data(data)
  self:SendTLogData(str)
end
function ApartmentTLogProxy:EntryApartmentTime()
  local data = UE4.FApartmentTimeFlowData()
  self:HandleCommonData(data)
  data.Apartmenteventtime = data.Dteventtime
  data.Apartmentevent = 1
  local str = UE4.UPMCliTLogApi.Make_Apartmenttimeflow_Data(data)
  self:SendTLogData(str)
end
function ApartmentTLogProxy:LeaveApartmentTime()
  local data = UE4.FApartmentTimeFlowData()
  self:HandleCommonData(data)
  data.Apartmenteventtime = data.Dteventtime
  data.Apartmentevent = 2
  local str = UE4.UPMCliTLogApi.Make_Apartmenttimeflow_Data(data)
  self:SendTLogData(str)
end
function ApartmentTLogProxy:MessageFrequency()
  local data = UE4.FApartmentClickEventFlowData()
  data.Apartmentclickevent = 1
  self:HandleCommonData(data)
  local str = UE4.UPMCliTLogApi.Make_Apartmentclickeventflow_Data(data)
  self:SendTLogData(str)
end
function ApartmentTLogProxy:HandleCommonData(data)
  local commonData = UE4.FCinematicChapterFlowData()
  UE4.UCyClientEventTrackSubsystem.Get(LuaGetWorld()):GetCommonData(commonData)
  data.Gamesvrid = commonData.Gamesvrid
  data.Dteventtime = commonData.Dteventtime
  data.Vgameappid = commonData.Vgameappid
  data.Platid = commonData.Platid
  data.Izoneareaid = commonData.Izoneareaid
  data.Vopenid = commonData.Vopenid
  data.Vroleid = commonData.Vroleid
  data.Vrolename = commonData.Vrolename
end
function ApartmentTLogProxy:SendTLogData(data)
  LogDebug("ApartmentTLogProxySendTLogData", "Data is :")
  table.print(data)
  UE4.UPMTLogHttpSubSystem.GetInst(LuaGetWorld()):SendTLogData(data, false)
end
return ApartmentTLogProxy
