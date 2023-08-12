local GuideSkipGuidePage = class("GuideSkipGuidePage", PureMVC.ViewComponentPage)
function GuideSkipGuidePage:InitializeLuaEvent()
  GuideSkipGuidePage.super.InitializeLuaEvent(self)
  if self.Button_SkipGuide then
    self.Button_SkipGuide.OnClicked:Add(self, self.OnClickSkipGuide)
  end
end
function GuideSkipGuidePage:OnClickSkipGuide()
  local pageData = {}
  pageData.contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Context_BackToLobby")
  pageData.confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Confirm_BackToLobby")
  pageData.returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Cancel_BackToLobby")
  function pageData.cb(bConfirm)
    if bConfirm then
      self:SureSkipGuide()
    end
  end
  ViewMgr:OpenPage(self, UIPageNameDefine.MsgDialogPage, false, pageData)
end
function GuideSkipGuidePage:SureSkipGuide()
  local PlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0)
  if PlayerController and PlayerController.SkipGuide then
    PlayerController:SkipGuide()
  end
end
return GuideSkipGuidePage
