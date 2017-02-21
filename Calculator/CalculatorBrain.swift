//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Yucheng Chuang on 2017/02/16.
//  Copyright © 2017 Yucheng Chuang. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private var accumulator = 0.0
    private var expression = [String]()
    private var internalProgram = [AnyObject]()

    let LEFT_PAREN = "("
    let RIGHT_PAREN = ")"

    init() {
        srand48(time(nil))
    }

    func setOperand(_ operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)

        if isPartialResult == false {
            expression.removeAll()
        }

        expression.append(String(operand))
    }

    private var operations: Dictionary<String,Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "√": Operation.UnaryOperation(sqrt),
        "cos": Operation.UnaryOperation(cos),
        "x²": Operation.UnaryOperation({ $0 * $0 }),
        "±": Operation.UnaryOperation({ -$0 }),
        "+": Operation.BinaryOperation({ $0 + $1 }),
        "-": Operation.BinaryOperation({ $0 - $1 }),
        "×": Operation.BinaryOperation({ $0 * $1 }),
        "÷": Operation.BinaryOperation({ $0 / $1 }),
        "xⁿ": Operation.BinaryOperation(pow),
        "=": Operation.Equals,
        "rnd": Operation.Generator(drand48)
    ]

    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Generator(() -> Double)
        case Equals
    }

    func performOperation(_ symbol: String) {
        internalProgram.append(symbol as AnyObject)

        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                expression.append(symbol)
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
                let lastOperand = expression.popLast()!
                expression.append(contentsOf: [symbol, LEFT_PAREN, lastOperand, RIGHT_PAREN])
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                expression.append(symbol)
            case .Generator(let function):
                accumulator = function()
                expression.append(symbol)
            case .Equals:
                executePendingBinaryOperation()
                expression = [expression.joined()]
            }
        }
    }

    func clear() {
        accumulator = 0
        pending = nil
        expression = []
        internalProgram = []
    }

    var description: String {
        get { return expression.joined() }
    }

    func pushHistory(_ digit: String) {
        expression.append(String(digit))
    }

    var isPartialResult: Bool {
        get { return pending != nil }
    }

    private func executePendingBinaryOperation () {
        if isPartialResult {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }

    private var pending: PendingBinaryOperationInfo?

    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }

    typealias PropertyList = AnyObject

    var program: PropertyList {
        get {
            return internalProgram as PropertyList
        }

        set {
            clear()

            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }

    var result: Double {
        get {
            return accumulator
        }
    }
}
