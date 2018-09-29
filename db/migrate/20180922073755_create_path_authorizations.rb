class CreatePathAuthorizations < ActiveRecord::Migration[5.2]
  def change
    create_table :path_authorizations do |t|
      t.string :path, null: false, index: true
      t.string :token, limit: 40
      t.integer :level, null: false
      t.timestamps
    end
  end
end
