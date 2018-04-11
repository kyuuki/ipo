require 'mechanize'
require 'nokogiri'

class IpoCompany < ApplicationRecord
  has_many :handlings

  #
  # 1 行処理
  #
  def self.parse_tr(tr)
    ipo = IPO.new

    # 上場日カラム処理
    ipo.date_listed = Date.parse(tr.xpath("td[1]").text)

    # 企業名カラム処理
    str = tr.xpath("td[2]").text
    str = str.gsub(/\s+/, "")
    str = str.tr("（）", "()")  # たまに全角ある。。。
    ipo.company_name = str.gsub(/\((.+)\)/, "")
    ipo.code = $1

    # 総合評価カラム処理
    ipo.rank = tr.xpath("td[3]/img/@alt").text.tr('ａ-ｚＡ-Ｚ', 'a-zA-Z').upcase

    # 申し込み期間カラム処理
    str = tr.xpath("td[5]").text
    str = str.gsub(/\s+/, "")
    ipo.date_apply_from, ipo.date_apply_to = str.split("～").map { |s| Date.parse(s) }

    # 想定価格カラム処理
    str = tr.xpath("td[7]").text
    str = str.gsub(/,/, "")
    str = str.gsub(/円/, "")
    ipo.price = str.to_i

    # 仮条件カラム処理

    # 公募価格カラム処理
    str = tr.xpath("td[9]").text
    str = str.gsub(/,/, "")
    str = str.gsub(/円/, "")
    ipo.price = str.to_i if not str.to_i == 0

    # 狙い目証券カラム処理
    str = tr.xpath("td[12]").text
    array_str = str.split(/\s+/)
    ipo.companies = array_str.map { |s| s.gsub(/（.*）/, "") }

    return ipo
  end

  def self.main
    agent = Mechanize.new
    page = agent.get(Rails.application.secrets[:url_ipo_data_1])
    doc = Nokogiri::HTML(page.body)
    # TODO: エラー処理

    ipo_list = []
    doc.xpath("//tr").each do |tr|
      next if tr.xpath("th").size > 3
      ipo_list << parse_tr(tr)
    end

    return ipo_list
  end

  # スクレイピング
  def self.get_data_2
    agent = Mechanize.new
    page = agent.get(Rails.application.secrets[:url_ipo_data_2])
    doc = Nokogiri::HTML(page.body)
    # TODO: エラー処理

    ipo_list = []
    doc.xpath("//tr[@bgcolor='#ffffff']").each do |tr|
      next if tr.xpath("th").size > 3
      ipo_list << get_data_2_parse_tr(tr)
    end

    # データ保存
    ipo_list.each do |ipo|
      ipo_company = IpoCompany.find_by(code: ipo.code)
      ipo_company = nil
      if ipo_company.nil?
        IpoCompany.create(code: ipo.code, name: ipo.company_name, rank: ipo.rank)
      end
    end
  end

  #
  # 1 行処理
  #
  def self.get_data_2_parse_tr(tr)
    ipo = IPO.new

    # 上場日 BB 期間 カラム処理
    ipo.date_listed = Date.parse(tr.xpath("td[1]").children[0].text)
    ipo.date_apply_from, ipo.date_apply_to = tr.xpath("td[1]").children[2].text.split("-").map { |s| Date.parse(s) }

    # コード IPO 銘柄名 カラム処理
    ipo.code = tr.xpath("td[3]").children[0].text
    ipo.company_name = tr.xpath("td[3]").children[2].text

    # 想定価格 仮条件 カラム処理
    #puts tr.xpath("td[4]").children[3].text
    # TODO: HTML で解析した方が安全っぽい

    # 評価 カラム処理
    ipo.rank = tr.xpath("td[5]").text

    return ipo
  end
end

class IPO
  attr_accessor :date_listed, :date_apply_from, :date_apply_to, :code, :company_name, :rank, :price, :companies
  @date_listed
  @date_apply_from
  @date_apply_to

  @code
  @company_name
  @rank
  @price

  @companies

  def to_s
    str = "#{@date_listed} #{@date_apply_from} #{@date_apply_to} #{@rank} #{@code} #{@company_name} #{@price}"
    if not @companies.nil?
      @companies.each do |company|
        str << "\n  #{company}"
      end
    end

    return str
  end
end
