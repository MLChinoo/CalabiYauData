local DevisionCompetitionDownPage = class("DevisionCompetitionDownPage", PureMVC.ViewComponentPage)
function DevisionCompetitionDownPage:InitializeLuaEvent()
  self.initViewEvent = LuaEvent.new()
end
function DevisionCompetitionDownPage:OnOpen(luaOpenData, nativeOpenData)
  UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, true)
  self:PlayWidgetAnimationWithCallBack("Anim_Divition", {
    self,
    function()
      if self.Img_Click then
        self.Img_Click.OnMouseButtonDownEvent:Bind(self, self.OnBtClose)
      end
    end
  })
  self:UpdateView(luaOpenData)
end
function DevisionCompetitionDownPage:OnBtClose()
  ViewMgr:ClosePage(self)
end
function DevisionCompetitionDownPage:OnClose()
  if self.Img_Click then
    self.Img_Click.OnMouseButtonDownEvent:Unbind()
  end
  UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, false)
  if self.LoadingTask then
    self.LoadingTask:EndTask()
    self.LoadingTask = nil
  end
end
function DevisionCompetitionDownPage:UpdateView(datas)
  local rList = datas[1]
  if self.CP_Parent and rList then
    for index = 1, self.CP_Parent:GetChildrenCount() do
      local img = self.CP_Parent:GetChildAt(index - 1)
      if img then
        local result = rList[index]
        if result then
          img:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          img:SetColorAndOpacity(self.ImageColorArray:Get(result + 1))
        else
          img:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
      end
    end
    if self.RankBadge then
      self.RankBadge:ShowRankDivision(datas[2])
    end
  end
end
return DevisionCompetitionDownPage
