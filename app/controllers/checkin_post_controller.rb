class CheckinPostController < UIViewController
  extend IB

  attr_accessor :venue

  outlet :text_view
  outlet :image_view

  def viewDidLoad
    text_view.becomeFirstResponder
  end

  def publish(sender)
    SVProgressHUD.show

    # If there is no image, we only need to set a value.
    if @image == nil
      enqueue_publish
      return
    end

    # Upload image and create value
    image_base64 = UIImageJPEGRepresentation(@image, 0.8).base64EncodedStringWithOptions(NSDataBase64Encoding64CharacterLineLength)

    image_record = firebase.childByAppendingPath("media_uploads")
                     .childByAutoId

    image_record.setValue(image_base64, withCompletionBlock: lambda { |e, ref|
      if e != nil
        SVProgressHUD.showErrorWithStatus(e.localizedDescription)
        return
      end

      enqueue_publish({ image: image_record.key })
    })
  end

  def enqueue_publish(additional = {})
    value = {
      type: "checkin",
      content: text_view.text,
      venue_id: @venue[:id],
      created_at: Time.now.to_i,
      travel_id: App::Env["TRAVEL_ID"]
    }.merge(additional)

    record = firebase.childByAppendingPath("queues")
                     .childByAppendingPath("post")
                     .childByAppendingPath("tasks")
                     .childByAutoId

    record.setValue(value, withCompletionBlock: lambda do |e, ref|
      finalize_publish(e, ref)
    end)
  end

  def finalize_publish(e, ref)
    SVProgressHUD.dismiss
    dismissViewControllerAnimated(true, completion: nil)
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
    @firebase ||= Firebase.alloc.initWithUrl(App::Env["FIREBASE_URL"])
    @firebase
  end
end
