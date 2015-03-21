class URIGrabber
  def self.grab
    bundle_identifier = NSWorkspace.sharedWorkspace.frontmostApplication.bundleIdentifier
    return "missingfile://" if bundle_identifier == lapsus_bundle_identifier

    active_uri = grab_active_uri_of(bundle_identifier)
    if active_uri && active_uri.stringValue
      active_uri.stringValue
    else
      "missingfile://"
    end
  end

  def self.lapsus_bundle_identifier
    NSRunningApplication.currentApplication.bundleIdentifier
  end

  def self.grab_active_uri_of(bundle_identifier)
    source = %[
      tell application "System Events"
         value of attribute "AXDocument" of (front window of the (first process whose bundle identifier is "#{bundle_identifier}"))
      end tell
    ]
    script = NSAppleScript.alloc.initWithSource(source)
    script.executeAndReturnError(nil)
  end
end
