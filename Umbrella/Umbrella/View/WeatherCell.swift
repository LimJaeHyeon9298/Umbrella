//
//  WeatherCell.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/17.
//

import UIKit
import WeatherKit
import CoreLocation


class WeatherCell: UITableViewCell  {

    var weather: Weather?
    var myLocation = CLLocation(latitude: 37.5666, longitude: 126.9784)
    private let progressBar = UIProgressView(progressViewStyle: .bar)
    
    private let rainnyImage:UIImageView = {
        let ig = UIImageView()
        ig.image = #imageLiteral(resourceName: "cloud.bolt.rain.fill")
        return ig
    }()

     let timeLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
     let gansoohwakyul :UILabel = {
        let label = UILabel()
        label.text = "강수확률: 10%"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configUI() {
        addSubview(timeLabel)
        timeLabel.centerY(inView:contentView)
        timeLabel.anchor(top:contentView.topAnchor,left: contentView.leftAnchor,paddingTop:20,paddingLeft: 24)
        timeLabel.textColor = .black
        
        addSubview(rainnyImage)
        rainnyImage.centerY(inView: contentView)
        rainnyImage.anchor(left:timeLabel.rightAnchor,paddingLeft: 16,width: 16,height: 16)
        
        progressBar.setProgress(0.5, animated: true)
        progressBar.trackTintColor = UIColor.gray
        progressBar.tintColor = UIColor.blue
        
        addSubview(progressBar)
        progressBar.centerY(inView: contentView)
        progressBar.anchor(left: rainnyImage.rightAnchor,paddingLeft: 16,width: 190)
        
        addSubview(gansoohwakyul)
        gansoohwakyul.centerY(inView: contentView)
        gansoohwakyul.anchor(left: progressBar.rightAnchor,paddingLeft: 30)
    }
}


