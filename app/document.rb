class Document
  attr_accessor :url, :bundleIdentifier

  def initialize(attrs)
    @bundleIdentifier = attrs.fetch(:bundleIdentifier)
    @url = attrs.fetch(:url)
  end
end

