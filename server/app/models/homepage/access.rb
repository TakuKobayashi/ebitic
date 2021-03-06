# == Schema Information
#
# Table name: homepage_accesses
#
#  id         :bigint(8)        not null, primary key
#  ip_address :string(255)      not null
#  uid        :string(255)      not null
#  user_agent :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_homepage_accesses_on_ip_address  (ip_address)
#  index_homepage_accesses_on_uid         (uid) UNIQUE
#

class Homepage::Access < ApplicationRecord
  has_many :likes, class_name: 'Homepage::Like', foreign_key: :homepage_access_id
  has_many :upload_jobs, class_name: 'Homepage::UploadJobQueue', foreign_key: :homepage_access_id
  has_many :accounts, class_name: 'Homepage::Account', foreign_key: :homepage_access_id
  has_one :spotify, class_name: 'SpotifyAccount', as: :user
  has_one :google, class_name: 'GoogleAccount', as: :user
end
