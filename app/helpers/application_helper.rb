module ApplicationHelper
  def default_meta_tags
    {
      site: "IPO まとめ",
      reverse: true,
      description: "2018 年度の IPO (新規公開株・新規上場株) のデータをまとめています。日付と価格、取扱証券会社をシンプルに一覧にしてあるので、IPO の内容や予定を簡単にチェックすることができます。ログインして自分の持っている証券口座を登録すれば、Web 上で申込状況を管理、確認することができます。一つの証券会社に対して複数の口座を登録できるので、家族の口座を開設している方はぜひユーザー登録して使ってみてください。申込忘れの防止や資金計画にぜひ有効にご活用ください。",
      keywords: [ "IPO", "株", "投資", "株主優待" ],
      canonical: request.original_url,
      og: {
        title: :title,
        type: "website",
        url: request.original_url,
        image: "http://res.cloudinary.com/kyuuki/image/upload/v1524128793/IPO.png",
        site_name: :site,
      },
      twitter: {
        card: "summary",
        site: "@kyuuki0",
        image: "http://res.cloudinary.com/kyuuki/image/upload/v1524128793/IPO.png",
      },
    }
  end
end
