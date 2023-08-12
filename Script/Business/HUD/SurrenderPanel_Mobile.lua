require("UnLua")
local SurrenderPanel_Mobile = Class()
function SurrenderPanel_Mobile:Construct()
  if self.Button_Agree then
    self.Button_Agree.OnClicked:Add(self, SurrenderPanel_Mobile.OnClkAgree)
  end
  if self.Button_Refuse then
    self.Button_Refuse.OnClicked:Add(self, SurrenderPanel_Mobile.OnClkRefuse)
  end
end
function SurrenderPanel_Mobile:Destruct()
  if self.Button_Agree then
    self.Button_Agree.OnClicked:Remove(self, SurrenderPanel_Mobile.OnClkAgree)
  end
  if self.Button_Refuse then
    self.Button_Refuse.OnClicked:Remove(self, SurrenderPanel_Mobile.OnClkRefuse)
  end
end
function SurrenderPanel_Mobile:OnClkAgree()
  self:AgreeSurrender()
end
function SurrenderPanel_Mobile:OnClkRefuse()
  self:RefuseSurrender()
end
return SurrenderPanel_Mobile
