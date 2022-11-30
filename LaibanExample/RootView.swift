//
//  ContentView.swift
//  LaibanExample
//
//  Created by Tomas Green on 2022-09-16.
//

import SwiftUI

import SwiftUI
import Combine
import Assistant
import Laiban

struct RootView : View {
    @EnvironmentObject var appState:AppState
    var dashboardLayout:[[LBDashboardItem]] {
        let a = appState
        return [
            [a.timeService,         a.calendarService,  a.singalongService,     a.foodService,      a.foodWasteService          ],
            [a.outdoorsService,     a.movementService,  a.recreationService,    a.activityService,  a.instagramService          ],
            [a.memoryGameService,   a.undpService,      a.trashMonsterService,  a.noticeboardService /*, a.myCustomService*/    ]
        ]
    }
    var config: LBRootViewConfig {
        .init(
            dashboardItems: dashboardLayout,
            adminServices: appState.adminServices
        )
    }
    var body: some View {
        LBRootView(config: config)
            .icon { item in
                switch item {
                case LBViewIdentity.time:            TimeHomeViewIcon()
                case LBViewIdentity.activities:      ActivitiesHomeViewIcon()
                case LBViewIdentity.outdoors:        OutdoorsHomeViewIcon(service: appState.outdoorsService)
                case LBViewIdentity.food:            FoodHomeViewIcon()
                case LBViewIdentity.foodwaste:       FoodWasteHomeViewIcon()
                case LBViewIdentity.singalong:       SingalongHomeViewIcon()
                case LBViewIdentity.calendar:        CalendarHomeViewIcon()
                case LBViewIdentity.instagram:       InstagramHomeViewIcon()
                case LBViewIdentity.recreation:      RecreationHomeViewIcon()
                case LBViewIdentity.memory:          MemoryHomeViewIcon()
                case LBViewIdentity.trashmonster:    TrashMonstersHomeViewIcon()
                case LBViewIdentity.noticeboard:     NoticeboardHomeViewIcon()
                case LBViewIdentity.undpinfo:        UNDPHomeViewIcon()
                case LBViewIdentity.movement:        MovementHomeViewIcon()
                //case LBViewIdentity.myCustomService: MyCustomViewIcon()
                default: EmptyView()
                }
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
                case LBViewIdentity.recreation:      RecreationView()
                case LBViewIdentity.singalong:       SingalongView()
                case LBViewIdentity.time:            TimeView(service:appState.timeService, contentProvider: nil)
                case LBViewIdentity.trashmonster:    TrashMontersView()
                case LBViewIdentity.undpinfo:        UNDPInfoView()
                case LBViewIdentity.home:            HomeView(publicCalendar: appState.publicCalendar, activityService: appState.activityService)
                case LBViewIdentity.movement:        MovementView(service: appState.movementService)
                //case LBViewIdentity.myCustomService: MyCustomView(service: appState.myCustomService)
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
