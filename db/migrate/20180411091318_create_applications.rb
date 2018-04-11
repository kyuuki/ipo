class CreateApplications < ActiveRecord::Migration[5.1]
  def change
    create_table :applications do |t|
      t.references :user, foreign_key: true
      t.references :ipo_company, foreign_key: true
      t.references :account, foreign_key: true
      t.integer :amount
      t.boolean :applied

      t.timestamps
    end
  end
end
