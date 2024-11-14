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
    
    // MARK: - Properties
    var viewModel: MainViewModel
    var mapViewModel: MapViewModel
    private let disposeBag = DisposeBag()
    
    let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    lazy var theme = isDarkMode ? Theme.dark : Theme.light
    
    var mapItemArray: [String] = []
    var locationManger = CLLocationManager()
    var currentHour: Int?
    
    var lat: Double = 0.0 { didSet { print("latChanged\(lat)") } }
    var lon: Double = 0.0 { didSet { print("lonChanged\(lon)") } }
    var weather: Weather?
    var hourWeather: HourWeather?
    let weatherService = WeatherService.shared
    
    private let refreshControl = UIRefreshControl()
    
    private let dateLabel = UILabel().then {
        $0.text = "yyyy-MM-dd ".stringFromDate()
        $0.font = UIFont.boldSystemFont(ofSize: 25)
        $0.textColor = .white
    }
    
    private let timeLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        $0.textColor = .white
    }
    
    private let umbrellaImage = UIImageView().then { $0.image = #imageLiteral(resourceName: "rainClould2") }
    
    private let precipitationLabel = UILabel().then {
        $0.text = "123"
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
    
    private let resetButton = UIButton().then {
        $0.setImage(UIImage(named: "reload"), for: .normal)
        
    }
    
    private lazy var tempLabel = UILabel().then { $0.font = UIFont.boldSystemFont(ofSize: 35) }
    
    private let weatherCard1 = WeatherCard(iconImage: UIImage(named: "free-icon-wind-2204344")!, labelText: "바람 세기", stateText: "5.6 km/h")
    private let weatherCard2 = WeatherCard(iconImage: UIImage(named: "rainCloud")!, labelText: "강수 확률", stateText: "5.6 km/h")
    private let weatherCard3 = WeatherCard(iconImage: UIImage(named: "free-icon-sun-7604060")!, labelText: "자외선 지수", stateText: "5.6 km/h")
    
    private let hourlyLabel = UILabel().then {
        $0.text = "시간대별 강수확률"
        $0.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    private var collectionView: UICollectionView!
    private var hourlyWeatherData: [HourlyWeather] = []
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // MARK: - Lifecycle
    
    init(viewModel: MainViewModel, mapViewModel: MapViewModel) {
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
        configureRefreshControl()
        bindViewModel()
        setupStackView()
        
        let name = Notification.Name("darkModeHasChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(enableDarkmode), name: name, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Functions
    func configureUI() {

        // 배경색 설정
        view.backgroundColor = theme.backgroundColor
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        contentView.addSubview(resetButton)
        resetButton.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide).offset(16)
            $0.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(20)
            $0.width.height.equalTo(25)
        }
        
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        
        contentView.addSubview(locationLabel)
        //locationLabel.textColor = .black
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide).offset(36)
            $0.centerX.equalToSuperview()
        }
        
        contentView.addSubview(tempLabel)
        tempLabel.snp.makeConstraints {
            $0.top.equalTo(locationLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        contentView.addSubview(umbrellaImage)
        umbrellaImage.snp.makeConstraints {
            $0.top.equalTo(tempLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(180)
        }
        
        contentView.addSubview(precipitationLabel)
        precipitationLabel.snp.makeConstraints {
            $0.top.equalTo(umbrellaImage.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        let weatherStackView = UIStackView(arrangedSubviews: [weatherCard1, weatherCard2, weatherCard3])
        weatherStackView.axis = .horizontal
        weatherStackView.distribution = .fillEqually
        weatherStackView.spacing = 15
        
        contentView.addSubview(weatherStackView)
        weatherStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(precipitationLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        weatherStackView.backgroundColor = .clear
        
        contentView.addSubview(hourlyLabel)
        hourlyLabel.snp.makeConstraints {
            $0.leading.equalTo(weatherStackView.snp.leading)
            $0.top.equalTo(weatherStackView.snp.bottom).offset(14)
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(HourlyWeatherCell.self, forCellWithReuseIdentifier: HourlyWeatherCell.identifier)
        collectionView.dataSource = self
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.leading.equalTo(hourlyLabel.snp.leading)
            $0.top.equalTo(hourlyLabel.snp.bottom).offset(8)
            $0.height.equalTo(110)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview() // To ensure the collectionView's bottom is constrained to contentView
        }
        
        collectionView.backgroundColor = .clear
    }
    

    
    
    func setupStackView() {
        // Configure stack view if needed
    }
    
    private func configureCollectionView() {
        // Additional configuration if needed
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
                self.viewModel.updateLocation(location)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshWeatherData), for: .valueChanged)
        scrollView.refreshControl = refreshControl
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
            
            precipitationLabel.text = currentWeather.precipitationChance == 0.0 ? " " : "123"
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
            let precipitationChance = String(format: "%.0f%%", hourly.precipitationChance * 100)
            let weather = HourlyWeather(time: time, icon: icon, precipitationChance: precipitationChance)
            hourlyWeatherData.append(weather)
        }
        
        collectionView?.reloadData()
    }
    
    private func updateWeatherUI(_ weather: Weather) {
        print("weather \(weather.currentWeather.temperature.value)")
        print("uvIndex \(weather.currentWeather.uvIndex)")
        print("wind \(weather.currentWeather.wind)")
        tempLabel.text = String(weather.currentWeather.temperature.value)
        fetchHourlyWeather(with: weather)
        precipitationLabel.text = "예상 강수량 - \(weather.currentWeather.precipitationIntensity.value) mm"
        weatherCard1.updateStateText("\(weather.currentWeather.wind.speed.value) km/h")
        weatherCard3.updateStateText("\(weather.currentWeather.uvIndex.value)")
    }
    
    // MARK: - Actions
    
    @objc private func refreshWeatherData() {
        let location = viewModel.selectedLocation ?? viewModel.currentLocation ?? CLLocation(latitude: lat, longitude: lon)
        viewModel.updateLocation(location)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func enableDarkmode() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let theme = isDarkMode ? Theme.dark : Theme.light
        view.backgroundColor = theme.backgroundColor
        
    }
    
    @objc func resetButtonTapped() {
        print("Reset button tapped")
        if let currentLocation = viewModel.currentLocation {
            viewModel.updateLocation(currentLocation)
        }
    }
    
}
extension MainViewController: UICollectionViewDataSource {
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
