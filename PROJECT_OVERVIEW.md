# Judgement Game - Project Overview

## 📋 Project Summary

A moral dilemma game built with Flutter following Clean Architecture principles. Players face ethical scenarios and make choices that reveal their moral alignment.

## 🏛️ Clean Architecture Layers

### 1. Domain Layer (Business Logic)
**Location**: `lib/features/judgement/domain/`

- **Entities**: Core business objects
  - `Scenario`: Represents a moral dilemma with choices
  - `Choice`: Individual decision option with type and outcome
  - `GameState`: Tracks player progress and alignment
  - `JudgementType`: Enum (Lawful, Neutral, Chaotic)

- **Repositories**: Abstract interfaces
  - `ScenarioRepository`: Contract for data access

- **Use Cases**: Business rules
  - `GetScenarios`: Retrieves all scenarios

### 2. Data Layer (Data Management)
**Location**: `lib/features/judgement/data/`

- **Models**: Data transfer objects
  - `ScenarioModel`: Extends Scenario with JSON serialization
  - `ChoiceModel`: Extends Choice with JSON serialization

- **Data Sources**: Data providers
  - `ScenarioLocalDataSource`: Provides hardcoded scenarios

- **Repository Implementations**
  - `ScenarioRepositoryImpl`: Implements ScenarioRepository

### 3. Presentation Layer (UI)
**Location**: `lib/features/judgement/presentation/`

- **BLoC (State Management)**
  - `GameBloc`: Manages game state
  - `GameEvent`: User actions (LoadScenarios, MakeChoice, RestartGame)
  - `GameBlocState`: UI states (Loading, Loaded, ChoiceMade, Completed, Error)

- **Pages**
  - `HomePage`: Landing page with game introduction
  - `GamePage`: Main gameplay screen with scenarios
  - `ResultPage`: Final results and alignment reveal

- **Widgets**
  - `ScenarioCard`: Displays scenario information
  - `ChoiceButton`: Interactive choice selection
  - `OutcomeDialog`: Shows choice consequences

### 4. Core Layer
**Location**: `lib/core/`

- **Error Handling**
  - `Failure`: Abstract failure class
  - `ServerFailure`, `CacheFailure`: Specific failures

- **Use Cases**
  - `UseCase`: Base use case interface
  - `NoParams`: Empty parameter class

### 5. Dependency Injection
**Location**: `lib/injection_container.dart`

- Uses `get_it` for dependency injection
- Registers all dependencies (BLoC, Use Cases, Repositories, Data Sources)

## 🎨 UI/UX Features

### Design Elements
- **Gradient Backgrounds**: Purple, pink, and deep purple gradients
- **Typography**: 
  - Orbitron (headings, scores)
  - Poppins (body text)
- **Animations**: FadeIn, SlideIn, Bounce effects using animate_do
- **Color Coding**:
  - Lawful: Blue
  - Neutral: Green
  - Chaotic: Red

### User Flow
1. **Home Screen** → START GAME button
2. **Game Screen** → Scenario display + 3 choices
3. **Outcome Dialog** → Shows result of choice
4. **Next Scenario** → Continues until all complete
5. **Result Screen** → Final alignment + statistics

## 📊 Game Mechanics

### Scoring System
- Each choice has a `moralScore` (10-60 points)
- Total score accumulates throughout the game
- Higher scores indicate more "positive" outcomes

### Alignment System
- Tracks count of each judgement type
- Final alignment determined by majority:
  - **Lawful Good**: Most lawful choices
  - **Chaotic Rebel**: Most chaotic choices
  - **True Neutral**: Most neutral or balanced choices

### Scenarios (5 Total)
1. **The Stolen Bread** (Ethics)
2. **The Secret Keeper** (Loyalty)
3. **The Lost Wallet** (Integrity)
4. **The Whistleblower** (Justice)
5. **The Final Test** (Values)

## 🔧 Technical Stack

### State Management
- **flutter_bloc**: BLoC pattern for predictable state management
- **equatable**: Value comparison for state objects

### Functional Programming
- **dartz**: Either type for error handling

### Dependency Injection
- **get_it**: Service locator pattern

### UI/Animations
- **animate_do**: Pre-built animation widgets
- **google_fonts**: Custom typography

## 📁 File Structure
```
lib/
├── core/
│   ├── error/failures.dart
│   └── usecases/usecase.dart
├── features/judgement/
│   ├── data/
│   │   ├── datasources/scenario_local_data_source.dart
│   │   ├── models/scenario_model.dart
│   │   └── repositories/scenario_repository_impl.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── game_state.dart
│   │   │   └── scenario.dart
│   │   ├── repositories/scenario_repository.dart
│   │   └── usecases/get_scenarios.dart
│   └── presentation/
│       ├── bloc/
│       │   ├── game_bloc.dart
│       │   ├── game_event.dart
│       │   └── game_state.dart
│       ├── pages/
│       │   ├── home_page.dart
│       │   ├── game_page.dart
│       │   └── result_page.dart
│       └── widgets/
│           ├── scenario_card.dart
│           ├── choice_button.dart
│           └── outcome_dialog.dart
├── injection_container.dart
└── main.dart
```

## 🚀 Running the App

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build for production
flutter build apk  # Android
flutter build ios  # iOS
flutter build web  # Web
```

## 🧪 Testing

The project includes basic widget tests. To run:
```bash
flutter test
```

## 🔄 Data Flow

```
User Action → Event → BLoC → Use Case → Repository → Data Source
                ↓
            New State
                ↓
            UI Update
```

## 🎯 Clean Architecture Benefits

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Testability**: Easy to unit test each layer independently
3. **Maintainability**: Changes in one layer don't affect others
4. **Scalability**: Easy to add new features or scenarios
5. **Flexibility**: Can swap data sources without affecting business logic

## 📝 Notes

- Currently uses hardcoded scenarios (can be extended to use API or database)
- Portrait orientation only
- Material 3 design system
- Supports all Flutter platforms (mobile, web, desktop)
