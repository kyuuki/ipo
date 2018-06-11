class Account < ApplicationRecord
  belongs_to :user
  belongs_to :stock_company

  has_many :applications, dependent: :destroy

  validates :user,
    presence: true
  validates :stock_company,
    presence: true
  validates :name,
    presence: true

  # 特定ユーザーの口座
  # merge で使いたいがため？！
  # https://nekogata.hatenablog.com/entry/2012/12/11/054555
  scope :by_user, ->(user) { where(user: user) }

  # 申込を追加する
  def update_applications(user)
    IpoCompany.all.each do |ipo_company|
      if ipo_company.handlings.pluck(:stock_company_id).include?(stock_company_id)
        application = Application.find_by(ipo_company: ipo_company, account: self)
        if application.nil?
          Application.create(ipo_company: ipo_company, account: self, amount: 0, applied: false)
        end
      end
    end
  end
end
