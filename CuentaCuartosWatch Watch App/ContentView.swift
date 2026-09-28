import SwiftUI
import Charts

struct ContentView: View {
    @EnvironmentObject var receiver: WatchDataReceiver
    
    var body: some View {
        ScrollView {
            if let data = receiver.dashboardData {
                VStack(spacing: 12) {
                    // Saldo Total
                    VStack(spacing: 2) {
                        Text("Saldo Total")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                        
                        Text(String(format: "%.2f €", data.totalBalance))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(data.totalBalance >= 0 ? .green : .red)
                    }
                    .padding(.vertical, 8)
                    
                    // Gráfico de Donut Rápido
                    Chart {
                        SectorMark(
                            angle: .value("Ingresos", max(0.1, data.totalIncome)),
                            innerRadius: .ratio(0.65),
                            angularInset: 1
                        )
                        .foregroundStyle(Color.green.gradient)
                        .cornerRadius(4)
                        
                        SectorMark(
                            angle: .value("Gastos", max(0.1, data.totalExpenses)),
                            innerRadius: .ratio(0.65),
                            angularInset: 1
                        )
                        .foregroundStyle(Color.red.gradient)
                        .cornerRadius(4)
                    }
                    .frame(height: 100)
                    .chartBackground { proxy in
                        VStack {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.secondary.opacity(0.5))
                        }
                    }
                    
                    // Cajas de Ingresos/Gastos
                    HStack(spacing: 8) {
                        StatBox(title: "Ingresos", amount: data.totalIncome, color: .green)
                        StatBox(title: "Gastos", amount: data.totalExpenses, color: .red)
                    }
                }
                .padding(.horizontal)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "iphone.and.arrow.forward")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue.gradient)
                    
                    Text("Abre la app en tu iPhone para sincronizar")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatBox: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
            
            Text(String(format: "%.0f €", amount))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(color.opacity(0.15))
        .cornerRadius(8)
    }
}
