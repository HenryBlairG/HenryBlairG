# frozen_string_literal: true

# Currency ControllerConcern
module CurrencyControllerConcern
  extend ActiveSupport::Concern

  included do
    helper_method :get_exchange
  end

  def get_exchange(origin_currency, target_currency)
    if origin_currency != target_currency
      exchange_rates[origin_currency][target_currency]
    else
      1
    end
  end

  private

  def exchange_rates
    { 'CLP' => { 'USD' => 0.8 }, 'USD' => { 'CLP' => 1.25 } }
  end
end
