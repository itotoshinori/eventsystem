class MailsysMailer < ApplicationMailer
  default from: 'xgppm340@ybb.ne.jp'

  def sendmail(str,link,mailad)
    @str = str
    @link=link
    @mailad=mailad
    mail(to: mailad, subject: "イベント管理システムからのメールです")
  end
end
