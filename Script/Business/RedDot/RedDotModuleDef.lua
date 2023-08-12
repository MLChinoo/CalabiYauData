local RedDotModuleDef = {}
RedDotModuleDef.ModuleName = {}
local C = {}
C.NavAvatar = "Main.NavAvatar"
C.BusinessCard = "Main.NavAvatar.BusinessCard"
C.BCAvatar = "Main.NavAvatar.BusinessCard.BCAvatar"
C.BCFrame = "Main.NavAvatar.BusinessCard.BCFrame"
C.BCAchieve = "Main.NavAvatar.BusinessCard.BCAChieve"
C.Career = "Main.Career"
C.CareerAchievement = "Main.Career.Achievement"
C.CareerAchieveCombat = "Main.Career.Achievement.Combat"
C.CareerACItem = "Main.Career.Achievement.Item"
C.CareerACReward = "Main.Career.Achievement.Combat.Reward"
C.CareerAchieveEpic = "Main.Career.Achievement.Epic"
C.CareerAEItem = "Main.Career.Achievement.Item"
C.CareerAEReward = "Main.Career.Achievement.Epic.Reward"
C.CareerAchieveHornor = "Main.Career.Achievement.Hornor"
C.CareerAHItem = "Main.Career.Achievement.Item"
C.CareerAHReward = "Main.Career.Achievement.Hornor.Reward"
C.CareerAchieveGlory = "Main.Career.Achievement.Glory"
C.CareerAGItem = "Main.Career.Achievement.Item"
C.CareerAGReward = "Main.Career.Achievement.Glory.Reward"
C.CareerAchieveHero = "Main.Career.HeroAchievement"
C.CareerAHeroItem = "Main.Career.HeroAchievement.Item"
C.CareerAHeroReward = "Main.Career.Achievement.Hero.Reward"
C.CareerWarehouse = "Main.Career.WareHouse"
C.KaPhone = "Main.KaPhone"
C.KaChat = "Main.KaPhone.KaChat"
C.KaChatItem = "Main.KaPhone.KaChat.KaChatItem"
C.KaChatSubItem = "Main.KaPhone.KaChat.KaChatItem.KaChatSubItem"
C.KaMail = "Main.KaPhone.KaMail"
C.KaNavigation = "Main.KaPhone.KaNavigation"
C.Friend = "Main.Friend"
C.Battlepass = "Main.Battlepass"
C.BPProgress = "Main.Battlepass.BPProgress"
C.BPTask = "Main.Battlepass.BPTask"
C.BPClue = "Main.Battlepass.BPClue"
C.EquipRoom = "Main.EquipRoom"
C.Decal = "Main.EquipRoom.ReleDefault.Decal"
C.EquipRoomFlyEffect = "Main.EquipRoom.ReleDefault.FlyEffect"
C.RoleDefault = "Main.EquipRoom.ReleDefault"
C.EquipRoomRoleSkin = "Main.EquipRoom.ReleDefault.RoleSkin"
C.EquipRoomRoleVoice = "Main.EquipRoom.ReleDefault.RoleVoice"
C.EquipRoomCommuication = "Main.EquipRoom.ReleDefault.Commuication"
C.EquipRoomCommuicationVoice = "Main.EquipRoom.ReleDefault.Commuication.Voice"
C.EquipRoomPersonal = "Main.EquipRoom.ReleDefault.Personal"
C.EquipRoomCommuicationAction = "Main.EquipRoom.ReleDefault.Personal.Action"
C.EquipRoomPersonalEmote = "Main.EquipRoom.ReleDefault.Personal.Emote"
C.EquipRoomWeaponSkin = "Main.EquipRoom.WeaponSkin"
C.EquipRoomPrimaryWeaponSkin = "Main.EquipRoom.WeaponSkin.PrimaryWeaponSkin"
C.EquipRoomSecondaryWeaponSkin = "Main.EquipRoom.WeaponSkin.SecondaryWeaponSkin"
C.Apartment = "Main.Apartment"
C.Promise = "Main.Apartment.Promise"
C.PromiseBiography = "Main.Apartment.Promise.PromiseBiography"
C.PromiseTaskRewards = "Main.Apartment.Promise.PromiseTaskRewards"
C.PromiseGift = "Main.Apartment.Promise.PromiseGift"
C.PromiseItemAndMemory = "Main.Apartment.Promise.PromiseItemAndMemory"
C.PromiseItem = "Main.Apartment.Promise.PromiseItemAndMemory.PromiseItem"
C.PromiseMemory = "Main.Apartment.Promise.PromiseItemAndMemory.PromiseMemory"
local PC = {}
PC.CareerRank = "Main.Career.Rank"
PC.CareerRankReward = "Main.Career.Rank.Reward"
local M = {}
M.Chat = "Main.Chat"
M.ChatWorld = "Main.Chat.World"
M.ChatTeam = "Main.Chat.Team"
M.ChatRoom = "Main.Chat.Room"
M.ChatPrivate = "Main.Chat.Private"
M.ChatPFriend = "Main.Chat.Private.Friend"
M.ChatPNearest = "Main.Chat.Private.Nearest"
M.GameChat = "Main.GameChat"
M.GameChatPrivate = "Main.GameChat.Private"
M.CareerRank = "Main.Rank"
M.CareerRankReward = "Main.Rank.Reward"
M.FriendMB = "Main.FriendMB"
M.FriendReq = "Main.FriendMB.FriendReq"
function RedDotModuleDef.Init()
  for key, value in pairs(C) do
    RedDotModuleDef.ModuleName[key] = value
  end
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    for key, value in pairs(M) do
      RedDotModuleDef.ModuleName[key] = value
    end
  else
    for key, value in pairs(PC) do
      RedDotModuleDef.ModuleName[key] = value
    end
  end
end
return RedDotModuleDef
