//
//  QuantityPickerPopup.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 2/1/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

protocol QuantityPickerPopupDelegate: class {
    func chosen(weight: Double, answer: [String: Any])
}

struct WeightViewItem {
    var rawWeights: [Double]
    var viewWeight: [Int]
    var suff: String
    var divider: Double
}

class QuantityPickerPopup: UIViewController {
    var weightViewItems: [WeightViewItem] = []
    var indexPath: IndexPath?
    weak var delegate: QuantityPickerPopupDelegate?
    var quantityEntity: QuantityEntity!

    let weightPicker: UIPickerView = {
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        picker.backgroundColor = .white
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.showsSelectionIndicator = true
        return picker
    }()

    let toolbar: UIToolbar = {
        let tlbr = UIToolbar()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelection))
        let flex = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(choosen))
        tlbr.items = [cancelButton, flex, doneButton]
        tlbr.isUserInteractionEnabled = true
        return tlbr
    }()

    let containerView = UIView()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init(delegate: QuantityPickerPopupDelegate, model: QuantityEntity) {
        self.init()
        self.delegate = delegate
        self.quantityEntity = model
        self.configurePopup()
        self.modalPresentationStyle = .overCurrentContext
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.configurePopup()
    }

    // TODO: refactor here divide on coefficient
    @objc func choosen() {
        var value: Double = 0.0
        for component in 0..<weightPicker.numberOfComponents {
            let weightIndex = weightPicker.selectedRow(inComponent:component)
            value += weightViewItems[component].rawWeights[weightIndex]
        }
        delegate?.chosen(weight: value * quantityEntity.parameters[0].divider!, answer: self.quantityEntity.answerDict)
        self.view.antiObscure {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc func cancelSelection() {
        self.view.antiObscure {
            self.dismiss(animated: true, completion: nil)
        }
    }

    private func configurePopup() {
        weightPicker.delegate = self
        for par in quantityEntity.parameters {
            let weightViewItem = makeWeightViewItem(parameter: par)
            weightViewItems.append(weightViewItem)
        }
    }

    /// Method for transformation from model ParameterEntity to PickerDataEntity
    ///
    /// - Parameter parameter: list addtional oprions for uom entity
    /// - Returns: model with raw values for picker and view values
    private func makeWeightViewItem(parameter: ParameterEntity) -> WeightViewItem {
        let stridedWeightsArray = stride(from: 0, to: Double(parameter.maxValue), by: parameter.step)

        let rawWeightArray: [Double] = stridedWeightsArray.map { $0 / parameter.divider! }
        let viewWeightsArray: [Int] = stridedWeightsArray.map { Int($0) }

        return WeightViewItem(rawWeights: rawWeightArray,
                              viewWeight: viewWeightsArray,
                              suff: parameter.suffix,
                              divider: parameter.divider!)
    }

    
    func transformIntoIndexes(from searchingValue: Double) -> [Int] {
        var searchingIndexes: [Int] = []
        var str = String(format: "%.\(self.weightViewItems.count - 1)f", searchingValue)
        str = str.replacingOccurrences(of: ".", with: "")
        var maxDivider = 1
        for (index, character) in str.enumerated().reversed() {
            let extractedFigure = (Int(String(character)) ?? 0) * (index == 0 ? 1 : Int(maxDivider))
            for (index2, value) in weightViewItems[index].viewWeight.enumerated().reversed() {
                if extractedFigure == value {
                    searchingIndexes.append(index2)
                    maxDivider *= 10
                    break
                }
            }
        }
        return searchingIndexes.reversed()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        selectCurrentValue()
    }

    func selectCurrentValue() {
        let indexes = transformIntoIndexes(from: quantityEntity.currentValue)

        guard !indexes.isEmpty else { return  }

        for comp in 0..<weightPicker.numberOfComponents {
            weightPicker.selectRow(indexes[comp], inComponent: comp, animated: true)
        }
    }

    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        weightPicker.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(containerView)
        containerView.addSubview(toolbar)
        containerView.addSubview(weightPicker)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            toolbar.topAnchor.constraint(equalTo: containerView.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 50.0),
            weightPicker.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            weightPicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            weightPicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            weightPicker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.obscure()
    }
}

extension QuantityPickerPopup: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        let weightViewItem = weightViewItems[component].viewWeight[row]
        let suff = weightViewItems[component].suff

        return "\(weightViewItem) \(suff)"
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return weightViewItems.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return weightViewItems[component].rawWeights.count
    }
}
