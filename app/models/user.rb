# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  first                  :string
#  last                   :string
#  banned                 :boolean
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime
#  updated_at             :datetime
#  roles_mask             :integer          default("0")
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  has_many :listings, dependent: :destroy
  has_many :offers, dependent: :destroy
  has_many :exchanges
  has_many :reports


  validates :first, presence:true
  validates :last, presence:true
  validates :email, presence:true, uniqueness:true
  validates_format_of :email, with: /.edu\z/, message: "must use .edu address"
  validate :in_school_list

  validates :first, presence: true
  validates :last, presence: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  def in_school_list
    return SCHOOLS[email.split("@")[1]].nil?
  end

  ROLES = %w[superuser admin]
  
  def roles=(roles)
    # => %w[admin]
    self.roles_mask = (roles&ROLES).map{|r| 2**ROLES.index(r)}.inject(0,:+)
  end
  
  def roles
    ROLES.reject do |r|
      (roles_mask & 2**ROLES.index(r)).zero?
    end
  end
  
  def is?(role)
    # => true if matches a role for this user, false otherwise
    roles.include?(role.to_s)
  end
end
