A module for the [tree-sitter](https://tree-sitter.github.io/) incremental parsing system. The tree-sitter has both runtime and per-language dependencies. They all have to be build separately. For a purpose of this project per-language dependencies are part of the resulting `tree_sitter.xcframework`.

The `tree_sitter.xcframework` binary comes with:
- [tree-sitter](https://tree-sitter.github.io/tree-sitter) runtime
- [tree-sitter-swift](https://github.com/alex-pinkus/tree-sitter-swift)
- [tree-sitter-go](https://github.com/tree-sitter/tree-sitter-go)
- [tree-sitter-gomod](https://github.com/camdencheek/tree-sitter-go-mod)
- [tree-sitter-ruby](https://github.com/tree-sitter/tree-sitter-ruby)
- [tree-sitter-json](https://github.com/tree-sitter/tree-sitter-json)
- [tree-sitter-php](https://github.com/tree-sitter/tree-sitter-php)
- [tree-sitter-markdown](https://github.com/ikatyang/tree-sitter-markdown)
- [tree-sitter-java](https://github.com/tree-sitter/tree-sitter-java)
- [tree-sitter-python](https://github.com/tree-sitter/tree-sitter-python)
- [tree-sitter-html](https://github.com/tree-sitter/tree-sitter-html)
- [tree-sitter-css](https://github.com/tree-sitter/tree-sitter-css)

This is a [work-in-progress](https://github.com/tree-sitter/tree-sitter/issues/1488). But, if the parser you'd like to use doesn't have a Makefile, let me know and I'll help get it set up.

## Integration

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/krzyzanowskim/tree-sitter-xcframework", from: "0.208.4")
]
```

## Usage

Accessing the parsers directly:

```swift
import TreeSitter

let parser = tree_sitter_swift()
let parser = tree_sitter_ruby()
```

Via the included "TreeSitterResource" abstraction:

```swift
import TreeSitterResource

let swift = TreeSitterLanguage.swift

let url = swift.highlightQueryURL
let parserPtr = swift.parser
```

### Suggestions or Feedback

I'd love to hear from you! Get in touch via twitter [@krzyzanowskim](https://x.com/krzyzanowskim), an issue, or a pull request.
