//
//  CalculatorVM.swift
//  Tips
//
//  Created by Denis Yaremenko on 01.04.2024.
//

import Foundation
import Combine

class CalculatorVM {
    
    // MARK: - Nested
    
    // Input structure containing publishers for bill, tip, and split
    struct Input {
        let billPublisher: AnyPublisher<Double, Never>
        let tipPublisher: AnyPublisher<Tip, Never>
        let splitPublisher: AnyPublisher<Int, Never>
        let logoViewTapPublisher: AnyPublisher<Void, Never>
    }
    
    // Output structure containing a publisher for updating the view
    struct Output {
        let updateViewPublisher: AnyPublisher<Result, Never>
        let resetCalculatorPublisher: AnyPublisher<Void, Never>
    }
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let audioPlayerService: AudioPlayerService
    
    init(audioPlayerService: AudioPlayerService = DefaultAudioPlayer()) {
        self.audioPlayerService = audioPlayerService
    }
    
    // MARK: - Methods
    
    // Output structure containing a publisher for updating the view
    func transform(input: Input) -> Output {
        
        /*
         // For test purposes
         
         input.tipPublisher.sink { tip in
         print(">> input.tipPublisher subscribe:", tip)
         }.store(in: &cancellables)
         
         input.billPublisher.sink { bill in
         print(">> input.billPublisher add observer: \(bill)")
         }.store(in: &cancellables)
         
         input.splitPublisher.sink { split in
         print(">> split subscribe:", split)
         }.store(in: &cancellables)
         */
        
        // if any of these publishers emit a value, need to re-compute everything
        let updateViewPublisher = Publishers.CombineLatest3(
            input.billPublisher,
            input.tipPublisher,
            input.splitPublisher
        )
            .flatMap { [unowned self] (bill, tip, split) in
                let totalTip = getTipAmount(bill: bill, tip: tip)
                let totalBill = bill + totalTip
                let amountPerPerson = totalBill / Double(split)
                let result = Result(amountPerPerson: amountPerPerson, totalBill: totalBill, totalTip: totalTip)
                return Just(result)
            }.eraseToAnyPublisher()
        
        let resultCalculatorPublisher = input.logoViewTapPublisher
            .handleEvents(receiveOutput: { [unowned self] in
            audioPlayerService.playSound()
        }).flatMap {
            return Just($0)
        }.eraseToAnyPublisher()
        
        return Output(
            updateViewPublisher: updateViewPublisher,
            resetCalculatorPublisher: resultCalculatorPublisher
        )
        
    }
    
    private func getTipAmount(bill: Double, tip: Tip) -> Double {
        switch tip {
        case .none:
            return .zero
        case .ten:
            return bill * 0.1
        case .fifteen:
            return bill * 0.15
        case .twenty:
            return bill * 0.20
        case .custom(value: let value):
            return Double(value)
        }
    }
}
