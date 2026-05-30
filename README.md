# software_for_nature

## Folder Structure

```
lib/
├── data/                        # Data layer
│   ├── data_sources/            # Raw data access (REST APIs, etc.)
│   ├── models/                  # Data models
│   └── repositories/            # Repositories
│
├── logic/                       # Business logic layer
│   └── bloc/                    # All BLoC state management
│       └── navigation/          # Navigation feature bloc
│
├── presentation/                # UI layer
│   ├── pages/                   # Screens/pages
│   └── widgets/                 # Components
│       └── navigation/          # Widgets specific components
│
├── app_routes.dart              # Route configuration
├── main.dart                    # App entry point
└── observer.dart                # BLoC observer
```

backend:
    in a new terminal: 
    cd backend
    docker-compose up -d

frontend:
    in a new terminal in project root:
    flutter run 
---

