class ApplicationMailer < ActionMailer::Base
  #下どこからメールが送られてきたのか？
  default from: 'noreply@example.com'
  #デフォルトで作られたものを使う。
  layout 'mailer'
end
