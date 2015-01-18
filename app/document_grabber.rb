class DocumentGrabber
  def initialize(bundleIdentifier)
    @bundleIdentifier = bundleIdentifier
    source = %Q[
      tell application "System Events"
        value of attribute "AXDocument" of (front window of the (first process whose bundle identifier is "#{bundleIdentifier}"))
      end tell
    ]
    @script = NSAppleScript.alloc.initWithSource(source)
    @script.compileAndReturnError(nil)
  end

  def activeDocument
    Document.new(url: NSURL.URLWithString(grabActiveDocumentUrl), bundleIdentifier: @bundleIdentifier)
  end

  private
  def grabActiveDocumentUrl
    activeUrl = @script.executeAndReturnError(nil)
    (activeUrl && activeUrl.stringValue) ? activeUrl.stringValue : 'missingfile://'
  end
end

