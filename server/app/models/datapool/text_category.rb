# == Schema Information
#
# Table name: datapool_text_categories
#
#  id                   :bigint(8)        not null, primary key
#  datapool_text_id     :integer          not null
#  datapool_category_id :integer          not null
#
# Indexes
#
#  datapool_text_category_relation_index  (datapool_text_id,datapool_category_id) UNIQUE
#

class Datapool::TextCategory < ApplicationRecord
end
