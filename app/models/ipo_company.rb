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
    @companies.each do |company|
      str << "\n  #{company}"
    end

    return str
  end
end
