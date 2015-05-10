class ProjectSummaryController < NSViewController
  extend IB

  attr_accessor :selected_date_range

  outlet :range_selector, NSSegmentedCell
  outlet :date_selector, NSDatePicker
  outlet :table_view, NSTableView

  def awakeFromNib
    @projects = Activity.projects
    select_date(self.date_selector)
    super
  end
  
  def select_date(sender)
    selected_date = sender.dateValue
    self.selected_date_range = (selected_date..selected_date.end_of_day)
    table_view.reloadData
  end

  def numberOfRowsInTableView(tableView)
    @projects.to_a.count
  end

  def tableView(tableView, viewForTableColumn: column, row: row)
    project = @projects[row]
    if column.identifier == "ProjectSummaryTimeColumn"
      cell = tableView.makeViewWithIdentifier("ProjectTime", owner: self)
      #cell.textField.formatter = MinutesDurationFormatter.new
      #cell.textField.objectValue = project.time_for(selected_date_range)
      cell.textField.stringValue = project.time_for(selected_date_range)
    else
      cell = tableView.makeViewWithIdentifier("ProjectIconAndName", owner: self)
      cell.textField.stringValue = project.name
    end
    cell
  end
end
