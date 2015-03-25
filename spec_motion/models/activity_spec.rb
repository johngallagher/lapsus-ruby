describe Activity do
  before do
    class << self
      include CDQ
    end

    cdq.setup
    cdq.reset!
  end

  after do
    cdq.reset!
  end

  it "finds projects" do
    Activity.create(name: "Careers")
    Activity.create(name: "Autoparts")
    Activity.projects.map(&:name).should == %w(Autoparts Careers)
  end

  it "creates just one off project" do
    Activity.find_or_create_none
    Activity.find_or_create_none

    Activity.count.should == 1
    Activity.first.attributes.should == { "urlString" => nil, "type" => "none", "name" => "None" }
  end

  it "creates just one idle" do
    Activity.find_or_create_idle
    Activity.find_or_create_idle

    Activity.count.should == 1
    Activity.first.attributes.should == { "urlString" => nil, "type" => "idle", "name" => "Idle" }
  end

  it "defaults to a project" do
    Activity.create.type.should == "project"
  end

  it "returns the idle activity if the user is idle" do
    IdleDetector.stub!(:idle?, return: true)
    Activity.current_from_active_uri("anything").should == Activity.idle
  end

  it "returns no activity if there are no projects" do
    IdleDetector.stub!(:idle?, return: false)
    Activity.current_from_active_uri("anything").should == Activity.none
  end

  it "returns a last active activity if the active uri has http schema" do
    Activity.create(name: "Lapsus", urlString: "file://localhost/Users/j/lapsus")
    IdleDetector.stub!(:idle?, return: false)
    URIGrabber.stub!(:grab, return: "http://www.google.co.uk")

    current = Activity.current_from_active_uri("http://www.google.co.uk")
    current.previous?.should == true
  end

  it "returns none if uri starts with missing file schema" do
    Activity.create(name: "Lapsus", urlString: "file://localhost/Users/j/lapsus")
    IdleDetector.stub!(:idle?, return: false)

    current = Activity.current_from_active_uri(URIGrabber::MISSING_FILE_URL)
    current.should == Activity.none
  end

  it "matches projects that contain the current uri" do
    lapsus = Activity.create(name: "Lapsus", urlString: "file://localhost/Users/j/lapsus")
    IdleDetector.stub!(:idle?, return: false)

    current = Activity.current_from_active_uri("file://localhost/Users/j/lapsus/main.rb")
    current.should == lapsus
  end

  it "gives a current activity of none for a non project file" do
    Activity.create(name: "Lapsus", urlString: "file://localhost/Users/j/lapsus")
    IdleDetector.stub!(:idle?, return: false)

    current = Activity.current_from_active_uri("file://localhost/Users/j/Autoparts/main.rb")
    current.should == Activity.none
  end
end
