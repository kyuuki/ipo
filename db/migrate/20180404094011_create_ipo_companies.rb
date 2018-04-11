class CreateIpoCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :ipo_companies do |t|
      t.string :code
      t.string :name
      t.string :rank
      t.integer :price
      t.date :listed_at
      t.date :apply_from
      t.date :apply_to

      t.timestamps
    end
  end
end
