# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!
  
  def my_page
 
  end
 
  protected
 
  def after_sign_up_path_for(resource)
     my_page_path
  end
end
