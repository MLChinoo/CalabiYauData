local GameFacade = PureMVC.Facade.GetInstance("GameFacade")
local LogInfo = _G.LogInfo
local GlobalModuleInits = {
  "Business/Common/Init",
  "Business/Login/Init",
  "Business/NewPlayerGuide/Init",
  "Business/Lobby/Init",
  "Business/BattlePass/Init",
  "Business/Player/Init",
  "Business/Career/Init",
  "Business/Chat/Init",
  "Business/PlayerProfile/Init",
  "Business/Lottery/Init",
  "Business/Items/Init",
  "Business/Role/Init",
  "Business/EquipRoom/Init",
  "Business/Weapon/Init",
  "Business/KaPhone/Init",
  "Business/WareHouse/Init",
  "Business/Friend/Init",
  "Business/Hermes/Init",
  "Business/Apartment/Init",
  "Business/Room/Init",
  "Business/Setting/Init",
  "Business/BattleScores/Init",
  "Business/ConnectDS/Init",
  "Business/SystemNotice/Init",
  "Business/Survey/Init",
  "Business/MidasPay/Init",
  "Business/Activities/Framework/Init",
  "Business/Activities/SpaceTime/Init",
  "Business/Activities/SpaceMusic/Init",
  "Business/Activities/SummerThemeSong/Init",
  "Business/Activities/InvitationLetter/Init",
  "Business/Activities/RechargeBate/Init",
  "Business/Activities/MichellePlaytime/Init",
  "Business/Tipoff/Init",
  "Business/Activities/FlapFace/Init",
  "Business/AccountBind/Init",
  "Business/Privilege/Init",
  "Business/Activities/MeredithRoleWarmUp/Init"
}
local LobbyModuleInits = {}
local GameModuleInits = {
  "Business/Growth/Init",
  "Business/BattleScores/Init",
  "Business/BattleResult/Init",
  "Business/Guide/Init",
  "Business/TacticWheel/Init",
  "Business/BattleData/Init",
  "Business/SelectRole/Init",
  "Business/Tipoff/InGame/Init"
}
function GameFacade:SetupGameProxy()
  GameFacade:RegisterProxy(require("Business/Common/Proxies/GameProxy").new(ProxyNames.GameProxy))
  GameFacade:RegisterCommand(NotificationDefines.ClearAllProxy, require("Business/Common/Commands/ClearAllProxyCmd"))
end
function GameFacade:Setup()
  LogInfo("GameFacade", "GameFacade SetupGlobal...")
  self:SetupModule(GlobalModuleInits)
  LogInfo("GameFacade", "GameFacade SetupLobby...")
  self:SetupModule(LobbyModuleInits)
  LogInfo("GameFacade", "GameFacade Setup End")
end
function GameFacade:Uninstall()
  LogInfo("GameFacade", "GameFacade UninstallGlobal...")
  self:UninstallModule(GlobalModuleInits)
  LogInfo("GameFacade", "GameFacade UninstallLobby...")
  self:UninstallModule(LobbyModuleInits)
  LogInfo("GameFacade", "GameFacade UninstallGame...")
  self:UninstallModule(GameModuleInits)
  LogInfo("GameFacade", "GameFacade Uninstall End")
end
function GameFacade:SetupGame()
  LogInfo("GameFacade", "GameFacade UninstallLobby...")
  self:UninstallModule(LobbyModuleInits)
  LogInfo("GameFacade", "GameFacade SetupGame...")
  self:SetupModule(GameModuleInits)
  LogInfo("GameFacade", "GameFacade SetupGame End")
end
function GameFacade:UninstallGame()
  LogInfo("GameFacade", "GameFacade UninstallGame...")
  self:UninstallModule(GameModuleInits)
  LogInfo("GameFacade", "GameFacade SetupLobby...")
  self:SetupModule(LobbyModuleInits)
  LogInfo("GameFacade", "GameFacade UninstallGame End")
end
function GameFacade:SetupModule(moduleInits)
  local bSuccess, errorMsg, ClassObject
  for k, v in pairs(moduleInits) do
    LogInfo("GameFacade", "GameFacade SetupModule Path = %s", v)
    bSuccess, errorMsg = pcall(require, v)
    if bSuccess then
      ClassObject = require(v)
      ClassObject:Init()
    else
      LogError("GameFacade:SetupModule", [[
File require error !!! 
 Error = %s]], errorMsg)
    end
  end
end
function GameFacade:UninstallModule(moduleInits)
  local bSuccess, errorMsg, ClassObject
  for k, v in pairs(moduleInits) do
    LogInfo("GameFacade", "GameFacade UninstallModule Path = %s", v)
    if pcall(require, v) then
      ClassObject = require(v)
      ClassObject:Clear()
    end
  end
end
LogInfo("GameFacade", "create default game facade with key GameFacade")
return GameFacade
