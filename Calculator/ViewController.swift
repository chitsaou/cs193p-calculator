//
//  ViewController.swift
//  Calculator
//
//  Created by Yucheng Chuang on 2017/02/14.
//  Copyright © 2017 Yucheng Chuang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var descriptionDisplay: UILabel!

    private var userIsInTheMiddleOfTyping = false

    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!

        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
        }

        userIsInTheMiddleOfTyping = true
    }

    private var displayValue: Double? {
        get {
            return Double(display.text!)
        }

        set {
            let value = newValue! as NSNumber
            display.text = brain.formatter.string(from: value)
        }
    }

    private var brain = CalculatorBrain()

    @IBAction func delete() {
        if let text = display.text {
            var chars = text.characters
            chars.removeLast()

            if chars.isEmpty {
                display.text = "0"
                userIsInTheMiddleOfTyping = false
            } else {
                display.text = String(chars)
            }
        }
    }

    @IBAction private func clear(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        display.text = "0"
        brain.clear()
        clearDescription()
    }

    @IBAction private func appendFloatingPoint(_ sender: UIButton) {
        if display.text!.range(of: ".") == nil {
            display.text = display.text! + "."
        }

        userIsInTheMiddleOfTyping = true

        updateDescription()
    }

    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping, let value = displayValue {
            brain.setOperand(value)
            userIsInTheMiddleOfTyping = false
        }

        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            displayValue = brain.result
        }

        updateDescription()
    }

    var savedProgram: CalculatorBrain.PropertyList?

    @IBAction func save() {
        savedProgram = brain.program
    }

    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }

    private func updateDescription() {
        if brain.isPartialResult {
            descriptionDisplay.text = brain.description + "..."
        } else {
            descriptionDisplay.text = brain.description + "="
        }
    }

    private func clearDescription() {
        descriptionDisplay.text = " "
    }

}

