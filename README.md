# KeyDetector

KeyDetector is a Python application that detects the musical key of audio files or real-time audio streams. It uses advanced audio processing techniques to analyze the harmonic content and determine the most likely musical key.

## Features

- Detect musical key from WAV, MP3, and other audio file formats
- Real-time key detection from audio input (microphone)
- Support for both major and minor keys
- Configurable analysis window size
- Command-line interface for easy use

## Installation

1. Install system dependencies (Linux/Debian):
```bash
sudo apt-get install portaudio19-dev
```

2. Install the package:
```bash
pip install .
```

Requests Usage

### Command Line Interface

1. Analyze an audio file:
```bash
python src/keydetector_cli.py --file path/to/audio.wav --duration 30
```

2. Real-time analysis from microphone:
```bash
python src/keydetector_cli.py --duration 30 --analysis-window 3
```

Options:
- `--file`, `-f`: Input audio file path
- `--duration`, `-d`: Duration to analyze in seconds (default: 30.0)
- `--analysis-window`, `-w`: Analysis window size for streaming mode in seconds (default: 3.0)

### Python API

```python
from keydetector import KeyDetector

# Analyze a file
detector = KeyDetector(analysis_duration=30.0)
key = detector.detect_from_file("path/to/audio.wav")
print(f"The song is in {key}")

# Real-time analysis
detector = KeyDetector(analysis_duration=3.0)
detector.start_stream()
try:
    while True:
        current_key = detector.current_key
        print(f"Current key: {current_key}")
        time.sleep(0.1)
except KeyboardInterrupt:
    detector.stop_stream()
```

## How It Works

KeyDetector uses the Krumhansl-Schmuckler key-finding algorithm, which:

1. Analyzes the audio using chromagrams (pitch class profiles)
2. Compares the pitch class distribution to known major and minor key profiles
3. Determines the best matching key and mode (major/minor)

The analysis focuses on the first portion of the song (configurable duration) since the key is typically most clearly established in the beginning.

## Requirements

- Python 3.8 or higher
- PortAudio (for real-time audio processing)
- librosa (audio processing)
- numpy (numerical computations)
- sounddevice (audio streaming)

## Development

1. Install development dependencies:
```bash
pip install -e ".[dev]"
```

2. Run tests:
```bash
pytest tests/
```

## License

MIT License
