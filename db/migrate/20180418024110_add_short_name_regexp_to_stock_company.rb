class AddShortNameRegexpToStockCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :stock_companies, :short_name, :string
    add_column :stock_companies, :regexp, :string
  end
end
