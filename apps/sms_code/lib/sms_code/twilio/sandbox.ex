defmodule SmsCode.Twilio.Sandbox.Message do
  def create(payload) do
    send self(), {:create, payload}
    {:ok, payload}
  end
end
