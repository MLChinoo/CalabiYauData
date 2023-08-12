local GuideMediaGuideCmd = class("GuideMediaGuideCmd", PureMVC.Command)
function GuideMediaGuideCmd:Execute(notification)
  local world = LuaGetWorld()
  if not world or not ViewMgr then
    return
  end
  local TipsData = notification:GetBody()
  ViewMgr:OpenPage(world, UIPageNameDefine.GuideMediaGuidePage, false, {
    Title = TipsData.Title,
    ContentText = TipsData.ContentText,
    Media = TipsData.Media
  })
end
return GuideMediaGuideCmd
