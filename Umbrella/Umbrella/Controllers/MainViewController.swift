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

class MainViewController: UIViewController,CLLocationManagerDelegate {
    
    //MARK: - Properties
    
    let useWeatherkit = UseWeatherkit()
    var mapItemArray:[String] = []
    var locationManger = CLLocationManager()
    var currentHour:Int?
    
    var lat:Double = 0.0 {
        didSet {
            
            print("latChanged\(lat)")
            
            
            }
    }
    var lon:Double = 0.0 {
        
     didSet { print("lonChanged\(lon)")
         
         
        }
    }
    
  
    
    
    var weather: Weather?
    var hourWeather: HourWeather?
  
    
  
    
    let weatherService = WeatherService.shared
    
   
        
    
        
 
    var timer:Timer!
    
 
    private let resetButton:UIButton = {
        
        let button = UIButton()
        button.setTitle("지역초기화", for: .normal)
       
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
       
        return button
        
        
        
    }()
    
    
    
    
    
    private let dateLabel:UILabel = {
        
        let label = UILabel()
        
        label.text = "yyyy-MM-dd ".stringFromDate()
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = .white
        return label
        
    }()
    
    
    
    private let timeLabel:UILabel = {
        
        let label = UILabel()
        
     
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
        
    }()
    
    private var backgroundImage:UIImageView = {
        
        let ig = UIImageView()
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")

        let theme = isDarkMode ? Theme.dark : Theme.light
        ig.image = theme.backgroundImage
        return ig
        
    }()
    
    private let rainnyButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("시간대별 강수확률", for: .normal)
        
        button.addTarget(self, action: #selector(button1Tapped), for: .touchUpInside)
        
        return button
        
        
    }()
    
    private let button2: UIButton = {
        
        let button = UIButton()
        button.setTitle("위치설정", for: .normal)
      
        button.addTarget(self, action: #selector(button2Tapped), for: .touchUpInside)
        return button
        
        
    }()
    
    
    private let button3: UIButton = {
        
        let button = UIButton()
        button.setTitle("빗소리ASMR", for: .normal)
    
        button.addTarget(self, action: #selector(button3Tapped), for: .touchUpInside)
        return button
        
        
    }()
    

    
    
    private let button4: UIButton = {
        
        let button = UIButton()
        button.setTitle("App Setting", for: .normal)
     
        button.addTarget(self, action: #selector(button4Tapped), for: .touchUpInside)
        return button
        
    }()
    
    private let umbrellaImage:UIImageView = {
        
        let ig = UIImageView()
        
        ig.image = #imageLiteral(resourceName: "symbolic")
        
        return ig
        
        
    }()
    
    
    private let gangsoo: UILabel = {
        let label = UILabel()
        label.text = "강수량 10%"
        label.numberOfLines = 1
        return label
        
    }()
    
    private let locationLabel:UILabel = {
        
        let label = UILabel()
        
        label.text = "서울특별시"
        label.font = UIFont.boldSystemFont(ofSize: 40)
        return label
        
        
    }()
    
   private lazy var tempLabel:UILabel = {
        
        let label = UILabel()
        
          
        label.font = UIFont.boldSystemFont(ofSize: 35)
        
        return label
        
        
    }()
    
    

    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
       
        location()
        
        
        // runweatherkit(latitude: lat, longitude: lon)
        
        
        timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector:#selector(timerProc),userInfo:nil, repeats: true)
        
        
        
        let name = Notification.Name("darkModeHasChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(enableDarkmode), name: name, object: nil)
        


    }
    
    override func viewWillAppear(_ animated: Bool) {
        tempLabel.text = String(self.weather?.currentWeather.temperature.value ?? 0)
        NotificationCenter.default.addObserver(self, selector: #selector(test(_:)), name: NSNotification.Name("test"), object: nil)
    
        
    }
    
    
    
    
    //MARK: - Functions
    
    
    func location() {
        
        
        
        locationManger.delegate = self
        // 거리 정확도 설정
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        // 사용자에게 허용 받기 alert 띄우기
        locationManger.requestWhenInUseAuthorization()
        
        // 아이폰 설정에서의 위치 서비스가 켜진 상태라면
        
        DispatchQueue.global().async   {
            if CLLocationManager.locationServicesEnabled() {
                print("위치 서비스 On 상태")
                self.locationManger.startUpdatingLocation() //위치 정보 받아오기 시작
                //print(self.locationManger.location?.coordinate)
                
                return
            } else {
                print("위치 서비스 Off 상태")
            }
            
            
            
            
        }
     
        
        
        
    }
    
    // 위치 정보 계속 업데이트 -> 위도 경도 받아옴
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        if let location = locations.first {
            print("위도: \(location.coordinate.latitude)")
            print("경도: \(location.coordinate.longitude)")
            lat = location.coordinate.latitude
            lon = location.coordinate.longitude
            runweatherkit(latitude: lat, longitude: lon)
            self.locationManger.stopUpdatingLocation()
        
        }
    }
    
    // 위도 경도 받아오기 에러
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    
    func configureUI() {
        
        
        view.backgroundColor = .white
        
        view.addSubview(backgroundImage)
        backgroundImage.anchor(top:view.topAnchor,left: view.leftAnchor,bottom: view.bottomAnchor,right: view.rightAnchor,paddingTop: 0,paddingLeft: 0,paddingBottom: 0,paddingRight: 0)
        
        
        
        
        view.addSubview(dateLabel)
        dateLabel.anchor(top:view.topAnchor,left: view.leftAnchor,paddingTop: 400,paddingLeft: 30)
        
        
        view.addSubview(timeLabel)
        timeLabel.anchor(top:dateLabel.bottomAnchor,left: view.leftAnchor,paddingTop: 10,paddingLeft: 30)
        
        view.addSubview(rainnyButton)
        rainnyButton.anchor(top:view.topAnchor,right: view.rightAnchor,paddingTop: 470,paddingRight: 30)
        
        view.addSubview(button2)
        button2.anchor(top:rainnyButton.bottomAnchor,right: view.rightAnchor,paddingTop: 15,paddingRight: 30)
        
        
        view.addSubview(button3)
        button3.anchor(top:button2.bottomAnchor,right: view.rightAnchor,paddingTop: 15,paddingRight: 30)
        
        
        
        

        
        
        
        view.addSubview(button4)
        button4.anchor(top:button3.bottomAnchor,right: view.rightAnchor,paddingTop: 30,paddingRight: 30)
        
        view.addSubview(umbrellaImage)
        umbrellaImage.anchor(top:dateLabel.bottomAnchor,left: view.leftAnchor,paddingTop: 50,paddingLeft: 50,width: 150,height: 150)
        
        view.addSubview(gangsoo)
        gangsoo.anchor(top:umbrellaImage.bottomAnchor,left: view.leftAnchor,paddingTop: 10,paddingLeft: 50)

        view.addSubview(locationLabel)
        locationLabel.anchor(top: view.topAnchor,paddingTop: 100)
        locationLabel.centerX(inView: self.view)
        
       
        
        view.addSubview(tempLabel)
        tempLabel.anchor(top: locationLabel.bottomAnchor,paddingTop: 20)
        tempLabel.centerX(inView: self.view)
        tempLabel.text = String(self.weather?.currentWeather.temperature.value ?? 0 )
        
        
        view.addSubview(resetButton)
        //resetButton.anchor(top: view.topAnchor,right: view.rightAnchor,paddingTop: 70,paddingRight: 30,width: 50,height: 50)
        resetButton.anchor(bottom: rainnyButton.topAnchor,right: view.rightAnchor,paddingTop: 70,paddingRight: 30)
        
        
    }
    
//
    
    
    func runweatherkit(latitude:Double,longitude:Double) {
        
        
            
             let myLocation = CLLocation(latitude: latitude, longitude: longitude)
             let geocoder = CLGeocoder()
             let locale = Locale(identifier: "Ko-kr")
            geocoder.reverseGeocodeLocation(myLocation, preferredLocale: locale, completionHandler: {(placemarks, error) in
            if let address: [CLPlacemark] = placemarks {
                if let name: String = address.last?.subLocality,let name2:String = address.last?.locality{ print("hihihihi\(name+name2)")
                       
                    self.locationLabel.text = name2 + name
                
            } //전체 주소
            }
           })
//            print("hi\(latitude)")
//            print("hi\(longitude)")
            useWeatherkit.runWeatherkit(location:myLocation) { weathers in
                self.weather = weathers
            
                
               
               
                let hourlyPrecipitationPercent = Int(round((self.weather?.hourlyForecast[self.currentHour ?? 0].precipitationChance ?? 1) * 100))
                self.gangsoo.text = "강수확률 \(hourlyPrecipitationPercent * 100)% "
                self.configureUI()
                
                
            }
        
        
    }
    
    
    
    //MARK: - Actions
    
    
    @objc func button1Tapped() {
        //
        let controller = PrecipitationViewController()
        present(controller, animated: true)
        
    }
    
    
    @objc func button2Tapped () {
        
        let controller = SearchViewController()
        present(controller, animated: true)
        
        
    }
    
    
    @objc func button3Tapped () {
        let controller = RainSoundViewController    ()
        present(controller, animated: true)
        
    }
    
    

    
    @objc func button4Tapped () {
        let controller = SettingViewController()
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @objc func timerProc(timer:Timer){
        
        let date = Date()
        
        
        
        let formatter = DateFormatter();
        
        
        
        formatter.dateFormat = "a hh:mm:ss "
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        let msg = formatter.string(from: date)

        
        timeLabel.text = msg
//
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
    
    @objc func resetButtonTapped() {
//
        location()

        runweatherkit(latitude: lat, longitude: lon)
        print("초기화")
        
        
        
    }
    
    
    
    
    
    
    
    @objc func test(_ notification:NSNotification){
           
        
        guard let mapitem = notification.object as? [String] else {return}
        
        print("map\(mapitem)")
        
       mapItemArray = mapitem
        
         locationLabel.text = mapItemArray[0]
//
        lat = Double(mapItemArray[2])!
        lon = Double(mapItemArray[3])!
        
        runweatherkit(latitude: lat, longitude: lon)
        
        
        
        
      
     
        
           
        
        
        }
    

    
    
}





