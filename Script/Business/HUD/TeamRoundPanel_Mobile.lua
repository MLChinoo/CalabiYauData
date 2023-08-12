require("UnLua")
local TeamRoundPanel_Mobile = Class()
function TeamRoundPanel_Mobile:Construct()
  if self.Button_Tab then
    self.Button_Tab.OnClicked:Add(self, TeamRoundPanel_Mobile.OnClkTab)
  end
end
function TeamRoundPanel_Mobile:Destruct()
  if self.Button_Tab then
    self.Button_Tab.OnClicked:Remove(self, TeamRoundPanel_Mobile.OnClkTab)
  end
end
function TeamRoundPanel_Mobile:OnClkTab()
  ViewMgr:OpenPage(self, UIPageNameDefine.ScorePage)
end
return TeamRoundPanel_Mobile
