class Egaonotatsuzin::BaseController < BaseController
  before_action :find_user

  def find_user
    @user = Egaonotatsuzin::User.find_by(token: params[:token])
    @user.try(:sign_in!)
  end
end