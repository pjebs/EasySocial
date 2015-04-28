#
#  Be sure to run `pod spec lint EasySocial.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "EasySocial"
  s.version      = "1.0.0"
  s.summary      = "The Easiest and Simplest iOS library for Twitter and Facebook Integration."

  s.description  = <<-DESC
                   EasySocial does only these things:

                   --TWITTER--

                   * Send Plain Tweets
                   * Send Tweets with images (via a URL or UIImage/NSData)
                   * Get Data from user's timeline

                   --FACEBOOK--

                   * Full Facebook Connect (Log In/Log Out and Auto-Log In)
                   * Fetch User Information (objectID, name etc...)
                   * Share and Publish messages in user's timeline
                   DESC

  s.homepage     = "https://github.com/pjebs/EasySocial"

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "PJ Engineering and Business Solutions Pty. Ltd." => "enquiries@pjebs.com.au" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/pjebs/EasySocial.git", :tag => "v1.0.0" }
  s.source_files  = "EasySocial/*"
  s.requires_arc = true
  s.dependency "Facebook-iOS-SDK", "~> 3"

end
