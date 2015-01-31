schema "002" do
  entity "Event" do
    datetime  :happenedAt
    string    :url
    string    :application_bundle_id
    string    :application_name
    string    :type
  end

  entity "Entry" do
    datetime   :startedAt
    datetime   :finishedAt

    integer64    :duration

    belongs_to :project
  end

  entity "Project" do
    string     :name
    string     :path

    has_many   :entries
    belongs_to :container
  end

  entity "Container" do
    string   :name
    string   :path

    has_many :projects
  end
end
