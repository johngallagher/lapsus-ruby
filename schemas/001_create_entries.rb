schema "001" do
  entity "Entry" do
    datetime :startedAt
    datetime :finishedAt
    integer64 :duration

    belongs_to :activity
  end

  entity "Activity" do
    string :name
    string :urlString
    string :type, default: "Project"

    has_many :entries
    belongs_to :container
  end

  entity "Container" do
    string :name
    string :urlString
    string :type, default: "Container"

    has_many :activities
  end
end
