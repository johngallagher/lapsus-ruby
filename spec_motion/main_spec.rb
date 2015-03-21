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
    autoparts_finish_time = autoparts_start_time + 2

    @app_delegate.uri_grabber.uri = 'file://Users/John/Autoparts/main.rb'
    @app_delegate.time_class.now = autoparts_start_time

    @app_delegate.tracker.update

    @app_delegate.uri_grabber.uri = 'file://Users/John/Lapsus/app.rb'
    @app_delegate.time_class.now = autoparts_finish_time

    @app_delegate.tracker.update

    Entry.count.should == 1
    first_entry = Entry.first
    first_entry.project.should == autoparts
    first_entry.startedAt.should == autoparts_start_time
    first_entry.finishedAt.should == autoparts_finish_time
    first_entry.duration.should == autoparts_finish_time - autoparts_start_time
  end
end
