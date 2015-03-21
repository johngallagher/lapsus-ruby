class DbSeeder
  def initialize(cdq)
    @cdq = cdq
  end

  def seed
    Project.create_none
    @cdq.save
  end
end

class LapsusApp
  def initialize(cdq)
    @tracker = ActiveDocumentTracker.new(cdq)
    DbSeeder.new(cdq).seed
  end

  def update_active_document
    @tracker.update
  end
end

class AppDelegate
  include CDQ

  def applicationDidFinishLaunching(_notification)
    cdq.setup

    @lapsus_app = LapsusApp.new(cdq)

    if RUBYMOTION_ENV != "test"
      @timer = EM.add_periodic_timer 1.0 do
        @lapsus_app.update_active_document
      end
    end
    true
  end
end
