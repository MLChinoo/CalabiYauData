local ActivityBannerCell = class("ActivityBannerCell", PureMVC.ViewComponentPanel)
function ActivityBannerCell:InitializeLuaEvent()
  self.mouseEnterOrleaveEvent = LuaEvent.new()
  self.activityId = -1
  self.status = GlobalEnumDefine.EActivityStatus.Closed
end
function ActivityBannerCell:Construct()
  ActivityBannerCell.super.Construct(self)
  if self.Btn_Operate then
    self.Btn_Operate.OnClicked:Add(self, ActivityBannerCell.OnClicked)
    self.Btn_Operate.OnHovered:Add(self, ActivityBannerCell.OnHovered)
    self.Btn_Operate.OnUnhovered:Add(self, ActivityBannerCell.OnUnhovered)
  end
end
function ActivityBannerCell:Destruct()
  if self.Btn_Operate then
    self.Btn_Operate.OnClicked:Remove(self, ActivityBannerCell.OnClicked)
    self.Btn_Operate.OnHovered:Remove(self, ActivityBannerCell.OnHovered)
    self.Btn_Operate.OnUnhovered:Remove(self, ActivityBannerCell.OnUnhovered)
  end
  ActivityBannerCell.super.Destruct(self)
end
function ActivityBannerCell:OnClicked()
  if self.status == GlobalEnumDefine.EActivityStatus.Runing then
    local body = {
      activityId = self.activityId,
      pageName = self.pageName
    }
    GameFacade:SendNotification(NotificationDefines.Activities.ActivityOperateCmd, body, NotificationDefines.Activities.ActivityReqType)
  end
end
function ActivityBannerCell:OnHovered()
end
function ActivityBannerCell:OnUnhovered()
end
function ActivityBannerCell:InitInfo(data)
  if data then
    local cfg = data.cfg
    if cfg then
      self.activityId = cfg.id
      self.status = data.status
      self.pageName = cfg.blue_print
      local DownloadProxy = GameFacade:RetrieveProxy(ProxyNames.DownloadProxy)
      local fileDir = UE4.UBlueprintPathsLibrary.ProjectSavedDir() .. "ActivityPicture/"
      local fileName = UE4.UBlueprintPathsLibrary.GetBaseFilename(cfg.icon)
      local filePath = fileDir .. fileName .. ".png"
      if UE4.UBlueprintPathsLibrary.FileExists(filePath) then
        local InTexture = UE4.UKismetRenderingLibrary.ImportFileAsTexture2D(LuaGetWorld(), filePath)
        if self.Image_Icon then
          self.Image_Icon:SetBrushFromTexture(InTexture)
        end
        local NoticeSubSys = UE4.UPMNoticeSubSystem.GetInst(LuaGetWorld())
        if NoticeSubSys:GetFileIsExpired(filePath, 3600) then
          DownloadProxy:downloadUrl(cfg.icon, filePath, function(ret, url, savepath)
            if ret then
              if self.Image_Icon then
                local InTexture = UE4.UKismetRenderingLibrary.ImportFileAsTexture2D(LuaGetWorld(), savepath)
                self.Image_Icon:SetBrushFromTexture(InTexture)
              end
            else
              LogError("ActivityBannerCell", "Load  Picture Fail  url = " .. url)
            end
          end, function(receiveBytes, totalBytes)
          end)
        end
      else
        DownloadProxy:downloadUrl(cfg.icon, filePath, function(ret, url, savepath)
          if ret then
            if self.Image_Icon then
              local InTexture = UE4.UKismetRenderingLibrary.ImportFileAsTexture2D(LuaGetWorld(), savepath)
              self.Image_Icon:SetBrushFromTexture(InTexture)
            end
          else
            LogError("ActivityBannerCell", "Load  Picture Fail  url = " .. url)
          end
        end, function(receiveBytes, totalBytes)
        end)
      end
    end
    local reddot = data.reddot
    local proxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
    if proxy and proxy:GetRedNumByActivityID(self.activityId) ~= nil then
      reddot = proxy:GetRedNumByActivityID(self.activityId)
    end
    self:SetRedDot(reddot)
  end
end
function ActivityBannerCell:SetRedDot(num)
  if self.RedDot then
    self.RedDot:SetVisibility(num > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.CP_Anim then
    self.CP_Anim:SetVisibility(num > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    if num > 0 then
      self:PlayAnimation(self.Anim_Activity, 0, 0)
    else
      self:StopAnimation(self.Anim_Activity)
    end
  end
end
return ActivityBannerCell
