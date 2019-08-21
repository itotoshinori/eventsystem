class PasswordresetController < ApplicationController
  require 'securerandom'
  def reset
    email=params[:email]
    @user=User.find_by(email:email,provider:nil)
    if email.blank?
      flash[:notice]="メールアドレスを入力して送信して下さい"
    elsif @user.present?
      user_id=@user.id
      passnum=SecureRandom.hex(8)
      passwordreset=Passwordreset.new(passnum:passnum,user_id:user_id,email:email)
      passwordreset.save
      @content="下記アドレスをクリックしてパスワードをリセットして下さい"
      @link="https://enigmatic-lowlands-69028.herokuapp.com/passworrest/#{passnum}/#{passwordreset.id}"
      MailsysMailer.sendmail(@content,@link,email).deliver_later
      flash[:success]="パスワードのリセットのためのメールを送りました"
    else
      flash[:notice]="登録のアドレスではありません。処理を中止しました。"
    end
    redirect_to '/'
  end
end
