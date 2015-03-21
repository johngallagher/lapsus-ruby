class URIGrabber
  def self.grab
    bundle_identifier = NSWorkspace.sharedWorkspace.frontmostApplication.bundleIdentifier
    source = %Q[
      tell application "System Events"
         value of attribute "AXDocument" of (front window of the (first process whose bundle identifier is "#{bundle_identifier}"))
      end tell 
    ]
    script = NSAppleScript.alloc.initWithSource(source)
    active_url = script.executeAndReturnError(nil)
    if active_url && active_url.stringValue
      active_url.stringValue
    else
      'missingfile://'
    end
  end
end
