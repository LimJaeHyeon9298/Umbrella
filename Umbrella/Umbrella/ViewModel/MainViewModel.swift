//
//  MainViewModel.swift
//  Umbrella
//
//  Created by 임재현 on 6/23/24.
//

import Foundation
import RxSwift
import CoreLocation
import RxCocoa
import WeatherKit
import Foundation
import CoreLocation
import RxSwift

class MainViewModel: NSObject, CLLocationManagerDelegate {
    private let disposeBag = DisposeBag()
    var weatherData = PublishSubject<Weather>()
    var isLoading = BehaviorSubject<Bool>(value: false)
    var error = PublishSubject<Error>()
    var locationAddress = BehaviorSubject<String>(value: "위치를 확인할 수 없습니다.")
    var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        configureLocationManager()
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        updateLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error.onNext(error)
    }
    
    func updateLocation(_ location: CLLocation) {
           fetchWeather(for: location)
           reverseGeocodeLocation(location: location)
        locationManager.stopUpdatingLocation()
       }
    
    private func fetchWeather(for location: CLLocation) {
        isLoading.onNext(true)
        
        UseWeatherkit.shared.fetchWeather(location: location)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] weather in
                self?.isLoading.onNext(false)
                self?.weatherData.onNext(weather)
            }, onError: { [weak self] error in
                self?.isLoading.onNext(false)
                self?.error.onNext(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func reverseGeocodeLocation(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "ko-kr")) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.first else { return }
            // let address = "\(placemark.locality ?? "") \(placemark.subLocality ?? "")"
            let address = "\(placemark.locality ?? "")\n\(placemark.subLocality ?? "")"
            self.locationAddress.onNext(address)
        }
    }
    
    
    
    
}
