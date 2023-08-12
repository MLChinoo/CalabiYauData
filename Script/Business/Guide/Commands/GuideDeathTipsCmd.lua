local GuideDeathTipsCmd = class("GuideDeathTipsCmd", PureMVC.Command)
local DefaultDeathTipsTag = "Default"
function GuideDeathTipsCmd:Execute(notification)
  local world = LuaGetWorld()
  if not world or not ViewMgr then
    return
  end
  local TipsData = notification:GetBody()
  ViewMgr:OpenPage(world, UIPageNameDefine.GuideDeathTipsPage, false, {
    DeathInfo = TipsData.DeathInfo,
    Tips = TipsData.Tips
  })
end
return GuideDeathTipsCmd
