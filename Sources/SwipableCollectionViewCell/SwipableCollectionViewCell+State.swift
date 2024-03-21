//  SwipableCollectionViewCell+State
//
//  Created by Gaïl SANCTUSSY on 20/03/2024.
//

/// A typealias for `SwipableCollectionViewCell.State`.
public typealias SwipableCellState = SwipableCollectionViewCell.State

public extension SwipableCollectionViewCell {
    
    /// Enum that define the swipe position
    enum SwipePosition {
        /// Swipe initial position
        case initial
        /// Swipe final position
        case final
    }
    
    /// Enum that define the swipe possible states when update
    enum State {
        /// Swipe began
        case began
        /// End of the swipe, to the final offset position or to the original position
        /// if the swipe translation.x does not exceed the middle of the `slideOffset`
        case ended(SwipePosition)
    }
}

