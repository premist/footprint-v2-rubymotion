class CheckinController < UITableViewController
  extend IB

  def viewDidLoad
    self.refreshControl = UIRefreshControl.new
    self.refreshControl.backgroundColor = "#eee".uicolor
    self.refreshControl.tintColor = "#222".uicolor
    self.refreshControl.addTarget(self, action: "update_view", forControlEvents: UIControlEventValueChanged)

    manager.authorize!

    self.refreshControl.beginRefreshing
    update_view
  end

  def update_view
    manager.on_update = lambda do |locations|
      manager.stop_update!

      if locations == nil
         locations.first == nil ||
         locations.first.latitude == nil ||
         locations.first.longitude == nil
        self.refreshControl.endRefreshing
        SVProgressHUD.showErrorWithStatus("Can't get location.")
        return
      end

      foursquare.get_venues({ latitude: locations.first.latitude, longitude: locations.first.longitude }) do |venues|
        @venues = venues.map do |v|
           { name: v["name"], address: v["location"]["formattedAddress"][0], id: v["id"] }
        end

        @cells = []
        @cells_count = nil

        tableView.reloadData
        self.refreshControl.endRefreshing
      end

    end

    manager.update!
  end

  def close_view
    dismissViewControllerAnimated(true, completion: nil)
  end

  def tableView(tableView, estimatedHeightForRowAtIndexPath: indexPath)
    UITableViewAutomaticDimension
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @cells_count ||= venues.count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(
      "CheckinVenueCell",
      forIndexPath: indexPath
    )

    venue = venues[indexPath.row]
    return cell if !cell.nil? && cell.name_label.text == venue[:name] && cell.address_label.text == venue[:address]

    cell.name_label.text = venue[:name]
    cell.address_label.text = venue[:address]

    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    venue = venues[indexPath.row]
    puts "#{venue[:name]} touched"
    @venue = venue
    performSegueWithIdentifier("open_posting_screen", sender: self)
  end

  def prepareForSegue(segue, sender: sender)
    if segue.identifier == "open_posting_screen"
      segue.destinationViewController.venue = @venue
    end
  end

  private

  def venues
    @venues ||= []
  end

  def foursquare
    @foursquare ||= Foursquare.new
  end

  def manager
    @manager ||= Locman::Manager.new(
      background: false,
      distance_filter: 20
    )
  end
end
