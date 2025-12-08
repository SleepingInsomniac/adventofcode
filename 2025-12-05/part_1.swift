// https://adventofcode.com/2025/day/5

import Foundation

enum Failure: Error {
case message(String)
}

func solve(url: URL) async throws -> Int {
    let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }

    var solution: Int = 0
    let ranges: [ClosedRange<Int>] = []

    for try await line in handle.bytes.lines {
        if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            break
        }
        print(line)
    }

    return solution
}

let file = URL(fileURLWithPath: #filePath)
let dir  = file.deletingLastPathComponent()
let target = dir.appendingPathComponent("input.txt")

let result = try await solve(url: target)
print(result)
