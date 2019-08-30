class PasswordresetController < ApplicationController
  require 'securerandom'
  require 'date'
  require 'active_support/core_ext'
  today = DateTime.now()    
  def reset
    email=params[:email]
    @user=User.find_by(email:email,provider:nil)
    if email.blank?
      flash[:notice]="メールアドレスを入力して送信して下さい"
    elsif @user.present?
      user_id=@user.id
      passkey=SecureRandom.hex(8)+user_id.to_s
      passwordreset=Passwordreset.new(user_id:user_id,email:email)
      passwordreset.save
      passkey=SecureRandom.hex(8)+passwordreset.id.to_s
      passwordreset.passnum=passkey
      passwordreset.save
      @content="下記アドレスをクリックしてパスワードをリセットして下さい\n１時間以内に処理して下さい"
      @link=URL+"passwordreset/#{passkey}"
      MailsysMailer.sendmail(@content,@link,email).deliver_later
      flash[:success]="パスワードのリセットのためのメールを送りました。確認下さい。"
    else
      flash[:notice]="登録のアドレスではありません。処理を中止しました。"
    end
    redirect_to '/'
  end
  
  def show
    passkey=params[:id] 
    passwordreset=Passwordreset.find_by(passnum:passkey)
    if passwordreset.created_at+60*60>Time.now
      User.find(passwordreset.user_id).reset_password("password", "password")
      flash[:notice]="パスワードを password に変更しました。至急ログインして編集のリンクでご自分のパスワードに変更下さい。"
      redirect_to '/users/sign_in'
    else
      flash[:notice]="有効時間切れです"
      redirect_to '/'
    end
    
  end
end
