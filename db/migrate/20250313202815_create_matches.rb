class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      t.references :pet, null: false, foreign_key: true
      t.references :matched_pet, null: false, foreign_key: { to_table: :pets }
      t.string :status
      t.datetime :matched_at

      t.timestamps
    end
  end
end
