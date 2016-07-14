<p>
<a href="http://cocoadocs.org/docsets/DeckView"><img src="https://img.shields.io/cocoapods/v/DeckView.svg?style=flat"></a>
</p>

# DeckView

A simple card collection view for iOS, works like UITableView.

![Screenshot](https://raw.githubusercontent.com/xspyhack/DeckView/master/images/deckview.gif)

## API

DeckView follows Apple convention for data-driven views by providing `DataSource` & `Delegate` protocols. And the CardView is reusable like UITableViewCell.

##### DataSource

```swift
public protocol DeckViewDataSource: class {
    
    func numberOfCardInDeckView(deckView: DeckView) -> Int
    
    func deckView(deckView: DeckView, cardViewAt index: Int) -> CardView
}
```

##### Delegate

```swift
public protocol DeckViewDelegate: class {
    
    func deckView(deckView: DeckView, didSelectAt index: Int)
}
```

##### Method

```swift
public func reloadData()
```

```swift
public func register(type cardClass: AnyClass?)
```

```swift
public func dequeueCardView(for index: Int) -> CardView
```

```
public func fadeOut(with animation: (cardView: CardView, completion: () -> Void) -> Void)
```

## Requirements

Swift 2.0, iOS 8.0

## Installation

It's recommended to use CocoaPods.

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ [sudo] gem install cocoapods
```

To integrate DeckView into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'DeckView'
```

Then, run the following command:

```bash
$ pod install
```

You should open the `{Project}.xcworkspace` instead of the `{Project}.xcodeproj` after you installed anything from CocoaPods.

For more information about how to use CocoaPods, I suggest [this tutorial](http://www.raywenderlich.com/64546/introduction-to-cocoapods-2).


## License

DeckView is available under the [MIT License][mitLink] license. See the LICENSE file for more info.
[mitLink]:http://opensource.org/licenses/MIT
