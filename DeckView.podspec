Pod::Spec.new do |s|

  s.name        = "DeckView"
  s.version     = "0.1"
  s.summary     = "DeckView is a simple card collection view for iOS, works like UITableView."

  s.description = <<-DESC
                   A simple card collection view for iOS, works like UITableView.
                   DeckView providing UITableView like API so it is easy for use.
                   DESC

  s.homepage    = "https://github.com/xspyhack/DeckView"

  s.license     = { :type => "MIT", :file => "LICENSE" }

  s.authors           = { "xspyhack" => "xspyhack@gmail.com" }
  s.social_media_url  = "https://twitter.com/xspyhack"

  s.ios.deployment_target   = "8.0"

  s.source          = { :git => "https://github.com/xspyhack/DeckView.git", :tag => s.version }
  s.source_files    = "DeckView/*.swift"
  s.requires_arc    = true

end
