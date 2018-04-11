class CreateStockCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :stock_companies do |t|
      t.string :name

      t.timestamps
    end
  end
end
