class AddCuratedStreamerToDonation < ActiveRecord::Migration[6.1]
  def change
    add_belongs_to :donations, :curated_streamer
  end
end
