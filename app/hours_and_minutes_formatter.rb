class HoursAndMinutesFormtter < NSFormatter
  def stringForObjectValue(number)
    puts "Number was #{number.intValue}"
    as_hours_and_minutes_and_seconds(number.intValue)
  end

  def as_hours_and_minutes_and_seconds(total_seconds)
    seconds = total_seconds % 60
    minutes = (total_seconds / 60) % 60
    hours = total_seconds / (60 * 60)
    format('%d:%02d:%02d', hours, minutes, seconds)
  end
end

