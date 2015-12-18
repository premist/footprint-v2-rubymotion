class CheckinPostController < UIViewController
  extend IB

  outlet :text_view
  outlet :image_view

  def viewDidLoad
    text_view.becomeFirstResponder
  end

  def publish(sender)
    SVProgressHUD.show
    firebase.childByAppendingPath(UIDevice.currentDevice.name)
            .childByAppendingPath("posts")
            .childByAutoId.setValue(
              {
                text: text_view.text,
                image: UIImageJPEGRepresentation(@image, 1.0).base64Encoding,
                created_at: Time.now.to_i
              },
              withCompletionBlock: lambda { |error, ref| SVProgressHUD.dismiss }
            )
  end

  def pick_photo(sender)
    controller = UIImagePickerController.new
    controller.delegate = self
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary

    presentViewController(controller, animated: true, completion: nil)
  end

  def imagePickerController(picker, didFinishPickingMediaWithInfo: info)
    picker.dismissModalViewControllerAnimated(true)

    url = info.objectForKey(UIImagePickerControllerReferenceURL)

    fetch_result = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil)
    ph_asset = fetch_result.firstObject

    request_options = PHImageRequestOptions.new
    request_options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat
    request_options.synchronous = true

    manager = PHImageManager.defaultManager
    img = nil
    manager.requestImageForAsset(
      ph_asset,
      targetSize: PHImageManagerMaximumSize,
      contentMode: PHImageContentModeDefault,
      options: request_options,
      resultHandler: lambda { |ui_image, info| img = ui_image }
    )

    self.image = img
  end

  def image
    @image
  end

  def image=(img)
    @image = img.normalize!
    image_view.image = @image
  end

  private

  def firebase
    Dispatch.once {
      @firebase ||= Firebase.alloc.initWithUrl(App::Env["FIREBASE_URL"])
    }

    @firebase
  end
end
