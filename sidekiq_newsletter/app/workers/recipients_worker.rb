class RecipientsWorker < RecipientsController
  include Sidekiq::Worker

  def perform(h, count)
    h = JSON.load(h)
    Mailer.contact_email(h['name'], h['email']).deliver
    @recipients = recipient["email"]
    RecipientMailer.newsletter(@recipients).deliver_now
  end
end
# bundle exec sidekiq -q mailer