class DocumentGrabber
  MISSING_SCHEME = 'missingfile://'

  def activeDocument(bundleIdentifier)
    Document.new(url: NSURL.URLWithString(grabActiveDocumentUrl(bundleIdentifier)), 
                 bundleIdentifier: bundleIdentifier)
  end

  private
  def grabActiveDocumentUrl(bundleIdentifier)
    return MISSING_SCHEME if bundleIdentifier == NSRunningApplication.currentApplication.bundleIdentifier

    @script = NSAppleScript.alloc.initWithSource(sourceFromBundleIdentifier(bundleIdentifier))
    activeUrl = @script.executeAndReturnError(nil)

    if activeUrl && activeUrl.stringValue
      activeUrl.stringValue 
    else
      MISSING_SCHEME
    end
  end

  def sourceFromBundleIdentifier(bundleIdentifier)
    {
      'com.google.Chrome' => %Q[
        tell application "Google Chrome"
        	tell window 1
            tell active tab
              URL
            end tell
          end tell
        end tell
      ]
    }.fetch(bundleIdentifier) { defaultSourceFromBundleIdentifier(bundleIdentifier) }
  end

  def defaultSourceFromBundleIdentifier(bundleIdentifier)
    %Q[
        tell application "System Events"
          value of attribute "AXDocument" of (front window of the (first process whose bundle identifier is "#{bundleIdentifier}"))
        end tell 
    ]
  end
end

