namespace :scraping do
  desc "Scrape site 1"
  task :site_1 => :environment do
    puts "Start scraping site 1."

    ScrapingSite1Service::call
  end

  desc "Scrape site 1 and update db"
  task :update_1 => :environment do
    message = "Task scraping:update_1 start."
    puts message
    SlackNotifier.notify(message)

    IpoCompany::update_1

    message = "Task scraping:update_1 end."
    puts message
    SlackNotifier.notify(message)
  end

  desc "Scrape site 2"
  task :site_2 => :environment do
    puts "Start scraping site 2."

    ScrapingSite2Service::call
  end

  desc "Scrape site 2 and update db"
  task :update_2 => :environment do
    message = "Task scraping:update_2 start."
    puts message
    SlackNotifier.notify(message)

    IpoCompany::update_2

    message = "Task scraping:update_2 end."
    puts message
    SlackNotifier.notify(message)
  end

  desc "Scrape site 3"
  task :site_3 => :environment do
    puts "Start scraping site 3."

    ScrapingSite3Service::call
  end

  desc "Scrape site 3 and update db"
  task :update_3 => :environment do
    message = "Task scraping:update_3 start."
    puts message
    SlackNotifier.notify(message)

    IpoCompany::update_3

    message = "Task scraping:update_3 end."
    puts message
    SlackNotifier.notify(message)
  end
end

