class NewslettersController < ApplicationController

	def index
  end

  def contact
    h = JSON.generate({ 'name' => params[:name],
                        'email' => params[:email]
                        })

    NewsletterWorker.perform_async(h, 5)

    # if instead of sidekiq I was just sending email from rails
    # VisitorMailer.contact_email(@name, @email, @message).deliver

    redirect_to :root
  end
end


class NewsletterWorker < NewslettersController
  include Sidekiq::Worker

  def perform(h, count)
    h = JSON.load(h)
    NewsletterMailer.contact_email(h['name'], h['email']).deliver
  end

  
  
end
