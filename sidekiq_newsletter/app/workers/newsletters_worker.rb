class NewslettersWorker < RecipientsController
  include Sidekiq::Worker

  def perform(recipient_id)
    RecipientMailer.newsletter(Recipient.find(recipient_id))
  end

end