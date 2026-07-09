import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  AudioService._internal();

  final AudioPlayer _playerApple = AudioPlayer();
  final AudioPlayer _playerLevel = AudioPlayer();
  final AudioPlayer _playerGameOver = AudioPlayer();

  String? _applePath;
  String? _levelPath;
  String? _gameOverPath;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final tempDir = await getTemporaryDirectory();

      // Generate and write WAVs to temporary directory
      final appleFile = File('${tempDir.path}/snake_apple.wav');
      await appleFile.writeAsBytes(_generateAppleWav());
      _applePath = appleFile.path;

      final levelFile = File('${tempDir.path}/snake_level.wav');
      await levelFile.writeAsBytes(_generateLevelWav());
      _levelPath = levelFile.path;

      final gameOverFile = File('${tempDir.path}/snake_gameover.wav');
      await gameOverFile.writeAsBytes(_generateGameOverWav());
      _gameOverPath = gameOverFile.path;

      _initialized = true;
    } catch (e) {
      // Fail silently without crashing the app
      debugPrint('AudioService initialization error: $e');
    }
  }

  void playApple() {
    if (!_initialized || _applePath == null) return;
    _playerApple.play(DeviceFileSource(_applePath!));
  }

  void playLevelUp() {
    if (!_initialized || _levelPath == null) return;
    _playerLevel.play(DeviceFileSource(_levelPath!));
  }

  void playGameOver() {
    if (!_initialized || _gameOverPath == null) return;
    _playerGameOver.play(DeviceFileSource(_gameOverPath!));
  }

  // ── WAV Byte Generation ──────────────────────────────────────────────────

  static Uint8List _createWavBytes({
    required int sampleRate,
    required List<double> samples,
  }) {
    final int byteLength = samples.length * 2; // 16-bit PCM
    final byteData = ByteData(44 + byteLength);

    // RIFF header
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, 36 + byteLength, Endian.little); // Chunk size
    byteData.setUint8(8, 0x57); // 'W'
    byteData.setUint8(9, 0x41); // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // fmt subchunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6d); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little); // Subchunk1 Size
    byteData.setUint16(20, 1, Endian.little); // AudioFormat (1 = PCM)
    byteData.setUint16(22, 1, Endian.little); // NumChannels (1 = Mono)
    byteData.setUint32(24, sampleRate, Endian.little); // SampleRate
    byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate (SampleRate * 1 channel * 16 bits / 8)
    byteData.setUint16(32, 2, Endian.little); // BlockAlign
    byteData.setUint16(34, 16, Endian.little); // BitsPerSample (16)

    // data subchunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, byteLength, Endian.little);

    // Write samples
    int offset = 44;
    for (final sample in samples) {
      final int intVal = (sample * 32767.0).clamp(-32768.0, 32767.0).toInt();
      byteData.setInt16(offset, intVal, Endian.little);
      offset += 2;
    }

    return byteData.buffer.asUint8List();
  }

  // Coin pick bleep (high frequency sweep)
  static Uint8List _generateAppleWav() {
    const int sampleRate = 22050;
    const double duration = 0.10;
    final int totalSamples = (sampleRate * duration).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / sampleRate;
      final double freq = 800.0 + (t / duration) * 400.0;
      final double envelope = exp(-t * 30.0);
      samples[i] = sin(2.0 * pi * freq * t) * envelope;
    }

    return _createWavBytes(sampleRate: sampleRate, samples: samples);
  }

  // Level complete fanfare
  static Uint8List _generateLevelWav() {
    const int sampleRate = 22050;
    final notes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
    const double noteDuration = 0.09;
    const double finalDuration = 0.22;
    final int samplesPerNote = (sampleRate * noteDuration).toInt();
    final int samplesFinal = (sampleRate * finalDuration).toInt();
    final int totalSamples = samplesPerNote * 3 + samplesFinal;
    final samples = List<double>.filled(totalSamples, 0.0);

    int sampleIdx = 0;
    for (int n = 0; n < notes.length; n++) {
      final double freq = notes[n];
      final int durSamples = (n == notes.length - 1) ? samplesFinal : samplesPerNote;
      for (int i = 0; i < durSamples; i++) {
        final double t = i / sampleRate;
        final double envelope = exp(-t * 12.0);
        final double sine = sin(2.0 * pi * freq * t);
        final double square = sine > 0 ? 0.25 : -0.25;
        samples[sampleIdx++] = (sine * 0.75 + square * 0.25) * envelope;
      }
    }

    return _createWavBytes(sampleRate: sampleRate, samples: samples);
  }

  // Game over crash/buzz
  static Uint8List _generateGameOverWav() {
    const int sampleRate = 22050;
    const double duration = 0.40;
    final int totalSamples = (sampleRate * duration).toInt();
    final samples = List<double>.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / sampleRate;
      final double freq = 280.0 * exp(-t * 4.0);
      final double envelope = (1.0 - t / duration) * exp(-t * 1.5);
      final double saw = 2.0 * ((t * freq) - (t * freq).floor()) - 1.0;
      final double noise = (Random().nextDouble() * 2.0 - 1.0) * 0.15;
      samples[i] = (saw * 0.65 + noise) * envelope;
    }

    return _createWavBytes(sampleRate: sampleRate, samples: samples);
  }
}
