class ChangeDefaultStatusInPets < ActiveRecord::Migration[7.1]
  def change
    change_column_default :pets, :status, "active"
  end
end
