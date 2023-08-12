local ActivityEntryListPageMediatorMobile = require("Business/ActivityEntryList/Mediators/Mobile/ActivityEntryListPageMediatorMobile")
local ActivityEntryListPageMobile = class("ActivityEntryListPageMobile", PureMVC.ViewComponentPage)
function ActivityEntryListPageMobile:ListNeededMediators()
  return {ActivityEntryListPageMediatorMobile}
end
function ActivityEntryListPageMobile:InitializeLuaEvent()
end
function ActivityEntryListPageMobile:OnOpen(luaOpenData, nativeOpenData)
end
function ActivityEntryListPageMobile:OnClose()
end
return ActivityEntryListPageMobile
