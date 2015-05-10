class MinutesDurationFormatter < NSFormatter
  def stringForObjectValue(seconds)
    minutes = (seconds.intValue / 60) % 60
    hours = seconds.intValue / 3600
    "#{hours}:%02d" % minutes
  end
end
