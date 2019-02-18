class Users::SessionsController < Devise::SessionsController
  prepend_before_action :authenticate_with_two_factor, only: [:create]

  private

  def user_params
    params.require(:user).permit(:email, :password, :remember_me, :otp_attempt)
  end

  def find_user
    if user_params[:email]
      User.find_by(email: user_params[:email])
    elsif user_params[:otp_attempt].present? && session[:otp_user_id]
      User.find(session[:otp_user_id])
    end
  end

  def authenticate_with_two_factor
    user = self.resource = find_user

    return unless user && user.otp_required_for_login

    if user_params[:email]
      if user && user.valid_password?(user_params[:password])
        prompt_for_two_factor(user)
      end
    elsif user_params[:otp_attempt].present? && session[:otp_user_id]
      if valid_otp_attempt?(user)
        session.delete(:otp_user_id)
        sign_in(user) and return
      else
        flash.now[:alert] = 'Invalid two-factor code.'
        render :two_factor and return
      end
    end
  end

  def prompt_for_two_factor(user)
    session[:otp_user_id] = user.id
    render 'devise/sessions/two_factor' and return
  end

  def valid_otp_attempt?(user)
    user.validate_and_consume_otp!(user_params[:otp_attempt]) ||
    user.invalidate_otp_backup_code!(user_params[:otp_attempt])
  end
end
