#
# スクレイピング (サイト 3) サービス
#
require 'mechanize'
require 'nokogiri'

class ScrapingSite3Service
  #
  # スクレイピング
  #
  def self.call
    url = Rails.application.secrets.url_ipo_data_3

    agent = Mechanize.new
    # 例外起きたときはそのまま上に投げる
    # TODO: タスクで例外が起きたときの検知のしくみ
    page = agent.get(url)
    doc = Nokogiri::HTML(page.body)

    ipo_list = []
    doc.xpath("//tr[@class='even' or @class='odd']").each do |tr|
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

