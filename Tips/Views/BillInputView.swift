//
//  BillInputView.swift
//  Tips
//
//  Created by Denis Yaremenko on 31.03.2024.
//

import UIKit
import Combine
import CombineCocoa

class BillInputView: UIView {
    
    // MARK: - Public Properties
    
    
    /// So, whenever observe() is called, and billSubject emits a new value (triggered by changes in the text field's text value), the valuePublisher will automatically emit that value downstream to its subscribers. This is how valuePublisher knows to trigger after billSubject.send(text?.doubleValue ?? .zero) is called.
    var valuePublisher: AnyPublisher<Double, Never> {
        print(">> valuePublisher emits")
        return billSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    
    private let headerView: HeaderView = {
        let view = HeaderView()
        view.configure(
            topText: "Enter",
            bottomText: "your bill"
        )
        return view
    }()
    
    private let textFieldContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addCornerRadius(radius: 8.0)
        return view
    }()
    
    private let currencyDenominationLabel: UILabel = {
        let label = LabelFactory.build(text: "$", font: ThemeFont.bold(ofSize: 24))
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.font = ThemeFont.demiBold(ofSize: 28)
        textField.keyboardType = .decimalPad
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.tintColor = ThemeColor.text
        textField.textColor = ThemeColor.text
        // Add toolbar
        let toolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: frame.size.width, height: 36))
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(doneButtonTapped))
        
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            doneButton
        ]
        toolbar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolbar
        return textField
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    ///PassthroughSubject - does not have an initial value and only emits values that are sent to it after a subscriber has connected.
    ///It does not retain or remember any values. If a value is sent to it and there are no subscribers, that value is lost.
    private let billSubject = PassthroughSubject<Double, Never>()
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        layout()
        observe()
    }
    
    func reset() {
        textField.text = nil
        billSubject.send(.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func layout() {
        //        // option 1 + option 2
        //        [headerView, textFieldContainerView].forEach(addSubview(_:))
        //        textFieldContainerView.addSubview(currencyDenominationLabel)
        //        textFieldContainerView.addSubview(textField)
        
        // option 3
        prepareSubviewsForAutolayout(headerView, textFieldContainerView, currencyDenominationLabel, textField)
        
        headerView.snp.makeConstraints { maker in
            maker.leading.equalToSuperview()
            maker.centerY.equalTo(textFieldContainerView.snp.centerY)
            maker.width.equalTo(68)
            maker.height.equalTo(24)
            maker.trailing.equalTo(textFieldContainerView.snp.leading).offset(-24)
        }
        
        textFieldContainerView.snp.makeConstraints { maker in
            maker.top.trailing.bottom.equalToSuperview()
        }
        
        currencyDenominationLabel.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.leading.equalTo(textFieldContainerView.snp.leading).offset(16)
        }
        
        textField.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.leading.equalTo(currencyDenominationLabel.snp.trailing).offset(16)
            maker.trailing.equalTo(textFieldContainerView.snp.trailing).offset(-16)
        }
    }
    
    @objc private func doneButtonTapped() {
        textField.endEditing(true)
    }
    
    private func observe() {
        textField.textPublisher.sink { [unowned self] text in
            print("textField.textPublisher add observer: \(text)")
            billSubject.send(text?.doubleValue ?? .zero)
            // will automatically trigger computed property 'valuePublisher'
        }.store(in: &cancellables)
    }
    
}
