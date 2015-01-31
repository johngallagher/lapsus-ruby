class Project < CDQManagedObject
  def container?
    false
  end

  def url
    NSURL.URLWithString(urlString)
  end

  def url_scheme
    url.scheme
  end

  def urlPathComponents
    url.pathComponents
  end
end

