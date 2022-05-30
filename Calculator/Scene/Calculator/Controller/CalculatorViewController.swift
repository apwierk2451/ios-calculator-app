//
//  Calculator - CalculatorViewController.swift
//  Created by bonf. 
//  Copyright © yagom. All rights reserved.
// 
import UIKit
import Foundation

class CalculatorViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var expressionStackView: UIStackView!
    @IBOutlet weak var operatorInput: UILabel!
    @IBOutlet weak var numberInput: UILabel!
    
    private var totalCalculation: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabelText("0")
        clearStackView()
    }
    
    @IBAction private func numberButtonDidTapped(_ sender: UIButton) {
        updateNumberInput(sender)
    }
    
    private func updateNumberInput(_ sender: UIButton) {
        guard let number = checkNumber(sender) else {
            return
        }
        
        guard let formattedNumber = formatNumber(number) else {
            return
        }
        
        setNumber(formattedNumber)
    }
    
    private func checkNumber(_ sender: UIButton) -> String? {
        guard let firstConditionPassedText = isAdditionalNumberInput(sender) else {
            return nil
        }
        
        guard let secondConditionPassedText = isUsingComma(sender, firstConditionPassedText) else {
            return nil
        }
        
        return secondConditionPassedText
    }
    
    private func isAdditionalNumberInput(_ sender: UIButton) -> String? {
        guard let text = numberInput.text else {
            return nil
        }
        
        guard isNotAdditionalNumberInputAfterResultHasBeenShown(sender) else {
            return nil
        }
        return text
    }
    
    private func isNotAdditionalNumberInputAfterResultHasBeenShown(_ sender: UIButton) -> Bool {
        guard expressionStackView.arrangedSubviews.count <= 0 || operatorInput.text != "" else {
            clearStackView()
            numberInput.text = sender.currentTitle
            return false
        }
        return true
    }
    
    private func isUsingComma(_ sender: UIButton, _ text: String) -> String? {
        guard isCommaButtonNotTappedTwice(sender: sender, number: text) else {
            return nil
        }
        
        guard let newText = addNewNumber(sender, text) else {
            return nil
        }
        
        guard newText.contains(".") == false else {
            return nil
        }
        
        return newText
    }
    
    private func isCommaButtonNotTappedTwice(sender: UIButton, number: String) -> Bool {
        guard sender.currentTitle != "." || number.filter({ $0 == "." }).count < 1 else {
            return false
        }
        
        return true
    }
    
    private func addNewNumber(_ sender: UIButton, _ number: String) -> String? {
        guard let currentDigit: String = sender.currentTitle else {
            return nil
        }
        
        let newNumber: String
        newNumber = number + currentDigit
        numberInput.text = newNumber
        
        return numberInput.text
    }
    
    private func formatNumber(_ number: String) -> String? {
        guard let formattedNumber = formatNumberForBeingRecognizedAsNumber(number) else {
            return nil
        }
        
        guard let reFormattedNumber = formatNumberForExposure(formattedNumber) else {
            return nil
        }
        
        return reFormattedNumber
    }
    
    private func formatNumberForBeingRecognizedAsNumber(_ number: String) -> Double? {
        let onceTrimmmedInput = removeComma(number)
        
        guard let twiceTrimmedInput = convertStringToDouble(onceTrimmmedInput) else {
            return nil
        }
        
        return twiceTrimmedInput
    }
    
    private func removeComma(_ input: String) -> String {
        let trimmedInput = input.replacingOccurrences(of: ",", with: "")
        
        return trimmedInput
    }
    
    private func convertStringToDouble(_ input: String) -> Double? {
        guard let trimmedInput = Double(input) else {
            return nil
        }
        
        return trimmedInput
    }
    
    private func setNumber(_ number : String) {
        numberInput.text = number
    }
    
    private func formatNumberForExposure(_ number: Double) -> String? {
        let numberFormatter = setNumberFormatter()
        
        guard let formattedNumber = numberFormatter.string(from: number as NSNumber) else {
            return nil
        }
        
        return formattedNumber
    }
    
    private func setNumberFormatter() -> NumberFormatter {
        let numberFormatter = NumberFormatter()
            
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 20
        numberFormatter.maximumIntegerDigits = 20
        
        return numberFormatter
    }
    
    @IBAction private func operatorButtonDidTapped(_ sender: UIButton) {
        updateOperatorInput(sender)
        resetNumberInput()
        holdScrollDown()
    }
    
    private func updateOperatorInput(_ sender: UIButton) {
        guard checkOperator(sender) == true else {
            return
        }
        
        addCalculatorItems()
        setOperator(sender)
    }
    
    private func checkOperator(_ sender: UIButton) -> Bool {
        guard isNumberEqualToNaN() else {
            return false
        }
        
        guard operatorButtonDidTappedWhileFirstOperandIsZero(sender) else {
            return false
        }
        
        if isAdditionalOperatorAfterResultHasBeenShown() {
            return true
        }
        
        guard isCurrentNumberEqualToZero(sender) else {
            return false
        }
        
        return true
    }
    
    private func isNumberEqualToNaN() -> Bool {
        guard let number = numberInput.text else {
            return false
        }

        guard number.contains(CalculatorError.dividedByZero.localizedDescription) != true else {
            clearStackView()
            return false
        }

        return true
    }
    
    private func operatorButtonDidTappedWhileFirstOperandIsZero(_ sender: UIButton) -> Bool {
        guard numberInput.text != "0" || expressionStackView.arrangedSubviews.count > 0 else {
            return false
        }
        
        return true
    }
    
    private func isAdditionalOperatorAfterResultHasBeenShown() -> Bool {
        if operatorInput.text == "" && expressionStackView.arrangedSubviews.count > 0 {
            clearStackView()
            return true
        }
        
        return false
    }
    
    private func isCurrentNumberEqualToZero(_ sender: UIButton) -> Bool {
        guard let text = numberInput.text else {
            return false
        }
        
        guard Double(text) != 0.0 || expressionStackView.arrangedSubviews.count <= 0 else {
            operatorInput.text = sender.currentTitle
            return false
        }
        
        return true
    }
    
    private func addCalculatorItems() {
        guard let newCalculationItemsInput = makeUIStackView() else {
            return
        }
        
        addStackView(newCalculationItemsInput)
    }
    
    private func makeUIStackView() -> UIStackView? {
        guard let operandLabel = makeUILabel(), let operatorLabel = makeUILabel() else {
            return nil
        }
        
        updateTotalInput(operands: operandLabel, operators: operatorLabel)
        
        let stackView = UIStackView(arrangedSubviews: [operatorLabel, operandLabel])
        stackView.spacing = 10
        
        return stackView
    }
    
    private func makeUILabel() -> UILabel? {
        let label = UILabel()
        
        setLabelProperty(label)
        
        return label
    }
    
    private func setLabelProperty(_ label: UILabel) {
        label.isHidden = false
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
    }
    
    private func updateTotalInput(operands: UILabel, operators: UILabel) {
        guard let operandLabel = numberInput.text, let operatorLabel = operatorInput.text else {
            return
        }
        
        operands.text = numberInput.text
        operators.text = operatorInput.text
        
        let firstTrimmedOperand = removeWhitespaces(operandLabel)
        let secondTrimmedOperand = removeComma(firstTrimmedOperand)
        let firstTrimmedOperator = removeWhitespaces(operatorLabel)
        let secondTrimmedOperator = removeComma(firstTrimmedOperator)
        
        totalCalculation += secondTrimmedOperator + secondTrimmedOperand
    }
    
    private func addStackView(_ stackView: UIStackView) {
        expressionStackView.addArrangedSubview(stackView)
    }
    
    private func setOperator(_ sender: UIButton) {
        operatorInput.text = sender.currentTitle
    }
    
    private func resetNumberInput() {
        numberInput.text = "0"
    }
    
    private func holdScrollDown() {
        scrollView.layoutIfNeeded()
        
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height -
                                   scrollView.bounds.size.height)
        
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    @IBAction private func resultButtonDidTapped(_ sender: UIButton) {
        guard operatorInput.text != "" else {
            return
        }
        
        addCalculatorItems()
       
        var formula = ExpressionParser.parse(from: totalCalculation)
        
        do {
            let calculationResult = try formula.result()
            guard let result = formatNumberForExposure(calculationResult) else {
                return
            }
            setNumber(result)
        } catch {
            print(Error.self)
        }
    }
    
    @IBAction private func changeValueButtonDidTapped(_ sender: UIButton) {
        let changeValue = sender.currentTitle
        if changeValue == "AC" {
            clearStackView()
            setLabelText("0")
        } else if changeValue == "CE" {
            numberInput.text = "0"
        } else {
            guard let value = numberInput.text else { return }
            checkNegativeNumber(value)
        }
    }
    
    private func setLabelText(_ text: String) {
        operatorInput.text = ""
        numberInput.text = text
        totalCalculation = ""
    }

    private func checkNegativeNumber(_ text: String) {
        guard text != "0" else { return }
        guard text != "NAN" else { return }
        guard text.first == "-" else {
            numberInput.text = "-\(text)"
            return
        }
        numberInput.text = text.filter { $0 != "-" }
        return
    }
    
    private func removeWhitespaces(_ input: String) -> String {
        let trimmedInput = input.replacingOccurrences(of: " ", with: "")
        
        return trimmedInput
    }
    
    private func changeFormat(_ format: String) {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 20
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(for: Double(format))!
        operatorInput.text = ""
        numberInput.text = "\(result)"
    }
    
    private func clearStackView() {
        expressionStackView.subviews.forEach { $0.removeFromSuperview() }
    }
}
