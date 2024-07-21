//
//  MapViewModel.swift
//  Umbrella
//
//  Created by 임재현 on 7/21/24.
//

import RxSwift
import CoreLocation


class MapViewModel {
    let selectedLocation = PublishSubject<CLLocation>()
    var currentLocation: CLLocation?
}
