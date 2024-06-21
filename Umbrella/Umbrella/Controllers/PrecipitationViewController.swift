//
//  ViewController2.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/15.
//

import UIKit
import WeatherKit
import CoreLocation




let reuseIdentifier = "TableViewCell"


class PrecipitationViewController:UIViewController,CLLocationManagerDelegate {
    
    
    //MARK: - Properties
    
    let controller = MainViewController()
    var locationManger = CLLocationManager()
    var mapItemArray:[String] = []
    var weather: Weather?
    var timeCollect:[Int] = []
    
    var useWeatherkit = UseWeatherkit()
    
    
    
    
    var lat:Double = 0.0 {
        didSet {
            
            print("latChanged\(lat)")
            
            
        }
    }
    var lon:Double = 0.0 {
        
        didSet { print("lonChanged\(lon)")
            
            
        }
    }
    
    
    private let titleLabel:UILabel = {
        
        let label = UILabel()
        
        label.text = "시간대별 강수확률"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        
        return label
        
        
        
    }()
    private let tableView:UITableView = {
        let view = UITableView()
        return view
    }()
    
    
      var hourlyPrecipitation = [Int]()
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configUI()
        //location()
        tableView.delegate = self
        tableView.dataSource = self
        lat = controller.lat
        
        lon = controller.lon
        
        runweatherkit(latitude: lat, longitude: lon)
        self.alert("지금버전은 현재지역 강수량만 확인가능합니다")
      
    }
    
    override func viewWillAppear(_ animated: Bool) {

      //  NotificationCenter.default.addObserver(self, selector: #selector(test(_:)), name: NSNotification.Name("test"), object: nil)
        navigationController?.isNavigationBarHidden = true

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
            print("위도2: \(location.coordinate.latitude)")
            print("경도2: \(location.coordinate.longitude)")
            lat = location.coordinate.latitude
            lon = location.coordinate.longitude

            locationManger.stopUpdatingLocation()
            runweatherkit(latitude: lat, longitude: lon)
        }
    }

    // 위도 경도 받아오기 에러
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    func configUI() {
        
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top:view.topAnchor,left: view.leftAnchor,paddingTop: 10,paddingLeft: 20)
        
        view.addSubview(tableView)
        tableView.anchor(top:view.topAnchor,left: view.leftAnchor,bottom: view.bottomAnchor,right: view.rightAnchor,paddingTop: 100,paddingLeft: 0,paddingBottom: 0,paddingRight: 0)
        tableView.backgroundColor = .lightGray
        
        tableView.register(WeatherCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        
    }
    
    
    
    func runweatherkit(latitude:Double,longitude:Double) {
        
        let myLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        useWeatherkit.runWeatherkit(location: myLocation) { weathers in
            self.weather = weathers
            //let hiii = self.weather?.currentWeather.temperature.value ?? 12
            for i in 0...23 {
                
                
                let hourlyPrecipitationPercent = Int(round((self.weather?.hourlyForecast[i].precipitationChance ?? 1) * 100))
                self.hourlyPrecipitation.append(hourlyPrecipitationPercent)
                self.timeCollect.append(i)
                
                print("시간당강수확률\(self.hourlyPrecipitation)+\(self.lat)+\(self.lon)")
                print("시간당강수확률퍼센트\(hourlyPrecipitationPercent)")
                
                
            }
            self.configUI()
            self.tableView.reloadData()
         
       
        }
      
    }
    
    //MARK: - Actions

}
extension PrecipitationViewController : UITableViewDelegate,UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return hourlyPrecipitation.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! WeatherCell
        cell.backgroundColor = .lightGray
        cell.timeLabel.text = String(timeCollect[indexPath.row])
        cell.gansoohwakyul.text = String("강수확률:\(hourlyPrecipitation[indexPath.row])%")
        
        return cell
    }
    
}

extension PrecipitationViewController {
    func alert(_ message: String, completion: (()->Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .cancel) { (_) in
                completion?()
            }
            alert.addAction(okAction)
            self.present(alert, animated: false)
        }
    }
}
