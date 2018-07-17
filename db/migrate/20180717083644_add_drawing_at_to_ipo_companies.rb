class AddDrawingAtToIpoCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :ipo_companies, :drawing_at, :date
  end
end
