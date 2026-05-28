# Hackathon BE API

Dokumentasi ringkas untuk endpoint API di backend ini.

## Base URL

- Local: http://localhost:3000

## Format umum

- Content-Type: application/json (kecuali upload file)
- Semua respons dikembalikan dalam JSON
- Field dengan tanda * bersifat wajib

## Health

### GET /

Respon teks sederhana untuk memastikan server hidup.

Response

- 200 OK: string

## AI Partner

### POST /ai/chat/session

Buat sesi chat AI.

Body

```json
{
  "userId": "string",
  "title": "string"
}
```

Parameter

- userId: string, optional
- title: string, optional

Response

- 200 OK: objek sesi (sesuai implementasi service)

### GET /ai/chat/session/:id

Ambil detail sesi chat AI.

Path params

- id*: string

Response

- 200 OK: detail sesi

### POST /ai/chat/session/:id/message

Kirim pesan ke sesi chat AI.

Path params

- id*: string

Body

```json
{
  "userId": "string",
  "content": "string"
}
```

Parameter

- userId: string, optional
- content*: string

Response

- 200 OK: hasil dari AI

## Analysis

### POST /analysis/text

Analisis teks.

Body

```json
{
  "text": "string",
  "userId": "string"
}
```

Parameter

- text*: string
- userId: string, optional

Response

- 200 OK: hasil analisis teks

### POST /analysis/face

Analisis wajah dari gambar.

Content-Type

- multipart/form-data

Form-data

- image*: file (field name: image)
- mimeType: string, optional (jika tidak diisi, memakai mimetype file)
- userId: string, optional

Response

- 200 OK: hasil analisis wajah
- 400 Bad Request: jika image tidak dikirim

### GET /analysis/dashboard

Ringkasan dashboard analisis.

Query params

- userId: string, optional

Response

- 200 OK: data dashboard

## Human Partner

### POST /partner/queue/join

Masuk antrean partner manusia.

Body

```json
{
  "userId": "string"
}
```

Parameter

- userId*: string

Response

- 200 OK: status antrean

### POST /partner/queue/leave

Keluar dari antrean partner manusia.

Body

```json
{
  "userId": "string"
}
```

Parameter

- userId*: string

Response

- 200 OK: status antrean

### GET /partner/match/:id

Ambil detail match berdasarkan id.

Path params

- id*: string

Response

- 200 OK: detail match

### POST /partner/match/:id/favorite

Tandai partner sebagai favorit.

Path params

- id*: string

Body

```json
{
  "userId": "string",
  "targetUserId": "string"
}
```

Parameter

- userId*: string
- targetUserId*: string

Response

- 200 OK: status favorit

### POST /partner/match/:id/block

Blokir partner.

Path params

- id*: string

Body

```json
{
  "userId": "string",
  "targetUserId": "string",
  "reason": "string"
}
```

Parameter

- userId*: string
- targetUserId*: string
- reason: string, optional

Response

- 200 OK: status blokir

### POST /partner/match/:id/report

Laporkan partner.

Path params

- id*: string

Body

```json
{
  "userId": "string",
  "targetUserId": "string",
  "reason": "string"
}
```

Parameter

- userId*: string
- targetUserId*: string
- reason: string, optional (default: unspecified)

Response

- 200 OK: status laporan

### GET /partner/favorites/:userId

Daftar partner favorit.

Path params

- userId*: string

Response

- 200 OK: daftar favorit

## Psychologist

### POST /psychologist/search

Cari psikolog.

Body

```json
{
  "userId": "string",
  "criteria": "string",
  "limit": 10
}
```

Parameter

- userId: string, optional
- criteria: string, optional
- limit: number, optional

Response

- 200 OK: daftar psikolog

### GET /psychologist/:id

Detail psikolog.

Path params

- id*: string

Response

- 200 OK: detail psikolog

### POST /psychologist/booking

Buat booking sesi psikolog.

Body

```json
{
  "userId": "string",
  "psychologistId": "string",
  "fullName": "string",
  "method": "CHAT",
  "price": 0,
  "notes": "string",
  "scheduledAt": "2026-05-28T08:30:00.000Z"
}
```

Parameter

- userId*: string
- psychologistId*: string
- fullName*: string
- method*: CHAT | VOICE | VIDEO
- price*: number
- notes: string, optional
- scheduledAt*: string (ISO date)

Response

- 200 OK: detail booking

### POST /psychologist/booking/:id/pay

Bayar booking.

Path params

- id*: string (booking id)

Body

```json
{
  "userId": "string"
}
```

Parameter

- userId*: string

Response

- 200 OK: status pembayaran

### POST /psychologist/review

Tambah review psikolog.

Body

```json
{
  "userId": "string",
  "psychologistId": "string",
  "rating": 5,
  "comment": "string"
}
```

Parameter

- userId*: string
- psychologistId*: string
- rating*: number
- comment: string, optional

Response

- 200 OK: review berhasil

### POST /psychologist/verification/request

Minta verifikasi email psikolog.

Body

```json
{
  "psychologistId": "string"
}
```

Parameter

- psychologistId*: string

Response

- 200 OK: status permintaan

### GET /psychologist/verification/confirm/:token

Konfirmasi verifikasi email.

Path params

- token*: string

Response

- 200 OK: status verifikasi

## Auth

Semua endpoint yang menggunakan `SupabaseJwtGuard` membutuhkan header:

- `Authorization: Bearer <token>`

Token harus JWT Supabase yang valid. Jika token tidak valid atau tidak ada, backend akan merespon `401 Unauthorized`.

`CurrentUser` mengambil payload JWT dari request dan menyediakan `userId` (`sub`), `email`, dan metadata user.

## Profile

### POST /profile/client

Buat atau update profil client.

Auth: diperlukan

Body

```json
{
  "userId": "string",
  "email": "string",
  "displayName": "string",
  "username": "string",
  "birthDate": "YYYY-MM-DD",
  "gender": "MALE" | "FEMALE",
  "photoUrl": "string"
}
```

Response

- 200 OK: objek profil client yang dibuat atau diupdate

Contoh response:

```json
{
  "userId": "uuid",
  "username": "johndoe",
  "birthDate": "1990-01-01T00:00:00.000Z",
  "gender": "MALE",
  "photoUrl": "https://example.com/photo.jpg"
}
```

### POST /profile/psychologist

Buat atau update profil psikolog.

Auth: diperlukan

Body

```json
{
  "userId": "string",
  "email": "string",
  "fullName": "string",
  "phoneNumber": "string",
  "gender": "MALE" | "FEMALE",
  "location": "string",
  "clinicName": "string",
  "specialization": "string",
  "yearsExperience": 5,
  "nik": "string",
  "strNumber": "string",
  "photoUrl": "string",
  "education": ["string"],
  "clientsHandled": 10,
  "bio": "string",
  "tags": ["string"]
}
```

Response

- 200 OK: objek profil psikolog yang dibuat atau diupdate

### POST /profile/psychologist/documents

Kirim dokumen verifikasi psikolog.

Auth: diperlukan

Body

```json
{
  "userId": "string",
  "ktpUrl": "string",
  "faceWithKtpUrl": "string",
  "strLicenseUrl": "string"
}
```

Response

- 200 OK: daftar dokumen verifikasi yang dibuat atau diupdate

Contoh response:

```json
[
  { "psychologistId": "uuid", "type": "KTP", "url": "https://...", "status": "PENDING" },
  { "psychologistId": "uuid", "type": "FACE_WITH_KTP", "url": "https://...", "status": "PENDING" },
  { "psychologistId": "uuid", "type": "STR_LICENSE", "url": "https://...", "status": "PENDING" }
]
```
