struct CBOROptions {
    let useStringKeys: Bool
    let dateStrategy: DateStrategy
    let forbidNonStringMapKeys: Bool
    /// The maximum number of nested items, inclusive, to decode. A maximum set to 0 dissallows anything other than top-level primitives.
    let maximumDepth: Int
    let shouldSortMapKeys: Bool

    init(
        useStringKeys: Bool = false,
        dateStrategy: DateStrategy = .taggedAsEpochTimestamp,
        forbidNonStringMapKeys: Bool = false,
        maximumDepth: Int = .max,
        shouldShortMapKeys: Bool = true
    ) {
        self.useStringKeys = useStringKeys
        self.dateStrategy = dateStrategy
        self.forbidNonStringMapKeys = forbidNonStringMapKeys
        self.maximumDepth = maximumDepth
        self.shouldSortMapKeys = shouldShortMapKeys
    }
}

enum DateStrategy {
    case taggedAsEpochTimestamp
    case annotatedMap
}

struct AnnotatedMapDateStrategy {
    static let typeKey = "__type"
    static let typeValue = "date_epoch_timestamp"
    static let valueKey = "__value"
}

protocol SwiftCBORStringKey {}

extension String: SwiftCBORStringKey {}
