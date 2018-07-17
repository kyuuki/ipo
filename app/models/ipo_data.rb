#
# IPO 情報
#
# * Rails に依存しないで汎用に使えること
#
require 'mechanize'
require 'nokogiri'

class IpoData
  attr_accessor :code, :company_name, :rank, :price, :companies,
                :date_listed, :date_apply_from, :date_apply_to, :date_drawing

  def initialize
    @code
    @company_name
    @rank
    @price = 0

    @date_listed
    @date_apply_from
    @date_apply_to
    @date_drawing

    @companies = []
  end

  def to_s
    str = "#{@date_listed} #{@date_apply_from} #{@date_apply_to} #{@date_drawing} #{@rank} #{@code} #{@company_name} #{@price}"
    @companies.each do |company|
        str << "\n  #{company}"
    end

    return str
  end
end
