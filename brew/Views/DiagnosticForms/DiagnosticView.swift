import SwiftUI

struct DiagnosticView: View {
    @StateObject var viewModel = DiagnosisViewModel()
    @State private var showCamera = false
    @State private var selectedDiagnosis: Diagnosis?

    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.diagnoses) { diagnosis in
                    Button {
                        selectedDiagnosis = diagnosis
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(diagnosis.parcelName)
                                    .font(.headline)
                                Spacer()
                                Text(dateFormatter.string(from: diagnosis.date))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Text(diagnosis.plantNumber)
                                .font(.subheadline)
                            Text("Técnico: \(diagnosis.technicianName)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(diagnosis.diagnosis)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Diagnósticos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCamera = true }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(Color(red: 88 / 255, green: 92 / 255, blue: 48 / 255)))
                    }
                    .accessibilityLabel("Abrir cámara para diagnóstico")
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView()
            }
            .sheet(item: $selectedDiagnosis) { diagnosis in
                DiagnosticDetailView(diagnosis: diagnosis, viewModel: viewModel)
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }
}

#Preview {
    DiagnosticView()
}
