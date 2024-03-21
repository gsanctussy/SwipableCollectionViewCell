//
//  SwipableCollectionViewCellDelegate.swift
//  
//
//  Created by Gaïl SANCTUSSY on 21/03/2024.
//

import Foundation

/// Delegate protocol for the `SwipableCollectionViewCell`
public protocol SwipableCollectionViewCellDelegate: AnyObject {
    /// Return the state of the swipe using `TrailingSwipeState`
    func swipableCollectionViewCell(_ cell: SwipableCollectionViewCell, changedState: SwipableCellState)
    
    /// Called when the user select the swipe action view
    func swipableCollectionViewCell(_ cell: SwipableCollectionViewCell, didSelectActionAt index: Int)
}
