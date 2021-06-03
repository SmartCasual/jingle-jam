# ## Schema Information
#
# Table name: `curated_streamers`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `bigint`           | `not null, primary key`
# **`twitch_username`**  | `string`           | `not null`
# **`created_at`**       | `datetime`         | `not null`
# **`updated_at`**       | `datetime`         | `not null`
#
class CuratedStreamer < ApplicationRecord
  has_many :curated_streamer_administrators, dependent: :destroy, inverse_of: :curated_streamer
  has_many :admins, through: :curated_streamer_administrators, source: :donator
  has_many :donations, inverse_of: :curated_streamer, dependent: :nullify

  def to_param
    twitch_username
  end
end
