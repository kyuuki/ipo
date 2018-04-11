namespace :scraping do
  desc "Scraping get"
  task :get => :environment do
    ipo_list = IpoCompany::main
    ipo_list.each do |ipo|
      ipo_company_list = IpoCompany.where(code: ipo.code)
      ipo_company = nil
      if ipo_company_list.size == 0
        ipo_company = IpoCompany.create(
          code: ipo.code,
          name: ipo.company_name,
          rank: ipo.rank,
          price: ipo.price,
          listed_at: ipo.date_listed,
          apply_from: ipo.date_apply_from,
          apply_to: ipo.date_apply_to)
      else
        # TODO: データがあるときはアップデート
        ipo_company = ipo_company_list[0]
      end

      ipo.companies.each do |c|
        stock_company_list = StockCompany.where(name: c)
        stock_company = nil
        if stock_company_list.size == 0
          stock_company = StockCompany.create(name: c)
        else
          stock_company = stock_company_list[0]
        end

        # TODO: なくなっていても削除しない。追加のみ
        handling = Handling.find_by(ipo_company: ipo_company, stock_company: stock_company)
        if handling.nil?
          Handling.create(ipo_company: ipo_company, stock_company: stock_company)
        end
      end
    end
  end

  desc "Scraping get"
  task :get_data_2 => :environment do
    ipo_list = IpoCompany::get_data_2
  end
end

