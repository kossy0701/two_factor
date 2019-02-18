class TwoFactorAuthsController < ApplicationController

  # 2段階認証有効化確認
  def new
    unless current_user.otp_secret
      # この時点で認証コードのシークレットキーを生成して保存しておく
      current_user.otp_secret = User.generate_otp_secret(32)
      current_user.save!
    end

    @qr_code = build_qr_code
  end

  # 2段階認証有効化
  def create
    # 認証コードが合っているか確認
    if current_user.validate_and_consume_otp!(params[:otp_attempt])
      # 2段階認証有効化フラグを立てる
      current_user.otp_required_for_login = true
      @codes = current_user.generate_otp_backup_codes! # これを追加
      current_user.save!

      render 'codes'

    #　認証コードが合っていなければもう一度確認画面をレンダリング
    else
      @error = 'Invalid pin code'
      @qr_code = build_qr_code

      render 'new'
    end
  end

  # 2段階認証無効化
  def destroy
    current_user.update_attributes(
      otp_required_for_login:    false,
      encrypted_otp_secret:      nil,
      encrypted_otp_secret_iv:   nil,
      encrypted_otp_secret_salt: nil,
    )
    redirect_to root_path
  end

  private
  # QRコードを作成
  def build_qr_code
    # issuerがGoogle Authenticator上の登録サービス名として表示される
    label = "your_name"
    issuer = "LiBz Tech Blog"
    uri = current_user.otp_provisioning_uri(label, issuer: issuer)
    qrcode = RQRCode::QRCode.new(uri)
    # svg形式で表示
    qrcode.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 2
    )
  end
end
