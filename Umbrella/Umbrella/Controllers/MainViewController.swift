//
//  ViewController.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/15.
//

import UIKit
import WeatherKit
import CoreLocation
import SafariServices
import Then
import SnapKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    
    //MARK: - Properties
    var viewModel:MainViewModel!
    private let disposeBag = DisposeBag()

    var mapItemArray:[String] = []
    var locationManger = CLLocationManager()
    var currentHour:Int?
    
    var lat:Double = 0.0 { didSet {print("latChanged\(lat)")}}
    var lon:Double = 0.0 { didSet { print("lonChanged\(lon)")}}
    var weather: Weather?
    var hourWeather: HourWeather?
    let weatherService = WeatherService.shared
    var timer:Timer!

    private let dateLabel = UILabel().then {
        $0.text = "yyyy-MM-dd ".stringFromDate()
        $0.font = UIFont.boldSystemFont(ofSize: 25)
        $0.textColor = .white
    }

    private let timeLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        $0.textColor = .white
    }

    private var backgroundImage = UIImageView().then {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let theme = isDarkMode ? Theme.dark : Theme.light
        $0.image = theme.backgroundImage
        
    }

    private let umbrellaImage = UIImageView().then { $0.image = #imageLiteral(resourceName: "rainCloud") }

    
    private let precipitationLabel = UILabel().then {
        $0.text = "강수확률 10%"
        $0.numberOfLines = 1
        $0.font = UIFont.boldSystemFont(ofSize: 20)
    }
 
    private let locationLabel = UILabel().then {
        $0.text = "서울특별시"
        $0.font = UIFont.boldSystemFont(ofSize: 32)
        $0.numberOfLines = 0 // 여러 줄 표시를 위해 0으로 설정
        $0.textColor = .white
        $0.textAlignment = .center // 중앙 정렬
    }
    
    private lazy var tempLabel = UILabel().then { $0.font = UIFont.boldSystemFont(ofSize: 35) }
    
    private let weatherCard1 = WeatherCard(iconImage: UIImage(named: "rainCloud")!, labelText: "Wind State", stateText: "5.6 km/h")
    private let weatherCard2 = WeatherCard(iconImage: UIImage(named: "rainCloud")!, labelText: "Wind State", stateText: "5.6 km/h")
    private let weatherCard3 = WeatherCard(iconImage: UIImage(named: "rainCloud")!, labelText: "Wind State", stateText: "5.6 km/h")
    
    private let hourlyLabel = UILabel().then {
        $0.text = "시간대별 강수확률"
        $0.font = UIFont.boldSystemFont(ofSize: 16)
    }
 
    private var collectionView:UICollectionView!
    private var hourlyWeatherData: [HourlyWeather] = []
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
        loadData()
        timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector:#selector(timerProc),userInfo:nil, repeats: true)
        viewModel = MainViewModel()
        bindViewModel()
        setupStackView()
        
        let name = Notification.Name("darkModeHasChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(enableDarkmode), name: name, object: nil)
        


    }
    
    override func viewWillAppear(_ animated: Bool) {
        tempLabel.text = String(self.weather?.currentWeather.temperature.value ?? 0)
        NotificationCenter.default.addObserver(self, selector: #selector(test(_:)), name: NSNotification.Name("test"), object: nil)
        navigationController?.isNavigationBarHidden = true
        
    }
    
    //MARK: - Functions
    func configureUI() {
        
        view.backgroundColor = .white
    
        view.addSubview(backgroundImage)
        
        backgroundImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        
        view.addSubview(locationLabel)
        
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(36)
          //  $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        view.addSubview(tempLabel)
        
        tempLabel.snp.makeConstraints {
            $0.top.equalTo(locationLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        view.addSubview(umbrellaImage)
        
        umbrellaImage.snp.makeConstraints {
            $0.top.equalTo(tempLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(180)
        }
        
        
        view.addSubview(precipitationLabel)
        
        precipitationLabel.snp.makeConstraints {
            $0.top.equalTo(umbrellaImage.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        
        let weatherStackView = UIStackView(arrangedSubviews: [weatherCard1,weatherCard2,weatherCard3])
        weatherStackView.axis = .horizontal
        weatherStackView.distribution = .fillEqually
        weatherStackView.spacing = 10
        
        view.addSubview(weatherStackView)
        weatherStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(precipitationLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        weatherStackView.backgroundColor = .red
        
        
        view.addSubview(hourlyLabel)
        
        hourlyLabel.snp.makeConstraints {
            $0.leading.equalTo(weatherStackView.snp.leading)
            $0.top.equalTo(weatherStackView.snp.bottom).offset(14)
        }
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(HourlyWeatherCell.self, forCellWithReuseIdentifier: HourlyWeatherCell.identifier)
              collectionView.dataSource = self
              
              view.addSubview(collectionView)
              collectionView.snp.makeConstraints {
                  $0.leading.equalTo(hourlyLabel.snp.leading)
                  $0.top.equalTo(hourlyLabel.snp.bottom).offset(8)
                  $0.height.equalTo(110)
                  $0.width.equalToSuperview()
              }
        
        collectionView.backgroundColor = .clear

    }

    func setupStackView() {
    }
    
    private func configureCollectionView() {
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                               heightDimension: .absolute(110))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
  
    private func bindViewModel() {
            viewModel.weatherData
                .compactMap { $0 }
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] weather in
                    self?.updateWeatherUI(weather)
                })
                .disposed(by: disposeBag)

            viewModel.isLoading
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] isLoading in
                    // Show loading indicator
                })
                .disposed(by: disposeBag)

            viewModel.error
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { error in
                    // Show error message
                })
                .disposed(by: disposeBag)
    

        viewModel.locationAddress
                    .observe(on: MainScheduler.instance)
                    .bind(to: locationLabel.rx.text)
                    .disposed(by: disposeBag)

    }
    private func loadData() {
           // 예시 데이터 로드
           for hour in 0..<24 {
               let time = hour == 0 ? "NOW" : "\(hour) AM"
               let icon = UIImage(named: "rainCloud")! // 실제 이미지를 사용해야 합니다
               let temperature = "\(18 + hour % 5)°"
               let precipitationChance = "\(hour % 2 == 0 ? "30%" : "50%")"
               let weather = HourlyWeather(time: time, icon: icon, temperature: temperature, precipitationChance: precipitationChance)
               hourlyWeatherData.append(weather)
           }
           
           collectionView?.reloadData()
       }
    
    
    

        private func updateWeatherUI(_ weather: Weather) {
            print("weather \(weather.currentWeather.temperature.value)")
            tempLabel.text = String(weather.currentWeather.temperature.value)
           
        }
    
        //MARK: - Actions

    @objc func timerProc(timer:Timer){
        let date = Date()
        let formatter = DateFormatter();
        formatter.dateFormat = "a hh:mm:ss "
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        let msg = formatter.string(from: date)
        timeLabel.text = msg
        let formatter2 = DateFormatter();
        formatter2.dateFormat = "HH"
        let msg2 = formatter2.string(from: date)
        currentHour = Int(msg2)
        
    }
    @objc func enableDarkmode() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let theme = isDarkMode ? Theme.dark : Theme.light        //view.backgroundColor = theme.backgroundColor
        backgroundImage.image = theme.backgroundImage

    }
    @objc func test(_ notification:NSNotification){
           
        
        guard let mapitem = notification.object as? [String] else {return}
        
        print("map\(mapitem)")
        
       mapItemArray = mapitem
        
         locationLabel.text = mapItemArray[0]
        lat = Double(mapItemArray[2])!
        lon = Double(mapItemArray[3])!
        viewModel.locationManager.stopUpdatingLocation()
        viewModel.locationManager.startUpdatingLocation()
        
        }
    
}

extension MainViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyWeatherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyWeatherCell.identifier, for: indexPath) as? HourlyWeatherCell else {
                   return UICollectionViewCell()
               }
               
               let weather = hourlyWeatherData[indexPath.item]
               cell.configure(with: weather)
        cell.backgroundColor = .white
               return cell
    }
    

}

