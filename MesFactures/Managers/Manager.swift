//
//  Manager.swift
//  MesFactures
//
//  Created by Sébastien on 02/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift
import KeychainAccess

class Manager {

    private var _realm: Realm
    private var _yearsList: Results<Year>
    private var _applicationDataList: Results<ApplicationData>
    private var _categoryList: Results<Category>
    private var _groupIdeaList: Results<GroupIdea>

    /** INIT functions **/
    init (withRealm realm: Realm) {
        _realm = realm
        _yearsList = _realm.objects(Year.self).sorted(byKeyPath: "_year", ascending: false)
        _applicationDataList = _realm.objects(ApplicationData.self)
        _categoryList = _realm.objects(Category.self)
        _groupIdeaList = _realm.objects(GroupIdea.self).sorted(byKeyPath: "_title")
    }

    func initYear () {
        let _currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: _currentDate)
        if getApplicationDataCount() == 0 {
            let yearsStartAt = 1900
            for calculatedYears in yearsStartAt...currentYear {
                addYear(calculatedYears)
            }
        _yearsList.first?.selected = true
        } else {
            if let yearsListLast = _yearsList.first,
                yearsListLast.year != currentYear {
                addYear(currentYear)
            }
        }
    }

    func initCategory () {
        if getApplicationDataCount() == 0 {
            _ = addCategory("Toutes les catégories", isSelected: true)
            _ = addCategory("Non-classée")
        }
    }

    /** PRIVATE functions **/
    private func getApplicationDataCount () -> Int {
        return _applicationDataList.count
    }

    private func addYear (_ yearToAdd: Int) {
        let newYear = Year()
        newYear.year = yearToAdd
        try? _realm.write {
            _realm.add(newYear)
        }
    }

    /** PUBLIC functions **/

    // Password management
    func savePassword (_ password: String) {
        DbManager().saveMasterPassword(password)
    }

    func hasMasterPassword () -> Bool {
        return DbManager().getMasterPassword() != nil
    }

    // APPLICATIONDATA functions
    func updateApplicationData () {
        let applicationData = ApplicationData()
        _realm.beginWrite()
        _realm.add(applicationData)
        try? _realm.commitWrite()
    }

    // YEAR functions
    func getyearsCount () -> Int {
        return _yearsList.count
    }
    func getYear (atIndex index: Int) -> Year? {
        return _yearsList[index]
    }

    func setSelectedYear (forYear newSelectedYear: Year) {
        let oldSelectedYear = getSelectedYear()
        oldSelectedYear?.selected = false
        newSelectedYear.selected = true
    }

    func getSelectedYear () -> Year! {
        let selectedYear: Year?
        let findSelectedYear = NSPredicate(format: "_selected == true")
        if let getSelectedYear = _yearsList.filter(findSelectedYear).first {
            selectedYear = getSelectedYear
        } else {
            selectedYear = nil
        }
        return selectedYear
    }

    // GROUPIDEA functions
    func getGroupIdeaCount () -> Int {
        return _groupIdeaList.count
    }
    private func addGroupidea (_ groupIdeaName: String) {
        let newGroupIdea = GroupIdea()
        newGroupIdea.title = groupIdeaName
        try? _realm.write {
            _realm.add(newGroupIdea)
        }
    }
    func setGroupIdeaList () {
        addGroupidea("Achats en ligne")
        addGroupidea("Energies")
        addGroupidea("Fiches de paie")
        addGroupidea("Internet")
        addGroupidea("Magasins")
        addGroupidea("Téléphones")
    }
    func getGroupIdeaNameList () -> [String] {
        var groupIdeaName: [String] = []
        for groupIdeaIndex in 0...getGroupIdeaCount() {
             groupIdeaName.append(_groupIdeaList[groupIdeaIndex].title)
        }
        return groupIdeaName
    }

    // CATEGORY Functions
    func getCategoryCount () -> Int {
        return _categoryList.count
    }

    func getCategory (atIndex index: Int) -> Category? {
        return _categoryList[index]
    }

    func getCategoryIndex (forCategory category: Category) -> Int! {
        return _categoryList.index(of: category)
    }

    func getCategory (forName categoryName: String) -> Category? {
        var category: Category? = nil
        let categoryPredicate = NSPredicate(format: "_title == %@", categoryName)
        if let categoryIndex = _categoryList.index(matching: categoryPredicate) {
            category = getCategory(atIndex: categoryIndex)
        }
        return category
    }

    func addCategory (_ categoryTitle: String, isSelected: Bool? = false) -> Category {
        let newCategory = Category()
        newCategory.title = categoryTitle
        newCategory.selected = isSelected!
        try? _realm.write {
            _realm.add(newCategory)
        }
        return newCategory
    }

    func checkForDuplicateCategory (forCategoryName categoryName: String) -> Bool {
        var categoryNameExists: Bool = false
        for categoryIndex in 0..<getCategoryCount() {
            if let existingCategoryToCheck = getCategory(atIndex: categoryIndex) {
                if categoryName == existingCategoryToCheck.title {
                    categoryNameExists = true
                }
            }
        }
        return categoryNameExists
    }

    func getSelectedCategory () -> Category {
        let findSelectedCategory = NSPredicate(format: "_selected == true")
        guard let getSelectedCategory = _categoryList.filter(findSelectedCategory).first else {fatalError("No category selected")}
        return getSelectedCategory
    }
    func setSelectedCategory (forCategory newSelectedCategory: Category) {
        let oldSelectedCategory = getSelectedCategory()
        oldSelectedCategory.selected = false
        newSelectedCategory.selected = true
    }

    func modifyCategoryTitle (forCategory category: Category, withNewTitle newTitle: String) {
        category.title = newTitle
    }

    func removeCategory (atIndex index: Int) {
        if let categoryToDelete = getCategory(atIndex: index) {
            try? _realm.write {
                _realm.delete(categoryToDelete)
            }
        }
    }

    // Other functions
    func convertToCurrencyNumber (forTextField textField: UITextField? = nil, forLabel label: UILabel? = nil) {
        let textFieldToConvert = textField
        let labelToConvert = label

        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = NumberFormatter.Style.currency
        currencyFormatter.locale = NSLocale.autoupdatingCurrent
//        currencyFormatter.locale = Locale(identifier: "fr-FR")
        currencyFormatter.decimalSeparator = "."

        if let amountString = textFieldToConvert?.text?.replacingOccurrences(of: ",", with: "."),
            let amountDouble = Double(amountString) {
            let amountNumber = NSNumber(value: amountDouble)
            if let numberToCurrencyType = currencyFormatter.string(from: amountNumber) {
                textFieldToConvert?.text = numberToCurrencyType
            }
        } else if let amountString = labelToConvert?.text,
            let amountDouble = Double(amountString) {
            let amountNumber = NSNumber(value: amountDouble)
            if let numberToCurrencyType = currencyFormatter.string(from: amountNumber) {
                labelToConvert?.text = numberToCurrencyType
            }
        }
    }

    func convertFromCurrencyNumber (forTextField textField: UITextField) -> Decimal? {
        let convertedResult: Decimal?
        let textFieldToConvert = textField
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        if let amountString = textFieldToConvert.text,
            let currencyToNumber = currencyFormatter.number(from: amountString) {
            convertedResult = currencyToNumber.decimalValue
        } else {
            convertedResult = nil
        }
        return convertedResult
    }

    func setButtonLayer (_ button: UIButton) {
        button.layer.cornerRadius = 17
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOffset = CGSize(width:0, height: 2)
        button.layer.shadowRadius = 2.0
        button.layer.shadowOpacity = 1.0
        button.layer.masksToBounds = false
        button.layer.shadowPath = UIBezierPath(roundedRect:button.bounds, cornerRadius:button.layer.cornerRadius).cgPath
    }

    func setHeaderClippedToBound (_ collectionView: UICollectionView) {
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }

    func drawPDFfromURL (url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { print("error document")
            return nil }
        guard let page = document.page(at: 1) else { print("error page")
            return nil }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(page)
        }

        return img
    }

    func getImageFromURL (url: URL) -> UIImage? {
        let image: UIImage?
        if let data = NSData(contentsOf: url) {
            image = UIImage(data: data as Data)
        } else {
            image = nil
        }
        return image
    }
}
