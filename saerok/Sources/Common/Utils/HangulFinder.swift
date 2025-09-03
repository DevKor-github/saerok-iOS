import Foundation

class HangulFinder<Item> {
    private let initialConsonants: [Character] = [
        "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ",
        "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]
    
    private let vowels: [Character] = [
        "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ",
        "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"
    ]
    
    private let finalConsonants: [Character?] = [
        nil, "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ",
        "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ",
        "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]
    
    var items: [Item]
    private let keySelector: (Item) -> String
    private var decomposedItems: [(item: Item, decomposedKey: String)] = []
    
    init(items: [Item], keySelector: @escaping (Item) -> String) {
        self.items = items
        self.keySelector = keySelector
        decomposeAll()
    }
    
    func reInitialize(_ items: [Item]) {
        self.items = items
        decomposeAll()
    }
    
    func search(_ input: String) -> [Item] {
        let decomposedInput = input.flatMap(decomposeHangul).map { String($0) }.joined()
        
        return decomposedItems
            .filter { _, decomposedKey in
                decomposedKey.localizedCaseInsensitiveContains(decomposedInput)
            }
            .map { $0.item }
    }
}

private extension HangulFinder {
    func decomposeAll() {
        self.decomposedItems = items.map { item in
            let key = keySelector(item)
            let decomposed = key.flatMap(decomposeHangul).map { String($0) }.joined()
            return (item, decomposed)
        }
    }
    
    func decomposeHangul(_ char: Character) -> [Character] {
        guard let unicode = char.unicodeScalars.first?.value else { return [char] }
        if unicode.isHangulSyllable {
            let base = unicode - 0xAC00
            let initial = Int(base / (21 * 28))
            let vowel = Int((base % (21 * 28)) / 28)
            let final = Int(base % 28)
            
            var result = [initialConsonants[initial], vowels[vowel]]
            if let finalChar = finalConsonants[final] {
                result.append(finalChar)
            }
            return result
        }
        return [char]
    }
}

private extension UInt32 {
    var isHangulSyllable: Bool {
        return (self >= 0xAC00 && self <= 0xD7A3)
    }
}
