//
//  Weatherkit.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/24.
//

import Foundation
import WeatherKit
import CoreLocation


class UseWeatherkit {
    
    var weather: Weather?
    
    let weatherService = WeatherService.shared
    
    
 
    
    
    
     func runWeatherkit(location:CLLocation,completion:@escaping((Weather)->Void)) {
        
        
        
        DispatchQueue.main.async {
            Task{
                do {
                    self.weather = try await self.weatherService.weather(for: location)
                    
                    
                    guard let weather = self.weather else {return}
                    
                    completion(weather)
                    
                    
                } catch {
                    
                   
                    
                    print("DEVBUG:\(error)")
                   
                    
                }
            }
        }
        
        
        
        
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
