//
//  FAQView.swift
//  brew
//
//  Created by Regina Romero on 9/30/25.
//

import SwiftUI

struct FAQView: View {
    @StateObject private var faqVM = QuestionViewModel()
    @State private var searchText = ""
    
    // Filtra las preguntas según el texto de búsqueda
    var filteredQuestions: [Question] {
        if searchText.isEmpty {
            return faqVM.arrQuestion
        } else {
            return faqVM.arrQuestion.filter { question in
                question.question.localizedCaseInsensitiveContains(searchText) ||
                question.answer.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header personalizado con color
            ZStack {
                Color(red: 88 / 255, green: 92 / 255, blue: 48 / 255)
                    .ignoresSafeArea(edges: .top)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("FAQ")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("¿Tienes dudas sobre la app? Aquí encontrarás las preguntas más comunes. Usa el buscador para encontrar un tema específico.")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 250)
            
            // Barra de búsqueda
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Buscar preguntas...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Lista de preguntas
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(filteredQuestions.indices, id: \.self) { index in
                        let originalIndex = faqVM.arrQuestion.firstIndex(where: { $0.id == filteredQuestions[index].id }) ?? index
                        
                        DisclosureGroup(
                            isExpanded: Binding(
                                get: { faqVM.arrQuestion[originalIndex].isExpanded ?? false },
                                set: { faqVM.arrQuestion[originalIndex].isExpanded = $0 }
                            )
                        ) {
                            Text(filteredQuestions[index].answer)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .foregroundColor(.black)
                                .font(.system(size: 16))
                        } label: {
                            HStack {
                                Text(filteredQuestions[index].question)
                                    .foregroundColor(.black)
                                    .font(.system(size: 18))
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 12)
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .background(
                                faqVM.arrQuestion[originalIndex].isExpanded ?? false
                                ? Color(red: 88/255, green: 92/255, blue: 48/255).opacity(0.4) // color resaltado
                                : Color.clear
                            )
                            .cornerRadius(8)
                        }
                        Divider()
                    }
                    
                    // Mensaje cuando no hay resultados
                    if filteredQuestions.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No se encontraron resultados")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Intenta con otras palabras clave")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical)
            }
        }
    }
}

#Preview {
    FAQView()
}
