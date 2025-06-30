import Foundation

class SearchService {
    private static let SUBSTRING_BOOST = 50
    private static let PREFIX_BOOST = 30
    private static let TOKEN_MATCH_BOOST = 10
    private static let MIN_SCORE = 10

    // Edit distance boost constants
    private static let EDIT_DISTANCE_1_BOOST = 25
    private static let EDIT_DISTANCE_2_BOOST = 15
    private static let EDIT_DISTANCE_3_BOOST = 8
    private static let EDIT_DISTANCE_4_BOOST = 4
    private static let EDIT_DISTANCE_5_BOOST = 2

    public static func search<T: LosslessStringConvertible>(
        query: String, items: [T], resultLimit: Int = 5
    ) -> [T] {
        let scoredItems = items.map { (item: T) -> (T, Int) in
            (item, score(for: query, itemString: String(item)))
        }
        let filteredItems = scoredItems.filter { $0.1 >= MIN_SCORE }
        let sortedItems = filteredItems.sorted { $0.1 > $1.1 }
        return sortedItems.prefix(resultLimit).map { $0.0 }
    }

    private static func logBundleIdsWithScore(scoreItems: [(App, Int)]) {
        for item in scoreItems {
            print("(\(item.1)) ▸ \(item.0.bundleIdentifier)")
        }
    }

    private static func score(for query: String, itemString: String) -> Int {
        let normalizedQuery = query.lowercased()
        // replace the delimiter with a period to make it easier to tokenize
        let normalizedItem = itemString.lowercased().replacingOccurrences(
            of: App.DELIMITER, with: ".")

        var score = 0

        // Substring boost
        if normalizedItem.contains(normalizedQuery) {
            score += SUBSTRING_BOOST
        }

        // Prefix boost
        if normalizedItem.hasPrefix(normalizedQuery) {
            score += PREFIX_BOOST
        }

        // Token match boost
        let queryTokens = Set(normalizedQuery.split(separator: " "))
        let documentTokens = Set(normalizedItem.split(separator: " "))
        let commonTokens = queryTokens.intersection(documentTokens)
        score += commonTokens.count * TOKEN_MATCH_BOOST

        // Edit distance boost
        score += calculateEditDistanceScore(query: normalizedQuery, itemString: normalizedItem)

        return score
    }

    private static func calculateEditDistanceScore(query: String, itemString: String) -> Int {
        var score = 0

        // Tokenize based on the fact that we know query contains file paths
        // and bundle identifiers that are delimited by slashes and periods respectively.
        let queryTokens = tokenize(query)
        let itemTokens = tokenize(itemString)

        // Find the lowest edit distance between any query token and any document token
        // We picked the lowest because we want to prioritize the most relevant token.
        var minDistance = Int.max
        for queryToken in queryTokens {
            for itemToken in itemTokens {
                let distance = levenshteinDistance(queryToken, itemToken)
                minDistance = min(minDistance, distance)
            }
        }

        // If no tokens found, use distance between full strings
        if minDistance == Int.max {
            minDistance = levenshteinDistance(query, itemString)
        }

        // Add boost based on edit distance
        switch minDistance {
        case 1:
            score += EDIT_DISTANCE_1_BOOST
        case 2:
            score += EDIT_DISTANCE_2_BOOST
        case 3:
            score += EDIT_DISTANCE_3_BOOST
        case 4:
            score += EDIT_DISTANCE_4_BOOST
        case 5:
            score += EDIT_DISTANCE_5_BOOST
        default:
            break
        }

        return score
    }

    private static func tokenize(_ string: String) -> [String] {
        let tokens = string.components(separatedBy: CharacterSet(charactersIn: " ./"))
        return tokens.filter { !$0.isEmpty }
    }

    private static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let empty = Array(repeating: 0, count: s2.count + 1)
        var last = Array(0...s2.count)

        for (i, char1) in s1.enumerated() {
            var current = [i + 1] + empty
            for (j, char2) in s2.enumerated() {
                current[j + 1] =
                    char1 == char2 ? last[j] : min(last[j], last[j + 1], current[j]) + 1
            }
            last = current
        }
        return last[s2.count]
    }
}
