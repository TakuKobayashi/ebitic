# == Schema Information
#
# Table name: datapool_audio_track_details
#
#  id                :bigint(8)        not null, primary key
#  track_id          :integer          not null
#  sample_rate       :integer          default(0), not null
#  tempo             :float(24)        default(0.0), not null
#  start_of_fade_out :float(24)        default(0.0), not null
#  end_of_fade_in    :float(24)        default(0.0), not null
#  loudness          :float(24)        default(0.0), not null
#  key               :integer          default(0), not null
#  mode              :integer          default(0), not null
#  options           :text(65535)
#
# Indexes
#
#  index_datapool_audio_track_details_on_track_id  (track_id)
#

class Datapool::AudioTrackDetail < ApplicationRecord
  serialize :options, JSON
end
