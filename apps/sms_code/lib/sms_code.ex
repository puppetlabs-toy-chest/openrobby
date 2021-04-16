defmodule SmsCode do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(SmsCode.Worker, [arg1, arg2, arg3]),
      worker(SmsCode.Generator, []),
      worker(ConCache, [
        [
          ttl_check: :timer.minutes(1),
          ttl: :timer.minutes(15)
        ],
        [name: :sms_code]
      ])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SmsCode.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
