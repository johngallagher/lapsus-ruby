
describe URIGrabber do
  it "returns missing file if Lapsus is active" do
    assuming_active_application(bundle_identifier: NSBundle.mainBundle.bundleIdentifier)
    URIGrabber.new(@workspace).grab.should == URIGrabber::MISSING_FILE_URL
  end

  it "returns missing file if there was an error grabbing the window" do
    assuming_error_grabbing_active_uri
    assuming_active_application(bundle_identifier: 'com.notlapsus')
    URIGrabber.new(@workspace).grab.should == URIGrabber::MISSING_FILE_URL
  end

  it "returns the active uri" do
    lapsus_main = 'file://localhost/Users/Documents/Lapsus/main.rb'
    assuming_active_uri(lapsus_main)
    URIGrabber.new(@workspace).grab.should == lapsus_main
  end

  it "adds in localhost for the host if it's missing" do
    lapsus_main = 'file:///Users/Documents/Lapsus/main.rb'
    assuming_active_uri(lapsus_main)
    URIGrabber.new(@workspace).grab.should ==  'file://localhost/Users/Documents/Lapsus/main.rb'
  end

  it "uses correct Applescript for Google Chrome" do
    URIGrabber.new(@workspace).source_from_application(google_chrome).should == %Q[ tell application "Google Chrome" to return URL of active tab of front window ]
  end
end

def assuming_active_uri(uri)
  AppleScriptRunner.stub!(:run) { |source| OpenStruct.new(stringValue: uri) }
end

def assuming_error_grabbing_active_uri
  AppleScriptRunner.stub!(:run) { |source| nil }
end

def google_chrome
  OpenStruct.new(bundleIdentifier: 'com.google.Chrome')
end

def assuming_active_application(opts)
  frontmostApplication = OpenStruct.new(bundleIdentifier: opts.fetch(:bundle_identifier), processIdentifier: opts.fetch(:process_identifier, '1234'))
  @workspace = OpenStruct.new(frontmostApplication: frontmostApplication)
end
