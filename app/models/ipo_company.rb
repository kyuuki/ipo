require 'mechanize'
require 'nokogiri'

class IpoCompany < ApplicationRecord
  has_many :handlings

  # 申込期間中？
  def apply_active?
    today = Date.today  # TODO: 本当は 1 リクエストで固定する必要あり
    (apply_from <= today) and (today <= apply_to)
  end

  # スクレイピングしてデータを更新 1
  def self.update_1
    ipo_data_list = ScrapingSite1Service::call

    ipo_data_list.each do |ipo|
      # ipo: スクレイピングしてきたデータ
      # ipo_company: DB に登録した IPO 会社 (案件)

      ipo_company_list = IpoCompany.where(code: ipo.code)
      ipo_company = nil
      if ipo_company_list.size == 0
        #
        # IPO 会社追加
        #
        ipo_company = IpoCompany.create(
          code: ipo.code,
          name: ipo.company_name,
          rank: ipo.rank,
          price: ipo.price,
          listed_at: ipo.date_listed,
          apply_from: ipo.date_apply_from,
          apply_to: ipo.date_apply_to)

        SlackNotifier.notify("IPO 案件が追加されました. #{ipo_company.name}")
      else
        ipo_company = ipo_company_list[0]

        # 価格に変更があるときはアップデート
        if ipo_company.price != ipo.price
          old_price = ipo_company.price
          ipo_company.update(price: ipo.price)

          message = "価格が変更されました. #{ipo_company.name}: #{old_price} ---> #{ipo.price}"
          puts message
          SlackNotifier.notify(message)
        end

        # TODO: ランクも更新はどうしよう？
      end

      #
      # 取扱証券の更新
      #
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
          message = "#{c} にマッチする証券会社がありません."
          puts message
          SlackNotifier.notify(message)
          #stock_company = StockCompany.create(name: c)
        end

        # TODO: なくなっていても削除しない。追加のみ
        handling = Handling.find_by(ipo_company: ipo_company, stock_company: stock_company)
        if handling.nil?
          Handling.create(ipo_company: ipo_company, stock_company: stock_company)
          message = "取扱証券会社が追加されました. #{ipo_company.name}: #{stock_company.name}"
          SlackNotifier.notify(message)
        end
      end

      #
      # 申込の更新
      #
      # ipo_company の取扱証券会社の口座から申込を作成
      # TODO: 消えた場合
      ipo_company.handlings.each do |handling|
        stock_company = handling.stock_company
        # 取扱証券会社に関する全口座を洗い出し
        Account.where(stock_company: stock_company).each do |account|
          # 申込状況を追加
          application = Application.find_by(ipo_company: ipo_company, account: account)
          if application.nil?
            Application.create(ipo_company: ipo_company, account: account, amount: 0, applied: false)
          end
        end
      end
    end
  end

  # スクレイピングしてデータを更新 2
  def self.update_2
    ipo_data_list = ScrapingSite2Service::call

    # データ保存
    ipo_data_list.each do |ipo|
      ipo_company = IpoCompany.find_by(code: ipo.code)

      #
      # IPO 会社追加
      #
      if ipo_company.nil?
        ipo_company = IpoCompany.create(
          code: ipo.code,
          name: ipo.company_name,
          rank: ipo.rank,
          price: ipo.price,
          listed_at: ipo.date_listed,
          apply_from: ipo.date_apply_from,
          apply_to: ipo.date_apply_to)

        SlackNotifier.notify("IPO 案件が追加されました. #{ipo_company.name}")
      end

      #
      # 取扱証券の更新
      #
      ipo_company.update_handlings(ipo.companies)

      #
      # 申込の更新
      #
      ipo_company.update_application
    end
  end

  # スクレイピングしてデータを更新 3
  def self.update_3
    ipo_data_list = ScrapingSite3Service::call

    # データ保存
    ipo_data_list.each do |ipo|
      ipo_company = IpoCompany.find_by(code: ipo.code)
      # 現状は既存の評価データを入れ替えるだけ
      # 評価データは 10 段階は扱いづらいので S, A, B, C, D に
      case ipo.rank.to_i
      when 0
        ipo.rank = '-'
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

      # TODO: 他のデータもいろいろチェックできると安定性が増す

      if not ipo_company.nil?
        ipo_company.update(
          rank: ipo.rank)
      end
    end
  end

  #
  # 証券会社の文字列リストを元に handlings を更新
  #
  def update_handlings(stock_company_str_list)
    stock_company_str_list.each do |stock_company_str|
      # TODO: 部品化
      stock_company = nil
      StockCompany.all.each do |sc|
        match = Regexp.new(sc.regexp).match(stock_company_str)
        if not match.nil?
          stock_company = sc
          break
        end
      end

      if stock_company.nil?
        message = "#{stock_company_str} にマッチする証券会社がありません."
        puts message
        #SlackNotifier.notify(message)
        #stock_company = StockCompany.create(name: c)

        next
      end

      # TODO: なくなっていても削除しない。追加のみ
      handling = Handling.find_by(ipo_company: self, stock_company: stock_company)
      if handling.nil?
        Handling.create(ipo_company: self, stock_company: stock_company)
        message = "取扱証券会社が追加されました. #{self.name}: #{stock_company.name}"
        SlackNotifier.notify(message)
      end
    end
  end

  #
  # 申込の更新
  #
  # ipo_company の取扱証券会社の口座から申込を作成
  # TODO: 消えた場合
  # TODO: 変更のあった取扱商圏のみ更新
  def update_application
    self.handlings.each do |handling|
      stock_company = handling.stock_company
      # 取扱証券会社に関する全口座を洗い出し
      Account.where(stock_company: stock_company).each do |account|
        # 申込状況を追加
        application = Application.find_by(ipo_company: self, account: account)
        if application.nil?
          Application.create(ipo_company: self, account: account, amount: 0, applied: false)
        end
      end
    end
  end
end

