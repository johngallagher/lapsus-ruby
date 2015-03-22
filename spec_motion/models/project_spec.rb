describe Project do
  before do
    class << self
      include CDQ
    end

    cdq.setup
  end

  after do
    cdq.reset!
  end

  it "can create a blank project" do
    project = Project.create_none
    project.attributes.should == { "urlString" => nil, "type" => 'none', "name" => 'None' }
  end

  it "can only create one blank project" do
    Project.create_none
    Project.create_none

    Project.count.should == 1
    Project.first.attributes.should == { "urlString" => nil, "type" => 'none', "name" => 'None' }
  end

  it "creates an idle project" do
    Project.create_idle
    Project.create_idle

    Project.count.should == 1
    Project.first.attributes.should == { "urlString" => nil, "type" => 'idle', "name" => 'Idle' }
  end

  it "defaults to a project" do
    Project.create.type.should == 'project'
  end
end
