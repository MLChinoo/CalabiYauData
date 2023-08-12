local allProtoFiles = {
  "activity_cfg.proto",
  "common.proto",
  "dir_svr_cs.proto",
  "errcode_cs.proto",
  "ncmd_cs.proto",
  "ncmd_ds.proto",
  "s_dsa.proto",
  "public.proto"
}
local ProtobufMgr = {}
function ProtobufMgr:LoadPb(pbName)
  LogDebug("[LuaProto]", "begin load %s", pbName)
  local load_path = string.format("LuaProto/%s", pbName)
  local data = UE4.LuaBridge.LoadPbFile(load_path)
  local b, i = pb.load(data)
  LogDebug("[LuaProto]", "bool, int = %s %s", tostring(b), tostring(i))
end
function ProtobufMgr:LoadAllPb()
  LogDebug("[LuaProto]", "begin load lua proto")
  for _, v in ipairs(allProtoFiles) do
    self:LoadPb(v)
  end
  LogDebug("[LuaProto]", "finish load lua proto")
end
return ProtobufMgr
