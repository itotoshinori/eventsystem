class MailsysMailer < ApplicationMailer
  default from: 'xgppm340@ybb.ne.jp'

  def sendmail(str,link,mailad)
    @str = str
    @link=link
    @mailad=mailad
    mail(to: mailad, subject:"#{@str}　開催のお知らせ")
  end
end
