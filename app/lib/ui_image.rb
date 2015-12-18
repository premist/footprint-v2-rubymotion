class UIImage
  def normalize
    return self if imageOrientation == UIImageOrientationUp

    UIGraphicsBeginImageContextWithOptions(size, false, scale);
    drawInRect(CGRectMake(0, 0, size))

    normalized_image = UIGraphicsGetImageFromCurrentImageContext
    UIGraphicsEndImageContext

    normalized_image
  end
end
