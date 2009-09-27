# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090927005947) do

  create_table "events", :force => true do |t|
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_player_id"
    t.integer  "target_player_id"
    t.integer  "period_id"
  end

  create_table "games", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.boolean  "invite_only"
    t.integer  "min_players"
    t.integer  "period_length"
    t.string   "short_code"
    t.integer  "owner_id"
    t.integer  "max_players"
    t.datetime "deleted_at"
  end

  create_table "illustrations", :force => true do |t|
    t.string   "artist_name"
    t.string   "artist_url"
    t.string   "art_file_name"
    t.string   "art_content_type"
    t.string   "art_file_size"
    t.string   "art_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "game_id"
    t.string   "twitter_login"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "invited_by_id"
  end

  create_table "periods", :force => true do |t|
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", :force => true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "dead",       :default => false
  end

  create_table "users", :force => true do |t|
    t.string   "twitter_id"
    t.string   "login"
    t.string   "access_token"
    t.string   "access_secret"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "location"
    t.string   "description"
    t.string   "profile_image_url"
    t.string   "url"
    t.boolean  "protected"
    t.string   "profile_background_color"
    t.string   "profile_sidebar_fill_color"
    t.string   "profile_link_color"
    t.string   "profile_sidebar_border_color"
    t.string   "profile_text_color"
    t.string   "profile_background_image_url"
    t.boolean  "profile_background_tiled"
    t.integer  "friends_count"
    t.integer  "statuses_count"
    t.integer  "followers_count"
    t.integer  "favourites_count"
    t.integer  "utc_offset"
    t.string   "time_zone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "following",                    :default => false
    t.boolean  "notify_start",                 :default => true
    t.boolean  "notify_finish",                :default => true
    t.boolean  "notify_period_change",         :default => true
    t.boolean  "notify_death",                 :default => true
    t.boolean  "notify_quit",                  :default => true
    t.boolean  "notify_reply",                 :default => true
  end

end
