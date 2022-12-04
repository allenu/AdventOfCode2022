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

// Represents the maximum total we've found so far, along with its index
// for easy lookup later.
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
    // An array of all the calories per elf we've encountered thus far.
    let elfCalories: [Int]
    
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

                return .init(elfCalories: self.elfCalories + [run.total],
                             mode: .readingBlanks,
                             maxFound: newMaxFound)
            }
        } else if let value = Int(line) {
            let newRun: Run
            
            switch mode {
            case .readingBlanks:
                // Started a new run with this value
                newRun = Run(index: self.elfCalories.count, total: value)
                
            case .readingRun(let existingRun):
                // Add to the existing run
                newRun = Run(index: existingRun.index, total: existingRun.total + value)
            }

            return .init(elfCalories: self.elfCalories,
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

    let initialState = State(elfCalories: [],
                             mode: .readingBlanks,
                             maxFound: nil)
    
    let reducedState = lines.reduce(initialState, { previousState, line in
        return previousState.nextState(line: line)
    })

    let finalState: State
    let maxFound: MaxFound?
    
    switch reducedState.mode {
    case .readingBlanks:
        maxFound = reducedState.maxFound
        finalState = reducedState
        
    case .readingRun(let run):
        // We've ended the list with an open run. This represents the last elf
        // in the list.
        
        // Close out current run with whatever total we've found and merge with
        // max thus far in the complete list
        
        let potentialNewMaxFound = MaxFound(index: run.index, total: run.total)
        maxFound = potentialNewMaxFound.merge(previousMax: reducedState.maxFound)
        
        finalState = .init(elfCalories: reducedState.elfCalories + [run.total], mode: .readingBlanks, maxFound: maxFound)
    }

    // For Day 1
    if let maxFound = finalState.maxFound {
        print("Elf at index \(maxFound.index) had the most calories: \(maxFound.total)")
    } else {
        print("Oops, no max. Must've been an empty list or they're all invalid lines.")
    }
    
    // For Day 1 bonus
    let topThreeElves = finalState.elfCalories.sorted { $0 > $1 }.prefix(3)
    let sumOfTopThree = topThreeElves.reduce(0, +)
    print("The top three elves had calories of \(topThreeElves) and a sum of \(sumOfTopThree)")
}
