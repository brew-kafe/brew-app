//
//  WeatherCardView.swift
//  brew
//

import SwiftUI
import CoreLocation

// MARK: - API Response Models

struct OpenWeatherResponse: Codable {
    let main: MainWeather
    let weather: [WeatherCondition]
    let name: String

    struct MainWeather: Codable {
        let temp: Double
        let tempMin: Double
        let tempMax: Double

        enum CodingKeys: String, CodingKey {
            case temp
            case tempMin = "temp_min"
            case tempMax = "temp_max"
        }
    }

    struct WeatherCondition: Codable {
        let main: String
        let description: String
        let icon: String
    }
}

/// Pronóstico en bloques de 3h (usado para calcular Min/Máx reales del día)
struct ForecastResponse: Codable {
    let list: [ForecastItem]

    struct ForecastItem: Codable {
        let dt: TimeInterval
        let main: Main
        let pop: Double? // 0..1 probabilidad de precipitación

        struct Main: Codable {
            let temp: Double
            let tempMin: Double
            let tempMax: Double

            enum CodingKeys: String, CodingKey {
                case temp
                case tempMin = "temp_min"
                case tempMax = "temp_max"
            }
        }
    }
}

// MARK: - Weather Data Model (lo que consume la UI)

struct WeatherData: Codable {
    let temperature: Int
    let condition: String
    let icon: String
    let maxTemp: Int
    let minTemp: Int
    let rainProbability: Int
    let cityName: String

    static let sample = WeatherData(
        temperature: 24,
        condition: "Nublado",
        icon: "cloud.fill",
        maxTemp: 27,
        minTemp: 19,
        rainProbability: 52,
        cityName: "Monterrey"
    )
}

// MARK: - Weather Service

@MainActor
class OpenWeatherService: ObservableObject {
    // Tu API Key
    private let apiKey = "0a4404e22f52ce17fd8db4923b733116"
    private let baseURL = "https://api.openweathermap.org/data/2.5"

    @Published var weatherData: WeatherData?
    @Published var isLoading = false
    @Published var error: String?

    private let locationProvider = WeatherLocationProvider()

    /// Carga clima. Si no pasas lat/lon usa la ubicación del usuario.
    func fetchWeather(latitude: Double? = nil, longitude: Double? = nil) async {
        isLoading = true
        error = nil

        do {
            // Ubicación
            let location: CLLocation
            if let lat = latitude, let lon = longitude {
                location = CLLocation(latitude: lat, longitude: lon)
            } else {
                location = try await requestUserLocation()
            }

            // Sesión con timeouts
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 20
            config.timeoutIntervalForResource = 30
            let session = URLSession(configuration: config)

            // Clima actual
            let weatherURL = "\(baseURL)/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric&lang=es"
            guard let urlWeather = URL(string: weatherURL) else { throw WeatherError.invalidURL }

            let (wData, wResp) = try await session.data(from: urlWeather)
            if let http = wResp as? HTTPURLResponse, http.statusCode >= 400 {
                throw WeatherError.http(code: http.statusCode)
            }
            let weatherResponse = try JSONDecoder().decode(OpenWeatherResponse.self, from: wData)

            // 4) Pronóstico (para Min/Máx reales del día y POP)
            //    Tomamos los próximos 8 bloques (~24h) para min/máx y POP promedio
            let forecastURL = "\(baseURL)/forecast?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric&lang=es&cnt=12"
            guard let urlForecast = URL(string: forecastURL) else { throw WeatherError.invalidURL }

            let (fData, fResp) = try await session.data(from: urlForecast)
            if let http = fResp as? HTTPURLResponse, http.statusCode >= 400 {
                throw WeatherError.http(code: http.statusCode)
            }
            let forecastResponse = try JSONDecoder().decode(ForecastResponse.self, from: fData)

            let nextDaySlices = Array(forecastResponse.list.prefix(8)) // ~24h
            let dailyMin = nextDaySlices.map { $0.main.tempMin }.min() ?? weatherResponse.main.tempMin
            let dailyMax = nextDaySlices.map { $0.main.tempMax }.max() ?? weatherResponse.main.tempMax
            let avgRainProb = nextDaySlices.map { $0.pop ?? 0.0 }.reduce(0.0, +) / Double(max(nextDaySlices.count, 1))

            // Mapea a modelo de UI
            let newWeather = WeatherData(
                temperature: Int(weatherResponse.main.temp.rounded()),
                condition: weatherResponse.weather.first?.description.capitalized ?? "Desconocido",
                icon: mapWeatherIcon(weatherResponse.weather.first?.icon ?? "01d"),
                maxTemp: Int(dailyMax.rounded()),
                minTemp: Int(dailyMin.rounded()),
                rainProbability: Int((avgRainProb * 100).rounded()),
                cityName: weatherResponse.name
            )

            self.weatherData = newWeather
            isLoading = false
        } catch let urlError as URLError {
            self.error = "Error de conexión. Verifica tu internet."
            if self.weatherData == nil { self.weatherData = WeatherData.sample }
            isLoading = false
            print("URLError:", urlError)
        } catch WeatherError.invalidURL {
            self.error = "URL inválida."
            if self.weatherData == nil { self.weatherData = WeatherData.sample }
            isLoading = false
        } catch WeatherError.http(let code) {
            self.error = "Error del servidor (\(code))."
            if self.weatherData == nil { self.weatherData = WeatherData.sample }
            isLoading = false
        } catch {
            self.error = "No se pudo obtener el clima."
            if self.weatherData == nil { self.weatherData = WeatherData.sample }
            isLoading = false
            print("Error:", error.localizedDescription)
        }
    }

    private func requestUserLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { cont in
            locationProvider.requestOneShotLocation(
                onLocation: { loc in cont.resume(returning: loc) },
                onDenied: { cont.resume(throwing: WeatherError.locationDenied) }
            )
        }
    }

    private func mapWeatherIcon(_ iconCode: String) -> String {
        switch iconCode {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "smoke.fill"
        case "09d", "09n": return "cloud.rain.fill"
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "cloud.fill"
        }
    }

    enum WeatherError: Error {
        case invalidURL
        case locationDenied
        case http(code: Int)
    }
}

// MARK: - WeatherCard Component (simple + chips minimalistas)

struct WeatherCard: View {
    let latitude: Double?
    let longitude: Double?

    @StateObject private var weatherService = OpenWeatherService()

    init(latitude: Double? = nil, longitude: Double? = nil) {
        self.latitude = latitude
        self.longitude = longitude
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Text("Clima")
                .font(.title3).bold()
                .foregroundColor(.primary)

            // Divider a todo el ancho de la tarjeta
            Divider()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, -16)

            if let w = weatherService.weatherData {
                // Icono + Temperatura
                HStack(spacing: 12) {
                    weatherIcon(symbol: w.icon)
                        .font(.system(size: 36))
                        .frame(width: 40, height: 40)

                    Text("\(w.temperature)°")
                        .font(.system(size: 32, weight: .bold))
                        .monospacedDigit()
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer(minLength: 0)
                }

                // Condición y Ciudad
                VStack(alignment: .leading, spacing: 2) {
                    Text(w.condition)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Text(w.cityName)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
                .padding(.top, 4)

                // Chips minimalistas (horizontales, como te gustaron)
                HStack(spacing: 8) {
                    compactChip(icon: "arrow.up", text: "\(w.maxTemp)°")
                    compactChip(icon: "arrow.down", text: "\(w.minTemp)°")
                    compactChip(icon: "cloud.rain", text: "\(w.rainProbability)%")
                }
                .padding(.top, 8)

            } else if let error = weatherService.error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .lineLimit(2)
            } else {
                HStack {
                    ProgressView().scaleEffect(0.8)
                    Text("Cargando clima…")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
        .task {
            await weatherService.fetchWeather(latitude: latitude, longitude: longitude)
        }
    }

    // Ícono con tintes personalizados (para que la luna no se pierda)
    @ViewBuilder
    private func weatherIcon(symbol: String) -> some View {
        let tint: Color = {
            if symbol.contains("moon") { return .indigo }
            if symbol.contains("sun.max") || symbol.contains("sun") { return .yellow }
            if symbol.contains("cloud.bolt") { return .orange }
            if symbol.contains("cloud.rain") { return .blue }
            if symbol.contains("snow") { return .teal }
            if symbol.contains("fog") { return .gray }
            return .primary
        }()
        Image(systemName: symbol)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(tint)
    }

    // Chip compacto minimalista
    private func compactChip(icon: String, text: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption.weight(.semibold))
                .monospacedDigit()
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Location Provider

final class WeatherLocationProvider: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var onLocation: ((CLLocation) -> Void)?
    private var onDenied: (() -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestOneShotLocation(
        onLocation: @escaping (CLLocation) -> Void,
        onDenied: @escaping () -> Void
    ) {
        self.onLocation = onLocation
        self.onDenied = onDenied

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            onDenied()
        default:
            manager.requestLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            onDenied?()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.first {
            onLocation?(loc)
        } else {
            onDenied?()
        }
        onLocation = nil
        onDenied = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("CLLocation error:", error.localizedDescription)
        onDenied?()
        onLocation = nil
        onDenied = nil
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        WeatherCard() // ubicación del usuario
        WeatherCard(latitude: 25.6866, longitude: -100.3161) // Monterrey fijo
    }
    .padding()
    .background(Color(.systemBackground))
}
