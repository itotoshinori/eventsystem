class PasswordresetController < ApplicationController
  require 'securerandom'
  def reset
    email=params[:email]
    @user=User.find_by(email:email,provider:nil)
    if email.blank?
      flash[:notice]="メールアドレスを入力して送信して下さい"
    elsif @user.present?
      user_id=@user.id
      passkey=SecureRandom.hex(8)+user_id.to_s
      passwordreset=Passwordreset.new(passnum:passkey,user_id:user_id,email:email)
      passwordreset.save
      @content="下記アドレスをクリックしてパスワードをリセットして下さい"
      @link="https://enigmatic-lowlands-69028.herokuapp.com/passwordrest/#{passkey}"
      MailsysMailer.sendmail(@content,@link,email).deliver_later
      flash[:success]="パスワードのリセットのためのメールを送りました"
    else
      flash[:notice]="登録のアドレスではありません。処理を中止しました。"
    end
    redirect_to '/'
  end
  def show
     flash[:notice]="パスワードを password に変更しました。至急ご自分のパスワードに変更下さい。#{params[:id]}"
     redirect_to '/'
  end
end
