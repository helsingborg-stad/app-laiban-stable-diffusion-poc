//
//  PronunciationAdjustments.swift
//  LaibanExample
//
//  Created by Ehsan Zilaei on 2022-12-07.
//

import Foundation
import MSCognitiveServices

/// Example of MS cognitive pronunciation adjustments.
var pronunciationAdjustments: [Locale: [MSPronunciation]] = [
    Locale(identifier: "sv_SE"): [
        .init(string: "1 banan", replacement: " en banan"),
        .init(string: "banan", replacement: "<phoneme alphabet='ipa' ph='banɑːn'>banan</phoneme>"),
        .init(string: "Bananskal", replacement: "<phoneme alphabet='ipa' ph='banɑːn'>Banan</phoneme>skal"),
        .init(string: "1 kycklingklubba", replacement: "en kycklingklubba"),
        .init(string: "1 brödbit", replacement: "en brödbit"),
        .init(string: "1 köttbit", replacement: "en köttbit"),
        .init(string: "grönsaksbuffé", replacement: "grönsaks buffé"),
        .init(string: "ateljén", replacement: "ateljeen"),
        .init(string: "Ateljén", replacement: "Ateljeen"),
        .init(string: "Plastis", replacement: "Plast-is"),
        .init(string: "Pappis", replacement: "Papp-is"),
        .init(string: "sås", replacement: "<phoneme alphabet='ipa' ph='sɒs'>sås</phoneme>"),
        .init(string: "Sås", replacement: "<phoneme alphabet='ipa' ph='sɒs'>Sås</phoneme>"),
        .init(string: "couscous", replacement: "coos-coos"),
        .init(string: "Couscous", replacement: "Coos-coos"),
        .init(string: "el", replacement: "eel"),
        .init(string: "El", replacement: "Eel"),
        .init(string: "äppelskrutt", replacement: "äppel-skrutt"),
        .init(string: "Äppelskrutt", replacement: "Äppel-skrutt"),
        .init(string: "Pedagogen", replacement: "pedagog-en"),
        .init(string: "pedagogen", replacement: "Pedagog-en"),
        .init(string: "Kellogspaket", replacement: "Kell-loggspaket"),
        .init(string: "iPads", replacement: "aj-pädds"),
        .init(string: "Glasmo", replacement: "Glaasmo"),
        .init(string: "LED", replacement: "LÄDD"),
        .init(string: "fulspolningar", replacement: "ful-spolningar"),
    ]
]
