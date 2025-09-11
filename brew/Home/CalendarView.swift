//
//  CalendarView.swift
//  brew
//
//  Created by Monserrath Valenzuela on 10/09/25.
//

import SwiftUI

// MARK: - CalendarView Component
struct CalendarView: View {
    @State private var selectedDay: Int? = nil
    
    // Propiedades configurables
    let monthName: String
    let weekDays: [String]
    let days: [Int]
    let headerColor: Color
    
    // Callback para cuando se selecciona un día
    let onDaySelected: ((Int) -> Void)?
    
    // Inicializador con valores por defecto
    init(
        monthName: String = "Septiembre",
        weekDays: [String] = ["D", "L", "M", "M", "J", "V", "S"],
        days: [Int] = [8, 9, 10, 11, 12, 13, 14],
        headerColor: Color = Color(.systemGray6),
        onDaySelected: ((Int) -> Void)? = nil
    ) {
        self.monthName = monthName
        self.weekDays = weekDays
        self.days = days
        self.headerColor = headerColor
        self.onDaySelected = onDaySelected
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header del mes
            HStack {
                Text(monthName)
                    .font(.title3)
                    .fontWeight(.bold)
                
                    .padding(.horizontal, 16)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(headerColor)
            .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
            
            // Contenido del calendario
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                // --- Fila de días de la semana ---
                ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, minHeight: 35)
                        .foregroundColor(.primary)
                        .padding(.top, -10)
                }
                
                // --- Días numéricos clickeables ---
                ForEach(days, id: \.self) { day in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedDay = day
                            onDaySelected?(day) // Notifica al padre
                        }
                    }) {
                        Text("\(day)")
                            .font(.body)
                            .fontWeight(.regular)
                            .frame(width: 30, height: 30)
                            .background(selectedDay == day ? Color(red: 155/255, green: 186/255, blue: 116/255) : .white)
                            .foregroundColor(selectedDay == day ? .white : .primary)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                            .scaleEffect(selectedDay == day ? 1.05 : 1.0) // Pequeña animación
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, -10)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .background(Color(.systemGray6))
            .clipShape(RoundedCorner(radius: 16, corners: [.bottomLeft, .bottomRight]))
        }
        .shadow(color: .black.opacity(0.1), radius:4, x: 0, y: 2)
        //.shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
        .shadow(radius: 3)
        
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        CalendarView()
    }
    .background(Color(.systemBackground))
}
