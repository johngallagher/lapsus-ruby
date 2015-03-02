class AppDelegate
  include CDQ
  attr_accessor :status_menu, :status_item, :tracker, :timer, :moc

  def applicationDidFinishLaunching(_notification)
    cdq.setup
    true
  end
end
