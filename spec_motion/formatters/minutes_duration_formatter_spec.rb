describe MinutesDurationFormatter do
  it 'converts one hour one minute' do
    formatter.stringForObjectValue(3660).should == '1:01'
  end

  it 'converts one hour to zero minutes' do
    formatter.stringForObjectValue(3600).should == '1:00'
  end

  it 'converts two minutes to two minutes' do
    formatter.stringForObjectValue(120).should == '0:02'
  end

  it 'converts nearly two minutes to one minute' do
    formatter.stringForObjectValue(119).should == '0:01'
  end

  it 'converts a minute and a second' do
    formatter.stringForObjectValue(61).should == '0:01'
  end

  it 'converts a minute' do
    formatter.stringForObjectValue(60).should == '0:01'
  end

  it 'converts seconds to minutes' do
    formatter.stringForObjectValue(59).should == '0:00'
  end
end

def formatter
  MinutesDurationFormatter.new
end
