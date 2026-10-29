# LabLens AI: An Intelligent iOS-Based Laboratory Assistant
Using Computer Vision and Artificial Intelligence

## Project Overview
LabLens AI is a native iOS application built with SwiftUI, Apple Vision Framework, and Core ML. It provides real-time laboratory equipment identification, contextual standard operating procedures (SOPs), chemical hazard & safety guidance, QR-based asset retrieval, interactive experimental timers, and a contextual AI assistant for academic and research laboratories.

---

## Workspace Structure
```
LabLensAI/
├── LabLensAI/                      # Native iOS SwiftUI Application
│   ├── App/
│   │   └── LabLensAIApp.swift       # Application entry point & lifecycle
│   ├── Models/                     # Strongly-typed domain models & schemas
│   │   ├── Equipment.swift          # Equipment attributes, specs & SOP links
│   │   ├── Chemical.swift           # GHS hazard pictograms, safety & storage
│   │   ├── SOPProtocol.swift        # Standard operating procedures & steps
│   │   ├── ExperimentTimer.swift    # Multi-stage laboratory step timers
│   │   └── ScanResult.swift         # Vision & CoreML classification result
│   ├── Services/                   # Core business logic & native APIs
│   │   ├── VisionClassifierService.swift # AVFoundation + Vision + CoreML pipeline
│   │   ├── QRScannerService.swift   # Real-time QR metadata decoder
│   │   ├── DatabaseService.swift    # Local JSON repository & cache manager
│   │   └── GeminiService.swift      # Context-aware LLM assistance client
│   ├── ViewModels/                 # MVVM State management
│   │   ├── CameraScannerViewModel.swift
│   │   ├── EquipmentViewModel.swift
│   │   ├── ChemicalSafetyViewModel.swift
│   │   └── AIAssistantViewModel.swift
│   ├── Views/                      # SwiftUI Declarative User Interface
│   │   ├── MainTabView.swift        # 5-tab laboratory navigation shell
│   │   ├── CameraScanView.swift     # Live viewfinder, bounding box & overlay
│   │   ├── EquipmentDetailView.swift# Purpose, working principle, SOPs & hazards
│   │   ├── ChemicalSafetyView.swift # GHS classification, PPE & first-aid
│   │   ├── SOPLibraryView.swift     # Searchable laboratory protocol directory
│   │   ├── ExperimentTimerView.swift# Active incubation/centrifugation timers
│   │   └── AIAssistantView.swift    # Guardrailed laboratory Q&A chat
│   └── Resources/                  # Local curated laboratory databases
│       ├── equipment_db.json        # 7 equipment classes with verified data
│       ├── chemicals_db.json        # Curated chemical safety data sheets
│       └── sops_db.json             # Step-by-step SOP protocols
├── ML_Pipeline/                    # Machine Learning Training & Evaluation
│   ├── dataset_prep.py              # Data curation, augmentation & train/val/test split
│   ├── train_model.py               # Transfer learning & fine-tuning pipeline
│   ├── export_coreml.py             # PyTorch / ONNX to Core ML (.mlpackage) converter
│   └── evaluate_metrics.py          # Precision, Recall, F1, confusion matrix calculator
├── Documentation/
│   └── MIDTERM_PHASE3_SUBMISSION.md # Complete Capstone AI-Assisted Evaluation Submission
└── Tests/
    └── LabLensAITests.swift         # Unit and integration test suite
```
