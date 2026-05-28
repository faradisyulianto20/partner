# API Documentation - Backend Hackathon

Dokumentasi lengkap untuk semua endpoint API Backend. Frontend dapat menggunakan `ApiClient` yang sudah dikonfigurasi untuk melakukan fetching data.

## Table of Contents
- [Base URL & Setup](#base-url--setup)
- [Authentication](#authentication)
- [Health Check](#health-check)
- [Profile Management](#profile-management)
- [Analysis Module](#analysis-module)
- [AI Partner](#ai-partner)
- [Human Partner](#human-partner)
- [Psychologist](#psychologist)
- [Error Handling](#error-handling)
- [Frontend Integration Examples](#frontend-integration-examples)

---

## Base URL & Setup

### Development
```
http://localhost:3000
```

### Platform-Specific (Android/iOS)
```dart
// Automatically handled by AppConstants in FE
// Android: http://10.0.2.2:3000
// iOS: http://127.0.0.1:3000
```

### Headers
Semua request otomatis menyertakan:
```
Accept: application/json
Authorization: Bearer <supabase_access_token>
```

---

## Authentication

### Required Guards
Semua endpoint (kecuali GET /) menggunakan `@UseGuards(SupabaseJwtGuard)`.

**Apa artinya?**
- Setiap request harus menyertakan Supabase JWT token di header `Authorization`
- Token otomatis ditambahkan oleh `ApiClient` ketika user sudah login di aplikasi
- Jika token invalid/expired, endpoint akan return `401 Unauthorized`

**Current User Context:**
Setiap endpoint yang dihiasi `@CurrentUser()` akan menerima data user dari token:
```typescript
{
  sub: string,           // User ID dari Supabase
  email: string,
  user_metadata: {
    full_name?: string,
    name?: string
  }
}
```

---

## Health Check

### GET /
Memastikan server sedang aktif dan running.

**Response (200 OK)**
```
Server aktif
```

**Frontend Usage**
```dart
final response = await healthService.ping();
print(response.statusCode); // 200
```

---

## Profile Management

### POST /profile/client
Buat atau update profil client (pengguna regular).

**Required Fields** (ditandai *)
- `username*` (string): Username unik client
- `birthDate` (string): Format ISO 8601, contoh "1990-05-15"
- `gender` (enum): `MALE` atau `FEMALE`
- `photoUrl` (string): URL foto profil

**Auto-Filled Fields** (dari Supabase JWT)
- `userId`: Diambil otomatis dari token
- `email`: Diambil otomatis dari token

**Request Body Example**
```json
{
  "username": "budi_santoso",
  "birthDate": "1995-03-20",
  "gender": "MALE",
  "photoUrl": "https://example.com/photo.jpg"
}
```

**Response (200 OK)**
```json
{
  "id": "uuid-string",
  "userId": "supabase-user-id",
  "username": "budi_santoso",
  "birthDate": "1995-03-20T00:00:00Z",
  "gender": "MALE",
  "photoUrl": "https://example.com/photo.jpg",
  "createdAt": "2026-05-28T10:30:00Z",
  "updatedAt": "2026-05-28T10:30:00Z"
}
```

**Frontend Usage**
```dart
final profileService = ProfileService(apiClient);
final response = await profileService.upsertClientProfile({
  'username': 'budi_santoso',
  'birthDate': '1995-03-20',
  'gender': 'MALE',
  'photoUrl': 'https://example.com/photo.jpg',
});
```

---

### POST /profile/psychologist
Buat atau update profil psikolog (professional).

**Required Fields**
- `fullName*` (string): Nama lengkap psikolog
- `phoneNumber*` (string): Nomor telepon kontak
- `gender*` (enum): `MALE` atau `FEMALE`
- `location*` (string): Lokasi klinik/kantor
- `clinicName*` (string): Nama klinik
- `specialization*` (string): Bidang spesialisasi
- `yearsExperience*` (number): Tahun pengalaman
- `nik*` (string): Nomor Identitas Kependudukan (unique)
- `strNumber*` (string): Nomor STR (Surat Tanda Registrasi, unique)
- `education*` (array): Daftar riwayat pendidikan

**Optional Fields**
- `clientsHandled` (number): Jumlah klien yang ditangani
- `bio` (string): Deskripsi singkat tentang psikolog
- `tags` (array): Tag/keyword, misal ["anxiety", "depression"]
- `photoUrl` (string): URL foto profil

**Auto-Filled**
- `userId`: Dari Supabase JWT
- `email`: Dari Supabase JWT

**Request Body Example**
```json
{
  "fullName": "Dr. Siti Nurhaliza",
  "phoneNumber": "08123456789",
  "gender": "FEMALE",
  "location": "Jakarta Selatan",
  "clinicName": "Klinik Kesehatan Mental Sejahtera",
  "specialization": "Anxiety & Stress Management",
  "yearsExperience": 8,
  "nik": "1234567890123456",
  "strNumber": "STR/001234/2020",
  "education": ["S1 Psikologi UI", "S2 Psikologi Klinis Universitas Indonesia"],
  "clientsHandled": 150,
  "bio": "Spesialis dalam menangani kecemasan dan manajemen stres pada profesional muda",
  "tags": ["anxiety", "stress-management", "depression"],
  "photoUrl": "https://example.com/siti.jpg"
}
```

**Response (200 OK)**
```json
{
  "id": "uuid-string",
  "userId": "supabase-user-id",
  "fullName": "Dr. Siti Nurhaliza",
  "phoneNumber": "08123456789",
  "gender": "FEMALE",
  "location": "Jakarta Selatan",
  "clinicName": "Klinik Kesehatan Mental Sejahtera",
  "specialization": "Anxiety & Stress Management",
  "yearsExperience": 8,
  "nik": "1234567890123456",
  "strNumber": "STR/001234/2020",
  "education": ["S1 Psikologi UI", "S2 Psikologi Klinis Universitas Indonesia"],
  "clientsHandled": 150,
  "bio": "Spesialis dalam menangani kecemasan dan manajemen stres...",
  "tags": ["anxiety", "stress-management", "depression"],
  "photoUrl": "https://example.com/siti.jpg",
  "rating": 4.8,
  "reviewCount": 45,
  "createdAt": "2026-05-28T10:30:00Z",
  "updatedAt": "2026-05-28T10:30:00Z"
}
```

**Frontend Usage**
```dart
final response = await profileService.upsertPsychologistProfile({
  'fullName': 'Dr. Siti Nurhaliza',
  'phoneNumber': '08123456789',
  'gender': 'FEMALE',
  // ... other fields
});
```

---

### POST /profile/psychologist/documents
Submit dokumen verifikasi psikolog (KTP, foto dengan KTP, STR).

**Required Fields**
- `ktpUrl*` (string): URL foto KTP
- `faceWithKtpUrl*` (string): URL foto wajah dengan KTP
- `strLicenseUrl*` (string): URL foto STR (Surat Tanda Registrasi)

**Auto-Filled**
- `userId`: Dari Supabase JWT

**Request Body Example**
```json
{
  "ktpUrl": "https://storage.example.com/documents/ktp-siti.jpg",
  "faceWithKtpUrl": "https://storage.example.com/documents/face-ktp-siti.jpg",
  "strLicenseUrl": "https://storage.example.com/documents/str-siti.jpg"
}
```

**Response (200 OK)**
```json
{
  "id": "uuid-string",
  "psychologistId": "uuid-string",
  "type": "KTP",
  "url": "https://storage.example.com/documents/ktp-siti.jpg",
  "status": "PENDING",
  "createdAt": "2026-05-28T10:30:00Z"
}
```

**Frontend Usage**
```dart
final response = await profileService.submitPsychologistDocuments(
  ktp: ktpFile,
  faceWithKtp: faceKtpFile,
  strLicense: strFile,
  userId: supabaseUserId,
);
```

---

## Analysis Module

### POST /analysis/text
Analisis emosi dari teks input menggunakan AI (Google Gemini).

**Request**
- `text*` (string): Teks yang ingin dianalisis
- `userId` (string): User ID (optional, untuk tracking)

**Request Body Example**
```json
{
  "text": "Hari ini aku merasa sangat sedih dan khawatir tentang presentasi kerja besok. Semuanya terasa berat di bahu saya.",
  "userId": "user-123"
}
```

**Response (200 OK)**
```json
{
  "id": "uuid-string",
  "emotionLabel": "anxiety_sadness",
  "summary": "Kamu sedang mengalami kecemasan yang signifikan terkait dengan tanggung jawab pekerjaan yang akan datang, disertai dengan perasaan sedih yang cukup mendalam.",
  "recommendations": "Coba luangkan waktu 5-10 menit untuk bernapas dengan perlahan dan menenangkan pikiran kamu. Cobalah mencari hal-hal positif tentang presentasi yang akan kamu lakukan, seperti kesempatan untuk menunjukkan kemampuanmu...",
  "confidence": 0.87,
  "userId": "user-123",
  "createdAt": "2026-05-28T10:30:00Z"
}
```

**Frontend Usage**
```dart
final analysisService = AnalysisService(apiClient);
final response = await analysisService.analyzeText(
  AnalysisTextRequest(
    text: userInput,
    userId: supabaseUserId,
  ),
);
print(response.data.emotionLabel);
```

---

### POST /analysis/face
Analisis emosi dari ekspresi wajah pada foto menggunakan Face Detection + AI.

**Request**
- `image*` (file): Foto wajah (multipart/form-data)
- `mimeType` (string): MIME type foto, contoh "image/jpeg"
- `userId` (string): User ID (optional)

**Request Example (Dart)**
```dart
final analysisService = AnalysisService(apiClient);
final response = await analysisService.analyzeFace(
  image: imageFile,
  mimeType: 'image/jpeg',
  userId: supabaseUserId,
);
```

**Response (200 OK)**
```json
{
  "id": "uuid-string",
  "emotionLabel": "happy_confident",
  "summary": "Berdasarkan analisis ekspresi wajah, kamu terlihat bahagia dan percaya diri. Mata kamu terbuka lebar dengan senyuman yang tulus.",
  "recommendations": "Pertahankan energi positif ini! Gunakan kepercayaan diri kamu untuk mencapai tujuan hari ini...",
  "confidence": 0.92,
  "userId": "user-123",
  "faceLandmarks": {
    "leftEyeOpen": 0.95,
    "rightEyeOpen": 0.93,
    "mouthOpen": 0.45,
    "smileProbability": 0.88
  },
  "createdAt": "2026-05-28T10:30:00Z"
}
```

**Frontend Usage**
```dart
final response = await analysisService.analyzeFace(
  image: faceImageFile,
  userId: supabaseUserId,
);
```

---

### GET /analysis/dashboard
Dapatkan ringkasan analisis dashboard untuk user tertentu.

**Query Parameters**
- `userId` (string): User ID (optional, jika tidak ada akan gunakan dari JWT)

**Request Example**
```
GET /analysis/dashboard?userId=user-123
```

**Response (200 OK)**
```json
{
  "totalAnalysis": 42,
  "lastAnalysis": "2026-05-28T10:30:00Z",
  "emotionDistribution": {
    "happy": 8,
    "sad": 12,
    "anxious": 15,
    "calm": 7
  },
  "averageConfidence": 0.85,
  "recentAnalyses": [
    {
      "id": "uuid-1",
      "emotionLabel": "anxious",
      "timestamp": "2026-05-28T10:30:00Z"
    },
    {
      "id": "uuid-2",
      "emotionLabel": "happy",
      "timestamp": "2026-05-28T09:15:00Z"
    }
  ]
}
```

**Frontend Usage**
```dart
final response = await analysisService.fetchDashboard(
  userId: supabaseUserId,
);
```

---

## AI Partner

### POST /ai/chat/session
Buat sesi chat baru dengan AI partner.

**Request**
- `userId` (string): User ID (optional, auto-filled dari JWT jika kosong)
- `title` (string): Judul sesi (optional)

**Request Body Example**
```json
{
  "userId": "user-123",
  "title": "Chat tentang anxiety minggu ini"
}
```

**Response (200 OK)**
```json
{
  "id": "session-uuid",
  "userId": "user-123",
  "title": "Chat tentang anxiety minggu ini",
  "createdAt": "2026-05-28T10:30:00Z",
  "updatedAt": "2026-05-28T10:30:00Z",
  "messages": []
}
```

**Frontend Usage**
```dart
final aiService = AiPartnerService(apiClient);
final response = await aiService.createSession(
  AiChatSessionRequest(
    userId: supabaseUserId,
    title: 'My first chat',
  ),
);
final sessionId = response.data.id;
```

---

### GET /ai/chat/session/:id
Ambil detail sesi chat beserta riwayat pesan.

**Path Parameters**
- `id*` (string): Session ID

**Request Example**
```
GET /ai/chat/session/session-uuid-123
```

**Response (200 OK)**
```json
{
  "id": "session-uuid",
  "userId": "user-123",
  "title": "Chat tentang anxiety minggu ini",
  "createdAt": "2026-05-28T10:30:00Z",
  "updatedAt": "2026-05-28T10:35:00Z",
  "messages": [
    {
      "id": "msg-1",
      "role": "user",
      "content": "Halo, aku lagi merasa cemas",
      "createdAt": "2026-05-28T10:30:00Z"
    },
    {
      "id": "msg-2",
      "role": "assistant",
      "content": "Halo! Terima kasih sudah berbagi perasaanmu. Aku di sini untuk membantu...",
      "createdAt": "2026-05-28T10:30:30Z"
    }
  ]
}
```

**Frontend Usage**
```dart
final response = await aiService.getSession(sessionId);
print(response.data.messages.length);
```

---

### POST /ai/chat/session/:id/message
Kirim pesan ke sesi AI dan dapatkan respons.

**Path Parameters**
- `id*` (string): Session ID

**Request**
- `userId` (string): User ID (optional, auto-filled dari JWT)
- `content*` (string): Isi pesan

**Request Body Example**
```json
{
  "userId": "user-123",
  "content": "Aku merasa khawatir dengan deadline project besok"
}
```

**Response (200 OK)**
```json
{
  "id": "msg-uuid",
  "sessionId": "session-uuid",
  "role": "assistant",
  "content": "Khawatir tentang deadline adalah hal yang wajar. Mari kita cari cara untuk mengelola kecemasan ini dengan lebih efektif...",
  "metadata": {
    "model": "gemini-pro",
    "inputTokens": 150,
    "outputTokens": 200
  },
  "createdAt": "2026-05-28T10:35:00Z"
}
```

**Frontend Usage**
```dart
final response = await aiService.sendMessage(
  sessionId,
  AiChatMessageRequest(
    userId: supabaseUserId,
    content: userMessage,
  ),
);
print(response.data.content);
```

---

## Human Partner

### POST /partner/queue/join
Masuk antrean untuk ditemukan dengan partner manusia berdasarkan kesamaan energi emosional.

**Request**
- `userId*` (string): User ID

**Request Body Example**
```json
{
  "userId": "user-123"
}
```

**Response (200 OK)**
```json
{
  "id": "queue-entry-uuid",
  "userId": "user-123",
  "energy": "POSITIVE",
  "position": 3,
  "estimatedWaitTime": 120,
  "createdAt": "2026-05-28T10:30:00Z"
}
```

**Frontend Usage**
```dart
final partnerService = HumanPartnerService(apiClient);
final response = await partnerService.joinQueue(
  HumanPartnerQueueRequest(userId: supabaseUserId),
);
```

---

### POST /partner/queue/leave
Keluar dari antrean.

**Request**
- `userId*` (string): User ID

**Request Body Example**
```json
{
  "userId": "user-123"
}
```

**Response (200 OK)**
```json
{
  "message": "Berhasil keluar dari antrean",
  "userId": "user-123"
}
```

**Frontend Usage**
```dart
await partnerService.leaveQueue(
  HumanPartnerQueueRequest(userId: supabaseUserId),
);
```

---

### GET /partner/match/:id
Ambil detail match dengan partner manusia.

**Path Parameters**
- `id*` (string): Match ID

**Request Example**
```
GET /partner/match/match-uuid-123
```

**Response (200 OK)**
```json
{
  "id": "match-uuid",
  "userAId": "user-123",
  "userBId": "user-456",
  "energyA": "POSITIVE",
  "energyB": "POSITIVE",
  "status": "active",
  "createdAt": "2026-05-28T10:30:00Z",
  "messages": [
    {
      "id": "msg-1",
      "userId": "user-123",
      "content": "Halo! Senang berkenalan denganmu",
      "createdAt": "2026-05-28T10:30:30Z"
    }
  ]
}
```

**Frontend Usage**
```dart
final response = await partnerService.getMatch(matchId);
```

---

### POST /partner/match/:id/favorite
Tandai partner sebagai favorit.

**Path Parameters**
- `id*` (string): Match ID

**Request**
- `userId*` (string): User ID kamu
- `targetUserId*` (string): User ID partner

**Request Body Example**
```json
{
  "userId": "user-123",
  "targetUserId": "user-456"
}
```

**Response (200 OK)**
```json
{
  "message": "Partner ditambahkan ke favorit",
  "favoriteId": "fav-uuid",
  "createdAt": "2026-05-28T10:30:00Z"
}
```

**Frontend Usage**
```dart
await partnerService.favoriteMatch(
  matchId,
  HumanPartnerFavoriteRequest(
    userId: supabaseUserId,
    targetUserId: partnerUserId,
  ),
);
```

---

### POST /partner/match/:id/block
Blokir partner.

**Path Parameters**
- `id*` (string): Match ID

**Request**
- `userId*` (string): User ID kamu
- `targetUserId*` (string): User ID partner untuk diblokir
- `reason` (string): Alasan pemblokiran (optional)

**Request Body Example**
```json
{
  "userId": "user-123",
  "targetUserId": "user-456",
  "reason": "Ucapan tidak menghormati"
}
```

**Response (200 OK)**
```json
{
  "message": "Partner berhasil diblokir",
  "blockId": "block-uuid",
  "reason": "Ucapan tidak menghormati"
}
```

**Frontend Usage**
```dart
await partnerService.blockMatch(
  matchId,
  HumanPartnerBlockRequest(
    userId: supabaseUserId,
    targetUserId: partnerUserId,
    reason: 'Inappropriate behavior',
  ),
);
```

---

### POST /partner/match/:id/report
Laporkan partner.

**Path Parameters**
- `id*` (string): Match ID

**Request**
- `userId*` (string): User ID kamu
- `targetUserId*` (string): User ID partner untuk dilaporkan
- `reason` (string): Alasan laporan (optional, default: "unspecified")

**Request Body Example**
```json
{
  "userId": "user-123",
  "targetUserId": "user-456",
  "reason": "Pesan mengandung konten terlarang"
}
```

**Response (200 OK)**
```json
{
  "message": "Laporan berhasil dikirim kepada admin",
  "reportId": "report-uuid",
  "status": "pending_review"
}
```

**Frontend Usage**
```dart
await partnerService.reportMatch(
  matchId,
  HumanPartnerReportRequest(
    userId: supabaseUserId,
    targetUserId: partnerUserId,
    reason: 'Inappropriate content',
  ),
);
```

---

### GET /partner/favorites/:userId
Dapatkan daftar partner favorit user.

**Path Parameters**
- `userId*` (string): User ID

**Request Example**
```
GET /partner/favorites/user-123
```

**Response (200 OK)**
```json
{
  "userId": "user-123",
  "favorites": [
    {
      "id": "fav-1",
      "partnerId": "user-456",
      "partnerName": "Budi Santoso",
      "partnerPhotoUrl": "https://example.com/budi.jpg",
      "createdAt": "2026-05-28T10:30:00Z"
    },
    {
      "id": "fav-2",
      "partnerId": "user-789",
      "partnerName": "Siti Nurhaliza",
      "partnerPhotoUrl": "https://example.com/siti.jpg",
      "createdAt": "2026-05-27T15:20:00Z"
    }
  ]
}
```

**Frontend Usage**
```dart
final response = await partnerService.getFavorites(supabaseUserId);
```

---

## Psychologist

### POST /psychologist/search
Cari psikolog berdasarkan kriteria tertentu.

**Request**
- `userId` (string): User ID (optional)
- `criteria` (string): Kata kunci pencarian (optional)
- `limit` (number): Jumlah hasil maksimal (default: 10)

**Request Body Example**
```json
{
  "userId": "user-123",
  "criteria": "anxiety stress management",
  "limit": 5
}
```

**Response (200 OK)**
```json
[
  {
    "id": "psych-1",
    "fullName": "Dr. Siti Nurhaliza",
    "specialization": "Anxiety & Stress Management",
    "yearsExperience": 8,
    "rating": 4.8,
    "reviewCount": 45,
    "location": "Jakarta Selatan",
    "photoUrl": "https://example.com/siti.jpg",
    "tags": ["anxiety", "stress-management"]
  },
  {
    "id": "psych-2",
    "fullName": "Dr. Ahmad Wijaya",
    "specialization": "Trauma & PTSD",
    "yearsExperience": 10,
    "rating": 4.9,
    "reviewCount": 67,
    "location": "Jakarta Pusat",
    "photoUrl": "https://example.com/ahmad.jpg",
    "tags": ["trauma", "ptsd"]
  }
]
```

**Frontend Usage**
```dart
final psyService = PsychologistService(apiClient);
final response = await psyService.search(
  PsychologistSearchRequest(
    criteria: 'anxiety',
    limit: 10,
  ),
);
```

---

### GET /psychologist/:id
Dapatkan detail lengkap psikolog.

**Path Parameters**
- `id*` (string): Psychologist ID

**Request Example**
```
GET /psychologist/psych-uuid-123
```

**Response (200 OK)**
```json
{
  "id": "psych-123",
  "fullName": "Dr. Siti Nurhaliza",
  "email": "siti@kliniksejahtera.com",
  "phoneNumber": "08123456789",
  "gender": "FEMALE",
  "location": "Jakarta Selatan",
  "clinicName": "Klinik Kesehatan Mental Sejahtera",
  "specialization": "Anxiety & Stress Management",
  "yearsExperience": 8,
  "nik": "1234567890123456",
  "strNumber": "STR/001234/2020",
  "bio": "Spesialis dalam menangani kecemasan dan manajemen stres...",
  "tags": ["anxiety", "stress-management", "depression"],
  "photoUrl": "https://example.com/siti.jpg",
  "rating": 4.8,
  "reviewCount": 45,
  "clientsHandled": 150,
  "education": ["S1 Psikologi UI", "S2 Psikologi Klinis Universitas Indonesia"],
  "schedules": [
    {
      "id": "sched-1",
      "dayOfWeek": 1,
      "startTime": "09:00",
      "endTime": "17:00",
      "isAvailable": true
    }
  ],
  "reviews": [
    {
      "id": "review-1",
      "rating": 5,
      "comment": "Sangat membantu dan profesional",
      "createdAt": "2026-05-20T14:30:00Z"
    }
  ],
  "createdAt": "2026-01-15T10:30:00Z",
  "updatedAt": "2026-05-28T10:30:00Z"
}
```

**Frontend Usage**
```dart
final response = await psyService.getDetail(psychologistId);
```

---

### POST /psychologist/booking
Buat booking sesi dengan psikolog.

**Request**
- `userId*` (string): User ID client
- `psychologistId*` (string): Psychologist ID
- `fullName*` (string): Nama lengkap client
- `method*` (enum): Tipe konsultasi: `CHAT`, `VOICE`, atau `VIDEO`
- `price*` (number): Harga dalam Rupiah
- `scheduledAt*` (string): Waktu booking (ISO 8601 format)
- `notes` (string): Catatan khusus (optional)

**Request Body Example**
```json
{
  "userId": "user-123",
  "psychologistId": "psych-456",
  "fullName": "Budi Santoso",
  "method": "VIDEO",
  "price": 300000,
  "scheduledAt": "2026-06-05T14:00:00Z",
  "notes": "Saya sangat gugup, tolong bantuan untuk anxiety"
}
```

**Response (200 OK)**
```json
{
  "id": "booking-uuid",
  "psychologistId": "psych-456",
  "userId": "user-123",
  "fullName": "Budi Santoso",
  "method": "VIDEO",
  "price": 300000,
  "notes": "Saya sangat gugup, tolong bantuan untuk anxiety",
  "scheduledAt": "2026-06-05T14:00:00Z",
  "status": "PENDING_PAYMENT",
  "paymentStatus": "UNPAID",
  "createdAt": "2026-05-28T10:30:00Z"
}
```

**Frontend Usage**
```dart
final response = await psyService.createBooking(
  PsychologistBookingRequest(
    userId: supabaseUserId,
    psychologistId: selectedPsychId,
    fullName: userName,
    method: 'VIDEO',
    price: 300000,
    scheduledAt: selectedDateTime.toIso8601String(),
    notes: userNotes,
  ),
);
final bookingId = response.data.id;
```

---

### POST /psychologist/booking/:id/pay
Bayar booking yang sudah dibuat.

**Path Parameters**
- `id*` (string): Booking ID

**Request**
- `userId*` (string): User ID

**Request Body Example**
```json
{
  "userId": "user-123"
}
```

**Response (200 OK)**
```json
{
  "id": "booking-uuid",
  "status": "PAID",
  "paymentStatus": "PAID",
  "paymentTime": "2026-05-28T10:35:00Z",
  "transactionId": "TXN-123456789",
  "message": "Pembayaran berhasil. Silahkan tunggu psikolog menghubungi Anda"
}
```

**Frontend Usage**
```dart
final response = await psyService.payBooking(
  bookingId,
  PsychologistPayRequest(userId: supabaseUserId),
);
```

---

### POST /psychologist/review
Tambah review untuk psikolog setelah sesi selesai.

**Request**
- `userId*` (string): User ID client
- `psychologistId*` (string): Psychologist ID
- `rating*` (number): Rating 1-5
- `comment` (string): Komentar/ulasan (optional)

**Request Body Example**
```json
{
  "userId": "user-123",
  "psychologistId": "psych-456",
  "rating": 5,
  "comment": "Sesi sangat membantu dan Dr. Siti sangat profesional. Saya merasa lebih tenang setelah sesi ini."
}
```

**Response (200 OK)**
```json
{
  "id": "review-uuid",
  "psychologistId": "psych-456",
  "userId": "user-123",
  "rating": 5,
  "comment": "Sesi sangat membantu dan Dr. Siti sangat profesional...",
  "createdAt": "2026-05-28T16:30:00Z"
}
```

**Frontend Usage**
```dart
await psyService.addReview(
  PsychologistReviewRequest(
    userId: supabaseUserId,
    psychologistId: psychologistId,
    rating: userRating,
    comment: userComment,
  ),
);
```

---

### POST /psychologist/verification/request
Minta link verifikasi email untuk psikolog (bagian dari proses registrasi).

**Request**
- `psychologistId*` (string): Psychologist ID

**Request Body Example**
```json
{
  "psychologistId": "psych-456"
}
```

**Response (200 OK)**
```json
{
  "id": "verify-uuid",
  "psychologistId": "psych-456",
  "email": "siti@kliniksejahtera.com",
  "status": "PENDING",
  "expiresAt": "2026-05-29T10:30:00Z",
  "message": "Link verifikasi telah dikirim ke email Anda"
}
```

**Frontend Usage**
```dart
await psyService.requestVerification(
  PsychologistVerificationRequest(psychologistId: psychologistId),
);
```

---

### GET /psychologist/verification/confirm/:token
Konfirmasi verifikasi email psikolog (via link email).

**Path Parameters**
- `token*` (string): Verification token dari email

**Request Example**
```
GET /psychologist/verification/confirm/token-abc123xyz789
```

**Response (200 OK)**
```json
{
  "id": "verify-uuid",
  "psychologistId": "psych-456",
  "status": "VERIFIED",
  "message": "Verifikasi email berhasil! Profil Anda sudah aktif.",
  "verifiedAt": "2026-05-28T10:35:00Z"
}
```

**Frontend Usage**
```dart
// Biasanya dibuka via deep link atau URL di email
// URL akan terlihat seperti:
// https://apps.example.com/verify?token=token-abc123xyz789
// Kemudian FE parse token dan panggil:
await psyService.confirmVerification(token);
```

---

## Error Handling

### Common Error Responses

**400 Bad Request**
```json
{
  "statusCode": 400,
  "message": "text is required",
  "error": "Bad Request"
}
```

**401 Unauthorized** (Invalid/Missing token)
```json
{
  "statusCode": 401,
  "message": "Unauthorized",
  "error": "Invalid JWT token"
}
```

**404 Not Found**
```json
{
  "statusCode": 404,
  "message": "Resource not found",
  "error": "Not Found"
}
```

**500 Internal Server Error**
```json
{
  "statusCode": 500,
  "message": "Internal server error",
  "error": "Internal Server Error"
}
```

### Frontend Error Handling
```dart
try {
  final response = await analysisService.analyzeText(request);
  if (response.statusCode == 200) {
    // Success
    final data = response.data;
  } else {
    print('Error: ${response.statusCode}');
  }
} catch (e) {
  print('Exception: $e');
  _showToast('Error: $e', isError: true);
}
```

---

## Frontend Integration Examples

### Complete Example: Text Analysis Flow

```dart
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/services/analysis_service.dart';
import 'package:hackathon/core/constants.dart';

// 1. Initialize API Client dengan base URL otomatis
final apiClient = ApiClient(baseUrl: AppConstants.baseUrl);

// 2. Initialize Analysis Service
final analysisService = AnalysisService(apiClient);

// 3. Get current user from Supabase
final supabase = Supabase.instance.client;
final userId = supabase.auth.currentUser?.id;

// 4. Analyze text
final response = await analysisService.analyzeText(
  AnalysisTextRequest(
    text: "Aku merasa sedih dan khawatir hari ini",
    userId: userId,
  ),
);

// 5. Handle response
if (response.statusCode == 200) {
  print('Emotion: ${response.data.emotionLabel}');
  print('Confidence: ${response.data.confidence}');
  print('Recommendation: ${response.data.recommendations}');
} else {
  print('Error: ${response.statusCode}');
}
```

### Complete Example: Psychologist Booking Flow

```dart
// 1. Search psychologists
final psyService = PsychologistService(apiClient);
final searchResponse = await psyService.search(
  PsychologistSearchRequest(
    criteria: 'anxiety',
    limit: 10,
  ),
);
final psychologists = searchResponse.data;

// 2. Get detail of selected psychologist
final detailResponse = await psyService.getDetail(selectedPsychId);
final psychologistDetail = detailResponse.data;

// 3. Create booking
final bookingResponse = await psyService.createBooking(
  PsychologistBookingRequest(
    userId: userId,
    psychologistId: selectedPsychId,
    fullName: userFullName,
    method: 'VIDEO',
    price: 300000,
    scheduledAt: '2026-06-05T14:00:00Z',
    notes: 'Konsultasi untuk anxiety',
  ),
);
final bookingId = bookingResponse.data.id;

// 4. Pay booking
final payResponse = await psyService.payBooking(
  bookingId,
  PsychologistPayRequest(userId: userId),
);

// 5. Add review after session (optional)
if (payResponse.statusCode == 200) {
  await psyService.addReview(
    PsychologistReviewRequest(
      userId: userId,
      psychologistId: selectedPsychId,
      rating: 5,
      comment: 'Sesi sangat membantu!',
    ),
  );
}
```

---

## API Request/Response Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│              Flutter Frontend (FE)                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. User Input → Service Layer (e.g., AnalysisService)     │
│       ↓                                                      │
│  2. Service builds request + sends via ApiClient            │
│       ↓                                                      │
│  3. ApiClient auto-adds:                                    │
│      - Base URL dari AppConstants                           │
│      - Authorization header (Supabase JWT)                  │
│      - Content-Type: application/json                       │
│       ↓                                                      │
│  4. HTTP Request sent to Backend                            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                           ↓
                    (Network Call)
                           ↓
┌─────────────────────────────────────────────────────────────┐
│         NestJS Backend (http://localhost:3000)              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Request received by Controller                          │
│       ↓                                                      │
│  2. SupabaseJwtGuard validates JWT token                    │
│       ↓                                                      │
│  3. @CurrentUser() extracts user context from token         │
│       ↓                                                      │
│  4. Service processes business logic                        │
│       (e.g., call Gemini API, database queries)             │
│       ↓                                                      │
│  5. Response returned as JSON                               │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                           ↓
                    (Network Return)
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              Flutter Frontend (FE)                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. ApiClient receives & parses JSON response               │
│       ↓                                                      │
│  2. Service's parser processes data (if needed)             │
│       ↓                                                      │
│  3. ApiResponse<T> returned to UI                           │
│       ↓                                                      │
│  4. UI updates with response.data                           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Notes untuk Developer

1. **JWT Token Otomatis**: Tidak perlu manual setting Authorization header. ApiClient sudah handle semuanya.
2. **Platform-Aware Base URL**: Tidak perlu hardcode URL berbeda untuk iOS/Android. AppConstants sudah otomatis.
3. **Error Handling**: Pastikan selalu wrap API call dalam try-catch block.
4. **userId Field**: Banyak endpoint yang punya `userId` optional. Jika kosong, BE akan auto-fill dari JWT context.
5. **Async Operations**: Semua API call adalah async. Gunakan `await` atau `.then()`.
6. **Testing**: Gunakan Postman/Insomnia untuk test endpoint, tapi jangan lupa set Authorization header dengan valid Supabase JWT.

---

**Last Updated:** May 28, 2026
**Backend Version:** 0.0.1
