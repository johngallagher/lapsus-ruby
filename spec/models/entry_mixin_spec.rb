describe 'Entry Mixin' do
  it 'does something' do
    e = EntryDummy.new(name: 'John')
    e.greet.should == 'Hello John'
  end
end
