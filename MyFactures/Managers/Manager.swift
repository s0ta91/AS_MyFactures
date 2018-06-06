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
    
    // MARK: -  INIT functions
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
        }else {
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
    
    
    // MARK: - PRIVATE functions
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
    
    
    // PUBLIC functions
    
    // MARK: - Save in user Defaults
    func saveInUserDefault(forKey key: String, andValue value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    func getFromUserDefault(forKey key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    func reinitUserDefaultValue(forKey key: String) {
        UserDefaults.standard.set(nil, forKey: Settings().USER_EMAIL_KEY)
    }
    
    // MARK: - Generate a random 4 digit code
    func generateRandomCode() -> String? {
        return String(1000+arc4random_uniform(8999))
    }
    
    // MARK: - Password management
    func savePassword (_ password: String) {
        DbManager().saveMasterPassword(password)
    }
    
    func hasMasterPassword () -> Bool{
        return DbManager().getMasterPassword() != nil
    }
    
    func sendPasswordToUser(fromViewController originViewController: UIViewController) {
        if let userEmail = getUserEmail(),
            let userPassword = DbManager().getMasterPassword() {
            
            if sendEmail(toEmail: userEmail, withPassword: userPassword) {
                Alert.message(title: "Message envoyé", message: "Un email contenant votre mot de passe vous a été envoyé", vc: originViewController)
            } else {
                Alert.message(title: "Une erreur est survenue lors de l'envoi du message", message: "", vc: originViewController)
            }
        }else {
            Alert.message(title: "Error retreiving user informations", message: "", vc: originViewController)
            print("Error retreiving user informations")
        }
    }
    // MARK: - Email management
    func sendEmail(toEmail email: String, withCode code: String? = nil, withPassword password: String? = nil) -> Bool {
        var didComplete: Bool!
        
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = Settings().hostname
        smtpSession.username = Settings().emailAdress
        smtpSession.password = Settings().emailPassword
        smtpSession.port = Settings().port
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    //                    NSLog("Connectionlogger: \(string)")
                }
            }
        }
        
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: email, mailbox: email)]
        builder.header.from = MCOAddress(displayName: "MyFacturesApp", mailbox: Settings().emailAdress)
        
        if let codeForUser = code {
            builder.header.subject = "Vérification de votre adresse email"
            builder.htmlBody = "Bonjour,<br/><br/> Veuillez recopier le code suivant dans l'application afin de vérifier votre adresse email.<br/><br/>code: \(codeForUser)<br/><br/> Merci<br/> MyFacturesApp"
        }
        if let userPassword = password {
            builder.header.subject = "Récupération de votre mot de passe"
            builder.htmlBody = "Bonjour,<br/><br/> Veuillez trouver ci-dessous votre mot de passe.<br/><br/> Mot de passe: \(userPassword)<br/><br/> MyFacturesApp"
        }
        
        let rfc822Data = builder.data()
        if let sendOperation = smtpSession.sendOperation(with: rfc822Data) {
            sendOperation.start { (error) -> Void in
                if (error != nil) {
                    NSLog("Error sending email: \(String(describing: error))")
                } else {
                    NSLog("Successfully sent email!")

                }
            }
            didComplete = true
        } else {
            didComplete = false
        }
        return didComplete
    }
    
    // MARK: - User management
    func createUser(with password: String, andEmail email: String) {
        savePassword(password)
        saveInUserDefault(forKey: Settings().USER_EMAIL_KEY, andValue: email)
    }
    
    func getUserEmail() -> String? {
        return getFromUserDefault(forKey: Settings().USER_EMAIL_KEY)
    }
    
    
    // MARK: - APPLICATIONDATA functions
    func updateApplicationData () {
        let applicationData = ApplicationData()
        _realm.beginWrite()
        _realm.add(applicationData)
        try? _realm.commitWrite()
    }
    
    // MARK: - YEAR functions
    func getyearsCount () -> Int {
        return _yearsList.count
    }
    
    func getYear (atIndex index: Int) -> Year? {
        return _yearsList[index]
    }
    
    func getYear (forValue value: Int) -> Year? {
        let yearPredicate = NSPredicate(format: "_year == %i", value)
        guard let yearIndex = _yearsList.index(matching: yearPredicate) else { return nil }
        return getYear(atIndex: yearIndex)
    }
    
    func getYearIndex (forValue value: Int) -> Int? {
        guard let year = getYear(forValue: value) else { return 0 }
        return _yearsList.index(of: year)
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
        }else {
            selectedYear = nil
        }
        return selectedYear
    }

    
    // MARK: - GROUPIDEA functions
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
    func getGroupIdeaNameList () -> [String]{
        var groupIdeaName:[String] = []
        for groupIdeaIndex in 0...getGroupIdeaCount() {
             groupIdeaName.append(_groupIdeaList[groupIdeaIndex].title)
        }
        return groupIdeaName
    }
    
    // MARK: - CATEGORY Functions
    func getCategoryCount () -> Int {
        return _categoryList.count
    }
    
    func getCategory (atIndex index: Int) -> Category? {
        return _categoryList[index]
    }
    
    func getCategoryIndex (forCategory category: Category) -> Int!{
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
    
    
    // MARK: - Other functions
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
        }else if let amountString = labelToConvert?.text,
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
        }else {
            convertedResult = nil
        }
        return convertedResult
    }
    
    func setButtonLayer (_ button: UIButton) {
        button.layer.cornerRadius = 17
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOffset = CGSize(width:0,height: 2)
        button.layer.shadowRadius = 2.0
        button.layer.shadowOpacity = 1.0
        button.layer.masksToBounds = false;
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
        }else {
            image = nil
        }
        return image
    }

    func shake(_ textField: UITextField) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 4, y: textField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: textField.center.x + 4, y: textField.center.y))
        
        textField.layer.add(animation, forKey: "position")
    }

    static func dismissVC (thisViewController vc: UIViewController, withTransition transition: UIModalTransitionStyle, animated: Bool! = false) {
        vc.modalTransitionStyle = transition
        vc.dismiss(animated: animated, completion: nil)
    }
    
    static func presentLoginScreen(fromViewController vc: UIViewController){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { fatalError("Could not load LoginVC") }
        vc.present(loginVC, animated: false, completion: nil)
    }
    
    static func setIsFirstLoad(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: "firstLoad")
    }
    static func isFirstLoad() -> Bool {
        return UserDefaults.standard.bool(forKey: "firstLoad")
    }
}
