class Account < ApplicationRecord
  belongs_to :user
  belongs_to :stock_company
end
