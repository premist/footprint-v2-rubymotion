class LoginController < UIViewController
  extend IB

  outlet :email_field
  outlet :password_field

  def viewDidLoad
    email_field.becomeFirstResponder
  end

  def close_view
    dismissViewControllerAnimated(true, completion: nil)
  end

  def login
    SVProgressHUD.show
    firebase.authUser(email_field.text, password: password_field.text, withCompletionBlock: lambda do |e, data|
      if e != nil
        SVProgressHUD.showErrorWithStatus(e.localizedDescription)
        return
      end

      SVProgressHUD.showSuccessWithStatus("Logged in!")
      close_view
    end)
  end

  private

  def firebase
    @firebase ||= Firebase.alloc.initWithUrl(App::Env["FIREBASE_URL"])
  end
end
