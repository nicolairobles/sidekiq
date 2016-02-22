class RecipientMailer < ApplicationMailer
  default from: "sidekiq.test.ga@gmail.com"
 
  def newsletter(recipient)
    @recipients = recipient["email"]
    mail(to: @recipients, subject: "
AMERICAN FREEDOM NEWS UPDATE")
  end
end
