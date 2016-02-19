class NewsletterMailer < ApplicationMailer
  default from: "sidekiq.test.ga@gmail.com"

  def newsletter(recipient)
    @recipients = recipient["email"]
    mail(to: @recipients_email, subject: "testing our emails")
  end

end
