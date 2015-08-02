class CreateSitios < ActiveRecord::Migration
  def change
    create_table :sitios do |t|
      t.integer :idSitio
      t.float :latitude
      t.float :longitude
      t.string :nombre
      t.timestamp :fecha

      t.timestamps
    end
  end
end
