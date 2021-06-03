class CreateCuratedStreamer < ActiveRecord::Migration[6.1]
  def change
    create_table :curated_streamers do |t|
      t.string :twitch_username, null: false, index: true, unique: true

      t.timestamps
    end

    create_table :curated_streamer_administrators do |t|
      t.references :curated_streamer, null: false, index: true
      t.references :donator, null: false, index: true

      t.index [:curated_streamer_id, :donator_id], unique: true, name: "ref_index"

      t.timestamps
    end
  end
end
