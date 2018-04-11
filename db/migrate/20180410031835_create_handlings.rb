class CreateHandlings < ActiveRecord::Migration[5.1]
  def change
    create_table :handlings do |t|
      t.references :ipo_company, foreign_key: true
      t.references :stock_company, foreign_key: true

      t.timestamps
    end
  end
end
