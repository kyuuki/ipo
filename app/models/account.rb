class Account < ApplicationRecord
  belongs_to :user
  belongs_to :stock_company

  # 申込を追加する
  def update_applications(user)
    IpoCompany.all.each do |ipo_company|
      if ipo_company.handlings.pluck(:stock_company_id).include?(stock_company_id)
        application = Application.find_by(user: user, ipo_company: ipo_company, account: self)
        if application.nil?
          Application.create(user: user, ipo_company: ipo_company, account: self, amount: 0, applied: false)
        end
      end
    end
  end
end
