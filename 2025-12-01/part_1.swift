// https://adventofcode.com/2025/day/1

import Foundation

enum Failure: Error {
    case message(String)
}

func solve(url: URL) async throws -> Int {
    let handle = try FileHandle(forReadingFrom: url)
    defer { try? handle.close() }

    var zeros = 0
    var pointer = 50

    for try await line in handle.bytes.lines {
        guard let dist = Int(line.replacing("L", with: "-").replacing("R", with: "")) else {
            throw Failure.message("dist could not be converted")
        }

        pointer = (pointer + dist) % 100

        if pointer == 0 {
            zeros += 1
        }
    }

    return zeros
}

let file = URL(fileURLWithPath: #filePath)
let dir  = file.deletingLastPathComponent()
let target = dir.appendingPathComponent("input.txt")

let result = try await solve(url: target)
print(result)
