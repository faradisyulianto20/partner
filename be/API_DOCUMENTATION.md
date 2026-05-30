# Backend API Documentation

Base URL examples below assume the backend runs at `http://localhost:3000`.

## Notes

- JWT guard is active for `/profile/*`, `/journal/*`, and selected `/psychologist/*` action routes.
- For guarded routes, prefer `Authorization: Bearer <token>` and do not rely on manual `userId` in body/query.
- Some endpoints are public by design, such as psychologist detail and verification confirmation.
- Multipart upload is used for the face analysis endpoint.

## Common Response Patterns

- Success responses usually return the created or updated entity directly.
- `list` endpoints usually return `{ total, items }` or an array.
- Validation errors are returned as `400 Bad Request`.
- Missing records usually return `404 Not Found` when the service checks ownership or existence.

---

## 1. App

### GET /
Returns a simple hello message from the server.

**Response**
```json
"Hello World!"
```

---

## 2. Auth

Base path: `/auth`

### POST /auth/register
Register a new user with email and password, then return a JWT bearer token.

**Body**
```json
{
  "email": "user@mail.com",
  "password": "password123",
  "displayName": "Nazwa User",
  "role": "CLIENT"
}
```

**Notes**
- Use `role: "CLIENT"` for client accounts.
- Use `role: "PSYCHOLOGIST"` for psychologist accounts.
- After psychologist register succeeds, call `POST /profile/psychologist` to fill the professional profile.

**Response**
```json
{
  "tokenType": "Bearer",
  "accessToken": "jwt-token",
  "expiresIn": "7d",
  "user": {
    "id": "user-id",
    "email": "user@mail.com",
    "displayName": "Nazwa User",
    "role": "CLIENT"
  }
}
```

### POST /auth/login
Login with email and password, then return a JWT bearer token.

**Body**
```json
{
  "email": "user@mail.com",
  "password": "password123"
}
```

**Response**
Same structure as `/auth/register`.

**Required env**
- `JWT_SECRET`
- `JWT_EXPIRES_IN` (optional, default `7d`)

## 3. Analysis

Base path: `/analysis`

### POST /analysis/text
Analyze free-text input with Gemini and save the result.

**Body**
```json
{
  "text": "Saya merasa cemas dan sulit tidur.",
  "userId": "user-id-optional"
}
```

**Response**
```json
{
  "id": "analysis-id",
  "createdAt": "2026-05-29T00:00:00.000Z",
  "emotionLabel": "Cemas",
  "summary": "...",
  "recommendations": {
    "title": "Rekomendasi Dukungan Untukmu",
    "narrative": "...",
    "items": [
      {
        "key": "AI_PARTNER",
        "title": "AI Partner",
        "description": "..."
      }
    ]
  },
  "confidence": 0.87
}
```

### POST /analysis/face
Analyze a face image and save the result.

**Content-Type**: `multipart/form-data`

**Fields**
- `image` file: required
- `mimeType`: optional
- `userId`: optional

**Response**
Same structure as `/analysis/text`.

### GET /analysis/dashboard?userId=...
Return the last 7 days of analysis data and today’s latest analysis.

**Query**
- `userId`: optional

**Response**
```json
{
  "last7Days": [
    {
      "date": "2026-05-29",
      "dayLabel": "Kamis",
      "emotionLabel": "Cemas"
    }
  ],
  "today": {
    "id": "analysis-id",
    "createdAt": "2026-05-29T00:00:00.000Z",
    "emotionLabel": "Cemas",
    "summary": "...",
    "recommendations": {
      "title": "...",
      "narrative": "...",
      "items": []
    }
  }
}
```

---

## 4. AI Partner

Base path: `/ai`

### POST /ai/chat/session
Create a new AI chat session.

**Body**
```json
{
  "userId": "user-id-optional",
  "title": "Curhat malam ini"
}
```

**Response**
```json
{
  "id": "session-id",
  "userId": "user-id",
  "title": "Curhat malam ini",
  "createdAt": "2026-05-29T00:00:00.000Z"
}
```

### GET /ai/chat/session/:id
Get one AI chat session and its messages.

**Path params**
- `id`: session id

**Response**
```json
{
  "id": "session-id",
  "userId": "user-id",
  "title": "Curhat malam ini",
  "messages": []
}
```

### POST /ai/chat/session/:id/message
Send a message to the AI partner and receive the assistant reply.

**Body**
```json
{
  "userId": "user-id-optional",
  "content": "Aku sedang capek sekali akhir-akhir ini."
}
```

**Response**
```json
{
  "id": "message-id",
  "sessionId": "session-id",
  "role": "assistant",
  "content": "...",
  "createdAt": "2026-05-29T00:00:00.000Z"
}
```

---

## 5. Profile

Base path: `/profile`

### GET /profile/me
Get the full profile for the current user record.

**Query/body**
- No explicit body

**Response**
User record with `clientProfile` and `psychologist` relations.

### GET /profile/me/client
Get only the client profile.

**Response**
```json
{
  "id": "client-profile-id",
  "userId": "user-id",
  "username": "Nazwa",
  "birthDate": "2000-01-01T00:00:00.000Z",
  "gender": "FEMALE",
  "photoUrl": null,
  "user": {
    "id": "user-id",
    "email": "user@mail.com",
    "displayName": "Nazwa",
    "role": "CLIENT"
  }
}
```

### GET /profile/me/psychologist
Get only the psychologist profile.

**Response**
Psychologist object with `education`, `documents`, `schedules`, and linked `user` data.

### POST /profile/client
Create or update the client profile.

**Body** `multipart/form-data`
- `username` required
- `birthDate` optional
- `gender` optional
- `photo` optional file upload, saved to Supabase Storage and stored as `photoUrl`
- Other text fields follow the same names as before (`userId`, `email`, `displayName`)

**Response**
The saved client profile.

### POST /profile/psychologist
Create or update the psychologist profile.

**Body** `multipart/form-data`
- `fullName`, `phoneNumber`, `gender`, `location`, `clinicName`, `specialization`, `yearsExperience`, `nik`, and `strNumber` are required
- `photo` optional file upload, saved to Supabase Storage and stored as `photoUrl`
- `education` and `tags` can be sent as JSON strings like `["S1 Psikologi UI"]` or `["Cemas", "Burnout"]`

**Response**
The saved psychologist profile.

### POST /profile/psychologist/documents
Upload or update psychologist verification documents.

**Body** `multipart/form-data`
- `ktp` required file upload
- `faceWithKtp` required file upload
- `strLicense` required file upload
- Each file is uploaded to Supabase Storage and the returned public URL is saved in the database

**Response**
Array of updated verification document records.

---

## 6. Journal

Base path: `/journal`

### POST /journal
Create a new journal entry and run AI mood analysis.

**Body**
```json
{
  "title": "Hari yang berat",
  "content": "Saya merasa sangat lelah hari ini."
}
```

**Response**
Journal record with AI mood result fields such as `moodLabel`, `moodCategory`, `summary`, and `moodConfidence`.

### GET /journal?limit=20&offset=0
List journal entries for the current user.

**Query**
- `limit`: optional, default `20`
- `offset`: optional, default `0`

**Response**
```json
{
  "total": 12,
  "items": []
}
```

### GET /journal/:id
Get one journal entry.

**Path params**
- `id`: journal id

**Response**
A journal record.

### PUT /journal/:id
Update a journal entry and re-run mood analysis.

**Body**
```json
{
  "title": "Judul baru",
  "content": "Isi baru"
}
```

**Response**
Updated journal record.

### DELETE /journal/:id
Delete a journal entry.

**Response**
```json
{
  "status": "deleted"
}
```

---

## 7. Psychologist

Base path: `/psychologist`

### POST /psychologist/search
Search psychologists and rank them.

**Body**
```json
{
  "userId": "user-id-optional",
  "criteria": "Cocok untuk kecemasan dan burnout",
  "limit": 10
}
```

**Response**
Array of ranked psychologist summaries.

### GET /psychologist/me/dashboard?userId=...
Return psychologist dashboard data.

**Query**
- `userId`: optional

**Response**
```json
{
  "psychologist": {},
  "stats": {
    "totalSessionsToday": 4,
    "monthlyIncome": 3500000,
    "pendingRequests": 2
  },
  "nextSession": {},
  "requests": [],
  "upcomingSessions": []
}
```

### GET /psychologist/me/sessions?date=2027-11-20
Return the full timeline for one day, including session cards and break blocks.

**Query**
- `date`: optional ISO date string, defaults to today

**Response**
```json
{
  "date": "2027-11-20",
  "dayLabel": "Senin",
  "psychologist": {
    "id": "psychologist-id",
    "fullName": "Dr. Shinta Prawiti",
    "isAcceptingSessions": true,
    "schedules": []
  },
  "sessions": [
    {
      "bookingId": "booking-id",
      "scheduledAt": "2027-11-20T02:00:00.000Z",
      "timeLabel": "09:00",
      "method": "CHAT",
      "status": "CONFIRMED",
      "paymentStatus": "PAID",
      "fullName": "Alana Fransisco",
      "notes": "Aku cemas...",
      "moodLabel": "Cemas",
      "summary": "...",
      "clientPhotoUrl": "https://...",
      "durationMinutes": 60
    }
  ],
  "timeline": [
    {
      "type": "SESSION",
      "bookingId": "booking-id",
      "timeLabel": "09:00",
      "startAt": "2027-11-20T02:00:00.000Z",
      "endAt": "2027-11-20T03:00:00.000Z",
      "fullName": "Alana Fransisco",
      "method": "CHAT",
      "status": "CONFIRMED",
      "paymentStatus": "PAID",
      "moodLabel": "Cemas",
      "summary": "...",
      "notes": "Aku cemas...",
      "clientPhotoUrl": "https://..."
    },
    {
      "type": "BREAK",
      "label": "Waktu Istirahat",
      "startAt": "2027-11-20T03:00:00.000Z",
      "endAt": "2027-11-20T04:00:00.000Z"
    }
  ],
  "totalSessions": 4
}
```

### PATCH /psychologist/me/status
Toggle consultation acceptance status.

**Body**
```json
{
  "userId": "user-id-optional",
  "isAcceptingSessions": true
}
```

**Response**
Updated psychologist record.

### PUT /psychologist/me/schedules
Replace weekly availability schedules.

**Body**
```json
{
  "userId": "user-id-optional",
  "schedules": [
    {
      "dayOfWeek": 1,
      "startTime": "09:00",
      "endTime": "17:00",
      "isAvailable": true
    }
  ]
}
```

**Response**
Updated psychologist record with `schedules`.

### POST /psychologist/booking/:id/respond
Accept or reject a booking request.

**Auth**
- Bearer token required

**Body**
```json
{
  "action": "ACCEPT"
}
```

**Response**
Updated booking record.

### PATCH /psychologist/booking/:id/complete
Mark a consultation as finished.

**Path params**
- `id`: booking id

**Response**
Updated booking record with `status: COMPLETED`.

### GET /psychologist/booking/:id/detail
Get all data needed for the client detail modal.

**Path params**
- `id`: booking id

**Response**
```json
{
  "booking": {
    "id": "booking-id",
    "scheduledAt": "2026-05-29T07:00:00.000Z",
    "method": "VIDEO",
    "notes": "Cemas karena pekerjaan",
    "status": "PENDING_PAYMENT",
    "paymentStatus": "UNPAID",
    "price": 250000,
    "fullName": "Suroto Ahmad"
  },
  "client": {
    "id": "client-profile-id",
    "userId": "user-id",
    "username": "suroto",
    "age": 32,
    "gender": "MALE",
    "photoUrl": "https://..."
  },
  "psychologist": {
    "id": "psychologist-id",
    "fullName": "Dr. Shinta Prawiti",
    "specialization": "Psikolog Klinis",
    "photoUrl": "https://..."
  },
  "latestAnalysis": {
    "id": "analysis-id",
    "emotionLabel": "Cemas",
    "summary": "...",
    "recommendations": {},
    "createdAt": "2026-05-29T00:00:00.000Z"
  }
}
```

### GET /psychologist/me/clients?search=alana&status=ACTIVE
Return the psychologist client list for the UI cards and tabs.

**Query**
- `search`: optional name/user search
- `status`: optional `ALL`, `ACTIVE`, or `COMPLETED`

**Response**
```json
{
  "items": [
    {
      "clientId": "client-profile-id",
      "userId": "user-id",
      "name": "Alana Fransisco",
      "age": 32,
      "gender": "MALE",
      "photoUrl": "https://...",
      "bookingId": "booking-id",
      "status": "COMPLETED",
      "statusLabel": "Selesai",
      "lastSessionAt": "2026-11-10T07:00:00.000Z",
      "lastSessionLabel": "10 November 2026",
      "totalBookings": 3,
      "latestMoodLabel": "Cemas",
      "latestSummary": "..."
    }
  ],
  "total": 1,
  "counts": {
    "all": 12,
    "active": 4,
    "completed": 8
  }
}
```

### GET /psychologist/me/income?limit=20
Return the income summary and payment history for the income page.

**Query**
- `limit`: optional number of history items to return, default `50`

**Response**
```json
{
  "totalBalance": 10650000,
  "transactions": [
    {
      "bookingId": "booking-id",
      "title": "Pembayaran Masuk",
      "amount": 150000,
      "amountLabel": "+Rp. 150.000",
      "dateLabel": "12 September 2026",
      "timeLabel": "10:00 WIB",
      "scheduledAt": "2026-09-12T03:00:00.000Z",
      "clientName": "Alana Fransisco",
      "method": "CHAT",
      "status": "PAID"
    }
  ],
  "total": 71
}
```

### GET /psychologist/me/reviews?limit=20&page=1
Return the review summary, rating breakdown, and latest client feedback.

**Query**
- `limit`: optional number of reviews to return, default `20`
- `page`: optional page number, default `1`

**Response**
```json
{
  "summary": {
    "averageRating": 4.5,
    "totalReviews": 476,
    "breakdown": [
      { "rating": 5, "count": 236 },
      { "rating": 4, "count": 145 },
      { "rating": 3, "count": 44 },
      { "rating": 2, "count": 56 },
      { "rating": 1, "count": 2 }
    ]
  },
  "items": [
    {
      "reviewId": "review-id",
      "reviewerName": "Amanda R",
      "reviewerPhotoUrl": "https://...",
      "rating": 5,
      "comment": "Dr. Sarah sangat membantu saya mengatasi kecemasan.",
      "createdAt": "2026-09-12T03:00:00.000Z",
      "timeLabel": "2 hari lalu",
      "dayLabel": "12 September 2026"
    }
  ],
  "total": 476
}
```

## 6. Profile

### GET /profile/me/psychologist
Return the authenticated psychologist profile, including `schedules` for the weekly settings page.

**Response**
```json
{
  "id": "psychologist-id",
  "fullName": "Dr. Shinta Prawiti",
  "schedules": [
    {
      "id": "schedule-id",
      "dayOfWeek": 1,
      "startTime": "09:00",
      "endTime": "17:00",
      "isAvailable": true
    }
  ]
}
```

### PUT /profile/me/psychologist/schedules
Replace weekly practice hours from the profile settings page.

**Body**
```json
{
  "schedules": [
    {
      "dayOfWeek": 1,
      "startTime": "09:00",
      "endTime": "17:00",
      "isAvailable": true
    }
  ]
}
```

**Response**
Updated psychologist record with `schedules`.

### GET /psychologist/:id
Get psychologist detail with education, reviews, and schedules.

**Path params**
- `id`: psychologist id

**Response**
Psychologist detail object.

### POST /psychologist/booking
Create a booking session.

**Auth**
- Bearer token required

**Body**
```json
{
  "psychologistId": "psychologist-id",
  "fullName": "Suroto Ahmad",
  "method": "VIDEO",
  "price": 250000,
  "notes": "Cemas karena pekerjaan",
  "scheduledAt": "2026-05-29T07:00:00.000Z"
}
```

**Response**
Created booking record.

### POST /psychologist/booking/:id/pay
Mark a booking as paid.

**Auth**
- Bearer token required

**Body**
```json
{}
```

**Response**
Updated booking record.

### POST /psychologist/review
Create a psychologist review.

**Auth**
- Bearer token required

**Body**
```json
{
  "psychologistId": "psychologist-id",
  "rating": 5,
  "comment": "Sangat membantu"
}
```

**Response**
Created review record.

### POST /psychologist/verification/request
Send a verification email to the psychologist.

**Body**
```json
{
  "psychologistId": "psychologist-id"
}
```

**Response**
```json
{
  "status": "sent"
}
```

### GET /psychologist/verification/confirm/:token
Confirm psychologist verification using the email token.

**Path params**
- `token`: verification token

**Response**
```json
{
  "status": "verified"
}
```

---

## 8. Human Partner

Base path: `/partner`

### POST /partner/queue/join
Join the human partner queue.

**Body**
```json
{
  "userId": "user-id"
}
```

**Response**
```json
{
  "status": "queued"
}
```

If a match is found:
```json
{
  "status": "matched",
  "matchId": "match-id",
  "partnerUserId": "other-user-id"
}
```

### POST /partner/queue/leave
Leave the queue.

**Body**
```json
{
  "userId": "user-id"
}
```

**Response**
```json
{
  "status": "left"
}
```

### GET /partner/match/:id
Get a match detail and its messages.

**Path params**
- `id`: match id

**Response**
Match object with `messages`.

### POST /partner/match/:id/favorite
Favorite a partner.

**Body**
```json
{
  "userId": "user-id",
  "targetUserId": "target-user-id"
}
```

**Response**
Created favorite record.

### POST /partner/match/:id/block
Block a partner and close the match if active.

**Body**
```json
{
  "userId": "user-id",
  "targetUserId": "target-user-id",
  "reason": "Tidak nyaman"
}
```

**Response**
```json
{
  "status": "blocked"
}
```

### POST /partner/match/:id/report
Report a partner.

**Body**
```json
{
  "userId": "user-id",
  "targetUserId": "target-user-id",
  "reason": "Spam"
}
```

**Response**
Created report record.

### GET /partner/favorites/:userId
List a user’s favorites.

**Path params**
- `userId`: user id

**Response**
Array of favorite records.

---

## 9. WebSocket APIs

### `/ai/voice`
Voice assistant namespace.

**Events**
- `start` → payload: `{ sessionId?: string, userId?: string, sampleRate?: number }`
- `audio` → payload: `Buffer | ArrayBuffer | { chunk?: string }`
- `stop` → no payload

**Server emits**
- `session` → `{ sessionId, userId, sampleRate }`
- `transcript` → transcript chunk object
- `assistant_text` → `{ sessionId, text }`
- `assistant_audio` → `{ chunk, mimeType, isLast }`
- `error` → `{ message }`

FE flow yang benar:

1. connect ke namespace `/ai/voice`
2. emit `start`
3. tunggu `session`
4. emit `audio`
5. emit `stop`
6. tunggu `transcript`, `assistant_text`, dan `assistant_audio`

Kalau event di atas muncul berurutan di log FE, koneksi WebSocket sudah bekerja.

### `/partner/chat`
Human / psychologist chat namespace.

**Events**
- `join` → payload:
```json
{
  "matchId": "string",
  "userId": "string",
  "roomType": "HUMAN | PSYCHOLOGIST",
  "role": "USER | PSYCHOLOGIST"
}
```
- `message` → payload:
```json
{
  "matchId": "string",
  "userId": "string",
  "content": "string",
  "roomType": "HUMAN | PSYCHOLOGIST",
  "role": "USER | PSYCHOLOGIST"
}
```

**Server emits**
- `joined` → `{ matchId, roomType }`
- `message` → message object

Room rule:

- `roomType: HUMAN` untuk human partner match.
- `roomType: PSYCHOLOGIST` untuk sesi psikolog.
- `matchId` adalah room identifier; untuk psikolog gunakan `bookingId`.

FE verification:

1. dua client join room yang sama
2. keduanya menerima `joined`
3. saat satu client emit `message`, client lain menerima event `message`
4. backend menyimpan message ke database

### `/partner/call`
WebRTC signaling namespace.

**Events**
- `join` → same shape as chat join
- `offer` → payload:
```json
{
  "matchId": "string",
  "userId": "string",
  "offer": {},
  "roomType": "HUMAN | PSYCHOLOGIST",
  "role": "USER | PSYCHOLOGIST"
}
```
- `answer` → payload:
```json
{
  "matchId": "string",
  "userId": "string",
  "answer": {},
  "roomType": "HUMAN | PSYCHOLOGIST",
  "role": "USER | PSYCHOLOGIST"
}
```
- `ice` → payload:
```json
{
  "matchId": "string",
  "userId": "string",
  "candidate": {},
  "roomType": "HUMAN | PSYCHOLOGIST",
  "role": "USER | PSYCHOLOGIST"
}
```

**Server emits**
- `joined` → `{ matchId, roomType }`
- `offer` → `{ userId, offer }`
- `answer` → `{ userId, answer }`
- `ice` → `{ userId, candidate }`

Room rule sama seperti chat:

- `roomType: HUMAN` untuk human partner match.
- `roomType: PSYCHOLOGIST` untuk sesi psikolog.
- `matchId` harus sama di dua peer yang sedang call.

FE verification:

1. dua client join room yang sama
2. client A emit `offer`, client B menerima `offer`
3. client B emit `answer`, client A menerima `answer`
4. kedua client saling emit `ice` dan diteruskan ke peer lain
5. kalau event signaling jalan, layer WebRTC media sudah bisa dilanjutkan di FE

---

## 10. Quick Route Summary

### Public HTTP routes
- `GET /`
- `GET /psychologist/:id`
- `GET /psychologist/verification/confirm/:token`

### Main grouped routes
- `/analysis`
- `/ai`
- `/profile`
- `/journal`
- `/psychologist`
- `/partner`
