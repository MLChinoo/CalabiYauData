local RankStarTrack = class("RankStarTrack", PureMVC.ViewComponentPanel)
local posChangeMinTime = 2
function RankStarTrack:ListNeededMediators()
  return {}
end
function RankStarTrack:InitializeLuaEvent()
  self.changeZOrder = LuaEvent.new(target, isFront)
  self.onStarDisappearAnimFinished = LuaEvent.new(starIndex)
end
function RankStarTrack:Construct()
  RankStarTrack.super.Construct(self)
  self.tickDeltaTime = 0.05
  self.timeLeft = 0
  self.playSpeed = 1
end
function RankStarTrack:Destruct()
  if self.tickHandle then
    self.tickHandle:EndTask()
  end
  RankStarTrack.super.Destruct(self)
end
function RankStarTrack:SetStarLevel(rankDivision)
  if self.RankBadgeStar then
    self.RankBadgeStar:SetStarLevel(rankDivision)
  end
end
function RankStarTrack:PlayAnimBasedOnIndex(index, total)
  self.starIndex = index
  if self.orbi then
    local endTime = self.orbi:GetEndTime()
    local timeInterval = 1 / total
    local startAtTime = 0.24 - (total - index) * timeInterval
    if startAtTime < 0 then
      startAtTime = startAtTime + 1
    end
    if startAtTime >= 0.25 and startAtTime <= 0.75 then
      self.changeZOrder(self, true)
    else
      self.changeZOrder(self, false)
    end
    self:PlayAnimation(self.orbi, startAtTime * endTime, 0)
  end
end
function RankStarTrack:StarIsBack()
  self.changeZOrder(self, false)
end
function RankStarTrack:StarIsFront()
  self.changeZOrder(self, true)
  if self.shouldAddStar == true and self.RankBadgeStar then
    self:SetRenderOpacity(1)
    self.RankBadgeStar:PlayAnimation(self.RankBadgeStar.AddStar)
    self.shouldAddStar = false
  end
end
function RankStarTrack:PlayStarAddAnim()
  self.shouldAddStar = true
  self:SetRenderOpacity(0)
end
function RankStarTrack:PlayStarDecreaseAnim()
  if self.RankBadgeStar then
    self.RankBadgeStar:BindToAnimationFinished(self.RankBadgeStar.DecreaseStar, {
      self,
      function()
        self.onStarDisappearAnimFinished(self.starIndex)
      end
    })
    self.RankBadgeStar:PlayAnimation(self.RankBadgeStar.DecreaseStar)
  end
end
function RankStarTrack:UpdatePosition(totalStar)
  if self.orbi and self.starIndex then
    local animDuration = self.orbi:GetEndTime()
    local currentPos = self:GetAnimationCurrentTime(self.orbi) / animDuration
    local firstStarPos = currentPos - (self.starIndex - 1) / (totalStar + 1)
    if firstStarPos < 0 then
      firstStarPos = firstStarPos + 1
    end
    local firstStarTargetPos = firstStarPos
    for index = 1, totalStar * 2 do
      if index / totalStar - firstStarPos > posChangeMinTime / animDuration then
        firstStarTargetPos = index / totalStar
        break
      end
    end
    local targetPos = firstStarTargetPos + (self.starIndex - 1) / totalStar
    self.targetAnimTime = (targetPos >= 1 and targetPos - 1 or targetPos) * animDuration
    self.timeLeft = (firstStarTargetPos - firstStarPos) * animDuration
    self.playSpeed = 1
    self:TickPositionSpeed()
  end
end
function RankStarTrack:TickPositionSpeed()
  if self.targetAnimTime and self.timeLeft > 0 then
    local currentAnimTime = self:GetAnimationCurrentTime(self.orbi)
    if math.abs(currentAnimTime - self.targetAnimTime) < 0.001 then
      self.playSpeed = 1
      self:SetPlaybackSpeed(self.orbi, self.playSpeed)
      self.targetAnimTime = nil
      self.timeLeft = 0
      return
    end
    local animDuration = self.orbi:GetEndTime()
    local animTimeNeed = self.targetAnimTime - currentAnimTime
    animTimeNeed = animTimeNeed > 0 and animTimeNeed or animTimeNeed + animDuration
    local interpTar = animTimeNeed / self.timeLeft * (animTimeNeed / self.timeLeft)
    self.playSpeed = UE4.UKismetMathLibrary.FInterpTo(self.playSpeed, interpTar, self.timeLeft, 1)
    self:SetPlaybackSpeed(self.orbi, self.playSpeed)
    self.timeLeft = self.timeLeft - self.tickDeltaTime
    self.tickHandle = TimerMgr:AddTimeTask(self.tickDeltaTime, 0, 1, function()
      self:TickPositionSpeed()
    end)
  end
end
return RankStarTrack
