namespace :scraping do
  desc "Scraping update_1"
  task :update_1 => :environment do
    puts "Start scraping 1."

    # TODO: サービス化
    notifier = Slack::Notifier.new(Rails.application.secrets.slack_webhook_url,
                                   channel: "#random", username: "ipo-rails")
    notifier.ping "Start scraping 1."

    IpoCompany::update_1
  end

  desc "Scraping update_2"
  task :update_2 => :environment do
    puts "Start scraping 2."

    # TODO: サービス化
    notifier = Slack::Notifier.new(Rails.application.secrets.slack_webhook_url,
                                   channel: "#random", username: "ipo-rails")
    notifier.ping "Start scraping 2."

    IpoCompany::update_2
  end

  desc "Scraping update_3"
  task :update_3 => :environment do
    puts "Start scraping 3."

    # TODO: サービス化
    notifier = Slack::Notifier.new(Rails.application.secrets.slack_webhook_url,
                                   channel: "#random", username: "ipo-rails")
    notifier.ping "Start scraping 3."

    IpoCompany::update_3
  end
end

