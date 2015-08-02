class RemoveFechaFromSitios < ActiveRecord::Migration
  def change
    remove_column :sitios, :fecha, :timestamp
  end
end
