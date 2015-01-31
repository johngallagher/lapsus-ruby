class Document
  attr_accessor :url, :bundleIdentifier

  def initialize(attrs)
    @bundleIdentifier = attrs.fetch(:bundleIdentifier)
    @url = attrs.fetch(:url)
  end

  def urlPathComponents
    puts "Url is #{@url.absoluteString}"
    if @url.pathComponents.nil?
      []
    else
      @url.pathComponents
    end
  end
end

