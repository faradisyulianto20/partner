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

## Journal

Semua endpoint journal membutuhkan `Authorization: Bearer <access_token>` dari Supabase.

### POST /journal

Buat jurnal baru dan AI akan mengategorikan mood berdasarkan isi jurnal.

Body

```json
{
  "title": "string",
  "content": "string"
}
```

Parameter

- title*: string
- content*: string

Response

- 200 OK: jurnal tersimpan dengan hasil analisis mood

Contoh response

```json
{
  "id": "string",
  "userId": "string",
  "title": "string",
  "content": "string",
  "moodLabel": "Cemas Ringan",
  "moodCategory": "ANXIOUS",
  "moodConfidence": 0.82,
  "summary": "Ringkasan mood dari isi jurnal",
  "createdAt": "2026-05-28T12:00:00.000Z",
  "updatedAt": "2026-05-28T12:00:00.000Z"
}
```

### GET /journal

Ambil daftar jurnal milik user login.

Query params

- limit: number, optional
- offset: number, optional

Response

- 200 OK: daftar jurnal + total

### GET /journal/:id

Ambil detail jurnal.

Path params

- id*: string

Response

- 200 OK: detail jurnal

### PUT /journal/:id

Update jurnal dan AI akan klasifikasi mood ulang.

Body

```json
{
  "title": "string",
  "content": "string"
}
```

Parameter

- title: string, optional
- content: string, optional

Response

- 200 OK: jurnal terupdate

### DELETE /journal/:id

Hapus jurnal.

Response

- 200 OK: `{"status":"deleted"}`

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
