class URIGrabber
  MISSING_FILE_URL = "missingfile://"

  def initialize(workspace)
    @lapsus_bundle_identifier = NSBundle.mainBundle.bundleIdentifier
    @workspace = workspace
  end

  def grab
    active_application = @workspace.frontmostApplication
    return MISSING_FILE_URL if active_application.bundleIdentifier == @lapsus_bundle_identifier

    source = source_from_application(active_application.bundleIdentifier, active_application.processIdentifier)
    active_uri = AppleScriptRunner.run(source)
    if active_uri && active_uri.stringValue
      standardised(active_uri.stringValue)
    else
      MISSING_FILE_URL
    end
  end

  def standardised(uri)
    standardised_uri = URI(uri)
    standardised_uri.host = "localhost" if !standardised_uri.host && standardised_uri.scheme == "file"
    standardised_uri.to_s
  end

  def source_from_application(bundle_identifier, process_identifier)
    if bundle_identifier == "com.google.Chrome"
      %( tell application "Google Chrome" to return URL of active tab of front window )
    elsif bundle_identifier == "com.apple.Safari"
      %( tell application "Safari" to return URL of front document )
    else
      %[ tell application "System Events" to return value of attribute "AXDocument" of (front window of (first process whose unix id is #{process_identifier})) ]
    end
  end
end

class AppleScriptRunner
  def self.run(source)
    NSAppleScript.alloc.initWithSource(source).executeAndReturnError(nil)
  end
end
