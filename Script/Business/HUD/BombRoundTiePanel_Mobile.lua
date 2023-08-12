require("UnLua")
local BombRoundTiePanel_Mobile = Class()
function BombRoundTiePanel_Mobile:Construct()
  if self.Button_Agree then
    self.Button_Agree.OnClicked:Add(self, BombRoundTiePanel_Mobile.OnClkAgree)
  end
  if self.Button_Refuse then
    self.Button_Refuse.OnClicked:Add(self, BombRoundTiePanel_Mobile.OnClkRefuse)
  end
end
function BombRoundTiePanel_Mobile:Destruct()
  if self.Button_Agree then
    self.Button_Agree.OnClicked:Remove(self, BombRoundTiePanel_Mobile.OnClkAgree)
  end
  if self.Button_Refuse then
    self.Button_Refuse.OnClicked:Remove(self, BombRoundTiePanel_Mobile.OnClkRefuse)
  end
end
function BombRoundTiePanel_Mobile:OnClkAgree()
  self:AgreeTie()
end
function BombRoundTiePanel_Mobile:OnClkRefuse()
  self:RefuseTie()
end
return BombRoundTiePanel_Mobile
