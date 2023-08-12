local ApartmentInformationPageDataCmd = class("ApartmentInformationPageDataCmd", PureMVC.Command)
function ApartmentInformationPageDataCmd:Execute(notification)
  local KaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local RoleTeamProxy = GameFacade:RetrieveProxy(ProxyNames.RoleTeamProxy)
  local CurrentRoleId = KaNavigationProxy:GetCurrentRoleId()
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local RoleProfileCfg = RoleProxy:GetRoleProfile(CurrentRoleId)
  local RoleProfile = KaPhoneProxy:GetRoleProperties(CurrentRoleId)
  local TeamCfg = RoleTeamProxy:GetTeamTableRow(RoleProfileCfg.Team)
  local CurExp = RoleProfile.intimacy
  local Body = {
    CnName = RoleProfileCfg.NameCn,
    EnName = RoleProfileCfg.NameEn,
    CnCVName = RoleProfileCfg.CvCn,
    EnCVName = RoleProfileCfg.CV,
    Sex = RoleProfileCfg.Sex,
    Height = RoleProfileCfg.Height,
    Weight = RoleProfileCfg.Weight,
    Age = RoleProfileCfg.Age,
    Birthday = RoleProfileCfg.Birthday,
    Team = TeamCfg.NameCn,
    BornPlace = RoleProfileCfg.BornPlace,
    Apartment = RoleProfileCfg.Apartment,
    BiographyList = {}
  }
  local bIsRefresh = false
  local RecordLevel = 0
  local BiographyTable = RoleProxy:GetRoleBiographCfg(CurrentRoleId)
  for BiographyId, BiographyData in pairsByKeys(BiographyTable or {}, function(a, b)
    return a < b
  end) do
    local Temp = {
      RoleId = CurrentRoleId,
      BiographyId = BiographyId,
      Title = BiographyData.StoryTitle,
      Content = BiographyData.StoryContent,
      bIsRead = table.containsValue(RoleProfile.read_biographys, BiographyId),
      bIsUnlock = table.containsValue(RoleProfile.biographys, BiographyId) or table.containsValue(RoleProfile.read_biographys, BiographyId),
      bIsLock = false,
      ExpText = "",
      ExpProgress = 0
    }
    local FavorLev = RoleProxy:GetRoleFavorLevByBiographyId(CurrentRoleId, BiographyId)
    if FavorLev then
      local RoleLvData = RoleProxy:GetRoleFavoribility(math.max(FavorLev - 1, 1))
      if CurExp < RoleLvData.FExp then
        Temp.CurExpText = CurExp
        Temp.TotalExpText = RoleLvData.FExp
      end
      if Temp.bIsUnlock then
        Temp.CurExpText = RoleLvData.FExp
        bIsRefresh = true
        RecordLevel = 1 == FavorLev and 0 or RoleLvData.FExp
        Temp.ExpProgress = 1
      else
        if RecordLevel < RoleLvData.FExp then
          if bIsRefresh then
            bIsRefresh = false
            RecordLevel = RoleLvData.FExp
          else
            Temp.bIsLock = true
          end
        end
        Temp.ExpProgress = math.clamp(CurExp / RoleLvData.FExp, 0, 1)
      end
    end
    table.insert(Body.BiographyList, Temp)
  end
  table.sort(Body.BiographyList, function(a, b)
    return a.BiographyId < b.BiographyId
  end)
  GameFacade:SendNotification(NotificationDefines.SetApartmentInformationPageData, Body)
end
return ApartmentInformationPageDataCmd
