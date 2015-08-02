class CreateUsuarioGustos < ActiveRecord::Migration
  def change
    create_table :usuario_gustos do |t|
      t.integer :idUsuarioGusto
      t.integer :idGustoU
      t.integer :idUsuarioG

      t.timestamps
    end
  end
end
