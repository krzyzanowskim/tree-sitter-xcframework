import Foundation
import tree_sitter

public enum LanguageResource: CaseIterable, Hashable {
    case go
    case gomod
    case java
    case json
    case markdown
    case php
    case ruby
    case swift

    var queryDirectoryName: String {
        switch self {
        case .go:
            return "go"
        case .gomod:
            return "gomod"
        case .java:
            return "java"
        case .json:
            return "json"
        case .markdown:
            return "markdown"
        case .php:
            return "php"
        case .ruby:
            return "ruby"
        case .swift:
            return "swift"
        }
    }

    public var parser: UnsafeMutablePointer<TSLanguage> {
        switch self {
        case .go:
            return tree_sitter_go()
        case .gomod:
            return tree_sitter_gomod()
        case .java:
            return tree_sitter_java()
        case .json:
            return tree_sitter_json()
        case .markdown:
            return tree_sitter_markdown()
        case .php:
            return tree_sitter_php()
        case .ruby:
            return tree_sitter_ruby()
        case .swift:
            return tree_sitter_swift()
        }
    }

    public func scmFileURL(named name: String) -> URL? {
        return Bundle.module.url(forResource: name,
                                 withExtension: "scm",
                                 subdirectory: "LanguageResources/\(queryDirectoryName)")
    }

    public var highlightQueryURL: URL? {
        return scmFileURL(named: "highlights")
    }

    public var localsQueryURL: URL? {
        return scmFileURL(named: "locals")
    }
}
