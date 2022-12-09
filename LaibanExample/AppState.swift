//
//  AppState.swift
//  LaibanApp-iOS
//
//  Created by Tomas Green on 2020-03-18.
//  Copyright © 2020 Evry AB. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

// Misc
import MSCognitiveServices
import AsyncPublisher

// Laiban
import Laiban

// Daisy
import Analytics
import Dragoman
import Assistant
import Instagram
import AppSettings
import Shout
import TTS
import AudioSwitchboard
import STT
import PublicCalendar
import Weather

class AppState : ObservableObject {
    var singalongService = SingalongService()
    var recreationService = RecreationService()
    var undpService = UNDPService()
    var trashMonsterService = TrashMonstersService()
    var instagramService = InstagramService()
    var noticeboardService = NoticeboardService()
    var memoryGameService = MemoryGameService()
    var participantService = ParticipantService()
    var activityService = ActivityService()
    var feedbackService = FeedbackService()
    var foodService = FoodService()
    var timeService = TimeService()
    var outdoorsService = OutdoorsService()
    var calendarService = CalendarService()
    var foodWasteService = FoodWasteService()
    var languageService = LanguageService()
    var returnToHomeScreenService = ReturnToHomeScreenService()
    var movementService = MovementService()
    var appAnalytics = AppAnalytics()
    
    // App specific services
    var myCustomService = MyCustomService()
    
    var adminServices:[LBAdminService] {
        return [
            instagramService,
            noticeboardService,
            memoryGameService,
            participantService,
            activityService,
            feedbackService,
            foodService,
            timeService,
            outdoorsService,
            calendarService,
            foodWasteService,
            languageService,
            returnToHomeScreenService,
            movementService
        ]
    }
    private var cancellables = Set<AnyCancellable>()
    
    let ttsLogger = Shout("TTS")
    var translator = MSTextTranslator(config: nil)
    var settings:LaibanSettings
    var msTTS:MSTTS
    var publicCalendar = PublicCalendar(fetchAutomatically: true, previewData: isPreview)
    var reportFoodDataTimer:Timer?
    var reportFoodWasteInProgress = false
    var assistant:Assistant
    let switchboard = AudioSwitchboard()
    @Published var events:[PublicCalendar.Event]? = nil
    @Published var currentLanguage:Locale = Locale(identifier: "sv_SE")
    @Published private(set) var setupCompleted = false
    
    var willTranslateTimer:Timer? = nil
    init() {
        self.settings = LaibanSettings(defaultsFromFile: Bundle.main.url(forResource: "Config", withExtension: "plist"), managedConfigEnabled: true)
        self.msTTS = MSTTS(config: nil, audioSwitchboard: switchboard)
        self.assistant = Assistant(
            sttService: AppleSTT(audioSwitchboard: switchboard, fft: nil),
            ttsServices: AppleTTS(audioSwitchBoard: switchboard),
            supportedLocales: languageService.data.languages,
            translator: translator,
            ttsGender: languageService.data.ttsGender,
            ttsPitch: languageService.data.ttsPitch,
            ttsRate: languageService.data.ttsRate,
            audioSwitchboard: switchboard
        )
        if !LBDevice.isDebug {
            defaultLogger.disabled = true
        }
        if LBDevice.isPreview {
            assistant.stt.disabled = true
            assistant.stt.disabled = true
        }
        assistant.dragoman.logger = defaultLogger
        assistant.tts.add(service: msTTS,prioritized: true)
        
        appAnalytics.initWith(settings: settings)

        translator.logger = defaultLogger
        translator.config = settings.config?.msTextTranslatorConfig
        
        assistant.dragoman.translationService = translator
        assistant.dragoman.add(bundle: LBBundle)
        
        msTTS.config = settings.config?.msSpeechConfig
        msTTS.pronunciations = pronunciationAdjustments
        
        $currentLanguage.sink { value in
            self.assistant.locale = value
        }.store(in: &cancellables)
        
        settings.$config.sink { config in
            self.updateInstagramSettings()
            self.translator.config = config?.msTextTranslatorConfig
            self.msTTS.config = config?.msSpeechConfig
        }.store(in: &cancellables)
        
        updateInstagramSettings()
        
        func checkServices() -> Bool {
            for service in adminServices {
                guard let s = service as? LBService else {
                    continue
                }
                if s.status != .idle {
                    return false
                }
            }
            return true
        }
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            if checkServices() {
                timer.invalidate()
                self.completeInitialization()
            }
        }
    }
    func completeInitialization(){
        // Setting upp assistant properties based on settings stored in language service
        assistant.ttsRate = languageService.data.ttsRate
        assistant.ttsPitch = languageService.data.ttsPitch
        assistant.ttsGender = languageService.data.ttsGender
        assistant.supportedLocales = languageService.data.languages
        
        // Listen for changes in langauge service and adjusting the assistant accordingly
        languageService.$data.sink { data in
            self.assistant.ttsRate = data.ttsRate
            self.assistant.ttsPitch = data.ttsPitch
            self.assistant.ttsGender = data.ttsGender
            self.assistant.supportedLocales = data.languages
            if self.languageService.data.languages != data.languages {
                self.willTranslateTimer?.invalidate()
                self.willTranslateTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                    self.translateAll()
                }
            }
        }.store(in: &cancellables)
        
        for service in adminServices {
            // Find all translation publishers in admin services
            if let s = service as? LBTranslatableContentProvider {
                s.stringsToTranslatePublisher.sink { strings in
                    self.assistant.translate(strings)
                }.store(in: &cancellables)
            }
            
            // Set particiapant publisher callbacks
            if let s = service as? LBParticipants {
                s.setParticipantsPublisher(publisher: participantService.getParticipantPublisher)
                s.setUpdateParticipantCallback(callback: handleParticipantCallback)
            }
        }
        
        // Connecting activity feedback with feedback service
        activityService.ratingPublisher.sink { rating in
            _ = self.feedbackService.add(reaction: rating.reaction, category: .activity, value: rating.activity)
            Task {
                await self.feedbackService.save()
            }
        }.store(in: &cancellables)
        
        // Connecting food feedback with feedback service
        foodService.ratingPublisher.sink { rating in
            let value = self.feedbackService.add(reaction: rating.reaction, category: .lunch, value: rating.food)
            self.foodService.setStaistics(.init(
                rating1: value.sum(.sad),
                rating2: value.sum(.neutral),
                rating3: value.sum(.happy),
                rating4: value.sum(.veryHappy),
                food: value.value
            ))
        }.store(in: &cancellables)
        
        // Populate calendar with public calendar events
        publicCalendar.latest.sink { events in
            guard let events = events else {
                return
            }
            let items = events.events(in: [.holidays,.nights])
            self.events = items
            self.translate(items.map { $0.title })
        }.store(in: &cancellables)
        
        self.translateAll()
        self.setupCompleted = true
    }
    func updateInstagramSettings() {
        guard let clientId = settings.config?.instagramClientId,let serverURL = settings.config?.instagramServerURL, let callbackScheme = settings.config?.instagramCallbackScheme else {
            return
        }
        let servicename = "\(Bundle.main.bundleIdentifier ?? "unknownapp")-instagram"
        instagramService.instagram.config = .init(serverURL: serverURL, callbackScheme: callbackScheme, clientId: clientId,keychainServiceName:servicename, keychainCredentialsKey: "instagramcredentials")
    }
    func handleParticipantCallback(participant: String, action: UpdateParticipantAction) {
        switch action {
        case .add: participantService.addParticipant(name: participant)
        case .remove: participantService.removeParticipant(name: participant)
        }
        Task {
            await participantService.save()
        }
    }
    // Translate all strings from services
    func translateAll() {
        var strings = [String]()
        strings.append(contentsOf: (events ?? []).map { $0.title })
        for service in adminServices {
            if let s = service as? LBTranslatableContentProvider {
                strings.append(contentsOf: s.stringsToTranslate)
            }
        }
        translate(strings)
    }
    // Translate an array of strings
    func translate(_ strings:[String]) {
        Task.detached { [assistant] in
            do {
                try await makeAsync(assistant.translate(strings))
            } catch {
                defaultLogger.error(error)
            }
        }
    }
}

extension AppState : NoticeboardContentProvider, TimeViewContentProvider, CalendarContentProvider {
    func otherClockItemsPublisher() -> AnyPublisher<[Laiban.ClockItem]?, Never> {
        activityService.$data.map { arr in
            arr.filter { $0.date.today == true && $0.starts != nil }.map {
                ClockItem(id: $0.id, emoji: $0.emoji ?? "🧩", date: $0.starts!, text: $0.formattedContent(), color: Color("RimColorActivities", bundle: LBBundle))
            }
        }.eraseToAnyPublisher()
    }
    
    func otherCalendarEventsPublisher() -> AnyPublisher<[OtherCalendarEvent]?, Never> {
        publicCalendar.latest.map { events -> [OtherCalendarEvent]? in
            guard let events = events?.events(in: [.holidays,.nights]) else {
                return nil
            }
            var result = [OtherCalendarEvent]()
            for event in events {
                if event.category == .holidays || event.category == .nights {
                    result.append(.init(date: event.date, title: event.title, emoji: "🎉"))
                } else {
                    result.append(.init(date: event.date, title: event.title, emoji: "💡"))
                }
            }
            return result
        }.eraseToAnyPublisher()
    }
    
    func noticeboardWeatherConditionsPublisher(from: Date, to: Date) -> AnyPublisher<Set<NoticeboardWeatherCondition>, Never> {
        outdoorsService.dataService.betweenDates(from: from, to: to).replaceNil(with: []).map { array in
            var res = Set<NoticeboardWeatherCondition>()
            for weather in array {
                if weather.precipitationCategory != .none {
                    res.insert(.precipitation)
                }
                if Date().month >= 4 && Date().month <= 10 && [ WeatherSymbol.clearSky,WeatherSymbol.nearlyClearSky,WeatherSymbol.halfclearSky,WeatherSymbol.variableCloudiness].contains(weather.symbol) {
                    res.insert(.sunny)
                }
                let c = weather.conditions
                if !(c == .hot || c == .warm || c == .unknown) {
                    res.insert(.conditionAppropriateClothes)
                }
            }
            return res
        }.eraseToAnyPublisher()
    }
}
