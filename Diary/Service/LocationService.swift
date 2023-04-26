//
//  LocationService.swift
//  Diary
//
//  Created by Higashihara Yoki on 2023/04/26.
//

import Combine
import CoreLocation

public class LocationService: NSObject, ObservableObject {
    static public let shared = LocationService()

    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()

    @Published public var authStatus: CLAuthorizationStatus?
    @Published public var location: CLLocation?

    override private init() {
        super.init()

        locationManager.delegate = self

        $authStatus
            .sink { status in
                guard let status,
                      status == .authorizedAlways || status == .authorizedWhenInUse
                else {
                    return
                }
                self.locationManager.requestLocation()
            }
            .store(in: &cancellables)
    }

    public func requestWhenInUseAuthorization() {
        guard locationManager.authorizationStatus == .notDetermined else {
            return
        }

        locationManager.requestWhenInUseAuthorization()
    }

    public func requestLocation() {
        guard locationManager.authorizationStatus == .authorizedAlways ||
                locationManager.authorizationStatus == .authorizedWhenInUse
        else {
            return
        }

        locationManager.requestLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
}

