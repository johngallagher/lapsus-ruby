class SourceListController < NSViewController
  extend IB

  def add(sender)
    puts "Hit add"
  end

  def remove(sender)
    puts "Hit remove"
  end


  def awakeFromNib
    @all_projects ||= OpenStruct.new(name: 'All Projects', type: 'All')
    @projects ||= Activity.projects
    super
  end

  def outlineView(outline_view, numberOfChildrenOfItem: item)
    if item
      Activity.projects.count
    else
      1
    end
  end

  def outlineView(outline_view, isItemExpandable: item)
    item.type == 'All'
  end
  
  def outlineView(outline_view, child: index, ofItem: item)
    if item
      @projects[index]
    else
      @all_projects
    end
  end

  def outlineView(outlineView, viewForTableColumn: column, item: object)
    cell = outlineView.makeViewWithIdentifier("ImageAndTextCell", owner:self)
    cell.textField.stringValue = object.name
    cell
  end
  #def outlineView(outlineView, isGroupItem:item)
    #false
  #end

  #def outlineView(outline_view, isItemExpandable:item)
    #true
  #end
end
