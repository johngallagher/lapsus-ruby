class MainWindowController < NSWindowController
  include CDQ

  def windowDidLoad
    @outlineView = window.contentView.viewWithTag(1)
  end

  def outlineView(outlineView, child: childIndex, ofItem: item)
    if item.nil?
      Container.all[childIndex]
    elsif item.container?
      item.projects[childIndex]
    end
  end

  def outlineView(outlineView, isItemExpandable: item)
    item && item.container? && item.projects.count > 0
  end

  def outlineView(outlineView, numberOfChildrenOfItem: item)
    if item.nil?
      Container.count
    elsif item.container?
      item.projects.count
    end
  end

  def outlineView(outlineView, viewForTableColumn: tableColumn, item: item)
    tableCellView = outlineView.makeViewWithIdentifier('DataCell', owner: self)
    tableCellView.textField.stringValue = item.name
    tableCellView
  end

  def addContainer(object)
    openDlg = NSOpenPanel.openPanel
    openDlg.canChooseFiles = false
    openDlg.canChooseDirectories = true
    if openDlg.runModal == NSOKButton
      openDlg.URLs.each do |filename|
        manager = NSFileManager.defaultManager
        selectedFolderURL = openDlg.URLs.first
        container = Container.create(name: selectedFolderURL.lastPathComponent,
                                     path: selectedFolderURL.absoluteString)
        urls = manager.contentsOfDirectoryAtURL(selectedFolderURL,
                                                includingPropertiesForKeys: [NSURLPathKey, NSURLIsDirectoryKey],
                                                options: 0,
                                                error: nil)
        directories = urls.select do |url|
          directoryPointer = Pointer.new(:object)
          url.getResourceValue(directoryPointer, forKey: NSURLIsDirectoryKey, error: nil)
          directoryPointer[0]
        end

        projects = directories.map do |directory|
          Project.create(name: directory.lastPathComponent, 
                         urlString: directory.absoluteString)
        end

        projects.each do |project|
          container.projects << project
        end

        cdq.save
        @outlineView.reloadData
      end
    end
  end
end
