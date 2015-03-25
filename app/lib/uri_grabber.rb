class URIGrabber
  MISSING_FILE_URL = "missingfile://"

  def initialize(workspace)
    @lapsus_bundle_identifier = NSBundle.mainBundle.bundleIdentifier
    @workspace = workspace
  end

  def grab
    active_application = @workspace.frontmostApplication
    return MISSING_FILE_URL if active_application.bundleIdentifier == @lapsus_bundle_identifier

    source = source_from_application(active_application)
    active_uri = AppleScriptRunner.run(source)
    return MISSING_FILE_URL if !active_uri || !active_uri.stringValue

    standardised_uri = URI(active_uri.stringValue)
    standardised_uri.host = 'localhost' if !standardised_uri.host && standardised_uri.scheme == 'file'
    standardised_uri.to_s
  end

  def source_from_application(application)
    if application.bundleIdentifier == 'com.google.Chrome'
      %Q[ tell application "Google Chrome" to return URL of active tab of front window ]
    elsif application.bundleIdentifier == 'com.apple.Safari'
      %Q[ tell application "Safari" to return URL of front document ]
    else
      %Q[ tell application "System Events" to return value of attribute "AXDocument" of (front window of (first process whose unix id is #{application.processIdentifier})) ]
    end
  end
end

class AppleScriptRunner
  def self.run(source)
    NSAppleScript.alloc.initWithSource(source).executeAndReturnError(nil)
  end
end
