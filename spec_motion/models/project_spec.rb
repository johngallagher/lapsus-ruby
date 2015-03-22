describe Project do
  it "can create a blank project" do
    project = Project.create_none
    project.urlString.should.nil?
    project.type.should == 'none'
    project.name.should == "None"
  end

  it "can only create one blank project" do
    Project.create_none
    Project.create_none
    Project.count.should == 1
    Project.first.urlString.should.nil?
    Project.first.type.should == 'none'
    Project.first.name.should == "None"
  end

  it "defaults to a project" do
    Project.create.type.should == 'project'
  end
end
