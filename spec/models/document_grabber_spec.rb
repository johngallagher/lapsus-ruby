class InMemoryRepo
  def initialize
    @entries = []
  end

  def create entry
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

  def == other
    @url == other.url
  end
end

class FakeDocumentGrabber
  attr_accessor :active_document

  def grab
    @active_document
  end
end

describe ActiveDocumentTracker do
  before do
    @repo = InMemoryRepo.new
    @document_grabber = FakeDocumentGrabber.new
    @tracker = ActiveDocumentTracker.new(@repo, @document_grabber)
  end

  def active_document_path_is(path)
    @document_grabber.active_document = Document.new(path)
  end

  it "when the document stays the same it doesn't create a new document" do
    active_document_path_is("/document_1.rb")
    @tracker.update

    active_document_path_is("/document_1.rb")
    @tracker.update

    @repo.all.count.should == 0
  end

  it "when the document changes it creates an entry" do
    active_document_path_is("/document_1.rb")
    @tracker.update

    active_document_path_is("/document_2.rb")
    @tracker.update

    @repo.all.count.should == 1
    @repo.all.first.should == Document.new("/document_1.rb")
  end
end
