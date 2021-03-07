# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "example_#{n}@gmail.com" }
    password { 'pass12345' }
  end
end
