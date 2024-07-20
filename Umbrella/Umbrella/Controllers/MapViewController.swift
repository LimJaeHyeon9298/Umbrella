//
//  MapViewController.swift
//  Umbrella
//
//  Created by 임재현 on 7/19/24.
//

import UIKit
import MapKit
import SnapKit

class MapViewController:UIViewController {
    
    let mapView = MKMapView()
    private let geocoder = CLGeocoder()
    private var lastSelectedLocation: CLLocation?
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
               mapView.addGestureRecognizer(tapGesture)
    }
    
    private func configureUI() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        mapView.mapType = MKMapType.standard
       
        mapView.delegate = self
        
        
        mapView.isZoomEnabled = true
        // 이동 가능 여부
        mapView.isScrollEnabled = true
        // 각도 조절 가능 여부 (두 손가락으로 위/아래 슬라이드)
        mapView.isPitchEnabled = true
        // 회전 가능 여부
        mapView.isRotateEnabled = true
        // 나침판 표시 여부
        mapView.showsCompass = true
        // 축척 정보 표시 여부
        mapView.showsScale = true
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.none, animated: true)
    }
    
    @objc func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
       
        if let lastLocation = lastSelectedLocation {
            let distance = newLocation.distance(from: lastLocation)
          
            if distance < 1000 {
                print("Selected location is too close to the previous location.")
                return
            }
           
        }
        addPin(at: coordinate)
            reverseGeocode(coordinate: coordinate)
        lastSelectedLocation = newLocation
        
    }

    func addPin(at coordinate: CLLocationCoordinate2D) {
            // 기존 핀 제거
            mapView.removeAnnotations(mapView.annotations)
            
            // 새로운 핀 추가
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            print("Selected coordinates: \(coordinate.latitude), \(coordinate.longitude)")
        }
    
    func reverseGeocode(coordinate: CLLocationCoordinate2D) {
           let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
           geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
               guard let self = self else { return }
               if let error = error {
                   print("Reverse geocoding failed: \(error.localizedDescription)")
                   return
               }
               guard let placemark = placemarks?.first else {
                   print("No placemarks found")
                   return
               }
               if let name = placemark.name, let locality = placemark.locality, let country = placemark.country {
                   print("Location: \(name), \(locality), \(country)")
               } else {
                   print("Location details not found")
               }
           }
       }
    
}

extension MapViewController:MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("지도 위치 변경")
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate,
                                        latitudinalMeters: 5000,
                                        longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
    }
    
    
    
}
