defmodule SmsCodeTest do
  use ExUnit.Case
  doctest SmsCode

  test "send_reset packages a payload for Twilio" do
    SmsCode.Generator.send_reset("ABC123", "555-555-1212")
    assert_received {:create, [to: "555-555-1212", from: "+5035551234", body: "Your password reset code is ABC123"]}
  end

  test "the reset code gets put into cache" do
    SmsCode.Generator.send_new_code("a.random.user.id", "555-555-1234")
    assert ConCache.get(:sms_code, "a.random.user.id")
  end

  test "validate_code looks for the code in the cache" do
    ConCache.put(:sms_code, "some.random.user.id", "DEF456")
    assert SmsCode.Generator.validate_code("some.random.user.id", "DEF456")
  end

  test "generate_code creates 6 random hex digits" do
    assert Regex.match?(~r/\A[0-9A-F]{6}\Z/, SmsCode.Generator.generate_code)
  end
end
