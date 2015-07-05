class Container < CDQManagedObject
  def self.create_from_url(url)
    container = Container.create(name: url.lastPathComponent, urlString: url.absoluteString)
    directories_in(url).each do |directory|
      Activity.create(name: directory.lastPathComponent, urlString: directory.absoluteString, container: container)
    end
    container
  end

  def self.directories_in(url)
    contents_of(url).select do |file_url|
      directoryPointer = Pointer.new(:object)
      file_url.getResourceValue(directoryPointer, forKey: NSURLIsDirectoryKey, error: nil)
      directoryPointer[0]
    end
  end

  def self.contents_of(url)
    NSFileManager.defaultManager.contentsOfDirectoryAtURL(url,
                                                          includingPropertiesForKeys: [NSURLPathKey, NSURLIsDirectoryKey],
                                                          options: 0,
                                                          error: nil)
  end

  def url
    NSURL.URLWithString(urlString)
  end

  def activities_with_time
    activities.sort_by { |a| a.name.downcase }.select { |a| a.time > 0 }
  end
end
