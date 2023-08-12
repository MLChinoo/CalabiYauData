local QuestionnaireProxy = class("QuestionnaireProxy", PureMVC.Proxy)
function QuestionnaireProxy:OnRegister()
  self.super.OnRegister(self)
  self.questionIsOpen = false
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_QUESTIONNAIRE_RES, FuncSlot(self.OnResQuestionnaire, self))
end
function QuestionnaireProxy:OnRemove()
  self.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_QUESTIONNAIRE_RES, FuncSlot(self.OnResQuestionnaire, self))
end
function QuestionnaireProxy:ReqQuestionnaire()
  local questionnaireReq = {}
  local req = pb.encode(Pb_ncmd_cs_lobby.questionnaire_req, questionnaireReq)
  local lobbyService = GetLobbyServiceHandle()
  if not lobbyService then
    return
  end
  lobbyService:SendRequest(Pb_ncmd_cs.NCmdId.NID_QUESTIONNAIRE_REQ, req)
end
function QuestionnaireProxy:OnResQuestionnaire(data)
  local questionnaireRes = pb.decode(Pb_ncmd_cs_lobby.questionnaire_res, data)
  self.questionIsOpen = 1 == questionnaireRes.open
  GameFacade:SendNotification(NotificationDefines.OnResQuestionnaire)
end
function QuestionnaireProxy:GetQuestionIsOpen()
  LogDebug("QuestionnaireProxy", "questionIsOpen = " .. tostring(self.questionIsOpen))
  return self.questionIsOpen
end
return QuestionnaireProxy
