//  SwipableCollectionViewCell+Configuration
//
//  Created by Gaïl SANCTUSSY on 20/03/2024.
//

import Foundation
import UIKit

/// A typealias for `SwipableCollectionViewCell.Configuration`.
public typealias SwipableCellConfiguration = SwipableCollectionViewCell.Configuration
/// A typealias for `SwipableCollectionViewCell.Action`.
public typealias SwipableCellAction = SwipableCollectionViewCell.Action

public extension SwipableCollectionViewCell {
    /// Struct that defines the configuration for the trailing swipe action in a collection view cell.
    struct Configuration {
        /// The distances for the swipe action.
        public let distances: Distances
        /// The durations for the animations associated with the swipe action.
        public let animationsDuration: AnimationsDuration
        
        /// Initializes a new `Configuration` instance using the default values.
        public init() {
            self.distances = .default
            self.animationsDuration = .default
        }
    }
    
    /// Struct that define a trailing swipe action
    struct Action {
        var title: String
        var style: Style
        var icon: UIImage?

        /// Initializes a new `TrailingSwipeAction` instance with custom values.
        /// - Parameters:
        ///   - title: The title for the swipe action view.
        ///   - style: The style for the swipe action view.
        ///   - icon: The icon for the swipe action view.
        public init(
            title: String,
            style: Style,
            icon: UIImage? = nil
        ) {
            self.title = title
            self.style = style
            self.icon = icon
        }
    }
}

public extension SwipableCollectionViewCell {
    /// Struct that define the distances
    struct Distances {
        /// The distance the cell should swipe.
        var swipe: Double
        /// The bounce distance after the swipe action.
        var bounce: Double
        
        /// Default distances configuration.
        static let `default`: Self = {
            .init(swipe: 90, bounce: 10)
        }()
    }
    
    /// Struct that defines the animation durations for various states of the trailing swipe action.
    struct AnimationsDuration {
        /// Duration of the swipe animation.
        var swipe: Double
        /// Duration of the animation when the swipe action is manually close.
        var close: Double
        /// Duration of the bounce animation.
        var bounce: Double
        
        /// Default animations duration configuration.
        static let `default`: Self = {
            .init(swipe: 0.3, close: 0.2, bounce: 0.2)
        }()
    }
    
    /// An enum that describe the available style for different actions.
    enum Style {
        /// Primary style of the swipe action
        case primary
        /// Attention style of the swipe action
        case attention
        
        var backgroundColor: UIColor {
            switch self {
            case .primary:
                return .black
            case .attention:
                return .orange
            }
        }
        
        var foregroundColor: UIColor {
            return .white
        }
    }
}
