module ApplicationHelper
  def default_meta_tags
    {
      site: "IPO まとめ",
      reverse: true,
      description: "IPO 情報をまとめています。自分の口座を登録することで申込状況を管理でき、IPO 申込忘れを防ぐことができます。",
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
