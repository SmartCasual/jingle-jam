# ## Schema Information
#
# Table name: `curated_streamer_administrators`
#
# ### Columns
#
# Name                       | Type               | Attributes
# -------------------------- | ------------------ | ---------------------------
# **`id`**                   | `bigint`           | `not null, primary key`
# **`created_at`**           | `datetime`         | `not null`
# **`updated_at`**           | `datetime`         | `not null`
# **`curated_streamer_id`**  | `bigint`           | `not null`
# **`donator_id`**           | `bigint`           | `not null`
#
class CuratedStreamerAdministrator < ApplicationRecord
  belongs_to :curated_streamer, inverse_of: :curated_streamer_administrators
  belongs_to :donator, inverse_of: :curated_streamer_administrators
end
