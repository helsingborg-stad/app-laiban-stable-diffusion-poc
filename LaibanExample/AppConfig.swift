//
//  AppConfig.swift
//  Laiban
//
//  Created by Tomas Green on 2021-09-17.
//

import Foundation
import AppSettings
import MSCognitiveServices
import Laiban

struct AppConfig: AppSettingsConfig, Equatable {
    let analyticsEnabled:Bool?
    let msTranslatorKey:String?
    let msTranslatorRegion:String?
    let msSpeechKey:String?
    let msSpeechRegion:String?
    let instagramClientId:String?
    let instagramCallbackScheme:String?
    let instagramServerURL:String?

    func combine(deafult config: AppConfig?) -> AppConfig {
        guard let config = config else {
            return self
        }
        let analyticsEnabled = self.analyticsEnabled ?? config.analyticsEnabled
        let msTranslatorKey = self.msTranslatorKey ?? config.msTranslatorKey
        let msTranslatorRegion = self.msTranslatorRegion ?? config.msTranslatorRegion
        let msSpeechKey = self.msSpeechKey ?? config.msSpeechKey
        let msSpeechRegion = self.msSpeechRegion ?? config.msSpeechRegion
        let instagramClientId = self.instagramClientId ?? config.instagramClientId
        let instagramCallbackScheme = self.instagramCallbackScheme ?? config.instagramCallbackScheme
        let instagramServerURL = self.instagramServerURL ?? config.instagramServerURL
        return .init(
            analyticsEnabled:analyticsEnabled,
            msTranslatorKey:msTranslatorKey,
            msTranslatorRegion:msTranslatorRegion,
            msSpeechKey:msSpeechKey,
            msSpeechRegion:msSpeechRegion,
            instagramClientId:instagramClientId,
            instagramCallbackScheme:instagramCallbackScheme,
            instagramServerURL:instagramServerURL
        )
    }
    var msTextTranslatorConfig:MSTextTranslator.Config? {
        guard let key = msTranslatorKey else {
            return nil
        }
        guard let region = msTranslatorRegion else {
            return nil
        }
        return .init(key: key, region: region)
    }
    var msSpeechConfig:MSTTS.Config? {
        guard let key = msSpeechKey else {
            return nil
        }
        guard let region = msSpeechRegion else {
            return nil
        }
        return .init(key: key, region: region)
    }
    var keyValueRepresentation: [String : String] {
        var dict = [String:String]()
        dict["Analytics Enabled"] = analyticsEnabled == true ? "ja" : "nej"
        dict["Microsoft Translator Key"] = String.mask(msTranslatorKey, leave: 4)
        dict["Microsoft Translator Region"] = msTranslatorRegion
        dict["Microsoft Speech Key"] = String.mask(msSpeechKey, leave: 4)
        dict["Microsoft Speech Region"] = msSpeechRegion
        dict["Instagram ClientId"] = String.mask(instagramClientId, leave: 4)
        dict["Instagram Callback Scheme"] = instagramCallbackScheme
        dict["Instagram Server Url"] = instagramServerURL
        return dict
    }

}
