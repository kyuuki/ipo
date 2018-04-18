# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
StockCompany.find_or_create_by(name: "SBI 証券", short_name: "SBI", regexp: "^SBI")
StockCompany.find_or_create_by(name: "SMBC 日興証券", short_name: "SMBC日興", regexp: "^SMBC")
StockCompany.find_or_create_by(name: "マネックス証券", short_name: "マネックス", regexp: "^マネックス")
StockCompany.find_or_create_by(name: "GMO 証券", short_name: "GMO", regexp: "^GMO")
StockCompany.find_or_create_by(name: "楽天証券", short_name: "楽天", regexp: "^楽天")
StockCompany.find_or_create_by(name: "岡三オンライン証券", short_name: "岡三", regexp: "^岡三")
StockCompany.find_or_create_by(name: "カブドットコム証券", short_name: "カブドットコム", regexp: "^(カブドットコム|カブコム)")
StockCompany.find_or_create_by(name: "大和証券", short_name: "大和", regexp: "^大和")
StockCompany.find_or_create_by(name: "ライブスター証券", short_name: "ライブスター", regexp: "^ライブスター")
StockCompany.find_or_create_by(name: "東海東京証券", short_name: "東海東京", regexp: "^東海東京")
StockCompany.find_or_create_by(name: "岩井コスモ証券", short_name: "岩井", regexp: "^岩井")
StockCompany.find_or_create_by(name: "むさし証券", short_name: "むさし", regexp: "^むさし")

