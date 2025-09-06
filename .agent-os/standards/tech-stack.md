# Tech Stack

## Context

Global tech stack defaults for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

- Mobile App Framework: Flutter (latest stable)
- Language (Frontend): Dart (latest stable)
- Backend API: Go (Golang, latest stable)
- Backend Hosting: Google Cloud Run / Firebase Cloud Functions
- Database: Firebase Firestore (NoSQL, serverless)
- Authentication: Firebase Auth
- Storage: Firebase Storage
- Realtime: Firebase Realtime Database (if needed)
- Push Notifications: Firebase Cloud Messaging
- Analytics: Firebase Analytics
- CI/CD: GitHub Actions (Flutter, Go workflows)
- Package Manager (Frontend): pub
- Package Manager (Backend): go modules
- App Distribution: Firebase App Distribution / Google Play / Apple App Store
- Hosting Region: Closest to primary user base (Firebase/Google Cloud regions)
- Asset/CDN: Firebase Hosting / Google Cloud CDN
- Monitoring: Google Cloud Monitoring / Firebase Crashlytics
- Testing: Flutter test, Go test
- Environment Management: .env files, Firebase/Google Cloud environment configs
