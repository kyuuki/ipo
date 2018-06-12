#
# スクレイピング (サイト 2) サービス
#
require 'mechanize'
require 'nokogiri'

class ScrapingSite2Service
  #
  # スクレイピング
  #
  def self.call
    url = Rails.application.secrets.url_ipo_data_2

    agent = Mechanize.new
    # 例外起きたときはそのまま上に投げる
    # TODO: タスクで例外が起きたときの検知のしくみ
    page = agent.get(url)
    doc = Nokogiri::HTML(page.body)

    ipo_list = []
    doc.xpath("//tr[@bgcolor='#ffffff']").each do |tr|
      next if tr.xpath("th").size > 3
      ipo_list << parse_tr(tr)
    end

    puts ipo_list

    return ipo_list
  end

  #
  # 1 tr 処理
  #
  def self.parse_tr(tr)
    ipo = IpoData.new

    # 上場日 BB 期間 カラム処理
    ipo.date_listed = Date.parse(tr.xpath("td[1]").children[0].text)
    ipo.date_apply_from, ipo.date_apply_to = tr.xpath("td[1]").children[2].text.split("-").map { |s| Date.parse(s) }

    # コード IPO 銘柄名 カラム処理
    ipo.code = tr.xpath("td[3]").children[0].text
    ipo.company_name = tr.xpath("td[3]").children[2].text

    # 想定価格 仮条件 カラム処理
    td = tr.xpath("td[4]")

    # 想定価格 (x,xxx円 or x,xxx-x,xxx円)
    str = td.children[0].text
    str.gsub!(/.*-/, "")
    str.gsub!(/,/, "")
    str.gsub!(/円/, "")
    ipo.price = str.to_i

    # 仮条件 (x,xxx-x,xxx円 or -円)
    str = td.children[3].text
    str.gsub!(/.*-/, "")
    str.gsub!(/,/, "")
    str.gsub!(/円/, "")
    i = str.to_i
    ipo.price = i if i > 0  # 仮条件があればこちらが優先

    # 評価 カラム処理
    str = tr.xpath("td[5]").text
    str.gsub!(/.*→/, "")
    ipo.rank = str

    # リンク先取得
    url = tr.xpath("td[3]").children[2].attribute("href").value
    get_detail_page(url, ipo)

    return ipo
  end

  #
  # 詳細ページ処理
  #
  def self.get_detail_page(url, ipo)
    agent = Mechanize.new
    page = agent.get(url)
    doc = Nokogiri::HTML(page.body)

    table = doc.xpath("//div[@class='article']//table")
    table.xpath("//tr").each do |tr|
      if tr.xpath("th").text.match(/主幹事/)
        ipo.companies << parse_tr_main_kanji(tr)
      elsif tr.xpath("th").text.match(/引受幹事/)
        ipo.companies.concat(parse_tr_sub_kanji(tr))
      end
    end
  end

  #
  # 詳細ページ - tr (主幹事) 処理
  #
  def self.parse_tr_main_kanji(tr)
    return tr.xpath("td").text
  end

  #
  # 詳細ページ - tr (引受幹事) 処理
  #
  def self.parse_tr_sub_kanji(tr)
    return tr.xpath("td").text.split(/\s+/)
  end
end
