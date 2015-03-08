class AppDelegate
  include CDQ

  def applicationDidFinishLaunching(_notification)
    cdq.setup
    true
  end
end
