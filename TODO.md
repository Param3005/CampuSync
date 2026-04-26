# Face Verification Feature

## Steps
- [x] Read relevant files (profile_screen, class_card, pubspec)
- [x] Add `image` package to pubspec.yaml
- [x] Create `lib/image_helpers.dart` with capture dialog + image comparison
- [x] Update `lib/screens/profile_screen.dart` — show face photo top right, logout below save name
- [x] Update `lib/widgets/class_card.dart` — face verification before marking attendance
- [ ] Test and verify

---

# Compress face photos before saving to Firestore

## Steps
- [x] Read relevant files (profile_screen, class_card, image_helpers)
- [x] Add `compressFacePhoto` helper in `lib/image_helpers.dart`
- [x] Update `ProfileScreen._updateFacePhoto` to compress before saving
- [x] Update `ClassCard` attendance save to compress face photo before saving
- [ ] Test and verify
