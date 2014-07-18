require 'rspec'
require 'statement'


describe "Account" do
  it "can create an array of transcations from a checking account statement" do
    balance = Statement.new("spec/fixtures")
    expect(balance.hashify_checking).to eq([
        {"Date" => "2014-04-06",
            "Description" => "Check #1077",
            "Credit" => nil,
            "Debit" => "$60.00"},
        {"Date" => "2014-04-30",
            "Description" => "Deposit ATM",
            "Credit" => "$3,000.00",
            "Debit" => nil}])
  end

  it "can create an array of transcations from a credit card statement" do
    balance = Statement.new("spec/fixtures")
    expect(balance.hashify_credit).to eq([
        {"Date" => "2014-04-01",
            "Description" => "Sleek Cotton Shirt",
            "Amount" => "$94.79"},
        {"Date" => "2014-04-01",
            "Description" => "Gorgeous Cotton Chair",
            "Amount" => "$8.82"},])
  end

  it "can return the non-credit withdrawls from the cheking account statement for a given month" do
    balance = Statement.new("spec/fixtures")
    expect(balance.non_credit_withdrawls("2014-04")).to eq(6000)
  end

  it "can return the credit card purchases from the credit card statement given a month" do
    balance = Statement.new("spec/fixtures")
    expect(balance.credit_card_purchases("2014-04")).to eq(10361)
  end

  it "returns the deposits from the checking accuont statements for a given month" do
    balance = Statement.new("spec/fixtures")
    expect(balance.deposits("2014-04")).to eq(300000)

  end

  it "returns the balances of cheking accounnt statements and credit card statements for a given time from" do
    balance = Statement.new("spec/fixtures")
    expect(balance.balance("04", "04", "2014")).to eq([["2014", "April", "$2,836.39"]])
  end

  it "returns the baances from a given time frame from a data directory" do
    balance = Statement.new("data")
    expect(balance.balance("01", "06", "2014")).to eq([
        ["2014", "January", "$374.94"],
        ["2014", "February", "$30.79"],
        ["2014", "March", "$-106.04"],
        ["2014", "April", "$292.38"],
        ["2014", "May", "$-37.62"],
        ["2014", "June", "$-71.33"]]
    )
  end
end