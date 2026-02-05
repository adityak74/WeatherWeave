//
//  LocationManager.swift
//  WeatherWeave
//
//  Created by WeatherWeave on 2026-02-05.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var cityName: String = "Unknown"
    @Published var error: Error?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    func getCurrentLocation() {
        print("getCurrentLocation called, status: \(authorizationStatus.rawValue)")
        guard authorizationStatus == .authorizedAlways else {
            print("Location authorization not granted: \(authorizationStatus.rawValue)")
            return
        }
        print("Requesting location...")
        locationManager.requestLocation()
    }

    private func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                self?.error = error
                return
            }

            if let placemark = placemarks?.first {
                self?.cityName = placemark.locality ?? placemark.subLocality ?? "Unknown"
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("Authorization status changed to: \(authorizationStatus.rawValue)")

        if authorizationStatus == .authorizedAlways {
            getCurrentLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        reverseGeocode(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
        print("Location error: \(error.localizedDescription)")
    }
}
