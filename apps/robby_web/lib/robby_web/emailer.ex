defmodule RobbyWeb.Emailer do
  def config do
    env = Application.get_env(:robby_web, RobbyWeb.Emailer)
    %Mailman.Context{
      config: %Mailman.SmtpConfig{
        relay: env[:server],
        port: env[:port],
        username: env[:username],
        password: env[:password],
        ssl: env[:ssl],
        tls: env[:tls],
        auth: env[:auth]
      },
     # composer: %Mailman.EexComposeConfig{}
    }
  end

  def send_reset_link(email, link) do
    %Mailman.Email{
      subject: "Robby Password Reset Link",
      from: "password-reset@example.com",
      to: [email],
      text: "Your password reset link: #{link}\n",
      html:
      """
      <html><body><b>Your password <a href="#{link}">reset link.</a></b></body></html>
      """
    }
    |> Mailman.deliver(config())
  end

  def send_profile_picture_complaint(recipient_email) do
    %Mailman.Email{
      subject: "Your Robby Profile Picture Requires Attention",
      from: "robby-photo@example.com",
      to: [recipient_email],
      text:
      """
      Your profile picture could use a refresh.  Please follow this link to upload a new photo: #{RobbyWeb.Router.Helpers.settings_profile_url(RobbyWeb.Endpoint, :edit)}\n
      \n
      Thank You!\n
      \n
      ::Robby::
      """,
      html:
      """
      <html>
      <body>
      <p>Your profile picture could use a refresh.  Please visit <a href="#{RobbyWeb.Router.Helpers.settings_profile_url(RobbyWeb.Endpoint, :edit)}">your profile in Robby</a> to upload a better picture.</p>
      <p>Thank You!</p>
      ::Robby::
      </body>
      </html>
      """
    }
    |> Mailman.deliver(config())
  end
end
