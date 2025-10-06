//
//  QuestionRowView.swift
//  brew
//
//  Created by Regina Romero on 9/30/25.
//


import SwiftUI

struct QuestionRowView: View {
    
    let question : Question
    
    var body: some View {
        
        VStack{
            
            Text(question.question)
        }
    }
}

#Preview {
    QuestionRowView(question: Question(id: 1, question: "what?", answer: "up", isExpanded: false))
}


