# frozen_string_literal: true

# Filterable Module
module Filterable
  extend ActiveSupport::Concern

  # ClassMethods Module
  module ClassMethods
    def filter(filtering_params)
      results = where(nil)
      filtering_params.each do |key, value|
        if value.present?
          results = results.public_send("filter_by_#{key}", value)
        end
      end
      results
    end
  end
end
