class CheckinSearchController < UIViewController
  extend IB

  outlet :text_field

  def viewDidLoad
    text_field.becomeFirstResponder
  end

  def search
    checkin_controller = self.presentingViewController.viewControllers.detect {|c| c.is_a?(CheckinController) }

    dismissViewControllerAnimated(true, completion: lambda do
      p checkin_controller
      checkin_controller.search_query = text_field.text
      checkin_controller.update_view
    end)
  end
end
