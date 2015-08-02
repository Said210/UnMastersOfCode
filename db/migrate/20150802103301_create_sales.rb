class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.integer :userId
      t.string :desc
      t.decimal :value
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
