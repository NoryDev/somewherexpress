# frozen_string_literal: true
# == Schema Information
#
# Table name: badges
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  name        :string
#  picture     :string
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_badges_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Badge < ApplicationRecord
  belongs_to :user
end
