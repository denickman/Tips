//
//  ViewController.swift
//  Tips
//
//  Created by Denis Yaremenko on 31.03.2024.
//

import UIKit
import SnapKit
import Combine
import CombineCocoa

class CalculatroVC: UIViewController {
    
    // MARK: - Properties
    
    private let logoView = LogoView()
    private let resultView = ResultView()
    private let billInputView = BillInputView()
    private let tipInputView = TipInputView()
    private let splitInputView = SplitInputView()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            logoView,
            resultView,
            billInputView,
            tipInputView,
            splitInputView,
            UIView()
        ])
        stackView.axis = .vertical
        stackView.spacing = 36
        return stackView
    }()
    
    // ViewModel for performing calculations
    private let calculatorVM = CalculatorVM()
    
    // ViewModel for performing calculations
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var viewTapPublisher: AnyPublisher<Void, Never> = {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(tapGesture)
        /// since tapPublisher returns AnyPublisher<UITapGestureRecognizer, Never>
        /// we have to use flatmap to transform to <Void, Never>
        return tapGesture.tapPublisher.flatMap { _ in
            Just(())
        }.eraseToAnyPublisher()
    }()
    
    private lazy var logoViewTapPublisher: AnyPublisher<Void, Never> = {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.numberOfTapsRequired = 2
        logoView.addGestureRecognizer(tapGesture)
        return tapGesture.tapPublisher.flatMap { _ in
            Just(())
        }.eraseToAnyPublisher()
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeColor.bg
        layout()
        bind()
        observe()
    }
}

extension CalculatroVC {
    
    func layout() {
        view.addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leadingMargin).offset(16)
            make.trailing.equalTo(view.snp.trailingMargin).offset(-16)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-16)
            make.top.equalTo(view.snp.topMargin).offset(16)
        }
        
        logoView.snp.makeConstraints { make in
          make.height.equalTo(48)
        }
        
        resultView.snp.makeConstraints { make in
            make.height.equalTo(224)
        }
        
        billInputView.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        tipInputView.snp.makeConstraints { make in
            make.height.equalTo(56 + 56 + 16)
        }
        
        splitInputView.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    // Method to bind UI to ViewModel
    func bind() {
        
        /*
         // For test purposes
         let input = CalculatorVM.Input(
         buildPublisher: Just(10).eraseToAnyPublisher(),
         tipPublisher: Just(.ten).eraseToAnyPublisher(),
         splitPublisher: Just(5).eraseToAnyPublisher())
         
         billInputView.valuePublisher.sink { bill in
         print(">> billInputView.valuePublisher add observer: \(bill)")
         }.store(in: &cancellables)
         */
        
        let input = CalculatorVM.Input(
            billPublisher: billInputView.valuePublisher,
            tipPublisher: tipInputView.valuePublisher,
            splitPublisher: splitInputView.valuePublisher,
            logoViewTapPublisher: logoViewTapPublisher
        )
        
        // Call the transform method of ViewModel to get output data
        let output = calculatorVM.transform(input: input)
        
        // For test purposes
        // Subscribe to the updateViewPublisher of the output
        //        output.updateViewPublisher.sink { result in
        //            print(">> Output: \(result)")
        //        }.store(in: &cancellables)
        
        output.updateViewPublisher.sink { [unowned self] result in
            print(">> Output result:", result)
            resultView.configure(result: result)
        }.store(in: &cancellables)
        
        output.resetCalculatorPublisher.sink { [unowned self] _ in
            print("reset the form please")
            billInputView.reset()
            tipInputView.reset()
            splitInputView.reset()
            
            output.resetCalculatorPublisher.sink { [unowned self] _ in
                billInputView.reset()
                tipInputView.reset()
                splitInputView.reset()
                UIView.animate(
                    withDuration: 0.1,
                    delay: 0,
                    usingSpringWithDamping: 5.0,
                    initialSpringVelocity: 0.5,
                    options: .curveEaseInOut) {
                        self.logoView.transform = .init(scaleX: 1.5, y: 1.5)
                    } completion: { _ in
                        UIView.animate(withDuration: 0.1) {
                            self.logoView.transform = .identity
                        }
                    }
            }.store(in: &cancellables)
            
        }
    }
    
    func observe() {
        viewTapPublisher.sink { [unowned self] value in
            view.endEditing(true)
        }.store(in: &cancellables)
        
//        logoViewTapPublisher.sink { [unowned self] _ in
//           print("logo view tapped")
//        }.store(in: &cancellables)
    }
}

