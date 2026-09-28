import Foundation
import FirebaseFirestore
import Combine
import Network

class DataManager: ObservableObject {
    @Published var transactions: [FinancialTransaction] = []
    @Published var categories: [TransactionCategory] = []
    @Published var accounts: [FinancialAccount] = []
    @Published var isOnline: Bool = true
    
    private var db = Firestore.firestore()
    private var categoriesListener: ListenerRegistration?
    private var transactionsListener: ListenerRegistration?
    private var accountsListener: ListenerRegistration?
    
    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    var userId: String? {
        didSet {
            // Cuando cambie el usuario (login/logout), recargamos los datos
            if userId != oldValue {
                restartListeners()
            }
        }
    }
    
    init(userId: String? = nil) {
        self.userId = userId
        setupNetworkMonitor()
        restartListeners()
    }
    
    deinit {
        networkMonitor.cancel()
        removeListeners()
    }
    
    private func setupNetworkMonitor() {
        networkMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isOnline = path.status == .satisfied
            }
        }
        networkMonitor.start(queue: monitorQueue)
    }
    
    private func removeListeners() {
        accountsListener?.remove()
        categoriesListener?.remove()
        transactionsListener?.remove()
    }
    
    private func restartListeners() {
        removeListeners()
        // Si no hay usuario, limpiamos los datos
        guard userId != nil else {
            self.accounts = []
            self.categories = []
            self.transactions = []
            return
        }
        
        fetchAccounts()
        fetchCategories()
        fetchTransactions()
    }
    
    // Rutas protegidas por usuario
    private var accountsCollection: CollectionReference {
        db.collection("users").document(userId ?? "unknown").collection("accounts")
    }
    private var categoriesCollection: CollectionReference {
        db.collection("users").document(userId ?? "unknown").collection("categories")
    }
    private var transactionsCollection: CollectionReference {
        db.collection("users").document(userId ?? "unknown").collection("transactions")
    }
    
    func fetchAccounts() {
        guard userId != nil else { return }
        accountsListener = accountsCollection.order(by: "name").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            self.accounts = documents.compactMap { try? $0.data(as: FinancialAccount.self) }
        }
    }
    
    func addAccount(_ account: FinancialAccount) {
        guard userId != nil else { return }
        do { let _ = try accountsCollection.addDocument(from: account) } catch { print(error) }
    }
    
    func updateAccount(_ account: FinancialAccount) {
        guard let id = account.id, userId != nil else { return }
        do { try accountsCollection.document(id).setData(from: account) } catch { print(error) }
    }
    
    func deleteAccount(_ account: FinancialAccount) {
        guard let id = account.id, userId != nil else { return }
        accountsCollection.document(id).delete()
    }
    
    func fetchCategories() {
        guard userId != nil else { return }
        categoriesListener = categoriesCollection.order(by: "name").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            self.categories = documents.compactMap { try? $0.data(as: TransactionCategory.self) }
        }
    }
    
    func addCategory(_ category: TransactionCategory) {
        guard userId != nil else { return }
        do { let _ = try categoriesCollection.addDocument(from: category) } catch { print(error) }
    }
    
    func updateCategory(_ category: TransactionCategory) {
        guard let id = category.id, userId != nil else { return }
        do { try categoriesCollection.document(id).setData(from: category) } catch { print(error) }
    }
    
    func deleteCategory(_ category: TransactionCategory) {
        guard let id = category.id, userId != nil else { return }
        categoriesCollection.document(id).delete()
    }
    
    func fetchTransactions() {
        guard userId != nil else { return }
        transactionsListener = transactionsCollection.order(by: "date", descending: true).addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            self.transactions = documents.compactMap { try? $0.data(as: FinancialTransaction.self) }
            
            // Sincronizar automáticamente con el Apple Watch
            WatchSyncManager.shared.syncDashboard(transactions: self.transactions)
        }
    }
    
    func addTransaction(_ transaction: FinancialTransaction) {
        guard userId != nil else { return }
        do { let _ = try transactionsCollection.addDocument(from: transaction) } catch { print(error) }
    }
    
    func updateTransaction(_ transaction: FinancialTransaction) {
        guard let id = transaction.id, userId != nil else { return }
        do { try transactionsCollection.document(id).setData(from: transaction) } catch { print(error) }
    }
    
    func deleteTransaction(_ transaction: FinancialTransaction) {
        guard let id = transaction.id, userId != nil else { return }
        transactionsCollection.document(id).delete()
    }
    
    func deleteAllData() {
        for acc in accounts { deleteAccount(acc) }
        for cat in categories { deleteCategory(cat) }
        for trans in transactions { deleteTransaction(trans) }
    }
    
    @MainActor
    func refreshData() async {
        restartListeners()
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
    
    // MARK: - MIGRACIÓN DE DATOS GLOBALES
    // Esta función coge todos los datos de cuando la app no tenía Login
    // y los copia al usuario actual.
    @MainActor
    func migrateOldGlobalData() async throws {
        guard userId != nil else { return }
        
        let batch = db.batch()
        
        // Cuentas globales
        let globalAccounts = try await db.collection("accounts").getDocuments()
        for doc in globalAccounts.documents {
            let newRef = accountsCollection.document()
            batch.setData(doc.data(), forDocument: newRef)
            // Opcionalmente borramos el antiguo
            // batch.deleteDocument(doc.reference)
        }
        
        // Categorías globales
        let globalCategories = try await db.collection("categories").getDocuments()
        for doc in globalCategories.documents {
            let newRef = categoriesCollection.document()
            batch.setData(doc.data(), forDocument: newRef)
        }
        
        // Transacciones globales
        let globalTransactions = try await db.collection("transactions").getDocuments()
        for doc in globalTransactions.documents {
            let newRef = transactionsCollection.document()
            batch.setData(doc.data(), forDocument: newRef)
        }
        
        // Ejecutamos todo de golpe
        try await batch.commit()
    }
}
