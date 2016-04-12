class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.references :user, index: true, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :name, default: ''
      t.string :accesstoken, default: ''
      t.string :refreshtoken, default: ''
      t.string :email, default: ''
      t.string :image, default: ''
      t.string :url, default: ''

      t.timestamps null: false
    end
  end
end
