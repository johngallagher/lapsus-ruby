class URIGrabber
  MISSING_FILE_URL = "missingfile://"

  def self.grab
    frontmost_application = NSWorkspace.sharedWorkspace.frontmostApplication
    return MISSING_FILE_URL if frontmost_application.bundleIdentifier == lapsus_bundle_identifier

    active_uri = grab_active_uri_of(frontmost_application)
    if active_uri && active_uri.stringValue
      active_uri.stringValue
    else
      MISSING_FILE_URL
    end
  end

  def self.lapsus_bundle_identifier
    NSRunningApplication.currentApplication.bundleIdentifier
  end

  def self.grab_active_uri_of(application)
    source = source_from_application(application)
    script = NSAppleScript.alloc.initWithSource(source)
    script.executeAndReturnError(nil)
  end

  def self.source_from_application(application)
    if application.bundleIdentifier == 'com.google.Chrome'
      %Q[ tell application "Google Chrome" to return URL of active tab of front window ]
    elsif application.bundleIdentifier == 'com.apple.Safari'
      %Q[ tell application "Safari" to return URL of front document ]
    else
      %Q[ tell application "System Events" to return value of attribute "AXDocument" of (front window of (first process whose unix id is #{application.processIdentifier})) ]
    end
  end
end
