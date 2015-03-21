class Project < CDQManagedObject
  def self.create_none
    Project.create(name: 'None', none: true)
  end

  def none?
    if none == 1
      true
    else
      false
    end
  end
end
