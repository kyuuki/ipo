class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.references :user, foreign_key: true
      t.references :stock_company, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
