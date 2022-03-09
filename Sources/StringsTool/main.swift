import ArgumentParser
import Foundation

extension Array where Element == Set<String> {
    func union() -> Set<String> {
        var union = Set<String>()

        for s in self {
            union.formUnion(s)
        }

        return union
    }
}

protocol ParserError: Error {
    var description: String { get }
}

struct NoStringsFileError: ParserError {
    let dir: String
    let file: String

    var description: String {
        "\u{001B}[34m\(dir)\u{001B}[0m does not contain file \u{001B}[31m\(file)\u{001B}[0m"
    }
}

struct DuplicatedKeyError: ParserError {
    let file: String
    let key: String

    var description: String {
        "Duplicated key: \u{001B}[31m\(key)\u{001B}[0m in \u{001B}[34m\(file)\u{001B}[0m"
    }
}

struct MissingKeyError: ParserError {
    let file: String
    let key: String

    var description: String {
        "Missing key: \u{001B}[31m\(key)\u{001B}[0m in \u{001B}[34m\(file)\u{001B}[0m"
    }
}

struct StringsTool: ParsableCommand {
    @Argument(help: "Path that contains the .lproj directory")
    var dir: String

    @Argument(help: "Strings file name")
    var name: String

    @Flag
    var checkMissingKey = false

    mutating func run() throws {
        var errors: [ParserError] = []

        var subDirsToCheck: [String] = []
        for subDir in list(dir: dir).sorted() where subDir.hasSuffix(".lproj") {
            if fileExists("\(dir)/\(subDir)/\(name)") {
                subDirsToCheck.append(subDir)
            } else {
                errors.append(NoStringsFileError(dir: "\(dir)/\(subDir)", file: name))
            }
        }

        if checkMissingKey {
            var subDirAndKeys: [(String, Set<String>)] = []

            for subDir in subDirsToCheck {
                let (keys, parsingErrors) = allKeysFromStringsFile("\(dir)/\(subDir)/\(name)")

                subDirAndKeys.append((subDir, keys))
                errors.append(contentsOf: parsingErrors)
            }

            let unionKeys = subDirAndKeys.map(\.1).union()

            for (subDir, keys) in subDirAndKeys {
                let diffKeys = unionKeys.subtracting(keys)
                if !diffKeys.isEmpty {
                    for diffKey in diffKeys {
                        errors.append(MissingKeyError(file: "\(dir)/\(subDir)/\(name)", key: diffKey))
                    }
                }
            }
        } else {
            for subDir in subDirsToCheck {
                let (_, parsingErrors) = allKeysFromStringsFile("\(dir)/\(subDir)/\(name)")
                errors.append(contentsOf: parsingErrors)
            }
        }

        errors.forEach { print($0.description) }
    }

    private func list(dir: String) -> [String] {
        (try? FileManager.default.contentsOfDirectory(atPath: dir)) ?? []
    }

    private func fileExists(_ filePath: String) -> Bool {
        FileManager.default.fileExists(atPath: filePath)
    }

    private func allKeysFromStringsFile(_ file: String) -> (Set<String>, [ParserError]) {
        var keys = Set<String>()
        var errors: [ParserError] = []

        for line in try! String(contentsOfFile: file).split(separator: "\n") {
            // line has format "key" = "value";
            guard let range = line.range(of: "\" = \"") else { continue }

            let key = String(line[line.index(after: line.startIndex) ..< range.lowerBound])

            if keys.contains(key) {
                errors.append(DuplicatedKeyError(file: file, key: key))
            } else {
                keys.insert(key)
            }
        }

        return (keys, errors)
    }
}

StringsTool.main()
