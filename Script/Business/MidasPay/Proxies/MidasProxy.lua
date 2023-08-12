local MidasProxy = class("MidasProxy", PureMVC.Proxy)
function MidasProxy:OnRegister()
  self.super.OnRegister(self)
  LogDebug("MidasProxy", "OnRegister")
  local midasSys = UE4.UPMMidasSdkSubSystem.GetInst(LuaGetWorld())
  self.OnMidasCreateOrderFinishedHandler = DelegateMgr:AddDelegate(midasSys.OnMidasCreateOrderFinished, self, "OnMidasCreateOrderFinished")
  self.IsByBrowse = false
end
function MidasProxy:OnRemove()
  self.super.OnRemove(self)
  LogDebug("MidasProxy", "OnRegister")
  if self.OnMidasCreateOrderFinishedHandler then
    local midasSys = UE4.UPMMidasSdkSubSystem.GetInst(LuaGetWorld())
    DelegateMgr:RemoveDelegate(midasSys.OnMidasCreateOrderFinished, self.OnMidasCreateOrderFinishedHandler)
    self.OnMidasCreateOrderFinishedHandler = nil
  end
end
function MidasProxy:WebViewCloseCb()
  LogDebug("MidasProxy:WebViewCloseCb:")
end
function MidasProxy:OnMidasCreateOrderFinished(url)
  LogDebug("OnMidasCreateOrderFinished", "goodsTokenUrl = " .. url)
  local url = "https://kq.calatopia.com/MidasPay.html"
  local midasSys = UE4.UPMMidasSdkSubSystem.GetInst(LuaGetWorld())
  url = url .. "?title=" .. midasSys:get_midas_data("title")
  url = url .. "&goodstokenurl=" .. FunctionUtil:urlEncode(midasSys:get_midas_data("goodstokenurl"))
  url = url .. "&pf=" .. midasSys:get_midas_data("pf")
  url = url .. "&openid=" .. midasSys:get_midas_data("openid")
  url = url .. "&openkey=" .. midasSys:get_midas_data("openkey")
  url = url .. "&sandbox=" .. midasSys:get_midas_data("sandbox")
  url = url .. "&wxappid=" .. midasSys:get_midas_data("wxappid")
  url = url .. "&qqAppid=" .. midasSys:get_midas_data("qqAppid")
  url = url .. "&appid=" .. midasSys:get_midas_data("appid")
  url = url .. "&pfKey=" .. midasSys:get_midas_data("pfKey")
  url = url .. "&aid=" .. midasSys:get_midas_data("aid")
  if self.IsByBrowse == true then
    url = url .. "&isByBrowser=1"
  end
  local GCloudSdk = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  LogDebug("OnMidasCreateOrderFinished", "sandbox = " .. midasSys:get_midas_data("sandbox"))
  if self.IsByBrowse == true then
    UE.UKismetSystemLibrary.LaunchURL(url)
  else
    GCloudSdk:OpenWebView(url, 1, 1)
  end
end
function MidasProxy:BuyGoodsByID(GoodsID, isByBrowse)
  self.IsByBrowse = isByBrowse
  if nil == GoodsID then
    LogError("MidasProxy", "GoodsID == nil")
  end
  local PayDirectlyTableCfg = self:GetPayDirectlyTableCfg(GoodsID)
  self:BuyGoods(PayDirectlyTableCfg.ProductIds, PayDirectlyTableCfg.Quantittys)
end
function MidasProxy:GetPayDirectlyTableCfg(_PayDirectlyId)
  local arrRows = ConfigMgr:GetPayDirectlyTableRow()
  if arrRows then
    return arrRows:ToLuaTable()[tostring(_PayDirectlyId)]
  end
end
function MidasProxy:BuyGoods(ProductIds, Quantittys)
  local midasSys = UE4.UPMMidasSdkSubSystem.GetInst(LuaGetWorld())
  if ProductIds and Quantittys then
    local ProductIdTB = load("return " .. ProductIds)()
    local product_list = UE4.TArray(UE4.FString)
    for key, value in pairs(ProductIdTB) do
      product_list:Add(value)
    end
    local quantityList = UE4.TArray(UE4.uint32)
    local QuantittyTB = load("return " .. Quantittys)()
    for key, value in pairs(QuantittyTB) do
      quantityList:Add(value)
    end
    midasSys:BuyGoods(product_list, quantityList)
  end
end
return MidasProxy
