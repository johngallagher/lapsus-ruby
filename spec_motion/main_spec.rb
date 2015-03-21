require 'spec_helper'

describe 'application' do
  before do
    @app = NSApplication.sharedApplication
    @app_delegate = @app.delegate
  end

  it 'records active documents' do
    @app_delegate.idle_detector.idle = false
    autoparts = Project.create(name: 'Autoparts', urlString: 'file://Users/John/Autoparts')
    autoparts_start_time = Time.new(2014, 6, 2, 0, 0, 0)

    @app_delegate.uri_grabber.uri = 'file://Users/John/Autoparts/main.rb'
    Time.stub!(:now, return: autoparts_start_time)

    @app_delegate.tracker.update

    @app_delegate.uri_grabber.uri = 'file://Users/John/Lapsus/app.rb'
    Time.stub!(:now, return: autoparts_start_time + 2)

    @app_delegate.tracker.update

    Entry.count.should == 1
    first_entry = Entry.first
    first_entry.project.should == autoparts
    first_entry.startedAt.should == autoparts_start_time
    first_entry.finishedAt.should == autoparts_start_time + 2
    first_entry.duration.should == 2
  end
end
