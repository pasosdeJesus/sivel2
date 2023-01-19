# frozen_string_literal: true

SimpleCov.formatters = [
  SimpleCov::Formatter::SimpleFormatter,
  SimpleCov::Formatter::HTMLFormatter,
]

SimpleCov.coverage_dir("coverage")
if ENV["CONFIG_HOSTS"] == "www.example.com"
  SimpleCov.coverage_dir("cobertura-unitarias")
elsif ENV["CONFIG_HOSTS"] == "127.0.0.1"
  SimpleCov.coverage_dir("cobertura-sistema")
end

SimpleCov.start do
  enable_coverage :branch
  primary_coverage :branch
  enable_coverage_for_eval
  filters.clear # This will remove default :root_filter and :bundler_filter
  add_filter do |src|
    !(src.filename =~ /^#{SimpleCov.root}/) unless src.filename =~ /msip/
  end
  add_filter "/test/"
end
