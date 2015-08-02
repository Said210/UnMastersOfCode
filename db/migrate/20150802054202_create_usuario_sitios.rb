class CreateUsuarioSitios < ActiveRecord::Migration
  def change
    create_table :usuario_sitios do |t|
      t.integer :idUsuarioSitio
      t.integer :idUsuarioS
      t.integer :idSitioU

      t.timestamps
    end
  end
end
