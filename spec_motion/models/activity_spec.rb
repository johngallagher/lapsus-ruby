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

  it "returns the idle project if the user is idle" do
    IdleDetector.stub!(:idle?, return: true)
    Activity.current.should == Activity.idle
  end
end
