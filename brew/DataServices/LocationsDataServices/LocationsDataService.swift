//
//  LocationsDataService.swift
//  MapTest
//
//  Created by AGRM  on 10/09/25.
//

import Foundation
import MapKit


class LocationsDataService {

    static let locations: [Location] = [
        Location(
            name: "Parcela 21",
            cityName: "Chiapas",
            coordinates: CLLocationCoordinate2D(latitude: 16.7365, longitude: -92.6376),
            description: "Parcela ubicada en la región de Los Altos de Chiapas. Cultivo de café arábica con sombra natural de árboles locales. Actualmente presenta buena salud general y producción estable.",
            imageNames: [
                "chiapas-parcela1-1",
                "chiapas-parcela1-2",
            ],
            status: "Sano",
            link: "https://es.wikipedia.org/wiki/Caf%C3%A9_de_Chiapas",
            kind: .safe,
            metrics: .init(sun: 70, moisture: 50, pestSeverity: 12, potassium: "K: Alto", phosphorus: "P: Medio"),
            reports: [
                .init(code: "CC27", date: iso("2025-07-28"), manager: "Luis Torres", file: "CC27.pdf"),
                .init(code: "CC26", date: iso("2025-07-25"), manager: "Luis Torres", file: "CC26.pdf")
            ]
        ),

        Location(
            name: "Parcela El Mirador",
            cityName: "Chiapas",
            coordinates: CLLocationCoordinate2D(latitude: 16.5554, longitude: -92.3125),
            description: "Terreno con presencia de roya leve en algunas plantas. El productor implementa controles biológicos y monitoreo constante para reducir riesgos.",
            imageNames: [
                "chiapas-parcela2-1",
                "chiapas-parcela2-2",
            ],
            status: "Con roya",
            link: "https://es.wikipedia.org/wiki/Roya_del_cafeto",
            kind: .risk,
            metrics: .init(sun: 63, moisture: 58, pestSeverity: 35, potassium: "K: Medio", phosphorus: "P: Bajo"),
            reports: [
                .init(code: "RM11", date: iso("2025-08-10"), manager: "Ana Pérez", file: "RM11.pdf")
            ]
        ),

        Location(
            name: "Parcela Santa María",
            cityName: "Chiapas",
            coordinates: CLLocationCoordinate2D(latitude: 15.9890, longitude: -92.2510),
            description: "Zona con humedad excesiva que ha provocado plagas en las raíces. Necesita intervención urgente para evitar pérdidas en la cosecha.",
            imageNames: [
                "chiapas-parcela3-1",
                "chiapas-parcela3-2",
            ],
            status: "En riesgo",
            link: "https://www.gob.mx/agricultura/",
            kind: .danger,
            metrics: .init(sun: 52, moisture: 87, pestSeverity: 68, potassium: "K: Bajo", phosphorus: "P: Bajo"),
            reports: [
                .init(code: "SM08", date: iso("2025-08-02"), manager: "Marcos López", file: "SM08.pdf"),
                .init(code: "SM07", date: iso("2025-07-18"), manager: "Marcos López", file: nil)
            ]
        ),

        Location(
            name: "Parcela Las Nubes",
            cityName: "Chiapas",
            coordinates: CLLocationCoordinate2D(latitude: 16.2453, longitude: -91.9580),
            description: "Finca ubicada en la Reserva de la Biósfera El Triunfo. Cultivo sostenible con certificación orgánica, altos niveles de biodiversidad y prácticas de conservación.",
            imageNames: [
                "chiapas-parcela4-1",
                "chiapas-parcela4-2",
            ],
            status: "En riesgo",
            link: "https://www.eltriunfo.org/",
            kind: .safe,
            metrics: .init(sun: 66, moisture: 56, pestSeverity: 10, potassium: "K: Medio", phosphorus: "P: Medio"),
            reports: [
                .init(code: "LN03", date: iso("2025-07-30"), manager: "Itzel Ruiz", file: "LN03.pdf")
            ]
        ),

        Location(
            name: "Parcela Río Verde",
            cityName: "Chiapas",
            coordinates: CLLocationCoordinate2D(latitude: 16.5083, longitude: -92.1042),
            description: "Parcela cercana a un río, en riesgo de erosión del suelo durante la temporada de lluvias. El productor trabaja en terrazas y barreras vivas.",
            imageNames: [
                "chiapas-parcela5-1",
                "chiapas-parcela5-2",
            ],
            status: "Con roya",
            link: "https://es.wikipedia.org/wiki/Erosi%C3%B3n_del_suelo",
            kind: .risk,
            metrics: .init(sun: 74, moisture: 42, pestSeverity: 28, potassium: "K: Alto", phosphorus: "P: Medio"),
            reports: [
                .init(code: "RV14", date: iso("2025-08-05"), manager: "Diego Chanona", file: "RV14.pdf")
            ]
        )
    ]
}

// Helper for dates
private func iso(_ s: String) -> Date {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withFullDate]
    return f.date(from: s) ?? .now
}
