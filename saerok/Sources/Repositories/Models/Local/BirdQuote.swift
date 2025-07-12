//
//  BirdQuote.swift
//  saerok
//
//  Created by HanSeung on 6/12/25.
//


struct BirdQuote {
    static let all: [String] = [
        "오늘은 어떤 새를\n관찰해볼까요?",
        "오늘 발견한 새,\n함께 기록해보아요.",
        "작은 날개짓도\n소중한 기록이에요!",
        "새를 보기 위한\n기다림은\n탐조의 시작이에요.",
        "관찰을 통해\n새를 더 알아가요!",
        "오늘은 어떤 새를\n보게 될까요?",
        "오늘은 어떤 새를\n보았나요?",
        "오늘 나의 시야를\n사로잡은\n새가 있었나요?",
        "날아간 새를\n기록으로\n남겨보아요!",
        "오늘 만난\n새의 이름은\n무엇일까요?",
        "잠시 멈춰\n새들의 노래에\n귀 기울여보세요.",
        "여러분만의\n탐조 일지를\n만들어보아요!",
        "새를 만나\n어떤 감정을\n느꼈나요?"
    ]

    static func random() -> String {
        all.randomElement() ?? ""
    }
}
