class ModifyPetsForArrayFields < ActiveRecord::Migration[7.1]
  def change
    change_column :pets, :personality_traits, :string, array: true, default: [], using: "(string_to_array(personality_traits, ','))"
    change_column :pets, :medical_conditions, :string, array: true, default: [], using: "(string_to_array(medical_conditions, ','))"
    change_column :pets, :looking_for, :string, array: true, default: [], using: "(string_to_array(looking_for, ','))"
    change_column :pets, :preferred_species, :string, array: true, default: [], using: "(string_to_array(preferred_species, ','))"
    change_column :pets, :preferred_size, :string, array: true, default: [], using: "(string_to_array(preferred_size, ','))"

    remove_column :pets, :breeding_history
  end
end
