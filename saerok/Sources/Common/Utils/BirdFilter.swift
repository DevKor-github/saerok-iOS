//
//  BirdFilter.swift
//  saerok
//
//  Created by HanSeung on 4/13/25.
//


import Foundation
import SwiftUI

struct BirdFilter: Equatable {
    var searchText: String = ""
    var isBookmarked: Bool = false
    var selectedHabitats: Set<Habitat> = []
    var selectedSeasons: Set<Season> = []
    var selectedSizes: Set<BirdSize> = []
    
    func build() -> Predicate<Local.Bird> {
        let predicates: [Predicate<Local.Bird>] = [
            nameFilter(),
            bookmarkFilter(),
            seasonFilter(),
            habitatFilter(),
            sizeFilter()
        ].compactMap { $0 }
        
        return predicates
            .reduce(#Predicate { _ in true }) { acc, next in
                #Predicate { bird in
                    acc.evaluate(bird) && next.evaluate(bird)
                }
            }
    }
}

// MARK: - Predicate Components

private extension BirdFilter {
    func nameFilter() -> Predicate<Local.Bird>? {
        guard !searchText.isEmpty else { return nil }

        return .true
    }

    func bookmarkFilter() -> Predicate<Local.Bird>? {
        guard isBookmarked else { return nil }

        return #Predicate { bird in
            bird.isBookmarked
        }
    }

    func seasonFilter() -> Predicate<Local.Bird>? {
        guard !selectedSeasons.isEmpty else { return nil }

        let conditions: [Predicate<Local.Bird>] = selectedSeasons.map { season in
            #Predicate { bird in
                bird.seasonRaw.contains(season.rawValue)
            }
        }

        return conditions.reduce(#Predicate { _ in false }) { partialResult, next in
            #Predicate { bird in
                partialResult.evaluate(bird) || next.evaluate(bird)
            }
        }
    }
    
    func habitatFilter() -> Predicate<Local.Bird>? {
        guard !selectedHabitats.isEmpty else { return nil }

        let conditions: [Predicate<Local.Bird>] = selectedHabitats.map { habitat in
            #Predicate { bird in
                bird.habitatRaw.contains(habitat.rawValue)
            }
        }

        return conditions.reduce(#Predicate { _ in false }) { partialResult, next in
            #Predicate { bird in
                partialResult.evaluate(bird) || next.evaluate(bird)
            }
        }
    }
    
    func sizeFilter() -> Predicate<Local.Bird>? {
        guard !selectedSizes.isEmpty else { return nil }
        
        let conditions: [Predicate<Local.Bird>] = selectedSizes.map { size in
            #Predicate { bird in
                bird.sizeRaw.contains(size.rawValue)
            }
        }

        return conditions.reduce(#Predicate { _ in false }) { partialResult, next in
            #Predicate { bird in
                partialResult.evaluate(bird) || next.evaluate(bird)
            }
        }
    }
}
