# == Schema Information
#
# Table name: datapool_hatsugen_komachis
#
#  id                :integer          not null, primary key
#  topic_id          :integer          not null
#  res_number        :string(255)      not null
#  top_res_flag      :string(255)      not null
#  title             :string(255)      not null
#  body              :text(65535)
#  handle_name       :string(255)      not null
#  posted_at         :datetime         not null
#  publish_flag      :string(255)      not null
#  parent_topic_flag :string(255)      not null
#  komachi_user_id   :integer          not null
#  advice            :text(65535)
#  funny             :integer          default(0), not null
#  surprise          :integer          default(0), not null
#  tears             :integer          default(0), not null
#  yell              :integer          default(0), not null
#  isee              :integer          default(0), not null
#  genre_code        :string(255)      default(""), not null
#  res_state         :string(255)
#  facemark_id       :string(255)
#  remark            :text(65535)
#  post_device       :string(255)
#
# Indexes
#
#  index_datapool_hatsugen_komachis_on_genre_code               (genre_code)
#  index_datapool_hatsugen_komachis_on_komachi_user_id          (komachi_user_id)
#  index_datapool_hatsugen_komachis_on_posted_at                (posted_at)
#  index_datapool_hatsugen_komachis_on_topic_id_and_res_number  (topic_id,res_number)
#

class Datapool::HatsugenKomachi < ApplicationRecord
  COLUMN_LABELS = {
    topic_id: "トピID",
    res_number: "レスNo",
    top_res_flag: "トピ・レス判定フラグ",
    title: "タイトル",
    body: "本文",
    handle_name: "ハンドルネーム",
    posted_at: "投稿日時",
    publish_flag: "公開状態",
    parent_topic_flag: "親トピ公開状態",
    komachi_user_id: "ユーザーID",
    advice: "備考",
    funny: "面白い",
    surprise: "びっくり",
    tears: "涙ぽろり",
    yell: "なるほど",
    genre_code: "ジャンルコード",
    res_state: "レス受付状態",
    facemark_id: "顔アイコンID",
    remark: "ご意見・ご感想",
    post_device: "投稿デバイス",
  }

  GENRE_CODE_TAG = {
    "01" => "話題",
    "02" => "働く",
    "03" => "健康",
    "04" => "男女",
    "05" => "子供",
    "06" => "ひと",
    "07" => "美",
    "08" => "学ぶ",
    "09" => "口コミ",
    "10" => "編集部",
    "11" => "男性発",
  }

  GENRE_CODE_NAME = {
    "01" => "生活・身近な話題",
    "02" => "キャリア・職場",
    "03" => "心や体の悩み",
    "04" => "恋愛・結婚・離婚",
    "05" => "妊娠・出産・育児",
    "06" => "家族・友人・人間関係",
    "07" => "美容・ファッション・ダイエット",
    "08" => "趣味・教育・教養",
    "09" => "旅行・国内外の地域情報",
    "10" => "編集部からのトピ",
    "11" => "男性から発信するトピ",
  }
end