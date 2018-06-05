#
# スクレイピング (サイト 1) サービス
#
# - サイトから IPO 情報を引っ張って IPO 情報を組み立てるところまでが責任
# - DB 保存は責任外
# - 引っ張ってこれる IPO 情報や DB への保存の仕方はサイトによっていろいろ変わってきそう
# - あんまりサービスっぽくないかも
#
require 'mechanize'
require 'nokogiri'

class ScrapingSite1Service
  #
  # スクレイピング
  #
  def self.call
    url = Rails.application.secrets.url_ipo_data_1

    agent = Mechanize.new
    # 例外起きたときはそのまま上に投げる
    # TODO: タスクで例外が起きたときの検知のしくみ
    page = agent.get(url)
    doc = Nokogiri::HTML(page.body)

    # テーブルが左と右で別 table という情報構造を全く無視した HTML
    table_head_list = doc.xpath("//div[contains(@class, 'tableHead')]/table")
    table_body_list = doc.xpath("//div[contains(@class, 'tableBody')]/table")

    # 念のためチェック
    raise "Table count error." if not (table_head_list.size == table_body_list.size)
    Rails.logger.debug("Table count = #{table_head_list.size}.")

    tr_set_list = []
    for i in 0...table_head_list.size
      tr_set_list.concat(parse_table(table_head_list[i], table_body_list[i]))
    end

    # ここまでで [tr_head, tr_body] の配列ができている (ただしゴミを含む)

    ipo_list = []
    tr_set_list.each do |tr_set|
      ipo_data = parse_tr_set(tr_set)
      ipo_list << ipo_data if not ipo_data.nil?
    end

    puts ipo_list
    return ipo_list
  end

  #
  # 1 テーブル (実際は 2 table) 処理
  #
  def self.parse_table(table_head, table_body)
    tr_head_list = table_head.xpath("tr")
    tr_body_list = table_body.xpath("tr")

    # 念のためチェック (というか結構まちがえてるはずなので例外にしない)
    if not (tr_head_list.size == tr_body_list.size)
      Rails.logger.error("tr_head_list.size = #{tr_head_list.size}, tr_body_list.size = #{tr_body_list.size}.")
      return []
    end
    Rails.logger.debug("Tr count = #{tr_head_list.size}.")

    tr_set_list = []
    for i in 0...tr_head_list.size
      tr_set_list << [tr_head_list[i], tr_body_list[i]]
    end

    return tr_set_list
  end

  #
  # 1 tr セット処理
  #
  def self.parse_tr_set(tr_set)
    tr_head = tr_set[0]
    tr_body = tr_set[1]

    # th がたくさん含まれていたらヘッダ行とみなす
    return nil if (tr_head.xpath("th").size > 0) and (tr_body.xpath("th").size > 3)

    ipo = IpoData.new

    # 上場日カラム処理
    ipo.date_listed = Date.parse(tr_head.xpath("td[1]").text)

    # 企業名カラム処理
    str = tr_head.xpath("td[2]").text
    str = str.gsub(/\s+/, "")
    str = str.tr("（）", "()")  # たまに全角ある。。。
    ipo.company_name = str.gsub(/\((.+)\)/, "")
    ipo.code = $1

    # 総合評価カラム処理
    ipo.rank = tr_body.xpath("td[1]/img/@alt").text.tr('ａ-ｚＡ-Ｚ', 'a-zA-Z').upcase

    # 申し込み期間カラム処理
    str = tr_body.xpath("td[3]").text
    str = str.gsub(/\s+/, "")
    ipo.date_apply_from, ipo.date_apply_to = str.split("～").map { |s| Date.parse(s) }

    # 想定価格カラム処理
    str = tr_body.xpath("td[5]").text
    str = str.gsub(/,/, "")
    str = str.gsub(/円/, "")
    ipo.price = str.to_i

    # 仮条件カラム処理
    str = tr_body.xpath("td[6]").text
    str = str.gsub(/\s+/, "")
    str = str.gsub(/,/, "")
    str = str.gsub(/円/, "")
    dev_null, price = str.split("～").map { |s| s.to_i }
    ipo.price = price if (not price.nil?) and (price > 0)

    # 公募価格カラム処理
    str = tr_body.xpath("td[7]").text
    str = str.gsub(/,/, "")
    str = str.gsub(/円/, "")
    ipo.price = str.to_i if not str.to_i == 0

    # 狙い目証券カラム処理
    str = tr_body.xpath("td[10]").text.strip
    array_str = str.split(/\s+/)
    ipo.companies = array_str.map { |s| s.gsub(/（.*）/, "") }

    return ipo
  end
end
