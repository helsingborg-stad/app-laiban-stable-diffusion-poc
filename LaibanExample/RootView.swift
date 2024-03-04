//
//  ContentView.swift
//  LaibanExample
//
//  Created by Tomas Green on 2022-09-16.
//

import SwiftUI
import Combine
import Assistant
import Laiban

@available(iOS 15.0 , *)
struct RootView : View {
    @EnvironmentObject var appState:AppState
    
    var config: LBRootViewConfig {
        .init(
            dashboardItems: appState.dashboardLayout,
            adminServices: appState.adminServices
        )
    }
    var body: some View {
        LBRootView(config: config)
            .icon { item in
                AppState.DashboardItemIcon(appState: appState, item: item)
            }
            .actionBar { item, properties in
                switch item {
                //case LBViewIdentity.time:            TimeActionBarView(actionBarProperties: properties)
                case LBViewIdentity.food:            FoodActionBarView(properties: properties)
                default: Spacer()
                }
            }
            .screen { item, propertis in
                switch item {
                case LBViewIdentity.activities:      ActivitiesView(service: appState.activityService)
                case LBViewIdentity.rateActivities:  ActivitiesFeedbackView(service: appState.activityService)
                case LBViewIdentity.calendar:        CalendarView(service: appState.calendarService, contentProvider: appState)
                case LBViewIdentity.outdoors:        OutdoorsView(service: appState.outdoorsService)
                case LBViewIdentity.food:            FoodView(service: appState.foodService)
                case LBViewIdentity.foodwaste:       FoodWasteView(service: appState.foodWasteService)
                case LBViewIdentity.instagram:       InstagramView(service: appState.instagramService)
                case LBViewIdentity.memory:          MemoryView(service: appState.memoryGameService)
                case LBViewIdentity.noticeboard:     NoticeboardView(service: appState.noticeboardService, contentProvider: appState)
                case LBViewIdentity.recreation:      RecreationView(service: appState.recreationService)
                case LBViewIdentity.singalong:       SingalongView()
                case LBViewIdentity.time:            TimeView(service:appState.timeService, contentProvider: nil)
                case LBViewIdentity.trashmonster:    TrashMontersView()
                case LBViewIdentity.undpinfo:        UNDPInfoView()
                case LBViewIdentity.home:            HomeView(publicCalendar: appState.publicCalendar, activityService: appState.activityService)
                case LBViewIdentity.imageGenerator:  ImageGeneratorView(service: appState.imageGeneratorService.service)
//                case LBViewIdentity.movement:        MovementView(service: appState.movementService)      // Disabled and waiting for feedback from test users.
//                case LBViewIdentity.myCustomService: MyCustomView()
                default: EmptyView()
                }
            }
            .onShouldDisable {
                return appState.languageService.data.voiceCancellable == false
            }
            .onLangaugeChanged { locale in
                self.appState.currentLanguage = locale
            }
    }
}
