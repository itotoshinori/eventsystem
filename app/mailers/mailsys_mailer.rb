class MailsysMailer < ApplicationMailer
  default from: 'no-replay@eventmail.com'

  def sendmail(str)
    @str = str
    mail(to: "tito40358@gmail.com", subject: "メールの件名")
  end
end
