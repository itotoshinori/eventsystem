class WithdrawController < ApplicationController
  def taikai
    User.find(current_user.id).delete
    Participant.where(user_id:current_user.id).destroy_all
    Comment.where(user_id:current_user.id).destroy_all
    flash[:warning]="退会処理されました"
    redirect_to("/")
  end
end
