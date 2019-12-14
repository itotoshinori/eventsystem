class MailsysMailer < ApplicationMailer
  default from: 'xgppm340@ybb.ne.jp'

  def sendmail(evnetname,str,link,mailad)
    @eventname=evnetname
    @str = str
    @link=link
    @mailad=mailad
    mail(to: mailad, subject:"#{@eventname}　のお知らせ")
  end
end
