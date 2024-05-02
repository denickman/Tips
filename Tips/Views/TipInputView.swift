//
//  TipInputView.swift
//  Tips
//
//  Created by Denis Yaremenko on 31.03.2024.
//

import UIKit
import Combine
import CombineCocoa

class TipInputView: UIView {
    
    // MARK: - Public Properties
    
    var valuePublisher: AnyPublisher<Tip, Never> {
        return tipSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properites
    
    private let headerView: HeaderView = {
        let view = HeaderView()
        view.configure(topText: "Choose", bottomText: "your tip")
        return view
    }()
    
    private lazy var tenPercentTipButton: UIButton = {
        let button = buildTipButton(tip: .ten)
        button.tapPublisher.flatMap({
            Just(Tip.ten)
        }).assign(to: \.value, on: tipSubject) // .value - tipSubject.value, trigger observer
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var fifteenPercentTipButton: UIButton = {
        let button = buildTipButton(tip: .fifteen)
        button.tapPublisher.flatMap({
            Just(Tip.fifteen)
        }).assign(to: \.value, on: tipSubject) // .value - tipSubject.value
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var twentyPercentTipButton: UIButton = {
        let button = buildTipButton(tip: .twenty)
        button.tapPublisher.flatMap({
            Just(Tip.twenty)
        }).assign(to: \.value, on: tipSubject) // .value - tipSubject.value
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var customTipButton: UIButton = {
        let button = UIButton()
        button.setTitle("Custom tip", for: .normal)
        button.titleLabel?.font = ThemeFont.bold(ofSize: 20)
        button.backgroundColor = ThemeColor.primary
        button.tintColor = .white
        button.addCornerRadius(radius: 8.0)
        button.tapPublisher.sink { [weak self] _ in
            self?.handleCustomTipButton()
        }.store(in: &cancellables)
        return button
    }()
    
    private lazy var buttonVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            buttonHStackView,
            customTipButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var buttonHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            tenPercentTipButton,
            fifteenPercentTipButton,
            twentyPercentTipButton
        ])
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.axis = .horizontal
        return stackView
    }()
    
    /// CurrentValueSubject holds and emits the most recent value that it received. When you create a CurrentValueSubject, you specify an initial value. Any new subscribers immediately receive this initial value.
    /// It always holds and emits the latest value, even if there are no subscribers.
    ///
    private let tipSubject = CurrentValueSubject<Tip, Never>(.none)
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
}

extension TipInputView {
    
    func layout() {
        [headerView, buttonVStackView].forEach(addSubview(_:))
        //        prepareSubviewsForAutolayout(headerView, buttonHStackView)
        
        buttonVStackView.snp.makeConstraints { maker in
            maker.top.bottom.trailing.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { maker in
            maker.leading.equalToSuperview()
            maker.trailing.equalTo(buttonVStackView.snp.leading).offset(-24)
            maker.width.equalTo(68)
            maker.centerY.equalTo(buttonHStackView.snp.centerY)
        }
    }
    
    func buildTipButton(tip: Tip) -> UIButton {
        let button = UIButton()
        button.backgroundColor = ThemeColor.primary
        button.addCornerRadius(radius: 8.0)
        
        let text = NSMutableAttributedString(
            string: tip.stringValue,
            attributes: [.font: ThemeFont.bold(ofSize: 20),
                         .foregroundColor: UIColor.white
            ]
        )
        
        text.addAttributes(
            [.font: ThemeFont.demiBold(ofSize: 14)],
            range: NSMakeRange(2, 1)
        )
        
        button.setAttributedTitle(text, for: .normal)
        return button
    }
    
    
    func handleCustomTipButton() {
        let alertCtrl: UIAlertController = {
            let ctrl = UIAlertController(
                title: "Enter custom tip",
                message: nil,
                preferredStyle: .alert)
            
            ctrl.addTextField { textField in
                textField.placeholder = "Put tip here"
                textField.keyboardType = .numberPad
                textField.autocapitalizationType = .none
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                guard let text = ctrl.textFields?.first?.text,
                      let value = Int(text) else {
                    return
                }
                self?.tipSubject.send(.custom(value: value))
            }
            
            [okAction, cancelAction].forEach(ctrl.addAction(_:))
            return ctrl
        }()
        
        parentViewController?.present(alertCtrl, animated: true)
    }
    
    private func resetView() {
        [tenPercentTipButton,
         fifteenPercentTipButton,
         twentyPercentTipButton,
         customTipButton].forEach {
            $0.backgroundColor = ThemeColor.primary
        }
        
        let text = NSMutableAttributedString(
            string: "Custom tip",
            attributes: [.font: ThemeFont.bold(ofSize: 20)])
        
        customTipButton.setAttributedTitle(text, for: .normal)
    }
    
    private func observe() {
        tipSubject.sink { [unowned self] tip in
            resetView()
            switch tip {
            case .none:
                break
            case .ten:
                tenPercentTipButton.backgroundColor = ThemeColor.secondary
            case .fifteen:
                fifteenPercentTipButton.backgroundColor = ThemeColor.secondary
            case .twenty:
                twentyPercentTipButton.backgroundColor = ThemeColor.secondary
            case .custom(value: let value):
                customTipButton.backgroundColor = ThemeColor.secondary
                let text = NSMutableAttributedString.init(string: "$\(value)", attributes: [
                    .font: ThemeFont.bold(ofSize: 20)
                ])
                
                text.addAttributes([
                    .font: ThemeFont.bold(ofSize: 14)
                ], range: NSMakeRange(0, 1)
                )
                
                customTipButton.setAttributedTitle(text, for: .normal)
            }
        }.store(in: &cancellables)
    }
    
    func reset() {
        tipSubject.send(.none)
    }
}


