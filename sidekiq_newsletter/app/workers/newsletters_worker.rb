class NewsletterWorker < NewslettersController
  include Sidekiq::Worker

  def perform(h, count)
    h = JSON.load(h)
    NewsletterMailer.contact_email(h['name'], h['email']).deliver
  end
end