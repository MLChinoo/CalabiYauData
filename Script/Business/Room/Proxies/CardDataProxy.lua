local CardDataProxy = class("CardDataProxy", PureMVC.Proxy)
local CardEnum = require("Business/Room/Mediators/Card/CardEnum")
function CardDataProxy:ctor(proxyName, data)
  CardDataProxy.super.ctor(self, proxyName, data)
end
function CardDataProxy:OnRegister()
  CardDataProxy.super.OnRegister(self)
  self.achievementInfoArray = {}
  self.achievementMap = {}
  self.achievementLevelMap = {}
  self.defaultAvatarId = -1
  self.defaultCardFrameId = -1
  self.defaultCardBorderId = -1
  self.avatarId = 0
  self.cardFrameId = 0
  self.cardBorderId = 0
  self.achievementId = 0
  self.ownedCardResourceInfo = {}
  self.cardResourceTable = {}
  self:InitTableCfg()
end
function CardDataProxy:InitTableCfg()
  self.cardResourceTable = {}
  local arrRows = ConfigMgr:GetPlayerIdCardTableRows()
  if arrRows then
    for rowName, rowData in pairs(arrRows:ToLuaTable()) do
      if rowData then
        self.cardResourceTable[rowData.Id] = rowData
        if rowData.Default then
          if rowData.Type == CardEnum.CardResourceType.Avatar then
            self.defaultAvatarId = rowData.Id
          elseif rowData.Type == CardEnum.CardResourceType.Frame then
            self.defaultCardFrameId = rowData.Id
          elseif rowData.Type == CardEnum.CardResourceType.Border then
            self.defaultCardBorderId = rowData.Id
          end
        end
      end
    end
  end
end
function CardDataProxy:GetDefaultAvatarId()
  return self.defaultAvatarId
end
function CardDataProxy:GetDefaultFrameId()
  return self.defaultCardFrameId
end
function CardDataProxy:GetDefaultBorderId()
  return self.defaultCardBorderId
end
function CardDataProxy:OnResCareerInfo(data)
  local career_info_res = pb.decode(Pb_ncmd_cs_lobby.career_info_res, data)
end
function CardDataProxy:OnResAvatarList(data)
  local careerGetHeadIconsRes = pb.decode(Pb_ncmd_cs_lobby.career_get_head_icons_res, data)
end
function CardDataProxy:UpdateCardInfo(inAvatarId, inCardFrameId, inBorderId, inAchievementId)
  self.avatarId = inAvatarId > 0 and inAvatarId or self.defaultAvatarId
  self.cardFrameId = inCardFrameId > 0 and inCardFrameId or self.defaultCardFrameId
  self.cardBorderId = inBorderId > 0 and inBorderId or self.defaultCardBorderId
  self.achievementId = inAchievementId
  local paras = {
    roleSKinId = inAvatarId,
    cardFrameId = inCardFrameId,
    cardBorderId = inBorderId,
    achievementId = inAchievementId
  }
  GameFacade:SendNotification(NotificationDefines.TeamRoom.RefreshCard, paras)
end
function CardDataProxy:GetOwnedCardResourceInfoFromId(inResourceId)
  return self.ownedCardResourceInfo[inResourceId]
end
function CardDataProxy:GetCardResourceTableFromId(inResourceId)
  return self.cardResourceTable[inResourceId]
end
function CardDataProxy:GetOwnedCardResourceInfoFromType(cardResourceType)
  local res = {}
  for _, v in pairs(self.ownedCardResourceInfo) do
    local resourceInfo = v.Value
    if resourceInfo.idCardTableRow.Type == cardResourceType then
      res[resourceInfo.ResourceId] = resourceInfo
    end
  end
  return res
end
function CardDataProxy:GetCardResourceTableFromType(cardResourceType)
  local res = {}
  for _, v in pairs(self.ownedCardResourceInfo) do
    local cardResourceInfo = v.Value
    if cardResourceInfo.Type == cardResourceType then
      res[cardResourceInfo.Id] = cardResourceInfo
    end
  end
  return res
end
function CardDataProxy:GetAvatarId()
  return self.avatarId
end
function CardDataProxy:GetFrameId()
  return self.cardFrameId
end
function CardDataProxy:GetBorderId()
  return self.cardBorderId
end
function CardDataProxy:GetAchievementId()
  return self.achievementId
end
function CardDataProxy:GetDefaultAvatarId()
  return self.defaultAvatarId
end
function CardDataProxy:GetDefaultFrameId()
  return self.defaultCardFrameId
end
function CardDataProxy:GetDefaultBorderId()
  return self.defaultCardBorderId
end
function CardDataProxy:GetDefaultMemberInfo()
  local defaultMemberInfo = {}
  defaultMemberInfo.playerId = 0
  defaultMemberInfo.pos = 0
  defaultMemberInfo.status = 0
  defaultMemberInfo.icon = 0
  defaultMemberInfo.sex = 0
  defaultMemberInfo.level = 0
  defaultMemberInfo.rank = 0
  defaultMemberInfo.ready = 0
  defaultMemberInfo.avatarId = 0
  defaultMemberInfo.frameId = 0
  defaultMemberInfo.borderId = 0
  defaultMemberInfo.achievementId = 0
  defaultMemberInfo.bIsRobot = false
  return defaultMemberInfo
end
return CardDataProxy
