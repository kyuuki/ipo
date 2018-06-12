#
# IPO 情報
#
# * Rails に依存しないで汎用に使えること
# * スクレイピング機能つき (というかそれがメイン)
#
require 'mechanize'
require 'nokogiri'

class IpoData
  attr_accessor :code, :company_name, :rank, :price, :companies,
                :date_listed, :date_apply_from, :date_apply_to

  def initialize
    @code
    @company_name
    @rank
    @price = 0

    @date_listed
    @date_apply_from
    @date_apply_to

    @companies = []
  end

  def to_s
    str = "#{@date_listed} #{@date_apply_from} #{@date_apply_to} #{@rank} #{@code} #{@company_name} #{@price}"
    @companies.each do |company|
        str << "\n  #{company}"
    end

    return str
  end

  #
  # スクレイピング 3
  #
  def self.scrape_3(url)
    agent = Mechanize.new
    page = agent.get(url)
    doc = Nokogiri::HTML(page.body)

    ipo_list = []
    doc.xpath("//tr[@class='even' or @class='odd']").each do |tr|
      ipo_list << scrape_3_parse_tr(tr)
    end

    puts ipo_list
    return ipo_list
  end

  #
  # 1 行処理
  #
  def self.scrape_3_parse_tr(tr)
    ipo = IpoData.new

    # code カラム処理
    ipo.code = tr.xpath("td[2]").text

    # 銘柄名カラム処理
    ipo.company_name = tr.xpath("td[3]").text

    # 評価カラム処理
    str = tr.xpath("td[7]").text
    ipo.rank = str.match(/\((.+)\)/)[1]

    # 公募カラム処理
    str = tr.xpath("td[8]").text
    str = str.gsub(/,/, "")
    ipo.price = str.to_i

    return ipo
  end
end
