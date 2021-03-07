# frozen_string_literal: true

if Rails.env.development? || Rails.env.test?
  require 'rubocop/rake_task'
  require 'scss_lint/rake_task'
  require 'bundler/audit'

  RuboCop::RakeTask.new
  SCSSLint::RakeTask.new do |t|
    t.files = Dir.glob(['app/assets/stylesheets/**/*.scss'])
  end

  task audit: :environment do
    sh 'bundle-audit check --update'
  end
  task brakeman: :environment do
    sh 'brakeman -z -q'
  end
  task eslint: :environment do
    sh 'yarn eslint'
  end
  task erblint: :environment do
    sh 'bundle exec erblint --lint-all'
  end
  task linters: %i[rubocop erblint eslint scss_lint brakeman audit]
  task default: %i[linters]

end
