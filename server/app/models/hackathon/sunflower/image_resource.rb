# == Schema Information
#
# Table name: hackathon_sunflower_image_resources
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  url        :string(255)      not null
#  category   :integer          default(0), not null
#  state      :integer          not null
#  width      :integer          default(0), not null
#  height     :integer          default(0), not null
#  options    :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_hackathon_sunflower_image_resources_on_user_id  (user_id)
#

class Hackathon::Sunflower::ImageResource < ApplicationRecord
end
