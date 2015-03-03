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
  def initialize(repo, grabber, idle_detector)
    @repo, @grabber, @idle_detector = repo, grabber, idle_detector
  end

  def update(date_time_class = Time)
    active_document_uri = @grabber.grab.uri

    if !@active_document
      @active_document = Document.new(active_document_uri)
      @active_document.start(date_time_class)
    elsif active_document_uri != @active_document.uri
      @active_document.finish(date_time_class)
      @repo.create(@active_document)
    end
  end
end

class Document
  attr_reader :uri, :started, :finished, :duration
  def initialize(uri)
    @uri = uri
  end

  def start(date_time_class = Time)
    @started = date_time_class.now
  end

  def finish(date_time_class = Time)
    @finished = date_time_class.now
    @duration = @finished - @started
  end

  def ==(other)
    @uri == other.uri
  end
end

class FakeDocumentGrabber
  attr_accessor :active_document

  def grab
    @active_document
  end
end

class FakeDate
  attr_accessor :now
end

class IdleDetector
  attr_writer :user_is_idle

  def user_is_idle?
    @user_is_idle
  end
end

describe ActiveDocumentTracker do
  before do
    @idle_detector = IdleDetector.new
    @repo = InMemoryRepo.new
    @document_grabber = FakeDocumentGrabber.new
    @tracker = ActiveDocumentTracker.new(@repo, @document_grabber, @idle_detector)
    @fake_date = FakeDate.new
  end

  def active_document_path_is(path)
    @document_grabber.active_document = Document.new(path)
  end

  def time_is(time)
    @fake_date.now = time
  end

  it "when the document stays the same it doesn't create a new document" do
    active_document_path_is("/document_1.rb")
    @tracker.update

    active_document_path_is("/document_1.rb")
    @tracker.update

    @repo.all.count.should == 0
  end

  it "when the document changes it creates an entry" do
    start_time = Time.parse('2014-01-01 11:00')
    finish_time = Time.parse('2014-01-01 11:01')
    time_is(start_time)
    active_document_path_is("/document_1.rb")
    @tracker.update(@fake_date)

    time_is(finish_time)
    active_document_path_is("/document_2.rb")
    @tracker.update(@fake_date)

    @repo.all.count.should == 1
    @repo.all.first.uri.should == "/document_1.rb"
    @repo.all.first.started.should == start_time
    @repo.all.first.finished.should == finish_time
    @repo.all.first.duration.should == 60
  end
end
