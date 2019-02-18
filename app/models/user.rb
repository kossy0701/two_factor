class User < ApplicationRecord
  devise :two_factor_authenticatable,
         :otp_secret_encryption_key => 'm2ipmioemul6nnbbcbwnuusl5kvwhsb7'
  devise :two_factor_backupable, otp_number_of_backup_codes: 10
  serialize :otp_backup_codes, JSON

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :registerable,
         :recoverable, :rememberable, :validatable
end
