require 'spec_helper'

class Entry < CDQManagedObject
end

describe 'Entry' do
  before do
    class << self
      include CDQ
    end

    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'accurately sets startedAt' do
    test_time = Time.new(2014, 6, 2, 0, 0, 0)
    10.times.each do
      Entry.create(startedAt: test_time).startedAt.should == test_time
      test_time = test_time + 1
    end
  end
end
