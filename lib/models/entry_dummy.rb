require_relative "entry_mixin"
require "ostruct"

class EntryDummy < OpenStruct
  include EntryMixin
end
