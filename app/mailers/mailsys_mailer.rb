class MailsysMailer < ApplicationMailer
  default from: 'tito40358@gmail.com'

  def sendmail(str,link,mailad)
    @str = str
    @link=link
    @mailad=mailad
    mail(to: mailad, subject: "イベント管理システムからのメールです")
  end
end
