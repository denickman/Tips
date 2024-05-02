//
//  LogoView.swift
//  Tips
//
//  Created by Denis Yaremenko on 31.03.2024.
//

import UIKit
import SnapKit

class LogoView: UIView {
    
    // MARK: - Properties
    
    private let imageView: UIImageView = {
        let view = UIImageView(image: .init(named: "icCalculatorBW"))
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let topLabel: UILabel = {
        let label = UILabel()
        let text = NSMutableAttributedString(string: "mr TIP", attributes: [
            .font: ThemeFont.demiBold(ofSize: 16)
        ])
        text.addAttributes([.font: ThemeFont.bold(ofSize: 24)], range: NSMakeRange(3, 3))
        label.attributedText = text
        return label
    }()
    
    private let bottomLabel: UILabel = {
        LabelFactory.build(
            text: "Calculator",
            font: ThemeFont.demiBold(ofSize: 20),
            textAlignment: .left
        )
    }()
    
    private lazy var vStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            topLabel,
            bottomLabel
        ])
        view.axis = .vertical
        view.spacing = -4
        return view
    }()
    
    private lazy var hStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            imageView,
            vStackView
        ])
        
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .center
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
    
    // MARK: - Methods
    
    private func layout() {
        addSubview(hStackView)
        hStackView.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { maker in
            maker.height.equalTo(imageView.snp.width)
        }
    }
    
}
