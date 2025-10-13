//
//
//

import SwiftUI

struct CreateReportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reportName: String = ""
    @State private var isCreatingReport: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var selectedDiagnosis: Diagnosis? = nil
    
    var diagnoses: [Diagnosis]
    var onCreate: (String, Diagnosis?) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Report Name")) {
                    TextField("Enter report name", text: $reportName)
                        .autocapitalization(.words)
                }
                
                Section(header: Text("Select the diagnose that you want to include in this report")) {
                    Picker("Select Diagnosis", selection: $selectedDiagnosis) {
                        Text("None").tag(nil as Diagnosis?)
                        ForEach(diagnoses, id: \.id) { diagnosis in
                            Text("\(diagnosis.parcelName) – Plant \(diagnosis.plantNumber)")
                                .tag(diagnosis as Diagnosis?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section {
                    Button(action: createReport) {
                        HStack {
                            Spacer()
                            if isCreatingReport {
                                ProgressView()
                            } else {
                                Text("Create Report")
                                    .bold()
                            }
                            Spacer()
                        }
                    }
                    .disabled(reportName.trimmingCharacters(in: .whitespaces).isEmpty || isCreatingReport)
                }
            }
            .navigationTitle("New Report")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func createReport() {
        let trimmedName = reportName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            alertMessage = "Report name cannot be empty."
            showAlert = true
            return
        }
        
        isCreatingReport = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isCreatingReport = false
            onCreate(trimmedName, selectedDiagnosis)
            dismiss()
        }
    }
}

#Preview {
    // Example diagnoses to preview
    let sampleDiagnoses = [
        Diagnosis(parcelName: "Parcel A", plantNumber: "1", technicianName: "Luis", diagnosis: "Nitrogen Deficiency"),
        Diagnosis(parcelName: "Parcel B", plantNumber: "2", technicianName: "Ana", diagnosis: "Healthy Plant"),
        Diagnosis(parcelName: "Parcel C", plantNumber: "3", technicianName: "Miguel", diagnosis: "Iron Deficiency")
    ]
    
    return CreateReportView(diagnoses: sampleDiagnoses) { name, selected in
        print("Created report: \(name), diagnosis: \(selected?.diagnosis ?? "None")")
    }
}
