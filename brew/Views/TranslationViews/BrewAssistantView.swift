//
//  BrewAssistantView.swift
//  brew
//
//  AI Assistant UI for coffee and tech support
//  Created by Humbe on 15/10/25.
//

import SwiftUI

struct BrewAssistantView: View {
    @StateObject private var assistant = BrewAssistantManager.shared
    @StateObject private var translator = TsotsilMLXTranslator.shared
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var messageText = ""
    @State private var showQuickActions = true
    @State private var isTranslationEnabled = true
    @FocusState private var isInputFocused: Bool
    
    // Colors
    private let brewBrown = Color(red: 81/255, green: 57/255, blue: 29/255)
    private let brewGreen = Color(red: 76/255, green: 130/255, blue: 89/255)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages ScrollView
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if assistant.conversationHistory.isEmpty {
                                welcomeView
                            } else {
                                ForEach(assistant.conversationHistory) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                            }
                            
                            if assistant.isProcessing {
                                TypingIndicator()
                            }
                        }
                        .padding()
                    }
                    .onChange(of: assistant.conversationHistory.count) { _ in
                        if let lastMessage = assistant.conversationHistory.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Quick Actions
                if showQuickActions && assistant.conversationHistory.isEmpty {
                    quickActionsView
                }
                
                Divider()
                
                // Input Area
                inputArea
            }
            .navigationTitle("Asistente brew")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { isTranslationEnabled.toggle() }) {
                            Label(
                                isTranslationEnabled ? "Desactivar Traducción" : "Activar Traducción",
                                systemImage: isTranslationEnabled ? "text.bubble.fill" : "text.bubble"
                            )
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: {
                            assistant.clearHistory()
                        }) {
                            Label("Limpiar Conversación", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(brewBrown)
                    }
                }
            }
        }
    }
    
    // MARK: - Welcome View
    
    private var welcomeView: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(brewGreen.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "leaf.fill")
                    .font(.system(size: 40))
                    .foregroundColor(brewGreen)
            }
            .padding(.top, 40)
            
            // Welcome text
            VStack(spacing: 12) {
                Text("¡Bienvenido!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Soy tu asistente de brew 🌱")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Puedo ayudarte con el cultivo de café, resolver problemas técnicos y gestionar tus parcelas.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Language indicator
            if translator.isModelLoaded {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Soporte multilingüe activo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("🌽 Tsotsil")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(20)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(assistant.getQuickActions()) { action in
                    QuickActionButton(action: action) {
                        messageText = action.prompt
                        sendMessage()
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 80)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Input Area
    
    private var inputArea: some View {
        HStack(spacing: 12) {
            // Translation indicator
            if isTranslationEnabled && translator.isTranslating {
                ProgressView()
                    .scaleEffect(0.8)
            }
            
            // Text field
            TextField("Escribe tu mensaje...", text: $messageText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .lineLimit(1...5)
                .focused($isInputFocused)
                .disabled(assistant.isProcessing)
            
            // Send button
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(messageText.isEmpty ? .gray : brewBrown)
            }
            .disabled(messageText.isEmpty || assistant.isProcessing)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let message = messageText
        messageText = ""
        isInputFocused = false
        showQuickActions = false
        
        assistant.autoTranslate = isTranslationEnabled
        
        Task {
            _ = await assistant.processMessage(message)
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ConversationMessage
    
    private let brewBrown = Color(red: 81/255, green: 57/255, blue: 29/255)
    private let brewGreen = Color(red: 76/255, green: 130/255, blue: 89/255)
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if !message.isFromUser {
                // Assistant icon
                Circle()
                    .fill(brewGreen.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 14))
                            .foregroundColor(brewGreen)
                    )
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                // Message content
                Text(message.content)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isFromUser ? brewBrown : Color(.systemGray5))
                    .foregroundColor(message.isFromUser ? .white : .primary)
                    .cornerRadius(18)
                
                // Timestamp and language indicator
                HStack(spacing: 4) {
                    if message.language == .tsotsil {
                        Text("🌽")
                            .font(.caption2)
                    }
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if message.isFromUser {
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let action: QuickAction
    let onTap: () -> Void
    
    private let brewBrown = Color(red: 81/255, green: 57/255, blue: 29/255)
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: action.icon)
                    .font(.system(size: 24))
                    .foregroundColor(brewBrown)
                    .frame(width: 44, height: 44)
                    .background(brewBrown.opacity(0.1))
                    .clipShape(Circle())
                
                Text(action.title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Assistant icon
            Circle()
                .fill(Color.green.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                )
            
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 8, height: 8)
                        .opacity(animationPhase == index ? 1 : 0.3)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemGray5))
            .cornerRadius(18)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                    animationPhase = (animationPhase + 1) % 3
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview

struct BrewAssistantView_Previews: PreviewProvider {
    static var previews: some View {
        BrewAssistantView()
            .environmentObject(LanguageManager.shared)
    }
}
