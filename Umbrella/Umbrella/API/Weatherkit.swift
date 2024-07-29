//
//  Weatherkit.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/24.
//

import Foundation
import WeatherKit
import CoreLocation
import RxSwift


class UseWeatherkit {
    
 static let shared = UseWeatherkit()
    
    private init () {}
    
    var weather: Weather?
    
    let weatherService = WeatherService.shared
    

}

extension UseWeatherkit {
    func fetchWeather(location:CLLocation) -> Observable<Weather> {
        return Observable.create { observer in
            let task = Task {
                do {
                    
                    
                    let weather = try await self.weatherService.weather(for: location)
                   
                   // print("--------이게 weatherkit의 낧씨다 \(weather) /n -------------------------------")
//                    if let dailyWeather = weather.dailyForecast.first {
//                        print("내일의 강수 확률은 \(dailyWeather.precipitationChance * 100)%입니다.")
//                        
//                    }
//                    
//                    if let hourlyWeather = weather.hourlyForecast.first {
//                        print("다음 시간의 강수 확률은 \(hourlyWeather.precipitationChance * 100)%입니다.")
//                    }
                    
                    let hourlyForecast = weather.hourlyForecast
                                    for (index, hourly) in hourlyForecast.prefix(24).enumerated() {
                                        print("\(index)시간 뒤의 강수 확률은 \(hourly.precipitationAmount)%입니다.")
                                    }
                    
//                    weather.currentWeather.precipitationIntensity
//                    ㅙㅕㄱ
                    
                    print(" gkgkgkgkgkgk\( weather.currentWeather.precipitationIntensity)")
                    
                    observer.onNext(weather)
                    observer.onCompleted()
                    
                }
                catch {
                    print("Error fetching weather:\(error)")
                    observer.onError(error)
                }
            }
            return Disposables.create {
                task.cancel()
            }
        }
        
    }
}
