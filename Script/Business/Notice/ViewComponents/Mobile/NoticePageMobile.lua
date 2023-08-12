local NoticePageMediatorMobile = require("Business/Notice/Mediators/Mobile/NoticePageMediatorMobile")
local NoticePageMobile = class("NoticePageMobile", PureMVC.ViewComponentPage)
function NoticePageMobile:ListNeededMediators()
  return {NoticePageMediatorMobile}
end
function NoticePageMobile:InitializeLuaEvent()
end
function NoticePageMobile:OnOpen(luaOpenData, nativeOpenData)
end
function NoticePageMobile:OnClose()
end
return NoticePageMobile
