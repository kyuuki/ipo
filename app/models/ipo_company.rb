require 'mechanize'
require 'nokogiri'

class IpoCompany < ApplicationRecord
  has_many :handlings

  # スクレイピングしてデータを更新 1
  def self.update_1
    # TODO: サービス化
    notifier = Slack::Notifier.new(Rails.application.secrets.slack_webhook_url, 
                                   channel: "#random", username: "ipo-rails")

    #ipo_data_list = IpoData::scrape_1(Rails.application.secrets.url_ipo_data_1)
    ipo_data_list = ScrapingSite1Service::call

    ipo_data_list.each do |ipo|
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
        #notifier.ping("IPO 案件が追加されました. #{ipo_company.name}")
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
          notifier.ping "#{c} にマッチする証券会社がありません."
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

  # スクレイピングしてデータを更新 2
  def self.update_2
    ipo_data_list = IpoData::scrape_2(Rails.application.secrets.url_ipo_data_2)

    # データ保存
    ipo_data_list.each do |ipo|
      ipo_company = IpoCompany.find_by(code: ipo.code)
      if ipo_company.nil?
        ipo_company = IpoCompany.create(
          code: ipo.code,
          name: ipo.company_name,
          rank: ipo.rank,
          #price: ipo.price,
          listed_at: ipo.date_listed,
          apply_from: ipo.date_apply_from,
          apply_to: ipo.date_apply_to)
      end
    end
  end

  # スクレイピングしてデータを更新 3
  def self.update_3
    ipo_data_list = IpoData::scrape_3(Rails.application.secrets.url_ipo_data_3)

    # データ保存
    ipo_data_list.each do |ipo|
      ipo_company = IpoCompany.find_by(code: ipo.code)
      # 現状は既存のデータの価格と評価データを入れ替えるだけ
      # 評価データは 10 段階は扱いづらいので S, A, B, C, D に
      case ipo.rank.to_i
      when 1..5
        ipo.rank = 'D'
      when 6
        ipo.rank = 'C'
      when 7..8
        ipo.rank = 'B'
      when 9
        ipo.rank = 'A'
      when 10
        ipo.rank = 'S'
      end

      if not ipo_company.nil?
        ipo_company.update(
          price: ipo.price,
          rank: ipo.rank)
      end
    end
  end
end

