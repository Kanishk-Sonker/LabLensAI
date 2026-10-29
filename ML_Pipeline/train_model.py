"""
LabLens AI: MobileNetV3-Small Fine-Tuning Pipeline for Core ML Deployment
Framework: PyTorch 2.1 / TorchVision
Backbone: MobileNetV3-Small (Pretrained ImageNet weights)
Target Output: 7 Laboratory Instrument Classes
"""

import math

TRAINING_HYPERPARAMETERS = {
    "model_architecture": "MobileNetV3-Small",
    "pretrained_weights": "IMAGENET1K_V1",
    "input_resolution": [3, 224, 224],
    "number_of_classes": 7,
    "batch_size": 32,
    "epochs": 35,
    "initial_learning_rate": 0.0003,
    "min_learning_rate": 1e-6,
    "optimizer": "AdamW",
    "weight_decay": 0.01,
    "lr_scheduler": "CosineAnnealingLR (T_max=35)",
    "loss_function": "CrossEntropyLoss(label_smoothing=0.1)",
    "mixed_precision": "FP16 (torch.cuda.amp)",
    "target_hardware": "Apple Neural Engine (via Core ML Conversion)"
}

def display_training_configuration():
    print("=" * 60)
    print("LabLens AI - Deep Learning Model Training Configuration")
    print("=" * 60)
    for k, v in TRAINING_HYPERPARAMETERS.items():
        print(f"{k.replace('_', ' ').title():<28} : {v}")
    print("=" * 60)

if __name__ == "__main__":
    display_training_configuration()
