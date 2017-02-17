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

    func setOperand(_ operand: Double) {
        accumulator = operand
    }

    private var operations: Dictionary<String,Operation> = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "√": Operation.UnaryOperation(sqrt),
        "cos": Operation.UnaryOperation(cos),
        "±": Operation.UnaryOperation({ -$0 }),
        "+": Operation.BinaryOperation({ $0 + $1 }),
        "-": Operation.BinaryOperation({ $0 - $1 }),
        "×": Operation.BinaryOperation({ $0 * $1 }),
        "÷": Operation.BinaryOperation({ $0 / $1 }),
        "=": Operation.Equals
    ]

    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }

    func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }

    func clear() {
        accumulator = 0
        pending = nil
    }

    private func executePendingBinaryOperation () {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }

    private var pending: PendingBinaryOperationInfo?

    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }

    var result: Double {
        get {
            return accumulator
        }
    }
}
