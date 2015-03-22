class IdleDetector
  IDLE_THRESHOLD = 30

  def self.idle?
    time_since_last_event >= IDLE_THRESHOLD
  end

  def self.time_since_last_event
    CGEventSourceSecondsSinceLastEventType(KCGEventSourceStateCombinedSessionState, KCGAnyInputEventType)
  end
end
