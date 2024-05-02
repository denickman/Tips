//
//  SplitInputView.swift
//  Tips
//
//  Created by Denis Yaremenko on 31.03.2024.
//

import UIKit
import Combine
import CombineCocoa

class SplitInputView: UIView {
    
    // MARK: - Public Properties
    
    var valuePublisher: AnyPublisher<Int, Never> {
        return splitSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    
    private let headerView: HeaderView = {
        let view = HeaderView()
        view.configure(topText: "Split", bottomText: "total:")
        return view
    }()
    
    private lazy var decrementButton: UIButton = {
        let button = buildButton(
            text: "-",
            corners: [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        )
        button.tapPublisher.flatMap { [unowned self] _ in
            Just(splitSubject.value == 1 ? 1 : splitSubject.value - 1)
        }.assign(to: \.value, on: splitSubject)
            .store(in: &cancellables)
        
        return button
    }()
    
    private lazy var incrementButton: UIButton = {
        let button = buildButton(
            text: "+",
            corners: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        )
        button.tapPublisher.flatMap { [unowned self] _ in
            Just(splitSubject.value + 1)
        }.assign(to: \.value, on: splitSubject)
            .store(in: &cancellables)
        
        return button
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = LabelFactory.build(
            text: "1",
            font: ThemeFont.bold(ofSize: 20),
            backgroundColor: .white
        )
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            decrementButton,
            quantityLabel,
            incrementButton
        ])
        stackView.axis = .horizontal
        stackView.spacing = .zero
        return stackView
    }()
    
    private let splitSubject: CurrentValueSubject<Int, Never> = .init(1)
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        layout()
        observe()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        splitSubject.send(1)
    }
}

extension SplitInputView {
    
    func layout() {
        prepareSubviewsForAutolayout(headerView, stackView)
        
        NSLayoutConstraint.activate {
            stackView.trailingAnchor == trailingAnchor
            stackView.topAnchor == topAnchor
            stackView.bottomAnchor == bottomAnchor
            
            incrementButton.widthAnchor == incrementButton.heightAnchor
            decrementButton.widthAnchor == decrementButton.heightAnchor
            
            headerView.leadingAnchor == leadingAnchor
            headerView.centerYAnchor == stackView.centerYAnchor
            headerView.trailingAnchor == stackView.leadingAnchor - 24
            headerView.widthAnchor == 60
        }
    }
    
    func buildButton(text: String, corners: CACornerMask) -> UIButton {
        let button = UIButton()
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = ThemeFont.bold(ofSize: 20)
        button.addRoundedCorners(corners: corners, radius: 8.0)
        button.backgroundColor = ThemeColor.primary
        
        return button
    }
    
    func observe() {
        splitSubject.sink { [unowned self] quantity in
            quantityLabel.text = quantity.stringValue
        }.store(in: &cancellables)
    }
}
