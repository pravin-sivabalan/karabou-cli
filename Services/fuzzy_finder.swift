import Foundation

class FuzzyFinder {
    func find(query: String) -> String {
        let apps = Apps()
        return apps.getActiveApp()
    }
}

func main() {
    let fuzzyFinder = FuzzyFinder()
    let result = fuzzyFinder.find(query: "chrome")
    print(result)
}