# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])

def transaction_filler(account, categories, transaction_num, factor)
  (1..transaction_num).each do |_i|
    base_amount = rand(1..10) * rand(100..500)
    (0..1).each do |category_group_i|
      Transaction.create(amount: base_amount * (2 - category_group_i),
                         currency: account.currency, origin: account,
                         description: "desc #{SecureRandom.hex(15)}",
                         category: categories[category_group_i].sample)
    end
    account.liquid_balance += base_amount * factor
  end
end

category_down_names = ['Travel', 'Basic Services', 'Financial Debt',
                       'Food and Groceries', 'Entertainment',
                       'Surprise Expenses', 'Other']
category_up_names = %w[Salary Bonus Refund Gratification]
categories_data1 = category_down_names.map do |category_name_i|
  { name: category_name_i }
end
categories_data2 = category_up_names.map do |category_name_i|
  { name: category_name_i }
end

categories_down = Category.create(categories_data1)
categories_up = Category.create(categories_data2)
categories = [categories_up, categories_down]

user_data = (0..5).map do |num|
  {
    email: "user#{num}@gmail.com",
    password: '123456',
    admin: num.zero?
  }
end
users = User.create(user_data)

users.each do |user_i|
  account1 = CreditAccount.create(currency: 'CLP', user: user_i)
  account2 = CheckingAccount.create(currency: 'CLP', user: user_i)
  account3 = DebitAccount.create(currency: 'CLP', user: user_i)
  account1.save
  transaction_filler(account2, categories, rand(2..10), 1)
  account2.save
  transaction_filler(account3, categories, rand(2..10), 1)
  account3.save
end
