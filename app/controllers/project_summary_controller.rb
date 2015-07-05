class ProjectSummaryController < NSViewController
  extend IB

  attr_accessor :selected_date_range

  outlet :range_selector, NSSegmentedCell
  outlet :date_selector, NSDatePicker
  outlet :table_view, NSTableView

  def awakeFromNib
    @projects ||= Activity.projects
    select_today
    super
  end

  def select_today
    self.date_selector.dateValue = NSDate.date.at_midnight
    self.date_selector.maxDate = NSDate.date.at_midnight
    select_date(self.date_selector)
  end
  
  def select_date(sender)
    change_date_to(sender.dateValue)
  end

  def change_date_to(selected_date)
    self.selected_date_range = (selected_date..selected_date.end_of_day)
    table_view.reloadData
  end

  def numberOfRowsInTableView(tableView)
    @projects.select { |p| p.time > 0 }.count
  end

  def tableView(tableView, viewForTableColumn: column, row: row)
    project = @projects.select { |p| p.time > 0 }[row]
    if column.identifier == "ProjectSummaryTimeColumn"
      cell = tableView.makeViewWithIdentifier("ProjectTime", owner: nil)
      cell.textField.stringValue = project.time_for(selected_date_range)
    else
      cell = tableView.makeViewWithIdentifier("ProjectIconAndName", owner: nil)
      cell.textField.stringValue = project.name
    end
    cell
  end
end
