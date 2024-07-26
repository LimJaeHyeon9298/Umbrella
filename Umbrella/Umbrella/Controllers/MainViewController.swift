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
import FLAnimatedImage

class MainViewController: UIViewController {
    
    //MARK: - Properties
    var viewModel:MainViewModel
    var mapViewModel: MapViewModel
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

    private let umbrellaImage = UIImageView().then { $0.image = #imageLiteral(resourceName: "rainClould2") }

//    private let umbrellaImage = FLAnimatedImageView().then {
//           $0.contentMode = .scaleAspectFit
//        $0.backgroundColor = .clear
//       }
    
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
    
    private let weatherCard1 = WeatherCard(iconImage: UIImage(named: "free-icon-wind-2204344")!, labelText: "바람 세기", stateText: "5.6 km/h")
    private let weatherCard2 = WeatherCard(iconImage: UIImage(named: "rainCloud")!, labelText: "강수 확률", stateText: "5.6 km/h")
    private let weatherCard3 = WeatherCard(iconImage: UIImage(named: "free-icon-sun-7604060")!, labelText: "자외선 지수", stateText: "5.6 km/h")
    
    private let hourlyLabel = UILabel().then {
        $0.text = "시간대별 강수확률"
        $0.font = UIFont.boldSystemFont(ofSize: 16)
    }
 
    private var collectionView:UICollectionView!
    private var hourlyWeatherData: [HourlyWeather] = []
    
    //MARK: - LifeCycle
    
    init(viewModel:MainViewModel,mapViewModel:MapViewModel) {
        self.viewModel = viewModel
        self.mapViewModel = mapViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("mainVC viewDidLoad")
        configureUI()
        configureCollectionView()
     
        //timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector:#selector(timerProc),userInfo:nil, repeats: true)
        viewModel = MainViewModel()
        bindViewModel()
        setupStackView()
        
        let name = Notification.Name("darkModeHasChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(enableDarkmode), name: name, object: nil)
        


    }
    
    override func viewWillAppear(_ animated: Bool) {
       // tempLabel.text = String(self.weather?.currentWeather.temperature.value ?? 0)
//        NotificationCenter.default.addObserver(self, selector: #selector(test(_:)), name: NSNotification.Name("test"), object: nil)
        navigationController?.isNavigationBarHidden = true
        
        
        
        
    }
    
    //MARK: - Functions
    func configureUI() {
        
        view.backgroundColor = .white
    
        view.addSubview(backgroundImage)
//        backgroundImage.alpha = 0.85
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
        
        // GIF 파일을 로드하여 FLAnimatedImageView에 설정
//               if let gifPath = Bundle.main.path(forResource: "free-animated-icon-umbrella-6455007", ofType: "gif") {
//                   let gifURL = URL(fileURLWithPath: gifPath)
//                   do {
//                       let gifData = try Data(contentsOf: gifURL)
//                       let animatedImage = FLAnimatedImage(animatedGIFData: gifData)
//                       umbrellaImage.animatedImage = animatedImage
//                   } catch {
//                       print("GIF 파일을 로드하는 데 실패했습니다: \(error)")
//                   }
//               }
        
        
        view.addSubview(precipitationLabel)
        
        precipitationLabel.snp.makeConstraints {
            $0.top.equalTo(umbrellaImage.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        let weatherStackView = UIStackView(arrangedSubviews: [weatherCard1,weatherCard2,weatherCard3])
        weatherStackView.axis = .horizontal
        weatherStackView.distribution = .fillEqually
        weatherStackView.spacing = 15
        
        
        
        
        view.addSubview(weatherStackView)
        weatherStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(precipitationLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        weatherStackView.backgroundColor = .clear
        
        
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
        
        mapViewModel.selectedLocation
                   .subscribe(onNext: { location in
                       print("Received location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                       // 여기서 location을 사용해 원하는 작업 수행
                       self.viewModel.updateLocation(location)
                   })
                   .disposed(by: disposeBag)

    }

    private func fetchHourlyWeather(with weather: Weather) {
        hourlyWeatherData.removeAll() // 기존 데이터를 초기화합니다.

           let currentHour = Calendar.current.component(.hour, from: Date())
           
           // 현재 시간을 "NOW"로 표시 (hourlyForecast의 첫 번째 값을 사용)
           if let currentWeather = weather.hourlyForecast.first {
               let nowIcon = currentWeather.precipitationChance == 0.0 ?
                                     UIImage(named: "free-icon-umbrella-3430143")! :
                                     UIImage(named: "free-icon-umbrella-1628865")!
               let nowPrecipitationChance = String(format: "%.0f%%", currentWeather.precipitationChance * 100)
               let nowWeather = HourlyWeather(time: "NOW", icon: nowIcon, precipitationChance: nowPrecipitationChance)
               hourlyWeatherData.append(nowWeather)
               
               weatherCard2.updateStateText("\(nowPrecipitationChance)")
           }
           
           // 현재 시간 이후부터 23시까지 (두 번째 값부터 사용)
           for (index, hourly) in weather.hourlyForecast.prefix(24).dropFirst().enumerated() {
               let hour = currentHour + index + 1
               let displayHour = hour % 24
               let period = displayHour < 12 ? "AM" : "PM"
               let formattedHour = displayHour == 0 ? 12 : (displayHour > 12 ? displayHour - 12 : displayHour)
               let time = "\(formattedHour) \(period)"
               let icon = hourly.precipitationChance == 0.0 ?
                                  UIImage(named: "free-icon-umbrella-3430143")! :
                                  UIImage(named: "free-icon-umbrella-1628865")!
              // let temperature = "\(18 + displayHour % 5)°"
               let precipitationChance = String(format: "%.0f%%", hourly.precipitationChance * 100)
               let weather = HourlyWeather(time: time, icon: icon, precipitationChance: precipitationChance)
               hourlyWeatherData.append(weather)
           }
           
           collectionView?.reloadData()
       }
    

        private func updateWeatherUI(_ weather: Weather) {
            print("weather \(weather.currentWeather.temperature.value)")
            print("uvIndex\(weather.currentWeather.uvIndex)")
            print("wind\(weather.currentWeather.wind)")
           // print("wind\(weather.currentWeather.precipitationChance)")
            tempLabel.text = String(weather.currentWeather.temperature.value)
            fetchHourlyWeather(with: weather)
            
            
            weatherCard1.updateStateText("\(weather.currentWeather.wind.speed.value) km/h")
         
               weatherCard3.updateStateText("\(weather.currentWeather.uvIndex.value)")

            
            
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
//        viewModel.locationManager.stopUpdatingLocation()
//        viewModel.locationManager.startUpdatingLocation()
        
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
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
               return cell
    }
    

}

