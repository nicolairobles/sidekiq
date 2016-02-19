class NewsletterMailer < ApplicationMailer

  def contact_email(name, email, message)
    @name = name
    @email = email
    @message = message
  end

  default from: "midways.midpointApp@gmail.com"

# Below is the email they recieve when they get an email from a friend
# with the midpoint location (resturant/bar) they are meeting

  def newsletter(info)
    @recipients_email = sidekiq_newsletter@mailinator.com
    mail(:to => @recipients_email, subject: "testing our emails")
  end

end
