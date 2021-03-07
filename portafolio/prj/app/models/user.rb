# frozen_string_literal: true

# Users Model
class User < ApplicationRecord
  include Filterable
  # Include default devise modules. Others available are:
  # :recoverable, :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  validates :email, presence: true, uniqueness: true
  validates :encrypted_password, presence: true

  has_many :debit_accounts, dependent: :destroy
  has_many :checking_accounts, dependent: :destroy
  has_many :credit_accounts, dependent: :destroy

  scope :filter_by_email, ->(email) { where email: email }
end
