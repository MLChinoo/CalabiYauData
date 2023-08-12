local SettingCustomLayoutMap = {}
local keyList = {
  Graffiti = {
    "GraffitiDragItem",
    "Graffiti",
    1
  },
  MiniMap = {
    "MiniMapDragItem",
    "MiniMap",
    2
  },
  KillMessage = {
    "KillMessageDragItem",
    "KillMessage",
    3
  },
  SummonHealth = {
    "SummonHealthDragItem",
    "SummonHealth",
    4
  },
  Character = {
    "CharacterDragItem",
    "Character",
    5
  },
  Grenade = {
    "GrenadeDragItem",
    "Grenade",
    6
  },
  CharHealth = {
    "CharHealthDragItem",
    "CharHealth",
    7
  },
  MainWeapon = {
    "MainWeaponDragItem",
    "MainWeapon",
    8
  },
  Skill1 = {
    "SkillQDragItem",
    "SkillQ",
    9
  },
  Skill2 = {
    "SkillXDragItem",
    "SkillX",
    10
  },
  Bomb = {
    "InventoryBombDragItem",
    "InventoryBomb",
    11
  },
  Move = {
    "MoveDragItem",
    "Move",
    12
  },
  Reload = {
    "ReloadDragItem",
    "Reload",
    13
  },
  Buff = {
    "BuffDragItem",
    "Buff",
    14
  },
  Grow = {
    "GrowthDragItem",
    "Growth",
    15
  },
  Setting = {
    "SettingDragItem",
    "Setting",
    16
  },
  Chat = {
    "ChatDragItem",
    "Chat",
    17
  },
  StickToWall = {
    "Wall2DDragItem",
    "Wall2D",
    18
  },
  Aim = {
    "ADSDragItem",
    "ADS",
    19
  },
  Jump = {
    "JumpDragItem",
    "Jump",
    20
  },
  Shoulder = {
    "AimingDragItem",
    "Aiming",
    21
  },
  RightFire = {
    "RightFireDragItem",
    "RightFire",
    22
  },
  LeftFire = {
    "LeftFireDragItem",
    "LeftFire",
    23
  },
  RightMarkPoint = {
    "RightMarkPointDragItem",
    "RightMarkPoint",
    24
  },
  LeftMarkPoint = {
    "LeftMarkPointDragItem",
    "LeftMarkPoint",
    25
  },
  Interact = {
    "InteractDragItem",
    "Interact",
    26
  },
  Signal = {
    "SignalDragItem",
    "Signal",
    27
  },
  MoveLine = {
    "SprintDragItem",
    "Sprint",
    28
  },
  ChatMsgArea = {
    "ChatMsgAreaDragItem",
    "ChatMsgArea",
    29
  },
  StandaloneWall2D = {
    "StandaloneWall2DDragItem",
    "StandaloneWall2D",
    30
  },
  Cancel = {
    "CancelDragItem",
    "Cancel",
    31
  },
  Channel = {
    "ChannelDragItem",
    "Channel",
    32
  },
  Voice = {
    "VoiceDragItem",
    "Voice",
    33
  },
  SwitchExpectedWeapon = {
    "SwitchExpectedWeaponDragItem",
    "SwitchExpectedWeapon",
    34
  }
}
local repeatTbl = {}
for k, v in ipairs(keyList) do
  repeatTbl[v[3]] = repeatTbl[v[3]] or 0
  repeatTbl[v[3]] = repeatTbl[v[3]] + 1
  if repeatTbl[v[3]] > 1 then
    LogError("SettingCustomLayoutMap", "index is repeat, please check!")
    break
  end
end
SettingCustomLayoutMap.KeyList = keyList
return SettingCustomLayoutMap
