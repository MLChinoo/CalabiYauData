require("UnLua")
local BombRoundPanel_Mobile = Class()
function BombRoundPanel_Mobile:Construct()
  if self.Button_Tab then
    self.Button_Tab.OnClicked:Add(self, BombRoundPanel_Mobile.OnClkTab)
  end
end
function BombRoundPanel_Mobile:Destruct()
  if self.Button_Tab then
    self.Button_Tab.OnClicked:Remove(self, BombRoundPanel_Mobile.OnClkTab)
  end
end
function BombRoundPanel_Mobile:OnClkTab()
  ViewMgr:OpenPage(self, UIPageNameDefine.ScorePage)
end
return BombRoundPanel_Mobile
