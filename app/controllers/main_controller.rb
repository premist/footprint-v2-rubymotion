class MainController < UIViewController
  extend IB

  def hello
    puts "Hello from modal!"
  end

  def viewDidLoad
    manager.after_authorize = lambda do |authorized|
      if authorized
        puts "Authorized"
      else
        puts "Not Authorized"
      end
    end

    manager.authorize!

    if firebase.authData != nil
      login.setTitle("로그아웃", forState: UIControlStateNormal)
    end
  end

  # IB Outlets
  outlet :location_button
  outlet :swarm_checkin_button
  outlet :login
  outlet :connect_foursquare
  outlet :connect_twitter

  # IB methods
  def authorize_location(sender)
    manager.authorize!
  end

  def swarm_checkin(sender)
    open_checkin_screen
  end

  def open_checkin_screen
    performSegueWithIdentifier("open_checkin_screen", sender: self)
  end

  def open_login_screen
    if firebase.authData != nil
      firebase.unauth
      SVProgressHUD.showSuccessWithStatus("Logged out")
      login.setTitle("로그인", forState: UIControlStateNormal)
      return
    end

    performSegueWithIdentifier("open_login_screen", sender: self)
  end

  def open_connect_foursquare
    foursquare_url = "#{App::Env['NXO_API_URL']}/link/foursquare?token=#{firebase.authData.token}".nsurl
    safari_view = SFSafariViewController.alloc.initWithURL(foursquare_url)
    safari_view.delegate = self

    presentViewController(safari_view, animated: true, completion: nil)
  end

  def open_connect_twitter
    twitter_url = "#{App::Env['NXO_API_URL']}/link/twitter?token=#{firebase.authData.token}".nsurl
    safari_view = SFSafariViewController.alloc.initWithURL(twitter_url)
    safari_view.delegate = self

    presentViewController(safari_view, animated: true, completion: nil)
  end

  def safariViewControllerDidFinish(controller)
  end

  private

  def firebase
    @firebase ||= Firebase.alloc.initWithUrl(App::Env["FIREBASE_URL"])
  end

  def manager
    @manager ||= Locman::Manager.new(
      background: false,
      distance_filter: 20
    )
  end
end
