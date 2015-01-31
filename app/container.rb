class Container < CDQManagedObject
  def container?
    true
  end

  def destroy
    projects.each { |p| p.destroy }
    super
  end
end
