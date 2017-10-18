class CreateHomepageAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :homepage_accounts do |t|
      t.integer :homepage_access_id, null: false
      t.string :type
      t.string :uid, null: false
      t.text :token
      t.text :token_secret
      t.datetime :expired_at
      t.text :options
      t.timestamps
    end
    add_index :homepage_accounts, :uid
    add_index :homepage_accounts, [:homepage_access_id, :type], unique: true, name: "unique_homepage_accounts_index"
  end
end
