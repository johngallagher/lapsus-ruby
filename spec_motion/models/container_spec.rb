describe Container do
  it 'creates a container with projects under it' do
    url = NSURL.URLWithString("file://#{Dir.pwd}/spec_motion/fixtures/")
    Container.create_from_url(url)
    Container.count.should == 1
    Container.first.urlString.should == "file://#{Dir.pwd}/spec_motion/fixtures/"
    Container.first.url.should == NSURL.URLWithString("file://#{Dir.pwd}/spec_motion/fixtures/")
    Container.first.name.should == 'fixtures'
    Container.first.activities.count.should == 1
    Container.first.activities.first.name.should == 'project_directory'
    Container.first.activities.first.urlString.should == "file://#{Dir.pwd}/spec_motion/fixtures/project_directory/"
  end
end
