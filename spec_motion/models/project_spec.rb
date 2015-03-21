describe Project do
  it "can create a blank project" do
    project = Project.create_none
    project.urlString.should.nil?
    project.none.should == 1
    project.name.should == "None"
    project.none?.should == true
  end

  it "can only create one blank project" do
    Project.create_none
    Project.create_none
    Project.count.should == 1
  end

  it "defaults none to false" do
    Project.create.none.should == 0
    Project.create.none?.should == false
  end
end
