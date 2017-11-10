class Egaonotatsuzin::AuthenticationController < BaseController
  def sign_in
    token = params[:token]
    if token.blank?
      token = SecureRandom.hex
    end
    user = Egaonotatsuzin::User.find_or_initialize_by(token: token)
    if user.new_record?
      user.update!(user_agent: request.user_agent)
    end
    session["user_id"] = user.id
    session["user_type"] = user.class.to_s
    session["redirect_url"] = callback_egaonotatsuzin_authentication_url
    redirect_to "/auth/spotify"
  end

  def callback
    user = session["user_type"].constantize.find_by(id: session["user_id"])
    session.delete("user_id")
    session.delete("user_type")
    redirect_to "egaonotatsuzin://auth?user_token=#{user.token}"
  end
end
