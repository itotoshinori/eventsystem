class MailsysMailer < ApplicationMailer
  default from: 'no-replay@eventmail.com'

  def sendmail(str,link,mailad)
    @str = str
    @link=link
    @mailad=mailad
    mail(to: mailad, subject: "イベント管理システムからのメールです")
  end
end
