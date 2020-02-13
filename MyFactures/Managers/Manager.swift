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
    private var _realmYears: Results<Year>?
    private var _realmCategoryList: Results<Category>?
    private var _realmGroups: Results<Group>?
    private var _realmMonths: Results<Month>?
    private var _realmInvoices: Results<Invoice>?
    
    // MARK: - COREDATA
    private var _cdApplicationDataList: [ApplicationData]
    private var _cdYearsList: [YearCD]
    private var _monthList: [MonthCD] {
        let monthRequest: NSFetchRequest<MonthCD> = MonthCD.fetchRequest()
        do {
            return try Manager.instance.context.fetch(monthRequest)
        } catch (let error) {
            print("Error fetching groups from DB: \(error)")
            return [MonthCD]()
        }
    }
    private var _cdTopCategories: [CategoryCD] {
        let categoryrequest: NSFetchRequest<CategoryCD> = CategoryCD.fetchRequest()
        categoryrequest.predicate = NSPredicate(format: "toplist == %@", NSNumber(value: true))
        categoryrequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        do {
            return try Manager.instance.context.fetch(categoryrequest)
        } catch (let error) {
            print("Error fetching groups from DB: \(error)")
            return [CategoryCD]()
        }
    }
    private var _cdCategoriesList: [CategoryCD] {
        get {
            let categoryrequest: NSFetchRequest<CategoryCD> = CategoryCD.fetchRequest()
            categoryrequest.predicate = NSPredicate(format: "toplist == %@", "false")
            categoryrequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            do {
                return try Manager.instance.context.fetch(categoryrequest)
            } catch (let error) {
                print("Error fetching groups from DB: \(error)")
                return [CategoryCD]()
            }
        }
        set {}
    }
//    private var _cdGroupIdeaList: [GroupIdea]
    
    
    // MARK: - INIT
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
        let request: NSFetchRequest<YearCD> = YearCD.fetchRequest()
        do {
            _cdYearsList = try context.fetch(request).sorted(by: { $0.year > $1.year} )
        } catch (let error) {
            _cdYearsList = [YearCD]()
            print("Error fetching Years: \(error)")
        }
        
        // Load CoreData Categories
//        let categoriesRequest: NSFetchRequest<CategoryCD> = CategoryCD.fetchRequest()
//        do {
//            _cdCategoryList = try context.fetch(categoriesRequest)
//        } catch (let error) {
//            _cdCategoryList = [CategoryCD]()
//            print("Error fetching categories: \(error)")
//        }
        
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
            print("realm exist, load Results")
            print("realmYears count \(realm.objects(Year.self).count)")
            _realmYears = realm.objects(Year.self)
            _realmGroups = realm.objects(Group.self)
            _realmMonths = realm.objects(Month.self)
            _realmInvoices = realm.objects(Invoice.self)
            _realmCategoryList = realm.objects(Category.self)
            
            // TODO: Create month list in database
//            initMonthList()
            
            // TODO: Migrate data from Realm to CoreData
            migrateFromRealmToCoreData()
        }
    }
    
    func migrateFromRealmToCoreData() {
//        guard let years = _realmYears?.toArray(ofType: YearCD.self) else {
//            print("ERROR: Cannot convert from RealmYears to Years array")
//            return }

        _realmYears?.forEach({ (rYear) in
            let cdYear = YearCD(context: context)
            cdYear.year = Int64(rYear.year)
            cdYear.selected = rYear.selected

            print("-> migrate year to newYear")
            print("--> newYear: \(cdYear.year)")
            print("---> nb of groups to migrate: \(rYear._groupList.count)")
            
            migrateGroups(fromRealmYear: rYear, toCoreDataYear: cdYear)
        })
        
        print("---> Save context")
        saveCoreDataContext()
        UserDefaults.standard.set(true, forKey: UserDefaults.keys.migrationDone.rawValue)
    }
    
    private func migrateGroups(fromRealmYear rYear: Year, toCoreDataYear cdYear: YearCD) {
        rYear._groupList.forEach { (rGroup) in
            let cdGroup = cdYear.addGroup(withTitle: rGroup.title, totalPrice: rGroup.totalPrice, totalDocuments: Int64(rGroup.totalDocuments), isListFiltered: false)
            print("---> \(cdYear.year) - Create new group: \(String(describing: cdGroup.title))")
            migrateMonths(fromRealmGroup: rGroup, toCoreDataGroup: cdGroup)
        }
    }
    
    private func migrateMonths(fromRealmGroup rGroup: Group, toCoreDataGroup cdGroup: GroupCD) {
        for monthIndex in 0...11 {
            guard let rMonth = rGroup.getMonth(atIndex: monthIndex) else {
                // SET ERROR
                return
            }
            
            cdGroup.addMonth(Int64(monthIndex+1), rMonth.month)
            
            guard let cdMonth = cdGroup.getMonth(atIndex: monthIndex) else {
                // SET ERROR
                return
            }
            print("---> \(String(describing: cdGroup.title)) - Create new month: \(String(describing: cdMonth.name))")
            migrateInvoices(forRealmMonth: rMonth, toCoreDataMonth: cdMonth)
        }
    }
    
    private func migrateInvoices(forRealmMonth rMonth: Month, toCoreDataMonth cdMonth: MonthCD) {
        for invoiceIndex in 0..<rMonth.getInvoiceCount() {
            guard let rInvoice = rMonth.getInvoice(atIndex: invoiceIndex),
                let rInvoiceIdentifier = rInvoice.identifier,
                let rInvoiceCategory = rInvoice.categoryObject else {
                //SET ERROR
                return
            }
            let cdCategory = Manager.instance.addCategory(rInvoiceCategory.title, isSelected: rInvoiceCategory.selected, topList: false)
            cdMonth.addInvoice(description: rInvoice.detailedDescription, amount: rInvoice.amount, categoryObject: cdCategory, identifier: rInvoiceIdentifier, documentType: rInvoice.documentType ?? "JPG", completion: nil)
            print("---> \(String(describing: cdMonth.name)) - Create new invoice: \(rInvoice.detailedDescription)")
        }
    }
    
    func initYear () {
//        print("init years")
        let _currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: _currentDate)
//        print("ApplicationDataCount: \(getApplicationDataCount())")
        if getApplicationDataCount() == 0 {
            let yearsStartAt = 1900
            for calculatedYears in yearsStartAt...currentYear {
//                print("add year \(calculatedYears)")
                addYear(calculatedYears)
            }
            _cdYearsList.last?.selected = true
//            print("set year \(String(describing: _cdYearsList.last?.year)) as selected \(String(describing: _cdYearsList.last?.selected))")
        } else {
            if let lastYear = _cdYearsList.first,
                lastYear.year != currentYear {
                addYear(currentYear)
            }
        }
        
        saveCoreDataContext()
    }
    
    
    // MARK: - PRIVATE
    private func getApplicationDataCount () -> Int {
        return _cdApplicationDataList.count
    }
    
    private func addYear(_ yearToAdd: Int) {
        let ny = YearCD(context: context)
        ny.year = Int64(yearToAdd)
        ny.selected = false
        _cdYearsList.append(ny)
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
    
    // MARK: Save in user Defaults
    func saveInUserDefault(forKey key: String, andValue value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func getFromUserDefault(forKey key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    func reinitUserDefaultValue(forKey key: String) {
        UserDefaults.standard.set(nil, forKey: Settings().USER_EMAIL_KEY)
    }
    
    
    // MARK: Generate a random 4 digit code
    func generateRandomCode() -> String? {
        return String(1000+arc4random_uniform(8999))
    }
    
    
    // MARK: Password management
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
    
    
    // MARK: Email management
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
    
    
    // MARK: User management
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
    
    
    // MARK: APPLICATIONDATA functions
    func updateApplicationData () {
        let applicationData = ApplicationData(context: context)
        applicationData.currentDate = Date()
        saveCoreDataContext()
    }
    
    
    // MARK: YEAR functions
    func getyearsCount () -> Int {
        return _cdYearsList.count
    }
    
    func getYear (atIndex index: Int) -> YearCD? {
        return _cdYearsList[index]
    }
    
    func getYear (forValue value: Int) -> YearCD? {
        guard let yearIndex = _cdYearsList.firstIndex(where: { (year) -> Bool in
            year.year == value
        }) else { return nil }
        return getYear(atIndex: yearIndex)
    }
    
    func getYearIndex (forValue value: Int) -> Int? {
        guard let year = getYear(forValue: value) else { return 0 }
        return _cdYearsList.firstIndex(of: year)
    }
    
    func setSelectedYear (forYear newSelectedYear: YearCD) {
        let oldSelectedYear = getSelectedYear()
        oldSelectedYear?.selected = false
        newSelectedYear.selected = true
    }
    
    func getSelectedYear () -> YearCD? {
        guard let selectedYear = _cdYearsList.first(where: { (year) -> Bool in
            year.selected == true
        }) else { return nil }
        
        return selectedYear
    }

    
    // MARK: GROUPIDEA functions
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
    
    
    // MARK: CATEGORY Functions
    func initCategory () {
        if getApplicationDataCount() == 0 {
            _ = addCategory(NSLocalizedString("All categories", comment: ""), isSelected: true, topList: true)
            _ = addCategory(NSLocalizedString("Unclassified", comment: ""), isSelected: false, topList: true)
        }
//        print("init categoryList?")
//        _cdCategoryList.forEach { (category) in
//            print(category)
//        }
    }
    
    func getCategoryCount () -> Int {
        return _cdCategoriesList.count
    }
    
    func getTopCategoryCount() -> Int {
        return _cdTopCategories.count
    }
    
    func getTopCategory(atIndex index: Int) -> CategoryCD {
        return _cdTopCategories[index]
    }
    
    func getCategory (atIndex index: Int) -> CategoryCD {
        return _cdCategoriesList[index]
    }
    
    func getCategoryIndex (forCategory category: CategoryCD) -> Int? {
        if category.toplist {
            return _cdTopCategories.firstIndex(of: category)
        } else {
            return _cdCategoriesList.firstIndex(of: category)
        }
    }
    
    func getCategory (forName categoryName: String) -> CategoryCD? {
        if let category = _cdCategoriesList.first(where: { (category) -> Bool in
            categoryName == category.title
        }) {
            return category
        } else if let category = _cdTopCategories.first(where: { (category) -> Bool in
            categoryName == category.title
        }) {
            return category
        } else {
            return nil
        }
    }
    
    func getPickerCategories() -> [String] {
        var pickerCategories = [String]()
        pickerCategories.append(_cdTopCategories[1].title!)
        _cdCategoriesList.forEach { (category) in
            pickerCategories.append(category.title!)
        }
        return pickerCategories
    }
    
    func addCategory (_ categoryTitle: String, isSelected: Bool, topList: Bool) -> CategoryCD {
        let newCategory = CategoryCD(context: context)
        newCategory.title = categoryTitle
        newCategory.selected = isSelected
        newCategory.toplist = topList
        saveCoreDataContext()
        return newCategory
    }

    func checkForDuplicateCategory (forCategoryName categoryName: String) -> Bool {
        var categoryNameExists: Bool = false
        
        _cdCategoriesList.forEach({ (category) in
            if categoryName == category.title {
                categoryNameExists.toggle()
            }
        })
        
        _cdTopCategories.forEach { (category) in
            if categoryName == category.title {
                categoryNameExists.toggle()
            }
        }
        
        return categoryNameExists
    }
    
    func getSelectedCategory () -> CategoryCD? {
        if let selectedCategory = _cdCategoriesList.first(where: { (category) -> Bool in
            category.selected == true
            }){
            return selectedCategory
        } else if let selectedCategory = _cdTopCategories.first(where: { (category) -> Bool in
            category.selected == true
        }){
            return selectedCategory
        } else {
            return nil
        }
    }
    
    func setSelectedCategory (forCategory newSelectedCategory: CategoryCD) {
        
        _cdTopCategories.forEach { (category) in
            category.selected = false
        }
    
        _cdCategoriesList.forEach { (category) in
            category.selected = false
        }
        
        newSelectedCategory.selected = true
        saveCoreDataContext()
    }
    
    func modifyCategoryTitle (forCategory category: CategoryCD, withNewTitle newTitle: String) {
        category.title = newTitle
        saveCoreDataContext()
    }
    
    func removeCategory (atIndex index: Int) {
        let categoryToDelete = getCategory(atIndex: index)
        context.delete(categoryToDelete)
        saveCoreDataContext()
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
