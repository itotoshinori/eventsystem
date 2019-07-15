class MailsysMailer < ApplicationMailer
  default from: 'no-replay@eventmail.com'

  def sendmail(str,link)
    @str = str
    @link=link
    mail(to: "tito40358@gmail.com", subject: "イベント管理システムからのメールです")
  end
end
