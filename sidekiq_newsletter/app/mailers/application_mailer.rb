class ApplicationMailer < ActionMailer::Base
  default from: "sidekiq.test.ga@gmail.com"
  layout 'mailer'
end
