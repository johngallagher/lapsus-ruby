describe Container do
  it 'creates a container with projects under it' do
    url = NSURL.URLWithString("file://#{Dir.pwd}/spec_motion/fixtures/")
    Container.create_from_url(url)
    Container.count.should == 1
    Container.first.urlString.should == 'file:///Users/johngallagher/Dropbox/Projects/ProgrammingProjects/CurrentProjects/lapsus/spec_motion/fixtures/'
    Container.first.url.should == NSURL.URLWithString('file:///Users/johngallagher/Dropbox/Projects/ProgrammingProjects/CurrentProjects/lapsus/spec_motion/fixtures/')
    Container.first.name.should == 'fixtures'
    Container.first.activities.count.should == 1
    Container.first.activities.first.name.should == 'dummy_project_1'
    Container.first.activities.first.urlString.should == 'file:///Users/johngallagher/Dropbox/Projects/ProgrammingProjects/CurrentProjects/lapsus/spec_motion/fixtures/dummy_project_1/'
  end
end
