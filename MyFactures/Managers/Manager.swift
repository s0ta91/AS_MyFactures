//
//  Manager.swift
//  MesFactures
//
//  Created by Sébastien on 02/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import CoreData
import KeychainAccess

import RealmSwift


enum action {
    case add
    case remove
}

class Manager {
    
    static let instance = Manager()
    
    let context = AppDelegate.persistentContainer.viewContext
    let _monthArray =   [NSLocalizedString("January", comment: ""),
                        NSLocalizedString("February", comment: ""),
                        NSLocalizedString("March", comment: ""),
                        NSLocalizedString("April", comment: ""),
                        NSLocalizedString("May", comment: ""),
                        NSLocalizedString("June", comment: ""),
                        NSLocalizedString("July", comment: ""),
                        NSLocalizedString("August", comment: ""),
                        NSLocalizedString("September", comment: ""),
                        NSLocalizedString("October", comment: ""),
                        NSLocalizedString("November", comment: ""),
                        NSLocalizedString("December", comment: "")]
    
    
    // MARK: REALM
    var _realm: Realm?
    private var _realmYears: Results<RealmYear>?
    private var _realmCategoryList: Results<RealmCategory>?
    private var _realmGroups: Results<RealmGroup>?
    private var _realmMonths: Results<RealmMonth>?
    private var _realmInvoices: Results<RealmInvoice>?
    
    // MARK: - COREDATA
    private var _cdApplicationDataList: [ApplicationData]
    private var _cdYearsList: [Year]
    private var _cdCategoryList: [Category]
//    private var _cdGroupIdeaList: [GroupIdea]
    
    
    // MARK: -  INIT
    init() {
        
//        _groupIdeaList = _realm.objects(GroupIdea.self).sorted(byKeyPath: "_title")
        
        
        // Load CoreData ApplicationData
        let applicationDataRequest: NSFetchRequest<ApplicationData> = ApplicationData.fetchRequest()
        do {
            _cdApplicationDataList = try context.fetch(applicationDataRequest)
        } catch (let error) {
            _cdApplicationDataList = [ApplicationData]()
            print("Error fetching applicationData: \(error)")
        }
        
        // Load CoreData years
        let request: NSFetchRequest<Year> = Year.fetchRequest()
        do {
            _cdYearsList = try context.fetch(request).sorted(by: { $0.year > $1.year} )
        } catch (let error) {
            _cdYearsList = [Year]()
            print("Error fetching Years: \(error)")
        }
        
        // Load CoreData Categories
        let categoriesRequest: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            _cdCategoryList = try context.fetch(categoriesRequest)
        } catch (let error) {
            _cdCategoryList = [Category]()
            print("Error fetching categories: \(error)")
        }
        
        // Load CoreData Group ideas
//       let groupIdeasRequest: NSFetchRequest<GroupIdea> = GroupIdea.fetchRequest()
//       do {
//           _cdGroupIdeaList = try context.fetch(groupIdeasRequest)
//       } catch (let error) {
//           print("Error fetching categories: \(error)")
//       }
    }
    
    func initRealmData() {
        if let realm = _realm {
            _realmYears = realm.objects(RealmYear.self)
            _realmGroups = realm.objects(RealmGroup.self)
            _realmMonths = realm.objects(RealmMonth.self)
            _realmInvoices = realm.objects(RealmInvoice.self)
            _realmCategoryList = realm.objects(RealmCategory.self)
            
            // TODO: Migrate data from Realm to CoreData
            migrateFromRealmToCoreData()
        }
    }
    
    func migrateFromRealmToCoreData() {
        guard let years = _realmYears?.toArray(ofType: Year.self) else {
            print("ERROR: Cannot convert from RealmYears to Years array")
            return }
//        guard let groups = _realmGroups?.toArray(ofType: Group.self) else { return }
//        guard let months = _realmMonths?.toArray(ofType: Month.self) else { return }
//        guard let invoices = _realmInvoices?.toArray(ofType: Invoice.self) else { return }
//        guard let categories = _realmCategoryList?.toArray(ofType: Category.self) else { return }
        print("years count \(years.count)")
        years.forEach { (year) in
            print("year: \(year.year)")
            print("selected: \(year.selected)")
            print("group: \(String(describing: year.group))")
        }
    }
    
    func initYear () {
        print("init years")
        let _currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: _currentDate)
        print("ApplicationDataCount: \(getApplicationDataCount())")
        if getApplicationDataCount() == 0 {
            let yearsStartAt = 1900
            print("create years")
            for calculatedYears in yearsStartAt...currentYear {
                addYear(calculatedYears)
            }
        _cdYearsList.first?.selected = true
            print("set year \(String(describing: _cdYearsList.first?.year)) as selected \(String(describing: _cdYearsList.first?.selected))")
        } else {
            if let yearsListLast = _cdYearsList.last,
                yearsListLast.year != currentYear {
                addYear(currentYear)
            }
        }
        
        saveCoreDataContext()
    }
    
    func initCategory () {
        if getApplicationDataCount() == 0 {
            _ = addCategory(NSLocalizedString("All categories", comment: ""), isSelected: true)
            _ = addCategory(NSLocalizedString("Unclassified", comment: ""))
        }
    }
    
    
    // MARK: - PRIVATE functions
    private func getApplicationDataCount () -> Int {
        return _cdApplicationDataList.count
    }
    
    private func addYear(_ yearToAdd: Int) {
        let ny = Year(context: context)
        ny.year = Int64(yearToAdd)
        ny.selected = false
    }
    
    
    // MARK: - PUBLIC
    
    func saveCoreDataContext() {
        do {
            try context.save()
        } catch {
            // A remplacer par une modale d'erreur à présenter à l'utilisateur
            print("Error saving context: \(error)")
        }
    }
    
    // TODO: Save in user Defaults
    func saveInUserDefault(forKey key: String, andValue value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func getFromUserDefault(forKey key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    func reinitUserDefaultValue(forKey key: String) {
        UserDefaults.standard.set(nil, forKey: Settings().USER_EMAIL_KEY)
    }
    
    
    // TODO: Generate a random 4 digit code
    func generateRandomCode() -> String? {
        return String(1000+arc4random_uniform(8999))
    }
    
    
    // TODO: Password management
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
                Alert.message(title: NSLocalizedString("Password sent", comment: ""), message: NSLocalizedString("An email containing your password as been sent", comment: ""), vc: originViewController)
            } else {
                Alert.message(title: NSLocalizedString("An error occured. Message has not been sent.", comment: ""), message: "", vc: originViewController)
            }
        }else {
            Alert.message(title: NSLocalizedString("Error retreiving user informations", comment: ""), message: "", vc: originViewController)
            print("Error retreiving user informations")
        }
    }
    
    
    // TODO: Email management
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
        builder.header.to = [MCOAddress(displayName: email, mailbox: email) as Any]
        builder.header.from = MCOAddress(displayName: "MyFacturesApp", mailbox: Settings().emailAdress)
        
        if let codeForUser = code {
            builder.header.subject = NSLocalizedString("Confirm your email address", comment: "")
            builder.htmlBody = NSLocalizedString("Hello,<br/><br/> Please copy/paste the code bellow in the app to verify your email address.<br/><br/>code:", comment: "")
                + "\(codeForUser)"
                + NSLocalizedString("<br/><br/> Thank you<br/> MyFacturesApp", comment: "")
        }
        if let userPassword = password {
            builder.header.subject = NSLocalizedString("Password recovery", comment: "")
            builder.htmlBody = NSLocalizedString("Hello,<br/><br/> Please find bellow your password.<br/><br/> Password:", comment: "")
                + "\(userPassword)"
                + "<br/><br/> MyFacturesApp"
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
    
    
    // TODO: User management
    func createUser(with password: String, andEmail email: String) {
        savePassword(password)
//        saveInUserDefault(forKey: Settings().USER_EMAIL_KEY, andValue: email)
        UserDefaults.standard.set(email, forKey: UserDefaults.keys.userEmail.rawValue)
    }
    
    func setUserEmail() {
        
    }
    
    func getUserEmail() -> String? {
        return getFromUserDefault(forKey: Settings().USER_EMAIL_KEY)
    }
    
    
    // TODO: APPLICATIONDATA functions
    func updateApplicationData () {
        let applicationData = ApplicationData(context: context)
        applicationData.currentDate = Date()
        saveCoreDataContext()
    }
    
    
    // TODO: YEAR functions
    func getyearsCount () -> Int {
        return _cdYearsList.count
    }
    
    func getYear (atIndex index: Int) -> Year? {
        return _cdYearsList[index]
    }
    
    func getYear (forValue value: Int) -> Year? {
        guard let yearIndex = _cdYearsList.firstIndex(where: { (year) -> Bool in
            year.year == value
        }) else { return nil }
        return getYear(atIndex: yearIndex)
    }
    
    func getYearIndex (forValue value: Int) -> Int? {
        guard let year = getYear(forValue: value) else { return 0 }
        return _cdYearsList.firstIndex(of: year)
    }
    
    func setSelectedYear (forYear newSelectedYear: Year) {
        let oldSelectedYear = getSelectedYear()
        oldSelectedYear?.selected = false
        newSelectedYear.selected = true
    }
    
    func getSelectedYear () -> Year? {
        guard let selectedYear = _cdYearsList.first(where: { (year) -> Bool in
            year.selected == true
        }) else { return nil }
        
        return selectedYear
    }

    
    // TODO: GROUPIDEA functions
    func getGroupIdeaCount () -> Int {
//        return _cdGroupIdeaList.count
        return 0
    }
    
    private func addGroupidea (_ groupIdeaName: String) {
        let newGroupIdea = GroupIdea()
        newGroupIdea.title = groupIdeaName
        saveCoreDataContext()
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
        let groupIdeaName:[String] = []
//        for groupIdeaIndex in 0...getGroupIdeaCount() {
//             groupIdeaName.append(_groupIdeaList[groupIdeaIndex].title)
//        }
        return groupIdeaName
    }
    
    
    // TODO: CATEGORY Functions
    func getCategoryCount () -> Int {
        return _cdCategoryList.count
    }
    
    func getCategory (atIndex index: Int) -> Category? {
        return _cdCategoryList[index]
    }
    
    func getCategoryIndex (forCategory category: Category) -> Int!{
        return _cdCategoryList.firstIndex(of: category)
    }
    
    func getCategory (forName categoryName: String) -> Category? {
        guard let categoryIndex = _cdCategoryList.firstIndex(where: { (category) -> Bool in
            category.title == categoryName
        }) else { return nil }
        
        return getCategory(atIndex: categoryIndex)
    }
    
    func addCategory (_ categoryTitle: String, isSelected: Bool? = false) -> Category {
        let newCategory = Category(context: context)
        newCategory.title = categoryTitle
        newCategory.selected = isSelected!
        saveCoreDataContext()
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
    
    func getSelectedCategory () -> Category? {
        guard let selectedCategory = _cdCategoryList.first(where: { (category) -> Bool in
            category.selected == true
        }) else { return nil }
        return selectedCategory
    }
    
    func setSelectedCategory (forCategory newSelectedCategory: Category) {
        _cdCategoryList.forEach { (category) in
            category.selected = false
        }
        newSelectedCategory.selected = true
        saveCoreDataContext()
    }
    
    func modifyCategoryTitle (forCategory category: Category, withNewTitle newTitle: String) {
        category.title = newTitle
    }
    
    func removeCategory (atIndex index: Int) {
        if let categoryToDelete = getCategory(atIndex: index) {
            _cdCategoryList.remove(at: index)
            context.delete(categoryToDelete)
            saveCoreDataContext()
        }
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
    
    //FIXME: TO DELETE
    // Has been moved to SaveManager.swift
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
        loginVC.modalPresentationStyle = .fullScreen
        vc.present(loginVC, animated: false, completion: nil)
    }
    
    static func setIsFirstLoad(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: "firstLoad")
    }
    
    static func isFirstLoad() -> Bool {
        return UserDefaults.standard.bool(forKey: "firstLoad")
    }
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        let array = Array(self) as! [T]
        return array
    }
}
