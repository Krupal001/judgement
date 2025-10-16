# 🎮 Multiplayer Setup Guide

## ✅ What's Been Done

Your card game now supports **real-time online multiplayer** using Firebase Realtime Database!

### Changes Made:

1. **Firebase Integration**
   - Added `firebase_core` and `firebase_database` packages
   - Firebase initialized in `main.dart`
   - Created `FirebaseGameRepository` for cloud storage

2. **Real-time Updates**
   - Game state syncs automatically across all devices
   - Players see updates instantly when others join, bid, or play cards
   - No manual refresh needed!

3. **Network Architecture**
   - Local storage replaced with Firebase Realtime Database
   - All game data stored in cloud at `/games/{gameId}`
   - Stream-based updates for real-time synchronization

## 🚀 How It Works Now

### For Host:
1. Enter name
2. Select number of players (2-10)
3. Click "HOST GAME"
4. Share the **6-character Game ID** with friends
5. Wait for players to join (see count update in real-time)
6. Start game when enough players joined

### For Players:
1. Enter name
2. Enter the **Game ID** from host
3. Click "JOIN GAME"
4. Automatically added to lobby
5. Wait for host to start

### During Game:
- All players see the same game state in real-time
- When someone plays a card, everyone sees it instantly
- Bids, tricks, and scores sync automatically
- Works across different devices and networks!

## 📱 Testing Multiplayer

### Option 1: Multiple Devices
- Run on your phone and a friend's phone
- Share the Game ID via WhatsApp/SMS
- Both can play together!

### Option 2: Multiple Emulators/Simulators
- Run multiple Android emulators or iOS simulators
- Each acts as a different player
- Great for testing

### Option 3: Web + Mobile
- Run on web browser: `flutter run -d chrome`
- Run on mobile device
- Play across platforms!

## 🔧 Firebase Console Setup

Your Firebase project should have:

**Database Structure:**
```
/games
  /{gameId}
    - gameId: "ABC123"
    - requiredPlayers: 4
    - startingCards: 7
    - isAscending: false
    - players: [...]
    - currentRound: {...}
```

**Security Rules** (Important!):
Go to Firebase Console → Realtime Database → Rules

```json
{
  "rules": {
    "games": {
      "$gameId": {
        ".read": true,
        ".write": true
      }
    }
  }
}
```

⚠️ **Note:** These rules allow anyone to read/write. For production, add proper authentication!

## 🎯 What Happens Behind the Scenes

1. **Host creates game** → Saved to Firebase with unique ID
2. **Players join** → Added to players array in Firebase
3. **Game starts** → Cards dealt, saved to Firebase
4. **Player makes move** → Firebase updated
5. **All devices listening** → Receive update via stream
6. **UI updates automatically** → Shows new game state

## 🌐 Network Requirements

- Internet connection required for all players
- Works on WiFi or mobile data
- Low bandwidth usage (~1-5 KB per move)
- Latency typically < 500ms

## 🐛 Troubleshooting

### "Failed to create game"
- Check internet connection
- Verify Firebase is initialized
- Check Firebase Console for errors

### "Failed to join game"
- Verify Game ID is correct (case-sensitive)
- Check if game exists in Firebase Console
- Ensure internet connection is stable

### Players not seeing updates
- Check Firebase Realtime Database rules
- Verify all devices have internet
- Check Firebase Console for connection status

## 🎉 You're Ready!

Run the app and test it:
```bash
flutter run
```

Create a game, share the ID, and have someone join from another device!

---

**Pro Tip:** You can monitor all games in real-time from Firebase Console → Realtime Database → Data tab
