//
//  MyCustomService.swift
//  LaibanExample
//
//  Created by Tomas Green on 2022-09-19.
//

import Foundation
import Laiban
import Combine

extension LBViewIdentity {
    static let myCustomService = LBViewIdentity("MyCustomService")
}

class MyCustomService : ObservableObject,LBDashboardItem {
    var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    @Published var isAvailable: Bool = true
    var viewIdentity: LBViewIdentity = .myCustomService
}
