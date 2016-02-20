class NewslettersWorker < RecipientsController
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(recipient_id)
  	recipient = Recipient.find(recipient_id)
    RecipientMailer.newsletter(recipient)
  end

end