class CreateCatGustos < ActiveRecord::Migration
  def change
    create_table :cat_gustos do |t|
      t.integer :idGusto
      t.text :gusto

      t.timestamps
    end
  end
end
