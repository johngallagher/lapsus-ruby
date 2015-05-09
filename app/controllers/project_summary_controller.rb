class ProjectSummaryController < NSViewController
  extend IB

  attr_accessor :selected_date_range

  outlet :range_selector, NSSegmentedCell
  outlet :date_selector, NSDatePicker
  outlet :table_view, NSTableView

  def awakeFromNib
    select_date(self.date_selector)
  end
  
  def select_date(sender)
    selected_date = sender.dateValue
    self.selected_date_range = (selected_date..selected_date.end_of_day)
    table_view.reloadData
  end

  def numberOfRowsInTableView(tableView)
    Activity.projects.count
  end

  def tableView(tableView, viewForTableColumn: column, row: row)
    project = Activity.projects[row]
    if column.identifier == "ProjectSummaryTimeColumn"
      cell = tableView.makeViewWithIdentifier("ProjectTime", owner: self)
      cell.textField.stringValue = project.time_for(selected_date_range)
    else
      cell = tableView.makeViewWithIdentifier("ProjectIconAndName", owner: self)
      cell.textField.stringValue = project.name
    end
    cell
  end
end
