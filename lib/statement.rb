require 'csv'
require 'money'
require "Date"

class Statement
  attr_accessor :dir
  def initialize (dir)
    @dir = dir
  end

  def hashify_checking
    checking_account_array = []
    Dir.foreach("#{dir}") do |file|
      next if file == '.' or file == '..'
      if file.include? "statement-checking"
        csv = CSV::parse(File.open("#{dir}/#{file}", 'r') { |f| f.read })
        fields = csv.shift
        checking_account_array += csv.collect { |record| Hash[*fields.zip(record).flatten] }
      end
    end
    checking_account_array
  end

  def hashify_credit
    credit_card_array = []
    Dir.foreach("#{dir}") do |file|
      next if file == '.' or file == '..'
      if file.include? "statement-credit"
        csv = CSV::parse(File.open("#{dir}/#{file}", 'r') { |f| f.read })
        fields = csv.shift
        credit_card_array += csv.collect { |record| Hash[*fields.zip(record).flatten] }
      end
    end
    credit_card_array
  end

  def non_credit_withdrawls(month)
    array = []
    total = 0
    hashify_checking.each do |trans|
      if  trans["Date"][0..6] == month
        array << trans
      end
    end
    array.reject! do |x|
      x["Description"] == "Payment CC"

    end
    array.reject! do |y|
      y["Debit"] == nil
    end

    array.each do |z|
      ammount_in_cents = z["Debit"].gsub(".", "").gsub(",", "").gsub("$", "")

      total += ammount_in_cents.to_i
    end
    total
  end

  def credit_card_purchases(month)
    array = []
    total = 0
    hashify_credit.each do |trans|
      if  trans["Date"][0..6] == month
        array << trans
      end
    end
    array.reject! do |x|
      x["Description"] == "Payment Thank You"

    end
    array.each do |z|
      ammount_in_cents = z["Amount"].gsub(".", "").gsub(",", "").gsub("$", "")
      total += ammount_in_cents.to_i
    end
    total
  end

  def deposits(month)
    array = []
    total = 0
    hashify_checking.each do |trans|
      if  trans["Date"][0..6] == month
        array << trans
      end
    end
    array.reject! do |y|
      y["Debit"] =~ /$/
    end
    array.each do |z|
      ammount_in_cents = z["Credit"].gsub(".", "").gsub(",", "").gsub("$", "")
      total += ammount_in_cents.to_i
    end
    total
  end

  def balance(start_month, end_month, year)
    result= []
    (start_month..end_month).each do |month|
      result << [year,
          Date::MONTHNAMES[month.to_i],
          Money.new(deposits("#{year}-#{month}") - (non_credit_withdrawls("#{year}-#{month}") + credit_card_purchases("#{year}-#{month}"))).format]
    end
    result
  end
end

