class DocumentGrabber
  attr_accessor :bundleIdentifier

  def initialize(bundleIdentifier)
    @bundleIdentifier = bundleIdentifier
    @script = NSAppleScript.alloc.initWithSource(DocumentGrabber.sourceFromBundleIdentifier(bundleIdentifier))
    @script.compileAndReturnError(nil)
  end

  def activeDocument
    Document.new(url: NSURL.URLWithString(grabActiveDocumentUrl), 
                 bundleIdentifier: self.bundleIdentifier)
  end

  private
  def grabActiveDocumentUrl
    return 'missingfile://' if @bundleIdentifier == NSRunningApplication.currentApplication.bundleIdentifier

    activeUrl = @script.executeAndReturnError(nil)
    (activeUrl && activeUrl.stringValue) ? activeUrl.stringValue : 'missingfile://'
  rescue => error
    puts "Error: #{error}"
    'missingfile://'
  end

  def self.sourceFromBundleIdentifier(bundleIdentifier)
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

  def self.defaultSourceFromBundleIdentifier(bundleIdentifier)
    %Q[
        tell application "System Events"
          value of attribute "AXDocument" of (front window of the (first process whose bundle identifier is "#{bundleIdentifier}"))
        end tell 
    ]
  end
end

