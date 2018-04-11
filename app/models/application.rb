class Application < ApplicationRecord
  belongs_to :user
  belongs_to :ipo_company
  belongs_to :account
end
