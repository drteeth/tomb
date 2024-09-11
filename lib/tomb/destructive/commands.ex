defmodule Tomb.Destructive.Commands do
  use TypedStruct

  typedstruct module: ReportDeviceStatus, enforce: true do
    field :device_id, String.t()
    field :batteryMV, non_neg_integer()
  end

  typedstruct module: CloseReportingPeriod, enforce: true do
    field :device_id, String.t()
  end
end
