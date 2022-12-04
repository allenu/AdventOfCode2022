//
//  Day1.swift
//  AdventOfCode-2022
//
//  Created by Allen Ussher on 12/4/22.
//

import Foundation

// MARK: - Data types

// Represents a run of integers
struct Run {
    // Which elf we are processing
    let index: Int
    
    // Total of calories thus far for this elf
    let total: Int
}

// We're either reading one or more blanks or a run of integers. Once we
// read a valid integer, we go into readingRun mode and only exit it once
// we encounter another blank.
enum Mode {
    case readingBlanks
    case readingRun(Run)
}

// Represents the maximum integers we've found so far.
struct MaxFound {
    let index: Int
    let total: Int
    
    // Takes the previous max and returns self or previous max, whichever is bigger.
    // The previous max may be nil if we didn't find any runs yet.
    func merge(previousMax: MaxFound?) -> MaxFound {
        guard let previousMax = previousMax else { return self }
        return self.total > previousMax.total ? self : previousMax
    }
}

// Represents our running state as we process each line, one by one. This will
// allow us to know at any moment what our maximum is thus far and avoid having
// to enumerate the list more than once.
struct State {
    let elvesFound: Int
    
    let mode: Mode
    let maxFound: MaxFound?
    
    // Read the current line and return our next state, which will be used
    // for the next line.
    func nextState(line: String) -> State {
        if line == "" {
            switch mode {
            case .readingBlanks:
                return self
                
            case .readingRun(let run):
                // Close out current run and merge with max thus far and go into blanks mode.
                let potentialNewMaxFound = MaxFound(index: run.index, total: run.total)
                let newMaxFound = potentialNewMaxFound.merge(previousMax: self.maxFound)

                return .init(elvesFound: self.elvesFound + 1,
                             mode: .readingBlanks,
                             maxFound: newMaxFound)
            }
        } else if let value = Int(line) {
            let newRun: Run
            
            switch mode {
            case .readingBlanks:
                // Started a new run with this value
                newRun = Run(index: self.elvesFound, total: value)
                
            case .readingRun(let existingRun):
                // Add to the existing run
                newRun = Run(index: existingRun.index, total: existingRun.total + value)
            }

            return .init(elvesFound: self.elvesFound,
                         mode: .readingRun(newRun),
                         maxFound: self.maxFound)
        } else {
            // Error: invalid state.
            assertionFailure("You gave me bad input. I'm too lazy to handle it.")

            // Let's assume, for simplicity, that we just skip this line and
            // pretend it didn't exist.
            return self
        }
    }
}

// MARK: - Driver

func day1(inputUrl: URL) {
    
    guard let inputString = try? String(contentsOf: inputUrl) else {
        assertionFailure("Couldn't open input file: \(inputUrl)")
        return
    }

    let lines = inputString.components(separatedBy: .newlines)

    let initialState = State(elvesFound: 0,
                             mode: .readingBlanks,
                             maxFound: nil)
    
    let result = lines.reduce(initialState, { previousState, line in
        return previousState.nextState(line: line)
    })

    let maxFound: MaxFound?
    
    switch result.mode {
    case .readingBlanks:
        maxFound = result.maxFound
        
    case .readingRun(let run):
        // We've ended the list with an open run. This represents the last elf
        // in the list.
        
        // Close out current run with whatever total we've found and merge with
        // max thus far in the complete list
        
        let potentialNewMaxFound = MaxFound(index: run.index, total: run.total)
        maxFound = potentialNewMaxFound.merge(previousMax: result.maxFound)
    }

    if let maxFound = maxFound {
        print("Elf at index \(maxFound.index) had the most calories: \(maxFound.total)")
    } else {
        print("Oops, no max. Must've been an empty list or they're all invalid lines.")
    }
}
