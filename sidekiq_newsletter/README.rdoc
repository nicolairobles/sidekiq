#Use Sidekiq to Send out a Newsletter

##Step 1: Set Up ActionMailer

Set up action mailer by running

```
rails g mailer ExampleMailer
```

For the purposes of our project we set up Action Mailer through Gmail (other options include SendGrid, Mandrill, etc). 

###In Development

As a note when testing make sure to configure to not only in development 
in config/environments/production

```ruby
config.action_mailer.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :user_name            => ENV[‘YOUR API CODE HERE FOR USERNAME],
    :password             => ENV['YOUR API CODE HERE FOR PASSWORD],
    :authentication       => "plain",
    :enable_starttls_auto => true
  } 
```

###Configure Action Mailer in Your Rails App
In Mailer/application make sure to configure the mailer 

```ruby
class ApplicationMailer < ActionMailer::Base
  default from: “THE EMAIL YOU ARE SENDING FROM"
  layout 'mailer'
end
```

and in the mailer you generated with the name you created in that same folder. Ours is called Recipient_Mailer

```ruby
class RecipientMailer < ApplicationMailer
  default from: "example@gmail.com" 

  def newsletter(recipient)
    @recipients = recipient["email"]
    mail(to: @recipients, subject: "testing our emails")
  end
end
```
Recipients in this case correlates to the emails in our database. The code above sets recipients to the emails in our database to send.

###Setup Your API Keys
Set up your API keys in your bash profile.

Then if you go into views/layouts/recipient_mailer/newsletter you can set up what you want the email to say and the format. Then you're set to test your action mailer.

##Step 2: Install Sidekiq
###Install gems and bundle
```ruby
gem 'sidekiq'
gem 'sinatra', '>= 1.3.0', :require => nil
```
You'll need sinatra for the following step where you'll set up the sidekiq dashboard. This is optional but pretty handy.
###Configure your routes to install the sidekiq dashboard for testing. (routes.rb file)
```ruby
require 'sidekiq/web'

Rails.application.routes.draw do
  resources :recipients
   mount Sidekiq::Web => '/sidekiq'
end
```
###Rev up your servers
On three separate tabs in your command line run a server for ```rails s```, another for ```redis-server```, and finally one for ```sidekiq```

Redis is the technology that allows you to instantiate several threads for running background jobs, while sidekiq manages their workflow. Therefore, make sure to run the redis server before the sidekiq server.


##Step 3: Configure Sidekiq
### Sidekiq Delayed Extensions
#### Basic Methods
​
Once Sidekiq is successfully installed (check localhost:3000/sidekiq to confirm), start experimenting with the .delay and .delay_for methods that Sidekiq gives you.
​
This is a create method from a controller from rails scaffold generator:
​
```ruby
  # POST /recipients
  # POST /recipients.json
  def create
    @recipient = Recipient.new(recipient_params)
​
    respond_to do |format|
      if @recipient.save
        RecipientMailer.newsletter(@recipient).deliver_now
        format.html { redirect_to @recipient, notice: 'Recipient was successfully created.' }
        format.json { render :show, status: :created, location: @recipient }
      else
        format.html { render :new }
        format.json { render json: @recipient.errors, status: :unprocessable_entity }
      end
    end
  end
 ```
​
 We will be looking at this line in particular: **RecipientMailer.newsletter(@recipient).deliver_now**
​
 When a new recipient object is submitted to the database, it sends an email via the RecipientMailer mailer class. Simple enough.
​
Sidekiq gives us a bunch of quick and  easy methods to add tasks to its qeue: 
​
+ `.delay` adds a task to Sidekiq's qeue and performs it ASAP as a background process
+ `.delay_for(time parameter)` takes an amount of time to wait before performing task as a parameter. Example: `RecipientMailer.delay_for(5.minutes).newsletter(@recipient)`
+ `.delay_until` delays until a specified time. Example: `RecipientMailer.delay_until(5.days.from_now).newsletter(@recipient)`
​
More info: https://github.com/mperham/sidekiq/wiki/Delayed-extensions

### Creating a Sidekiq worker 
+ Create a new file in app/workers.
+ Insert the basic skeleton of a Sidekiq worker class:
```ruby
class MyWorker
  include Sidekiq::Worker
​
  def perform(args)
    #do yo thang
  end
end
```
+ Say we have this line of code in our controller: `RecipientMailer.newsletter(@recipient).deliver_now` We want to refactor such that a Sidekiq worker does this asynchronously rather than being performed in the normal flow of execution.
+ Open up your Worker class file, and move the line of code in question to the perform method.
```ruby
def perform(recip)
    RecipientMailer.newsletter(recip).deliver_now
end
```
+ Then, change your controller to trigger that action via Sidekiq: ` NewslettersWorker.perform(@recipient)` replaces `RecipientMailer.newsletter(@recipient).deliver_now`
​
+ Wait! This is passing in an entire ActiveRecord model object (@recipient / recip) through Redis, which hs to convert it to and from JSON, which makes our program slower. Let's refactor again:
​
+ In the controller: `NewslettersWorker.perform(@recipient.id)` Instead of passing @recipient, we will just send one unique attribute about it- the ID
​
+ In the worker: 
```ruby
  def perform(recip_id)
    recip = Recipient.find(recip_id)
    RecipientMailer.newsletter(recip).deliver_now
  end
```  
+ One important consideration for the arguments you pass to the worker: They need to be serialized into JSON in order to be stored by Redis. Redis is a  database-like system that Sidekiq uses to manage its qeue. You do not want to make it store an entire model object from your app- that would be inefficient.
​
+ Instead of passing a whole model object to Sidekiq, consider just sending it that object's ID and moving the ActiveRecord call to the actual worker.

##Tips for debugging
###Server interference 
If for some reason you are getting an error make sure to check that you dont have more than one server running by writting
```
rogue
```
in the terminal and killing the other servers if there are any others running and starting everything back up
###Bash Profile Configuration
Remove the quotes from the ENV variables in your bash profile

