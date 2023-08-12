require("UnLua")
local BigSceneMap2D_Mobile = Class()
function BigSceneMap2D_Mobile:Construct()
  if self.Button_Close then
    self.Button_Close.OnClicked:Add(self, BigSceneMap2D_Mobile.OnCloseBigMap)
  end
end
function BigSceneMap2D_Mobile:Destruct()
  if self.Button_Close then
    self.Button_Close.OnClicked:Remove(self, BigSceneMap2D_Mobile.OnCloseBigMap)
  end
end
function BigSceneMap2D_Mobile:OnCloseBigMap()
  ViewMgr:ClosePage(self, UIPageNameDefine.BigMap)
end
return BigSceneMap2D_Mobile
