class URIGrabber
  MISSING_FILE_URL = "missingfile://"

  def initialize(workspace, current_application)
    @current_application = current_application
    @workspace = workspace
  end

  def grab
    frontmost_application = @workspace.frontmostApplication
    return MISSING_FILE_URL if frontmost_application.bundleIdentifier == lapsus_bundle_identifier

    source = source_from_application(frontmost_application)
    active_uri = AppleScriptRunner.run(source)
    if active_uri && active_uri.stringValue
      standardised_uri = URI(active_uri.stringValue)
      standardised_uri.host = 'localhost' if standardised_uri.host.nil? && standardised_uri.scheme == 'file'
      standardised_uri.to_s
    else
      MISSING_FILE_URL
    end
  end

  def lapsus_bundle_identifier
    @current_application.bundleIdentifier
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
