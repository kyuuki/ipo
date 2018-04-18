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

  # TODO: 複数サイトに手軽に対応出来るように
  def self.scrape_1(url)
    agent = Mechanize.new
    # 例外起きたときはそのまま上に投げる
    page = agent.get(url)
    doc = Nokogiri::HTML(page.body)

    ipo_list = []
    doc.xpath("//tr").each do |tr|
      next if tr.xpath("th").size > 3
      ipo_list << scrape_1_parse_tr(tr)
    end

    puts ipo_list
    return ipo_list
  end

  #
  # 1 行処理
  #
  def self.scrape_1_parse_tr(tr)
    ipo = IpoData.new

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

  def self.scrape_2(url)
    agent = Mechanize.new
    page = agent.get(url)
    doc = Nokogiri::HTML(page.body)

    ipo_list = []
    doc.xpath("//tr[@bgcolor='#ffffff']").each do |tr|
      next if tr.xpath("th").size > 3
      ipo_list << scrape_2_parse_tr(tr)
    end

    puts ipo_list
    return ipo_list
  end

  #
  # 1 行処理
  #
  def self.scrape_2_parse_tr(tr)
    ipo = IpoData.new

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
