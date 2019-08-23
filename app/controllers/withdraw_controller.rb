class WithdrawController < ApplicationController
  require 'date'
  def taikai
    event=Event.where('opendate >= ?',Date.today).where(held:true).where(user_id:current_user.id)
    if event.present?
      flash[:warning]="主催のイベントが残っています。イベントを中止の処理してから退会して下さい。"
    else
      User.find(current_user.id).delete
      Participant.where(user_id:current_user.id).destroy_all
      Comment.where(user_id:current_user.id).destroy_all
      flash[:warning]="退会処理されました"
    end
    redirect_to("/")
  end
end