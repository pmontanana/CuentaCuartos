import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var isShowingAddTransaction = false
    @State private var editingTransaction: FinancialTransaction?
    @State private var detailingTransaction: FinancialTransaction?
    
    @AppStorage("dashboardChartType") private var dashboardChartType: String = "donut"
    
    var body: some View {
        ZStack {
            // Fondo Dinámico Premium
            LinearGradient(
                colors: [Color.blue.opacity(0.08), Color.indigo.opacity(0.04), Color.purple.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Tarjeta Principal (Balance)
                    VStack(spacing: 12) {
                        Text("Balance Total")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(1.2)
                        
                        Text("\(totalBalance >= 0 ? "" : "-")\(abs(totalBalance), format: .currency(code: "EUR"))")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(totalBalance > 0 ? Color.green : totalBalance < 0 ? Color.red : Color.primary)
                            .contentTransition(.numericText())
                    }
                    .padding(.vertical, 36)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 20, x: 0, y: 12)
                    .padding(.horizontal)
                    
                    // Tarjetas de Ingresos y Gastos
                    HStack(spacing: 16) {
                        SummaryCard(title: "Ingresos", amount: totalIncome, icon: "arrow.down.left.circle.fill", color: .green, isIncome: true)
                        SummaryCard(title: "Gastos", amount: totalExpense, icon: "arrow.up.right.circle.fill", color: .red, isIncome: false)
                    }
                    .padding(.horizontal)
                    
                    if !dataManager.transactions.isEmpty {
                        
                        // Gráfico de Gastos por Categoría
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text(dashboardChartType == "donut" ? "Gastos por Categoría" : "Últimos Movimientos")
                                    .font(.title3.weight(.bold))
                                Spacer()
                                Image(systemName: dashboardChartType == "donut" ? "chart.pie.fill" : "chart.bar.xaxis")
                                    .foregroundStyle(.tertiary)
                            }
                            
                            if dashboardChartType == "donut" {
                                if expensesByCategory.isEmpty {
                                    Text("No hay gastos registrados aún")
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 40)
                                } else {
                                    Chart {
                                        ForEach(expensesByCategory, id: \.name) { item in
                                            SectorMark(
                                                angle: .value("Gasto", item.amount),
                                                innerRadius: .ratio(0.65),
                                                angularInset: 1.5
                                            )
                                            .cornerRadius(4)
                                            .foregroundStyle(by: .value("Categoría", item.name))
                                        }
                                    }
                                    .chartForegroundStyleScale(
                                        domain: expensesByCategory.map { $0.name },
                                        range: expensesByCategory.map { $0.color }
                                    )
                                    .frame(height: 220)
                                    .overlay {
                                        VStack {
                                            Text("Gastos")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text(totalExpense, format: .currency(code: "EUR"))
                                                .font(.headline.bold())
                                        }
                                    }
                                }
                            } else {
                                Chart {
                                    ForEach(dataManager.transactions.prefix(12)) { transaction in
                                        BarMark(
                                            x: .value("Fecha", transaction.date, unit: .day),
                                            y: .value("Cantidad", transaction.amount)
                                        )
                                        .foregroundStyle(by: .value("Tipo", transaction.type.rawValue))
                                        .position(by: .value("Tipo", transaction.type.rawValue))
                                        .cornerRadius(6)
                                    }
                                }
                                .chartForegroundStyleScale([
                                    TransactionType.income.rawValue: AnyShapeStyle(Color.green.gradient),
                                    TransactionType.expense.rawValue: AnyShapeStyle(Color.red.gradient)
                                ])
                                .frame(height: 220)
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day)) { _ in
                                        AxisValueLabel(format: .dateTime.day().month(), centered: true)
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks { value in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                                        AxisValueLabel()
                                    }
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .stroke(.white.opacity(0.15), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                        // Lista Rápida Recientes
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recientes")
                                .font(.title3.weight(.bold))
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                ForEach(Array(dataManager.transactions.prefix(3).enumerated()), id: \.element.id) { index, transaction in
                                    TransactionRowView(
                                        transaction: transaction,
                                        onEdit: { editingTransaction = transaction },
                                        onDetail: { detailingTransaction = transaction }
                                    )
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 14)
                                    
                                    if index < 2 {
                                        Divider().padding(.leading, 70)
                                    }
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .stroke(.white.opacity(0.15), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        }
                        
                    } else {
                        ContentUnavailableView(
                            "Sin datos",
                            systemImage: "chart.pie.fill",
                            description: Text("Añade tu primer movimiento para ver las estadísticas.")
                        )
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
            .refreshable {
                await dataManager.refreshData()
            }
        }
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    isShowingAddTransaction = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue.gradient)
                }
            }
        }
        .sheet(isPresented: $isShowingAddTransaction) {
            AddTransactionView()
        }
        .sheet(item: $editingTransaction) { transaction in
            AddTransactionView(transactionToEdit: transaction)
        }
        .sheet(item: $detailingTransaction) { transaction in
            TransactionDetailView(transaction: transaction)
        }
    }
    
    private var totalIncome: Double {
        dataManager.transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpense: Double {
        dataManager.transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalBalance: Double {
        totalIncome - totalExpense
    }
    
    private var expensesByCategory: [(name: String, amount: Double, color: Color)] {
        let expenses = dataManager.transactions.filter { $0.type == .expense }
        var grouped: [String: Double] = [:]
        
        for expense in expenses {
            let catName = expense.categoryName ?? "Otros"
            grouped[catName, default: 0] += expense.amount
        }
        
        return grouped.map { (name, amount) in
            let cat = dataManager.categories.first(where: { $0.name == name })
            let color = Color(hex: cat?.hexColor ?? "#808080") ?? .gray
            return (name, amount, color)
        }.sorted { $0.amount > $1.amount }
    }
}

struct SummaryCard: View {
    var title: String
    var amount: Double
    var icon: String
    var color: Color
    var isIncome: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundStyle(color.gradient)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
                Text("\(isIncome ? "+" : "-")\(abs(amount), format: .currency(code: "EUR"))")
                    .font(.title3.weight(.bold))
                    .fontDesign(.rounded)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}
