class CreatePets < ActiveRecord::Migration[7.1]
  def change
    create_table :pets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :species
      t.string :breed
      t.integer :age
      t.string :gender
      t.text :bio
      t.text :personality_traits
      t.string :temperament
      t.string :size
      t.string :age_group
      t.boolean :is_vaccinated
      t.boolean :is_neutered
      t.text :medical_conditions
      t.boolean :is_available_for_breeding
      t.text :breeding_history
      t.boolean :registered_pedigree
      t.string :looking_for
      t.string :preferred_species
      t.string :preferred_size
      t.string :status

      t.timestamps
    end
  end
end
