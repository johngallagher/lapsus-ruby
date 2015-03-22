schema "001" do
  entity "Entry" do
    datetime :startedAt
    datetime :finishedAt

    integer64 :duration

    belongs_to :project
  end

  entity "Project" do
    string :name
    string :urlString
    string :type, default: "project"

    has_many :entries
    belongs_to :container
  end

  entity "Container" do
    string :name
    string :path

    has_many :projects
  end
end
