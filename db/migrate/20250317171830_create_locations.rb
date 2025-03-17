class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :address
      t.float :latitude
      t.float :longitude
      t.string :city
      t.string :state
      t.string :zipcode

      t.timestamps
    end
  end
end
