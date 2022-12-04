//
//  ViewController.swift
//  AdventOfCode-2022
//
//  Created by Allen Ussher on 12/4/22.
//
//
//  I was too lazy to create an app that read from an input file. So I just wrote
//  a Mac app with a single view controller and use that to hook to my code. :)
//
//  A better way is to refactor to use a console app, but honestly who cares. This
//  is just for fun. I've got better things to do.
//
//  Go open the other swift files to see how I solved the problems.

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let dataUrl = Bundle.main.url(forResource: "day1-input", withExtension: "txt") {
            day1(inputUrl: dataUrl)
        } else {
            assertionFailure("Data not found")
        }
    }


}

