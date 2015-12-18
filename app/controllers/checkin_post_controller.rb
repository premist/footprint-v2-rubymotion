class CheckinPostController < UIViewController
  extend IB

  outlet :text_view
  outlet :image_view

  def viewDidLoad
    text_view.becomeFirstResponder
  end

  def publish(sender)
    SVProgressHUD.show
    record = firebase.childByAppendingPath(UIDevice.currentDevice.name)
            .childByAppendingPath("posts")
            .childByAutoId

    record.setValue(
      {
        text: text_view.text,
        created_at: Time.now.to_i
      },
      withCompletionBlock: lambda do |error, ref|
      end
    )

    image_record = firebase.childByAppendingPath(UIDevice.currentDevice.name)
                           .childByAppendingPath("images")
                           .childByAppendingPath(record.key)

    image_base64 = UIImageJPEGRepresentation(@image, 0.8).base64Encoding
    image_record.setValue(image_base64, withCompletionBlock: lambda do |error, ref|
      SVProgressHUD.dismiss
      dismissViewControllerAnimated(true, completion: nil)
    end)
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
    @image = img.normalize.resizedImageByMagick("1536x1536")
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
