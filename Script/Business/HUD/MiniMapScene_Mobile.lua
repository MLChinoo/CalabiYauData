require("UnLua")
local MiniMapScene_Mobile = Class()
function MiniMapScene_Mobile:Construct()
  if self.Button_OpenBigMap then
    self.Button_OpenBigMap.OnClicked:Add(self, MiniMapScene_Mobile.OnOpenBigMap)
  end
end
function MiniMapScene_Mobile:Destruct()
  if self.Button_OpenBigMap then
    self.Button_OpenBigMap.OnClicked:Remove(self, MiniMapScene_Mobile.OnOpenBigMap)
  end
end
function MiniMapScene_Mobile:OnOpenBigMap()
  ViewMgr:OpenPage(self, UIPageNameDefine.BigMap)
end
return MiniMapScene_Mobile
