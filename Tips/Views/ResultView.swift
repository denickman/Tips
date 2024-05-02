//
//  ResultView.swift
//  Tips
//
//  Created by Denis Yaremenko on 31.03.2024.
//

import UIKit

class ResultView: UIView {
    
    // MARK: - Properties
    
    private let headerLabel: UILabel = {
        LabelFactory.build(
            text: "Total p/person",
            font: ThemeFont.demiBold(ofSize: 18)
        )
    }()
    
    private let amountPerPersonLabel: UILabel = {
        let label  = UILabel()
        label.textAlignment = .center
        
        let text = NSMutableAttributedString(
            string: "$0",
            attributes: [.font: ThemeFont.bold(ofSize: 48)]
        )
        
        text.addAttributes([.font: ThemeFont.bold(ofSize: 24)],
                           range: NSMakeRange(0, 1))
        label.attributedText = text
        return label
    }()
    
    private let horizontalLineView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.separator
        return view
    }()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            headerLabel,
            amountPerPersonLabel,
            horizontalLineView,
            buildSpacerView(height: .zero),
            hStackView
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            totalBillView,
            UIView(),
            totalTipView
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let totalBillView: AmountView = {
        let view = AmountView(title: "Total bill", textAlighment: .left)
        return view
    }()
    
    private let totalTipView: AmountView = {
        let view = AmountView(title: "Total tip", textAlighment: .right)
        return view
    }()
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ResultView {

    func layout() {
        backgroundColor = .white
        addSubview(vStackView)
        vStackView.snp.makeConstraints { maker in
            maker.top.equalTo(snp.top).offset(24)
            maker.leading.equalTo(snp.leading).offset(24)
            maker.trailing.equalTo(snp.trailing).offset(-24)
            maker.bottom.equalTo(snp.bottom).offset(-24)
        }
        
        horizontalLineView.snp.makeConstraints { make in
            make.height.equalTo(2)
        }
        
        addShadow(
            offset: CGSize(width: 0, height: 3),
            color: .black,
            radius: 12.0,
            opacity: 0.2
        )
    }
    
    func buildSpacerView(height: CGFloat) -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
    
    func configure(result: Result) {
        let text = NSMutableAttributedString(
            string: result.amountPerPerson.currencyFormatter,
            attributes: [.font: ThemeFont.bold(ofSize: 48)])
        text.addAttributes(
            [.font: ThemeFont.bold(ofSize: 24)],
            range: NSMakeRange(0, 1)
        )
        amountPerPersonLabel.attributedText = text
        
        totalBillView.configure(amount: result.totalBill)
        totalTipView.configure(amount: result.totalTip)
    }
}
