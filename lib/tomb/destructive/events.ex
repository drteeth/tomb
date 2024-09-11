defmodule Tomb.Destructive.Events do
  use TypedStruct

  typedstruct module: DeviceBatteryLevelChanged, enforce: true do
    @derive Jason.Encoder
    field :device_id, String.t()
    field :from, non_neg_integer()
    field :to, non_neg_integer()
    field :version, pos_integer(), default: 1
  end

  typedstruct module: ReportingPeriodClosed, enforce: true do
    @derive Jason.Encoder
    field :device_id, String.t()
    field :batteryMV, non_neg_integer()
    field :version, pos_integer(), default: 1
  end
end
