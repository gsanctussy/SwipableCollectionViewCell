# SwipableCollectionViewCell

SwipableCollectionViewCell is a customizable, easy-to-use swipeable cell for UICollectionViews, designed to add interactive swipe actions such as delete or favorite to your collection view cells.

## Features

- Easy integration with UICollectionView.
- Customizable swipe actions.
- Support for left-to-right and right-to-left languages.
- Delegate pattern for handling swipe actions.
- Configuration for swipe distances and animation durations.

## Installation

### Swift Package Manager

You can add SwipableCollectionViewCell to an Xcode project by adding it as a package dependency.

1. From the File menu, select Swift Packages > Add Package Dependency...
2. Enter "https://github.com/gsanctussy/SwipableCollectionViewCell" into the package repository URL text field.
3. Link `SwipableCollectionViewCell` to your application target.

## How to use ?

First, import SwipableCollectionViewCell in your UICollectionView dataSource:

```swift
import SwipableCollectionViewCell
```
                                                                
Register the SwipableCollectionViewCell class with your collection view:

```swift
cell.trailingSwipeDelegate = self
self.trailingSwipeDelegate = self
self.addTrailingSwipe(
    actions: [
        .init(
            title: "Custom",
            style: .attention
        ),
        .init(
            title: "Delete",
            style: .primary
        )
    ],
    slidingAnimationView: self.slidingAnimationView
)
````

Implement the SwipableCollectionViewCellDelegate in your view controller to handle swipe actions:

```swift
extension YourViewController: SwipableCollectionViewCellDelegate {
    func swipableCollectionViewCell(_ cell: SwipableCollectionViewCell, didSelectActionAt index: Int) {
        // Handle action based on the index
    }
}
```

## Customization

SwipableCollectionViewCell allows for various customizations including setting the background color, image icons for actions, and more. You can set these properties on the cell's configuration object.

## License

SwipableCollectionViewCell is released under the MIT license. See LICENSE for details.

## Contributing
Contributions are very welcome 🎉. Please contact me for futher information.
