# 🃏 Judgement - The Ultimate Card Game

A beautifully designed multiplayer card game built with Flutter. Play the classic trick-taking game with friends, featuring bidding, trump suits, and strategic gameplay. Built with **Clean Architecture** principles and outstanding UI/UX design.

## ✨ Features

- **Multiplayer Support**: 4-10 players per game
- **Strategic Bidding**: Predict tricks and score points
- **Trump System**: Rotating trump suits (Spades, Diamonds, Clubs, Hearts, No Trump)
- **Multiple Scoring Strategies**: High Incentive, Medium Incentive, Low Incentive
- **Beautiful UI**: Modern gradient designs, smooth animations, and card visuals
- **Real-time Gameplay**: Track bids, tricks, and scores in real-time
- **Easy Game Hosting**: Create and share game codes with friends

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                          # Core utilities
│   ├── error/                     # Error handling
│   └── usecases/                  # Base use case
├── features/
│   └── judgement/
│       ├── data/                  # Data layer
│       │   ├── datasources/       # Data sources
│       │   ├── models/            # Data models
│       │   └── repositories/      # Repository implementations
│       ├── domain/                # Domain layer
│       │   ├── entities/          # Business entities
│       │   ├── repositories/      # Repository interfaces
│       │   └── usecases/          # Business logic
│       └── presentation/          # Presentation layer
│           ├── bloc/              # State management (BLoC)
│           ├── pages/             # UI pages
│           └── widgets/           # Reusable widgets
└── injection_container.dart       # Dependency injection
```

## 📦 Dependencies

- **flutter_bloc**: State management
- **equatable**: Value equality
- **get_it**: Dependency injection
- **dartz**: Functional programming
- **animate_do**: Smooth animations
- **google_fonts**: Beautiful typography

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd judgement
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🎮 How to Play

1. **Start the Game**: Tap "START GAME" on the home screen
2. **Read the Scenario**: Each scenario presents a moral dilemma
3. **Make Your Choice**: Select from three options (Lawful, Neutral, or Chaotic)
4. **See the Outcome**: Learn the consequences of your decision
5. **Complete All Scenarios**: Discover your moral alignment at the end

## 🎨 UI Highlights

- **Gradient Backgrounds**: Eye-catching color schemes
- **Smooth Animations**: Using animate_do for engaging transitions
- **Modern Typography**: Google Fonts (Orbitron & Poppins)
- **Interactive Elements**: Responsive buttons with visual feedback
- **Progress Tracking**: Visual progress bar and score display

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🔮 Future Enhancements

- Add more scenarios
- Implement local storage for game history
- Add sound effects and background music
- Multiplayer mode
- Share results on social media
- Leaderboard system

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Development

Built with ❤️ using Flutter and Clean Architecture principles.
