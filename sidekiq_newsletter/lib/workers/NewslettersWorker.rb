class NewslettersWorker < RecipientsController
  include Sidekiq::Worker

  def perform(recip)
    RecipientMailer.newsletter(recip).deliver_now
  end
  
end