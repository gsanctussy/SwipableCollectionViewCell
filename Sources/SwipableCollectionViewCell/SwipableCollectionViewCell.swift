//  SwipableCollectionViewCell
//
//  Created by Gaïl SANCTUSSY on 20/03/2024.
//

import UIKit

open class SwipableCollectionViewCell: UICollectionViewCell {

    // MARK: - Public variables
    
    /// An optional delegate conforming to `SwipableCollectionViewCellDelegate` to handle
    /// actions and events related to the trailing swipe.
    public weak var trailingSwipeDelegate: SwipableCollectionViewCellDelegate?

    /// A bool that indicate the if the trailing swipe is enabled
    public var trailingSwipeEnabled = true {
        didSet {
            self.setupGestures()
        }
    }
    /// A bool that indicate if the cell is swiped to its maximum value
    public var isSwiped = false
    
    // MARK: - Private variables
    
    /// The configuration
    private var actions: [SwipableCellAction] = []
    /// The configuration struct that will hold the necesary property
    private var configuration: SwipableCellConfiguration!
    /// Usefull to enable or disable the recognition of multiple simultaneous gesture using `UIGestureRecognizerDelegate`
    /// and prevent that the swipe has priority on the vertical scroll
    private var isActionViewVisible = false
    /// Computed var forwarding the layoutDirection of the content view
    private var isLTR: Bool {
        return self.contentView.traitCollection.layoutDirection == .leftToRight
    }
    /// The view that will be discover using the swipe gesture
    private var actionViewContainer: UIStackView?
    private var actionViewContainerWidthConstraint: NSLayoutConstraint?
    
    /// The view that will be animate using the swipe gesture
    private var slidingAnimationView: UIView!
    
    private var panGestureRecognizer: UIPanGestureRecognizer?
    
    private var swipeMaxDistance: Double {
        return self.configuration.distances.swipe * Double(self.actions.count)
    }
    
    // MARK: - Public variables
    
    open override var clipsToBounds: Bool {
        get {
            super.clipsToBounds
        }
        set {
            super.clipsToBounds = newValue
            self.contentView.clipsToBounds = newValue
        }
    }
    
    // MARK: - Public methods
    
    /// Add a trailing swipe action to the collection view cell.
    ///
    /// This method configures the cell with trailing swipe capabilities using the specified configuration,
    /// an optional title, and an optional delegate. It sets up the cell's internal state and prepares it
    /// for the swipe action.
    ///
    /// - Parameters:
    ///   - actions: The array of `SwipableCollectionViewCell.Action`
    ///   - configuration: The configuration for the trailing swipe action, defining aspects like swipe distances,
    ///                     animation durations, and whether the swipe is enabled.
    ///   - slidingAnimationView: The view that will be animate when swipe the trailing area
    public func addTrailingSwipe(
        actions: [SwipableCellAction],
        with configuration: SwipableCellConfiguration = .init(),
        slidingAnimationView: UIView
    ) {
        self.actions = actions
        self.configuration = configuration
        self.slidingAnimationView = slidingAnimationView
        self.setup()
    }

    /// Creates a view representing an action within a swipeable table view cell.
    ///
    /// - Parameters
    ///   - action: `SwipableCollectionViewCell.Action`
    /// - Returns: The newly created action view
    func createActionView(_ action: SwipableCollectionViewCell.Action) -> UIView {
        let actionView = UIView()
        actionView.backgroundColor = action.style.backgroundColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        actionView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: actionView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: actionView.centerYAnchor)
        ])
        
        // Check if an icon is provided for the action and create an UIImageView if needed
        if let icon = action.icon {
            let iconImageView = UIImageView(image: icon)
            iconImageView.tintColor = action.style.foregroundColor
            iconImageView.contentMode = .scaleAspectFit
            stackView.addArrangedSubview(iconImageView)
            iconImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
            iconImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        }
        
        let label = UILabel()
        label.text = action.title
        label.textColor = action.style.foregroundColor
        stackView.addArrangedSubview(label)

        return actionView
    }
    
    /// Trigger the opening of the action view manually
    public func openActionView() {
        guard self.trailingSwipeEnabled else { return }
        let distance = self.swipeMaxDistance
        let translationX = self.isLTR ? -distance : distance
        self.applyTranslationWithAnimation(translationX: translationX)
        // Inform the delegate that the state has changed
        self.trailingSwipeDelegate?.swipableCollectionViewCell(self, changedState: .ended(.final))
        self.isSwiped = true
        // Update the corner radius based on the swipe position
        self.updateCornerRadius()
    }
    
    /// Reset the swipable view to its origin position
    public func closeActionView() {
        guard self.trailingSwipeEnabled else { return }
        // Reinitialize the view position
        UIView.animate(withDuration: self.configuration.animationsDuration.close, animations: { [weak self] in
            self?.reset()
        })
        // Update the corner radius based on the swipe position
        self.updateCornerRadius()
        // Inform the delegate that the state has changed
        self.trailingSwipeDelegate?.swipableCollectionViewCell(self, changedState: .ended(.initial))
    }

    /// Reset the view
    public func reset() {
        self.actionViewContainerWidthConstraint?.constant = 0
        self.slidingAnimationView.transform = .identity
        self.layoutIfNeeded()
        self.isSwiped = false
        self.transform = .identity
    }
}

// MARK: - Initialisation
private extension SwipableCollectionViewCell {
    
    /// Initialise the swipe
    func setup() {
        guard self.configuration != nil else { return }
        // Set clips to bounds to false
        self.clipsToBounds = false
        self.setupGestures()
        self.setupSlidingAnimationView()
        self.reset()
    }
    
    /// Initialise the gesture based on the `trailingSwipeEnabled` property
    func setupGestures() {
        // Add the actions view as subview
        self.addActionsView()
        // Add the swipe gestion using `UIPanGestureRecognizer`
        self.addSwipeGesture()
    }
    
    /// Setup the sliding animation view
    func setupSlidingAnimationView() {
        self.slidingAnimationView.clipsToBounds = true
        self.slidingAnimationView.layer.cornerRadius = 8
    }
    
    /// Add the actions views below the content view
    func addActionsView() {
        guard self.trailingSwipeEnabled else { return }
        
        // Clean before
        if let oldContainerView = self.actionViewContainer, self.contentView.subviews.contains(oldContainerView) {
            oldContainerView.removeFromSuperview()
            self.actionViewContainer = nil
        }
        
        let containerView = UIStackView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .horizontal
        containerView.distribution = .fillEqually
        containerView.alignment = .fill
        containerView.clipsToBounds = true
        containerView.layer.maskedCorners = self.isLTR ?
            [.layerMaxXMinYCorner, .layerMaxXMaxYCorner] :
            [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        self.insertSubview(containerView, belowSubview: self.slidingAnimationView)
        let widthConstraint = containerView.widthAnchor.constraint(equalToConstant: self.swipeMaxDistance)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            widthConstraint
        ])
        self.actionViewContainerWidthConstraint = widthConstraint
        self.actionViewContainer = containerView
        
        self.actions.forEach { action in
            let actionView = self.createActionView(action)
            actionView.clipsToBounds = true
            containerView.addArrangedSubview(actionView)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap))
            actionView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    /// Add the swipe gesture using a `UIPanGestureRecognizer`
    func addSwipeGesture() {
        // Remove the pan gesture if exists
        if let existingPanGesture = self.panGestureRecognizer {
            self.removeGestureRecognizer(existingPanGesture)
        }

        // Check if the trailing swipe is enabled before add the gesture
        if self.trailingSwipeEnabled {
            let newPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
            newPanGesture.delegate = self
            self.panGestureRecognizer = newPanGesture
            self.addGestureRecognizer(newPanGesture)
        }
    }
}

// MARK: - Swipe gesture handling
private extension SwipableCollectionViewCell {
    
    /// Selector for handling the `UITapGestureRecognizer`
    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        guard let stackView = self.actionViewContainer, gesture.state == .ended else { return }
        let location = gesture.location(in: stackView)
        
        let tappedViewIndex = stackView.arrangedSubviews.firstIndex { view in
            view.frame.contains(location)
        }
        if let index = tappedViewIndex {
            self.trailingSwipeDelegate?.swipableCollectionViewCell(self, didSelectActionAt: index)
        }
    }
    
    /// Handles the pan gesture by updating the `transformView` and notifying the delegate of the change when necesary.
    ///
    /// - Parameter gesture: The pan gesture recognizer that detected the swipe.
    @objc func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        let isGestureVertical = abs(translation.y) > abs(translation.x)
        
        guard !isGestureVertical else {
            self.isActionViewVisible = false
            return
        }
        switch gesture.state {
        case .began:
            self.swipeBegan()
        case .changed:
            self.swipeChanged(gesture)
        case .cancelled, .failed:
            self.swipeCancelled()
        case .ended:
            self.swipeEnded(gesture)
        default:
            break
        }
        // Update the corner radius
        self.updateCornerRadius()
    }
    
    /// Called on state `began` of the `UIPanGestureRecognizer`
    func swipeBegan() {
        self.trailingSwipeDelegate?.swipableCollectionViewCell(self, changedState: .began)
        // Mark the swipe as active when the gesture begins.
        self.isActionViewVisible = true
    }
    
    /// Called on state `changed` of the `UIPanGestureRecognizer`
    func swipeChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        let distance = self.swipeMaxDistance
        let bounceDistance = self.isLTR ? -self.configuration.distances.bounce : self.configuration.distances.bounce
        let maxTranslation = self.isLTR ? -distance + bounceDistance : distance + bounceDistance
        let swipeDirectionLeading = self.isLTR ? translation.x < 0 : translation.x > 0
        var newTranslationX: CGFloat = maxTranslation

        // We need to perform the bounce animation only if the cell is swiped to the maximum distance
        if self.isSwiped {
            if swipeDirectionLeading {
                // If we try to swipe more than the maximum distance we perform a bounce animation
                self.applyTranslationWithAnimation(translationX: newTranslationX, animated: true)
            } else {
                // If the view is in the maximal position and the user desire to collapsed the view
                newTranslationX = self.isLTR ?
                min(max(bounceDistance, translation.x), 0) :
                max(min(bounceDistance, 0), translation.x)
                self.applyTranslationWithAnimation(translationX: newTranslationX, animated: true)
            }
        } else {
            // Trigger the swipe animation without enabling animation to reduce lag
            newTranslationX = self.isLTR ?
            max(min(translation.x, 0), maxTranslation) :
            min(max(translation.x, 0), maxTranslation)
            self.applyTranslationWithAnimation(translationX: newTranslationX, animated: false)
        }
        
        self.isSwiped = newTranslationX == maxTranslation        
    }
    
    /// Called on state `cancelled` or `failed` of the `UIPanGestureRecognizer`
    func swipeCancelled() {
        self.closeActionView()
        self.isActionViewVisible = false
    }
    
    /// Called on state `ended` of the `UIPanGestureRecognizer`
    ///
    /// - Parameters:
    ///     - gesture: The `UIPanGestureRecognizer`
    func swipeEnded(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        // When the user ended its swipe state we need to set the swipe state to the nearest position
        let swipePosition = self.nearestSwipeState(translationX: translation.x)
        let scrollPosition: ScrollPosition = swipePosition == .final ? .final : .initial
        
        self.applyTranslation(to: self.contentView, with: scrollPosition)
        // Reset the active swipe state in case of cancellation or failure.
        self.isActionViewVisible = false
        // Notify the delegate that the swipe has ended, and determine whether to complete the swipe action.
        self.trailingSwipeDelegate?.swipableCollectionViewCell(
            self,
            changedState: .ended(scrollPosition == .initial ? .initial : .final)
        )
        self.isSwiped = scrollPosition == .final
    }
    
    /// This function adjusts the corner radius of `slidingAnimationView` during a swipe gesture.
    /// The corner radius is modified differently depending on the gesture state to achieve a specific visual effect during the animation.
    func updateCornerRadius() {
        let maskedAllCorners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        var maskedTrailingCorners: CACornerMask = []
        if self.isLTR {
            maskedTrailingCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        } else {
            maskedTrailingCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
        self.slidingAnimationView.layer.cornerRadius = 8
        self.slidingAnimationView.layer.maskedCorners =
            self.slidingAnimationView.transform != .identity ? maskedTrailingCorners : maskedAllCorners
        self.slidingAnimationView.layer.masksToBounds = true
    }
}

private extension SwipableCollectionViewCell {
    
    /// The possible scroll states
    enum ScrollPosition {
        /// Scroll to the transform initial position
        case initial
        /// Scroll to the transform final position
        case final
    }
    
    /// Apply a basic transform animation
    func applyTranslationWithAnimation(translationX: CGFloat, animated: Bool = true) {
        self.actionViewContainerWidthConstraint?.constant = self.isLTR ? -translationX : translationX

        // Apply the modifications with or without animation
        if animated {
            UIView.animate(withDuration: self.configuration.animationsDuration.swipe) { [weak self] in
                self?.slidingAnimationView.transform = CGAffineTransform(translationX: translationX, y: 0)
                self?.layoutIfNeeded()
            }
        } else {
            self.slidingAnimationView.transform = CGAffineTransform(translationX: translationX, y: 0)
            self.layoutIfNeeded()
        }
    }
    
    /// Apply a transition to the target view with our configuration
    /// - Parameter view: The view that will be affected by the transform.
    /// - Parameter state: Value of `ScrollPosition`
    func applyTranslation(to view: UIView, with state: ScrollPosition) {
        let swipeAnimationDuration = self.configuration.animationsDuration.swipe

        switch state {
        case .initial:
            UIView.animate(withDuration: swipeAnimationDuration) {
                self.actionViewContainerWidthConstraint?.constant = 0
                self.slidingAnimationView.transform = .identity
                view.layoutIfNeeded()
            }
        case .final:
            let swipeMaxThreshold = self.swipeMaxDistance
            UIView.animate(withDuration: swipeAnimationDuration) {
                self.actionViewContainerWidthConstraint?.constant = swipeMaxThreshold
                self.slidingAnimationView.transform = CGAffineTransform(
                    translationX: self.isLTR ? -swipeMaxThreshold : swipeMaxThreshold, y: 0
                )
                self.layoutIfNeeded()
            }
        }
    }
    
    /// Determines the nearest swipe position (initial or final) based on the translation of a swipe gesture.
    ///
    /// This method calculates the closest state of a swipe gesture (either initial or final) based on the horizontal translation (`translationX`)
    ///  and the current layout direction (LTR or RTL).
    ///
    /// - Parameter translationX: The horizontal translation of the swipe gesture.
    /// - Returns: The nearest swipe position, either `.initial` or `.final`.
    func nearestSwipeState(translationX: CGFloat) -> SwipePosition {
        let swipeDistance = self.swipeMaxDistance
        let initialDistance = abs(translationX)
        let finalDistance = abs(translationX + (self.isLTR ? swipeDistance : -swipeDistance))
        return initialDistance < finalDistance ? .initial : .final
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SwipableCollectionViewCell: UIGestureRecognizerDelegate {
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return !self.isActionViewVisible
    }
}
