import Foundation
import TreeSitter

public enum TreeSitterLanguage: CaseIterable, Hashable {
    case css
    case go
    case gomod
    case html
    case java
    case json
    case markdown
    case php
    case python
    case ruby
    case swift

    var queryDirectoryName: String {
        switch self {
        case .css:
            return "css"
        case .go:
            return "go"
        case .gomod:
            return "gomod"
        case .html:
            return "html"
        case .java:
            return "java"
        case .json:
            return "json"
        case .markdown:
            return "markdown"
        case .php:
            return "php"
        case .python:
            return "python"
        case .ruby:
            return "ruby"
        case .swift:
            return "swift"
        }
    }

    public var parser: UnsafeMutablePointer<TSLanguage> {
        switch self {
        case .css:
            return tree_sitter_css()
        case .go:
            return tree_sitter_go()
        case .gomod:
            return tree_sitter_gomod()
        case .html:
            return tree_sitter_html()
        case .java:
            return tree_sitter_java()
        case .json:
            return tree_sitter_json()
        case .markdown:
            return tree_sitter_markdown()
        case .php:
            return tree_sitter_php()
        case .python:
            return tree_sitter_python()
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
