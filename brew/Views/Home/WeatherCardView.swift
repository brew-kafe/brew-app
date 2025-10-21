//
//  WeatherCardView.swift
//  brew
//
//  Created by Monserrath Valenzuela on 11/09/25.

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

struct ForecastResponse: Codable {
    let list: [ForecastItem]
    
    struct ForecastItem: Codable {
        let pop: Double // Probability of precipitation
    }
}

// MARK: - Weather Data Model
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
    private let apiKey = "0a4404e22f52ce17fd8db4923b733116"
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    
    @Published var weatherData: WeatherData?
    @Published var isLoading = false
    @Published var error: String?
    
    private let locationProvider = WeatherLocationProvider()
    
    // MARK: Fetch Weather
    func fetchWeather(latitude: Double? = nil, longitude: Double? = nil) async {
        isLoading = true
        error = nil
        
        do {
            let location: CLLocation
            
            if let lat = latitude, let lon = longitude {
                location = CLLocation(latitude: lat, longitude: lon)
            } else {
                location = try await requestUserLocation()
            }
            
            print("Using coords: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
            // URLSession Config
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 20
            config.timeoutIntervalForResource = 30
            let session = URLSession(configuration: config)
            
            // Fetch current weather
            let weatherURL = "\(baseURL)/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric&lang=es"
            guard let url = URL(string: weatherURL) else { throw WeatherError.invalidURL }
            
            print("Requesting: \(weatherURL)")
            
            let (weatherData, response) = try await session.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP status: \(httpResponse.statusCode)")
            }
            
            let weatherResponse = try JSONDecoder().decode(OpenWeatherResponse.self, from: weatherData)
            print("Weather: \(weatherResponse.main.temp)°C — \(weatherResponse.name)")
            
            // Fetch forecast
            let forecastURL = "\(baseURL)/forecast?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric&cnt=8"
            let (forecastData, _) = try await session.data(from: URL(string: forecastURL)!)
            let forecastResponse = try JSONDecoder().decode(ForecastResponse.self, from: forecastData)
            
            // Rain probability average
            let avgRainProb = forecastResponse.list.reduce(0.0) { $0 + $1.pop } / Double(forecastResponse.list.count)
            
            // Convert to model
            let newWeather = WeatherData(
                temperature: Int(weatherResponse.main.temp.rounded()),
                condition: weatherResponse.weather.first?.description.capitalized ?? "Desconocido",
                icon: mapWeatherIcon(weatherResponse.weather.first?.icon ?? "01d"),
                maxTemp: Int(weatherResponse.main.tempMax.rounded()),
                minTemp: Int(weatherResponse.main.tempMin.rounded()),
                rainProbability: Int((avgRainProb * 100).rounded()),
                cityName: weatherResponse.name
            )
            
            self.weatherData = newWeather
            saveToCache(newWeather)
            isLoading = false
            
        } catch let error as URLError {
            print("Network error: \(error.localizedDescription)")
            self.error = "Error de conexión. Verifica tu internet."
            if self.weatherData == nil { self.weatherData = loadFromCache() ?? WeatherData.sample }
            isLoading = false
        } catch {
            print("Error: \(error.localizedDescription)")
            self.error = "No se pudo obtener el clima"
            if self.weatherData == nil { self.weatherData = loadFromCache() ?? WeatherData.sample }
            isLoading = false
        }
    }
    
    // MARK: Location
    private func requestUserLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            locationProvider.requestOneShotLocation(
                onLocation: { location in continuation.resume(returning: location) },
                onDenied: { continuation.resume(throwing: WeatherError.locationDenied) }
            )
        }
    }
    
    // MARK: Icon mapping
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
    }
    
    // MARK: Cache methods
    private func saveToCache(_ data: WeatherData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "cachedWeather")
        }
    }
    
    private func loadFromCache() -> WeatherData? {
        if let saved = UserDefaults.standard.data(forKey: "cachedWeather"),
           let decoded = try? JSONDecoder().decode(WeatherData.self, from: saved) {
            return decoded
        }
        return nil
    }
}

// MARK: - WeatherCard Component
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
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
                .padding(.bottom,-7)

                // Chips en fila
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

    // Ícono con tintes personalizados
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

    // Chip compacto con icono SF Symbol
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
        print("CLLocation error: \(error.localizedDescription)")
        onDenied?()
        onLocation = nil
        onDenied = nil
    }
}


// MARK: - Preview
#Preview {
    ScrollView {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            WeatherCard()
            
            // Simula la tarjeta de Parcela para comparar tamaños
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(height: 200)
                .overlay(
                    Text("Parcela\n(Para comparar)")
                        .multilineTextAlignment(.center)
                )
        }
        .padding()
    }
    .background(Color(.systemBackground))
}
