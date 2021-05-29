defmodule MyTsgGlobal.EctoEnums do
  import EctoEnum

  defenum(DirectionEnum, :direction, [:inbound, :outbound])
  defenum(ServiceTypeEnum, :service_type, [:sms, :mms, :voice])
end
