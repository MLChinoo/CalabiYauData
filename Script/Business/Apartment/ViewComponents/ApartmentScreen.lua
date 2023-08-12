local ApartmentScreen = class("ApartmentScreen", PureMVC.ViewComponentPanel)
function ApartmentScreen:InitializeLuaEvent()
  self:BeginUpdateTimer()
end
function ApartmentScreen:BeginUpdateTimer()
  self:StopUpdateTimer()
  self.updateTimer = TimerMgr:AddTimeTask(0, 1, 0, function()
    local servertime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
    local serverTimeTxt = os.date("%H:%M", servertime)
    self.Tex_time_Hour1:SetText(string.sub(serverTimeTxt, 1, 1))
    self.Tex_time_Hour2:SetText(string.sub(serverTimeTxt, 2, 2))
    self.Tex_time_Minute1:SetText(string.sub(serverTimeTxt, 4, 4))
    self.Tex_time_Minute2:SetText(string.sub(serverTimeTxt, 5, 5))
  end)
end
function ApartmentScreen:StopUpdateTimer()
  if self.updateTimer then
    self.updateTimer:EndTask()
    self.updateTimer = nil
  end
end
function ApartmentScreen:Destruct()
  self:StopUpdateTimer()
  ApartmentScreen.super.Destruct(self)
end
return ApartmentScreen
