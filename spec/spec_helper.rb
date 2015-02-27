running_with_rspec = defined? RSpec
if running_with_rspec
  Dir.glob(File.dirname(__FILE__) + '/../lib/**/*.rb').each { |f| require f }

  RSpec.configure do |config|
    config.expect_with :rspec do |c|
      c.syntax = :should
    end
    config.mock_with :rspec do |c|
      c.syntax = :should
    end
  end
end
