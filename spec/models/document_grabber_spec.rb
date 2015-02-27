class InMemoryRepo
  def initialize
    @entries = []
  end

  def create(entry)
    @entries << entry
  end

  def all
    @entries
  end
end

class ActiveDocumentTracker
  def initialize(repo, grabber)
    @repo, @grabber = repo, grabber
    @last_active_document = @grabber.grab
  end

  def update
    active_document = @grabber.grab
    if active_document != @last_active_document
      @repo.create(@last_active_document)
    end
  end
end

class ActiveUrlGrabber
  def grab
    'missingurl://'
  end
end

class Document
  attr_reader :url
  def initialize(url)
    @url = url
  end

  def self.active(active_url_grabber=ActiveUrlGrabber.new)
    url = active_url_grabber.grab
    Document.new(url)
  end

  def ==(other)
    @url == other.url
  end
end

class FakeDocumentGrabber
  attr_accessor :active_document

  def initialize(initial_document)
    @active_document = initial_document
  end

  def grab
    @active_document
  end
end

describe ActiveDocumentTracker do
  it 'when the document changes it creates an entry' do
    repo = InMemoryRepo.new
    document_grabber = FakeDocumentGrabber.new(Document.new('/Users/jg/app.rb'))
    tracker = ActiveDocumentTracker.new(repo, document_grabber)

    document_grabber.active_document = Document.new('/Users/jg/different.rb')
    tracker.update

    repo.all.count.should == 1
    repo.all.first.should == Document.new('/Users/jg/app.rb')
  end
end

describe Document do
  it 'has url' do
    Document.new('missingfile://').url.should == 'missingfile://'
  end

  it 'grabs the active document' do
    fake_document_grabber = OpenStruct.new(grab: '/Users/jg/app.rb')
    Document.active(fake_document_grabber).url.should ==  '/Users/jg/app.rb'
    Document.active.url.should == 'missingurl://'
  end
end
