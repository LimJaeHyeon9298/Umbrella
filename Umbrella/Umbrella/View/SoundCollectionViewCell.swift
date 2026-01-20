//
//  SoundCollectionViewCell.swift
//  Umbrella
//
//  Created by 임재현 on 6/25/24.
//

import UIKit
import Then
import SnapKit
import AVFoundation
import RxSwift

class SoundCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let reuseIdentifier = "SoundCell"
    var disposeBag = DisposeBag()  // prepareForReuse에서 초기화
    
    // MARK: - UI Components
    var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
    }
    
    var titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textAlignment = .center
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    func setUpLayout() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func configure(with item: SoundItems) {
        imageView.image = item.backgroundImage
        titleLabel.text = item.title
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()  // DisposeBag 초기화로 구독 해제
    }
}


