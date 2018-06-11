class Application < ApplicationRecord
  belongs_to :ipo_company
  belongs_to :account

  # 特定ユーザーの申込
  scope :by_user, ->(user) { joins(:account).merge(Account.by_user(user)) }
end
