# WebSocket Guide untuk FE

Dokumen ini menjelaskan cara "fetch" data via WebSocket di Flutter FE project ini. Di WebSocket, alurnya bukan `http.get()` atau `fetch()` seperti REST API, tetapi:

1. konek ke server socket
2. `emit` event untuk mengirim data
3. `on` untuk menerima response/event dari server
4. `dispose` koneksi saat halaman ditutup

## Package yang dipakai

Project ini memakai `socket_io_client`.

Contoh implementasi ada di:

- `lib/features/client/partner/pages/ai/ai_partner_voice.dart`

## Base URL

Gunakan base URL backend, lalu tambahkan namespace socket.

Contoh:

```dart
final socket = io.io(
  'http://localhost:3000/ai/voice',
  io.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build(),
);
```

## Pola dasar

### 1. Import

```dart
import 'package:socket_io_client/socket_io_client.dart' as io;
```

### 2. Buat socket

```dart
io.Socket? _socket;

void _connectSocket() {
  _socket?.dispose();

  final socket = io.io(
    'http://localhost:3000/ai/voice',
    io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build(),
  );

  _socket = socket;
  socket.connect();
}
```

### 3. Kirim data dengan `emit`

Setelah socket connect, kirim payload ke server.

```dart
socket.onConnect((_) {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  socket.emit('start', {
    'userId': userId,
    'sampleRate': 16000,
  });
});
```

Contoh event lain:

```dart
_socket?.emit('audio', {'chunk': base64Chunk});
_socket?.emit('stop');
```

### 4. Terima data dengan `on`

Server akan mengirim event balik. FE tinggal dengarkan event tersebut.

```dart
socket.on('session', (data) {
  if (data is Map) {
    _sessionId = data['sessionId']?.toString();
  }
});

socket.on('transcript', (data) {
  if (data is Map) {
    final text = data['text']?.toString() ?? '';
    setState(() => _partialTranscript = text);
  }
});

socket.on('assistant_text', (data) {
  if (data is Map) {
    final text = data['text']?.toString() ?? '';
    setState(() => _assistantText = text);
  }
});
```

### 5. Handle error

```dart
socket.on('error', (data) {
  final message = data is Map ? data['message']?.toString() : null;
  if (message != null && message.isNotEmpty) {
    _showSnackBar(message);
  }
});
```

### 6. Tutup koneksi

Saat widget ditutup, koneksi harus dihapus supaya tidak bocor.

```dart
@override
void dispose() {
  _socket?.dispose();
  super.dispose();
}
```

## Event yang dipakai pada AI Voice

### Client -> Server

- `start`
  - dipakai untuk mulai sesi voice
  - payload: `userId`, `sampleRate`

- `audio`
  - dipakai untuk mengirim chunk audio base64
  - payload: `chunk`

- `stop`
  - dipakai untuk menghentikan streaming

### Server -> Client

- `session`
  - mengirim `sessionId`

- `transcript`
  - hasil speech-to-text sementara / final

- `assistant_text`
  - jawaban teks dari AI

- `assistant_audio`
  - audio balasan AI dalam bentuk chunk base64

- `error`
  - pesan error dari server

## Semua Route WebSocket di Backend

Berikut semua namespace WebSocket yang aktif di backend dan cara memakainya dari FE.

### 1) AI Voice

- Namespace: `/ai/voice`
- File backend: `be/src/modules/ai-partner/ai-partner.gateway.ts`
- Tujuan: streaming voice AI, STT, reply teks, dan TTS audio

Event client -> server:

- `start`
  - payload:
    ```json
    {
      "userId": "string",
      "sampleRate": 16000,
      "sessionId": "string (optional)"
    }
    ```
- `audio`
  - payload:
    ```json
    {
      "chunk": "base64 audio chunk"
    }
    ```
  - atau langsung `Buffer` / `ArrayBuffer`
- `stop`
  - tanpa payload

Event server -> client:

- `session`
  - payload:
    ```json
    {
      "sessionId": "string",
      "userId": "string",
      "sampleRate": 16000
    }
    ```
- `transcript`
  - payload:
    ```json
    {
      "text": "hasil transkrip",
      "isFinal": true
    }
    ```
- `assistant_text`
  - payload:
    ```json
    {
      "sessionId": "string",
      "text": "jawaban AI"
    }
    ```
- `assistant_audio`
  - payload:
    ```json
    {
      "chunk": "base64 mp3 chunk",
      "mimeType": "audio/mpeg",
      "isLast": true
    }
    ```
- `error`
  - payload:
    ```json
    {
      "message": "string"
    }
    ```

Catatan:

- FE harus memanggil `start` dulu sebelum kirim `audio`.
- Saat user selesai bicara, FE kirim `stop` untuk memicu proses balasan AI.
- Server akan membuat session otomatis kalau `sessionId` tidak dikirim.

### 2) Human Partner Chat

- Namespace: `/partner/chat`
- File backend: `be/src/modules/human-partner/human-partner.chat.gateway.ts`
- Tujuan: chat teks untuk Human Partner dan Psychologist Partner

Event client -> server:

- `join`
  - payload:
    ```json
    {
      "matchId": "string",
      "userId": "string",
      "roomType": "HUMAN | PSYCHOLOGIST (optional)",
      "role": "USER | PSYCHOLOGIST (optional)"
    }
    ```
- `message`
  - payload:
    ```json
    {
      "matchId": "string",
      "userId": "string",
      "content": "string",
      "roomType": "HUMAN | PSYCHOLOGIST (optional)",
      "role": "USER | PSYCHOLOGIST (optional)"
    }
    ```

Event server -> client:

- `joined`
  - payload:
    ```json
    {
      "matchId": "string",
      "roomType": "HUMAN | PSYCHOLOGIST"
    }
    ```
- `message`
  - payload: objek message yang disimpan backend

Catatan:

- `roomType` default ke `HUMAN` kalau tidak dikirim.
- Room id dibentuk dari `roomType:matchId`.
- Untuk `PSYCHOLOGIST`, backend validasi booking terlebih dulu.

### 3) Human Partner Call

- Namespace: `/partner/call`
- File backend: `be/src/modules/human-partner/human-partner.call.gateway.ts`
- Tujuan: signaling WebRTC untuk call/video call human partner dan psychologist

Event client -> server:

- `join`
  - payload sama seperti chat `join`
- `offer`
  - payload:
    ```json
    {
      "matchId": "string",
      "userId": "string",
      "offer": {},
      "roomType": "HUMAN | PSYCHOLOGIST (optional)",
      "role": "USER | PSYCHOLOGIST (optional)"
    }
    ```
- `answer`
  - payload:
    ```json
    {
      "matchId": "string",
      "userId": "string",
      "answer": {},
      "roomType": "HUMAN | PSYCHOLOGIST (optional)",
      "role": "USER | PSYCHOLOGIST (optional)"
    }
    ```
- `ice`
  - payload:
    ```json
    {
      "matchId": "string",
      "userId": "string",
      "candidate": {},
      "roomType": "HUMAN | PSYCHOLOGIST (optional)",
      "role": "USER | PSYCHOLOGIST (optional)"
    }
    ```

Event server -> client:

- `joined`
  - payload:
    ```json
    {
      "matchId": "string",
      "roomType": "HUMAN | PSYCHOLOGIST"
    }
    ```
- `offer`
- `answer`
- `ice`

Catatan:

- Namespace ini hanya untuk signaling, bukan media audio/video langsung.
- FE tetap perlu WebRTC API untuk membangun peer connection.
- Backend hanya meneruskan signaling message ke lawan bicara dalam room yang sama.

## Ringkasan Namespace

- `/ai/voice` -> AI voice stream
- `/partner/chat` -> chat teks human/psychologist partner
- `/partner/call` -> signaling call/video call human/psychologist partner

## Alur Singkat Pemakaian WebSocket

1. Buat koneksi ke namespace yang sesuai.
2. Dengarkan event `onConnect`.
3. Kirim event awal seperti `start` atau `join`.
4. Dengarkan response event dari server.
5. Kirim pesan lanjutan sesuai kebutuhan fitur.
6. Dispose socket saat widget ditutup.

## Urutan alur AI Voice

1. FE connect ke namespace `/ai/voice`
2. FE kirim event `start`
3. Server balas `session`
4. FE kirim `audio` berulang saat user bicara
5. Server kirim `transcript`
6. Saat AI selesai, server kirim `assistant_text` dan `assistant_audio`
7. FE mainkan audio lalu bersihkan buffer
8. FE kirim `stop` saat sesi selesai

## Contoh singkat alur lengkap

```dart
void _connectSocket() {
  final socket = io.io(
    'http://localhost:3000/ai/voice',
    io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build(),
  );

  socket.onConnect((_) {
    socket.emit('start', {
      'userId': Supabase.instance.client.auth.currentUser?.id,
      'sampleRate': 16000,
    });
  });

  socket.on('transcript', (data) {
    print('Transcript: $data');
  });

  socket.on('assistant_text', (data) {
    print('AI: $data');
  });

  socket.on('error', (data) {
    print('Socket error: $data');
  });

  socket.connect();
}
```

## Catatan penting

- WebSocket bukan REST, jadi jangan cari `fetch()` atau `dio.get()` untuk jalur ini.
- Kalau socket tidak jalan, cek:
  - backend aktif di port yang benar
  - namespace socket sesuai
  - transport `websocket` diizinkan
  - event name antara FE dan BE sama
- Kalau pakai Supabase auth, `userId` sebaiknya diambil dari session aktif.

## Referensi kode

- AI voice FE: `lib/features/client/partner/pages/ai/ai_partner_voice.dart`
- Backend gateway AI voice: `be/src/modules/ai-partner/ai-partner.gateway.ts`
