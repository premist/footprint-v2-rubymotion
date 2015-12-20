class TravelNewController < UIViewController
  extend IB

  outlet :travel_title

  def viewDidLoad
    travel_title.becomeFirstResponder
  end

  def close_view
    dismissViewControllerAnimated(true, completion: nil)
  end

  def create_travel
    SVProgressHUD.show
    firebase.childByAppendingPath("travels")
            .childByAutoId.setValue({
              name: travel_title.text,
              owner: firebase.authData.uid
            }, withCompletionBlock: lambda do |error, ref|
              SVProgressHUD.showSuccessWithStatus("Created!")
              close_view
            end)
  end

  private

  def firebase
    @firebase ||= Firebase.alloc.initWithUrl(App::Env["FIREBASE_URL"])
  end
end
