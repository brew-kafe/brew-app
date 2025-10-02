# Brew App

Brew is an iOS application developed for our social partner Káapeh México. The app is designed to help coffee producers in Chiapas monitor and manage their coffee plots (“parcelas”), offering features for tracking plot health, reviewing reports, and receiving actionable recommendations.

## Features

- **Dashboard:** An overview with cards showing the status of all coffee plots (healthy, at risk, or in danger), a weather summary, recent reports, and custom crop recommendations.
- **Interactive Map:** Visualize locations of coffee plots with status indicators (safe, risk, danger).
- **Location Details:** Each plot contains detailed information—location, metrics (sun, moisture, pest severity, nutrients), images, history of reports, and quick links to resources.
- **Recent Reports:** View and access the latest agronomic reports for each plot.
- **Recommendations:** Actionable suggestions (e.g., irrigation, fertilization, pest inspection) tailored to current plot conditions.
- **Alerts:** Notifications for urgent conditions or required interventions.

## Example Plot Data

Each plot includes:
- Name and city (e.g., "Parcela 21", Chiapas)
- GPS coordinates
- Description of the plot and current health
- Collection of images
- External reference links (e.g., Wikipedia, official resources)

## Core Architecture

- **SwiftUI** for all UI components and navigation.
- **MVVM Pattern**: 
  - `LocationsViewModel` handles state, filtering, and map logic.
  - `LocationsDataService` provides static plot data.
  - Views for dashboard, plot detail, home, and diagnostics.
- **MapKit**: Used for geospatial features and location display.
- **Charts** (iOS 16+): For visualizing plot status trends.

## Dependencies

- SwiftUI (iOS 16+)
- MapKit
- Charts (Apple)
- Foundation

## Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/brew-kafe/brew-app.git
   cd brew-app
   ```

2. **Open in Xcode:**
   - Open `brew-app.xcodeproj` or `brew-app.xcworkspace` (if using Swift Package Manager dependencies).

3. **Build & Run:**
   - Select an iOS Simulator (iPhone 14 or later recommended).
   - Build and run the project.

4. **Test Data:**
   - The app ships with sample data for several plots located in Chiapas, each with realistic agronomic metrics and reports.

---
© Brew Kafé, 2025
