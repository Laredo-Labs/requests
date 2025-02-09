#!/usr/bin/env python3
import argparse
from pathlib import Path
from keydetector import KeyDetector

def main():
    parser = argparse.ArgumentParser(description='Detect the musical key of an audio file.')
    parser.add_argument('file', type=str, help='Path to the audio file')
    parser.add_argument('--duration', type=float, default=30.0,
                       help='Duration in seconds to analyze (default: 30.0)')
    
    args = parser.parse_args()
    
    file_path = Path(args.file)
    if not file_path.exists():
        print(f"Error: File {file_path} does not exist")
        return 1
        
    try:
        detector = KeyDetector(analysis_duration=args.duration)
        key = detector.detect_from_file(file_path)
        print(f"Detected key: {key}")
        return 0
    except Exception as e:
        print(f"Error detecting key: {str(e)}")
        return 1

if __name__ == '__main__':
    exit(main())
