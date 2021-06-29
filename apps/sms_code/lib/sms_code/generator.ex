defmodule SmsCode.Generator do
  require Logger
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, []}
  end

  def send_new_code(id, mobile_number) do
    GenServer.call(__MODULE__, {:send_new_code, id, mobile_number})
  end

  def validate_code(id, code) do
    code == ConCache.get(:sms_code, id)
  end

  def handle_call({:send_new_code, id, mobile}, _from, state) do
    new_code = generate_code()
    {:ok, message} = send_reset(new_code, mobile)
    Logger.debug("We got this from Twilio: #{inspect(message)}")
    ConCache.put(:sms_code, id, new_code)

    {:reply, :ok, state}
  end

  def twilio_api do
    Application.get_env(:sms_code, :twilio_api)
  end

  def generate_code do
    :crypto.strong_rand_bytes(3)
    |> Base.encode16()
  end

  def send_reset(code, mobile) do
    payload = [to: mobile, from: "+15558675309", body: "Your password reset code is #{code}"]
    Module.concat(twilio_api(), Message).create(payload)
  end
end
