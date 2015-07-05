describe Activity do
  before do
    class << self
      include CDQ
    end

    cdq.setup
    cdq.reset!
    user_is_active
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
    Activity.first.attributes.should == { "urlString" => nil, "type" => Activity::NONE, "name" =>  Activity::NONE }
  end

  it "creates just one idle" do
    Activity.find_or_create_idle
    Activity.find_or_create_idle

    Activity.count.should == 1
    Activity.first.attributes.should == { "urlString" => nil, "type" => Activity::IDLE, "name" => Activity::IDLE }
  end

  it "defaults to a project" do
    Activity.create.type.should == Activity::PROJECT
  end

  it "returns the idle activity if the user is idle" do
    user_is_idle
    Activity.from_uri(NSURL.URLWithString("anything")).should == Activity.idle
  end

  it "returns no activity if there are no projects" do
    Activity.from_uri(NSURL.URLWithString("anything")).should == Activity.none
  end

  it "returns a last active activity if the active uri has http schema" do
    assume_a_project_exists

    Activity.from_uri(NSURL.URLWithString("http://www.google.co.uk")).last_active?.should == true
  end

  it "no activity for missing files" do
    assume_a_project_exists

    Activity.from_uri(URIGrabber::MISSING_FILE_URL).should == Activity.none
  end

  it "matches projects that contain the current uri" do
    assume_autoparts_project
  
    Activity.from_uri(autoparts_document_uri).should == @autoparts
  end

  it "assigns no activity to a non project file" do
    assume_autoparts_project

    Activity.from_uri(lapsus_file_uri).should == Activity.none
  end
  
  it "sorts activities by name" do
    assume_autoparts_project
    assume_lapsus_project

    Activity.by_name.map(&:name).should == ['Autoparts', 'Lapsus']
  end

  it "sums up all time" do
    assume_autoparts_project
    assume_lapsus_project
    add_time_to_lapsus

    @lapsus.time.should != 0
    @autoparts.time.should == 0
  end

  it "hides activities without time" do
    assume_autoparts_project
    assume_lapsus_project
    add_time_to_lapsus

    Activity.with_time.count.should == 1
    Activity.with_time.first.name.should == 'Lapsus'
  end
end

def add_time_to_lapsus
  entry = Entry.create(startedAt: 2.minutes.ago, finishedAt: 1.minute.ago)
  entry.update_duration
  @lapsus.entries << entry
end

def autoparts_document_uri
  NSURL.URLWithString("file://localhost/Users/John/Autoparts/main.rb")
end

def lapsus_file_uri
  NSURL.URLWithString("file://localhost/Users/John/Lapsus/main.rb")
end

def user_is_idle
  IdleDetector.stub!(:idle?, return: true)
end

def user_is_active
  IdleDetector.stub!(:idle?, return: false)
end

def assume_a_project_exists
  @autoparts = Activity.create(name: "Autoparts", urlString: "file://localhost/Users/John/Autoparts/")
end

def assume_autoparts_project
  @autoparts = Activity.create(name: "Autoparts", urlString: "file://localhost/Users/John/Autoparts/")
end

def assume_lapsus_project
  @lapsus = Activity.create(name: "Lapsus", urlString: "file://localhost/Users/John/Lapsus/")
end
