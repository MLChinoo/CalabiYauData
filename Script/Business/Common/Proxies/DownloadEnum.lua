local DownRetEnum = {
  Success = 0,
  NotDownCb = 1,
  UrlInvalid = 2,
  PathInvalid = 3,
  OpenWriteErr = 4,
  WriteDataErr = 5,
  RespStatusErr = 6,
  RespUnknownErr = 7,
  ProcessRequestFail = 8,
  TimeOut = 9
}
return DownRetEnum
