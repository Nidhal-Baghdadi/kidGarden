class ApplicationMailer < ActionMailer::Base
  default from: Rails.env.production? ? "noreply@kidgarden.com" : "noreply@localhost"
  layout "mailer"
end
