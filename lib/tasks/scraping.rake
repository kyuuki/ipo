namespace :scraping do
  desc "Scraping get"
  task :get => :environment do
    notifier = Slack::Notifier.new(Rails.application.secrets.slack_webhook_url, channel: "#random", username: "ipo-rails")
    notifier.ping('Start scraping.')

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
        notifier.ping("IPO 案件が追加されました. #{ipo_company.name}")
      else
        # TODO: データがあるときはアップデート
        ipo_company = ipo_company_list[0]
      end

      ipo.companies.each do |c|
        #stock_company_list = StockCompany.where(name: c)
        # TODO: 部品化
        stock_company = nil
        StockCompany.all.each do |sc|
          match = Regexp.new(sc.regexp).match(c)
          if not match.nil?
            stock_company = sc
            break
          end
        end

        if stock_company.nil?
          puts "#{c} にマッチする証券会社がありません."
          #stock_company = StockCompany.create(name: c)
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

