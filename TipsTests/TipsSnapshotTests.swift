//
//  TipsSnapshotTests.swift
//  TipsTests
//
//  Created by Denis Yaremenko on 04.04.2024.
//

import XCTest
import SnapshotTesting
@testable import Tips

// swift-snapshot-testing
// https://github.com/pointfreeco/swift-snapshot-testing

final class TipsSnapshotTests: XCTestCase {
    
    private var screenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    // MARK: - Without values
    
    func testLogoView() {
        // given
        let size = CGSize(width: screenWidth, height: 48)
        
        // when
        let view = LogoView()
        
        // then
        assertSnapshot(of: view, as: .image(size: size), record: false)
        // record: true - save snapshot into project folder
        
        // how to fail
        // go to logoview and change title to another one
        // re-launch the tests
        
        // once there is a required changes in title run test with record: true
        // then run test once again without record: true
    }
    
    func testInitialResultView() {
        // given
        let size = CGSize(width: screenWidth, height: 224)
        
        // when
        let view = ResultView()
        
        // then
        assertSnapshot(of: view, as: .image(size: size), record: false)
    }
    
    func testinitialBillInputView() {
        // given
        let size = CGSize(width: screenWidth, height: 56)
        
        // when
        let view = BillInputView()
        
        // then
        assertSnapshot(of: view, as: .image(size: size), record: false)
    }
    
    func testInitialTipInputView() {
        // given
        let size = CGSize(width: screenWidth, height: 56 + 56 + 16)
        
        // when
        let view = TipInputView()
        
        // then
        assertSnapshot(of: view, as: .image(size: size), record: false)
    }
    
    func testInitialSplitInputView() {
        // given
        let size = CGSize(width: screenWidth, height: 56)
        
        // when
        let view = TipInputView()
        
        // then
        assertSnapshot(of: view, as: .image(size: size), record: true)
    }
    
    // MARK: - With values
    
    func testResultViewWithValues() {
        // given
        let size = CGSize(width: screenWidth, height: 224)
        let result = Result(
            amountPerPerson: 100.25,
            totalBill: 45,
            totalTip: 60
        )
        
        // when
        let view = ResultView()
        view.configure(result: result)
        
        // then
        assertSnapshot(of: view, as: .image(size: size), record: true)
    }
    
    func testBillInputViewWithValues() {
        // given
        let size = CGSize(width: screenWidth, height: 56)
        
        // when
        let view = BillInputView()
        let textField = view.allSubviewsOf(type: UITextField.self).first
        textField?.text = "500"
        
        // then
        assertSnapshot(of: view, as: .image(size: size), record: true)
    }
    
    func testTipInputViewWithValues() {
        // given
        let size = CGSize(width: screenWidth, height: 56 + 56 + 16)
        
        // when
        let view = TipInputView()
        let button = view.allSubviewsOf(type: UIButton.self).first
        button?.sendActions(for: .touchUpInside)
        
        // then
        assertSnapshot(of: view, as: .image(size: size), record: true)
    }
    
    func testSplitInputViewWithValues() {
        // given
        let size = CGSize(width: screenWidth, height: 56)
        
        // when
        let view = SplitInputView()
        let button = view.allSubviewsOf(type: UIButton.self).last
        button?.sendActions(for: .touchUpInside)
        
        // then
        assertSnapshot(of: view, as: .image(size: size), record: true)
    }
}


extension UIView {
    func allSubviewsOf<T: UIView>(type: T.Type) -> [T] {
        var all = [T]()
        
        func getSubview(view: UIView) {
            if let aView = view as? T {
                all.append(aView)
            }
            guard view.subviews.count > 0 else { return }
            view.subviews.forEach {
                getSubview(view: $0)
            }
        }
        getSubview(view: self)
        return all
    }
}
