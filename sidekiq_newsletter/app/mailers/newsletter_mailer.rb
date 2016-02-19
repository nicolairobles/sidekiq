class NewsletterMailer < ApplicationMailer
  default from: "sidekiq.test.ga@gmail.com"

  def contact_email(name, email)
    @name = name
    @email = email
  end


# Below is the email they recieve when they get an email from a friend
# with the midpoint location (resturant/bar) they are meeting

  def newsletter(recipient)
  	@recipient = recipient
    @recipients_email = sidekiq_newsletter@mailinator.com
    mail(:to => @recipients_email, subject: "testing our emails")
  end

end
