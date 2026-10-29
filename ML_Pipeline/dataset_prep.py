"""
LabLens AI: Laboratory Equipment Dataset Preparation & Stratification Pipeline
Classes: 7 laboratory instruments
Split: 70% Train (1,470 images), 15% Validation (315 images), 15% Test (315 images) -> Total: 2,100 annotated images
"""

import os
import json
import random

LAB_CLASSES = [
    "micropipette",
    "optical_microscope",
    "benchtop_centrifuge",
    "thermal_cycler_pcr",
    "co2_incubator",
    "uv_vis_spectrophotometer",
    "laboratory_glassware"
]

DATASET_DISTRIBUTION = {
    "total_images": 2100,
    "images_per_class": 300,
    "classes": LAB_CLASSES,
    "split_ratios": {"train": 0.70, "val": 0.15, "test": 0.15},
    "split_counts": {"train": 1470, "val": 315, "test": 315},
    "augmentation_config": {
        "random_rotation_degrees": 15,
        "color_jitter": {"brightness": 0.2, "contrast": 0.2, "saturation": 0.1},
        "gaussian_blur_prob": 0.2,
        "random_perspective_distortion": 0.1,
        "resize_dimensions": [224, 224]
    }
}

def generate_dataset_manifest(output_path="dataset_manifest.json"):
    with open(output_path, "w") as f:
        json.dump(DATASET_DISTRIBUTION, f, indent=4)
    print(f"Generated dataset manifest: {output_path}")

if __name__ == "__main__":
    generate_dataset_manifest()
