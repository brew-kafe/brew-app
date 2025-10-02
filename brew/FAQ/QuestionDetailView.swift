//
//  QuestionDetailView.swift
//  brew
//
//  Created by Regina Romero on 9/30/25.
//

import SwiftUI

struct QuestionDetailView: View {
    let question : Question
    var body: some View {
    
        VStack{
            ScrollView{
                
                Text(question.question)
                    .font(.headline)
                
                Text(question.answer)
                    .padding(.horizontal, 26)
                    .font(.system(size: 18))
                
            }
            
        }
}
}

#Preview {
    QuestionDetailView(question: Question(id: 1, question: "what?", answer: "up", isExpanded: false))
}
