class SourceListController < NSViewController
  extend IB
  outlet :entries_controller, NSArrayController

  def add(sender)
    puts "Hit add"
  end

  def remove(sender)
    puts "Hit remove"
  end


  def awakeFromNib
    @all_projects ||= OpenStruct.new(name: 'PROJECTS', type: 'Group')
    @projects ||= Activity.projects
    super
  end

  def outlineView(outlineView, shouldSelectItem: item)
    item.type != 'Group'
  end

  def outlineView(outlineView, isGroupItem: item)
    item.type == 'Group'
  end

  def outlineView(outline_view, numberOfChildrenOfItem: item)
    Activity.projects.count
  end

  def outlineView(outline_view, isItemExpandable: item)
    item.type == 'Group'
  end
  
  def outlineView(outline_view, child: index, ofItem: item)
    if item
      @projects[index]
    else
      @all_projects
    end
  end

  def outlineView(outlineView, shouldExpandItem: item)
    true
  end

  def outlineView(outlineView, viewForTableColumn: column, item: object)
    if object.type == 'Group'
      cell = outlineView.makeViewWithIdentifier("TextCell", owner:self)
    else
      cell = outlineView.makeViewWithIdentifier("ImageAndTextCell", owner:self)
      cell.imageView.image = NSImage.imageNamed(NSImageNameFolder)
    end
    cell.textField.stringValue = object.name
    cell
  end

  def outlineViewSelectionDidChange(notification)
    outlineView = notification.object
    if outlineView.selectedRow == -1
      entries_controller.filterPredicate = nil
    else
      selected_project = outlineView.itemAtRow(outlineView.selectedRow)
      entries_controller.filterPredicate = NSPredicate.predicateWithFormat('activity == %@', selected_project)
    end
  end
end
