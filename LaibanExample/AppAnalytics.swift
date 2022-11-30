//
//  AppAnalytics.swift
//  LaibanExample
//
//  Created by Fredrik Häggbom on 2022-11-14.
//

import Analytics
import Combine
import Foundation

/// Helper class for collecting analytics data from the app and send to custom analytics backend. Optional to use.
/// To add your own analytic event in the app, use the `AnalyticsService.shared.log*` functions.
public class AppAnalytics {
    private var cancellables = Set<AnyCancellable>()
    private var settingsObserver: AnyCancellable?
    var isEnabled: Bool = false
    
    /// Initiate class with settings. Normally called from AppState
    /// - Parameter settings: LaibanSettings object containing a config parameter. The config object contains required information to to connect to analytics backend.
    func initWith(settings: LaibanSettings) {
        settingsObserver = settings.$config.sink { config in
            self.configure(using: config)
        }
    }
    
    /// Configure analytics service
    /// - Parameter config: Appconfig containing required information to to connect to analytics backend. If no valid config are found, no data will be sent to analytics service.
    func configure(using config: AppConfig?) {
        guard let config = config else {
            return
        }
        isEnabled = isEnabled(config: config)
        cancellables.forEach { $0.cancel() }
        cancellables = Set<AnyCancellable>()

        if isEnabled {
            subscribeToAnalyticsEvents()
        }
    }
        
    private func isEnabled(config: AppConfig) -> Bool {
        config.analyticsEnabled == true
    }
    
    private func subscribeToAnalyticsEvents() {
        /// Called when a page view is triggered (when a view is opened):
        AnalyticsService.shared.pageViewPublisher.sink { [weak self] pageView in
            guard let self = self, self.isEnabled else { return }
            // Send page view to analytics service
        }.store(in: &cancellables)
        
        /// Called when custom events oocurs, e.g. the user presses a button:
        AnalyticsService.shared.customPublisher.sink { [weak self] customEvent in
            guard let self = self, self.isEnabled else { return }
            let event = customEvent.name
            let properties = customEvent.properties
            // Handle custom event
        }.store(in: &cancellables)
        
        /// Called when an error occurs within the app. Recomended to be sent to crash reporting service (or analytics service):
        AnalyticsService.shared.errorPublisher.sink { [weak self] error in
            guard let self = self, self.isEnabled else { return }
            // Handle error event
        }.store(in: &cancellables)
        
        /// Called when content impression event occurs:
        AnalyticsService.shared.impressionPublisher.sink { [weak self] impression in
            guard let self = self, self.isEnabled else { return }
            // Handle impression event
        }.store(in: &cancellables)
        
        /// Called when user action events oocurs:
        AnalyticsService.shared.userActionPublisher.sink { [weak self] userAction in
            guard let self = self, self.isEnabled else { return }
            // Handle user action
        }.store(in: &cancellables)
    }
}
