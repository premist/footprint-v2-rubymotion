class MainController < UIViewController
  extend IB

  def hello
    puts "Hello from modal!"
  end

  def viewDidLoad
    manager.after_authorize = lambda do |authorized|
      if authorized
        puts "Authorized"
        # location_button.setTitle("Thanks!", forState: UIControlStateNormal)
      else
        puts "Not Authorized"
        # location.button.setTitle("No thanks!", forState: UIControlStateNormal)
      end
    end

    manager.authorize!
  end

  # IB Outlets
  outlet :location_button
  outlet :swarm_checkin_button

  # IB methods
  def authorize_location(sender)
    manager.authorize!
  end

  def swarm_checkin(sender)
    open_checkin_screen
  end

  def open_checkin_screen
    Dispatch.once { performSegueWithIdentifier("open_checkin_screen", sender: self) }
  end

  private

  def firebase
    Dispatch.once {
      @firebase ||= Firebase.alloc.initWithUrl(App::Env["FIREBASE_URL"])
    }
  end

  def manager
    Dispatch.once {
      @manager ||= Locman::Manager.new(
        background: false,
        distance_filter: 20
      )
    }

    @manager
  end
end
