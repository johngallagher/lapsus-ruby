class SourceListController < NSViewController
  include CDQ
  extend IB

  outlet :outline_view, NSOutlineView
  outlet :table_view, NSTableView

  def add(sender)
    openDlg = NSOpenPanel.openPanel
    openDlg.canChooseFiles = false
    openDlg.canChooseDirectories = true
    if openDlg.runModal == NSOKButton
      selected_url = openDlg.URLs.first
      Container.create_from_url(selected_url)
      cdq.save
      reload
    end
  end

  def remove(sender)
    selected_object = outline_view.itemAtRow(outline_view.selectedRow)
    return if selected_object.nil?

    if selected_object.type == 'Container'
      selected_object.activities.each { |a| a.destroy }
      selected_object.destroy
      cdq.save
      reload
    end
  end

  def reload
    @containers = Container.all.to_a
    outline_view.reloadData
    table_view.reloadData
  end


  def awakeFromNib
    @all_projects ||= OpenStruct.new(name: 'PROJECTS', type: 'Group')
    @containers ||= Container.all.to_a
    super
  end

  def outlineView(outlineView, shouldSelectItem: item)
    item.type != 'Group'
  end

  def outlineView(outlineView, isGroupItem: item)
    item.type == 'Group'
  end

  def outlineView(outline_view, numberOfChildrenOfItem: item)
    if item.nil?
      1
    elsif item.type == 'Group'
      @containers.count
    else
      item.activities.to_a.count
    end
  end

  def outlineView(outline_view, isItemExpandable: item)
    item.type == 'Group' || item.type == 'Container'
  end
  
  def outlineView(outline_view, child: index, ofItem: item)
    if item.nil?
      @all_projects
    elsif item.type == 'Group'
      @containers[index]
    else
      item.activities.to_a[index]
    end
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
end
