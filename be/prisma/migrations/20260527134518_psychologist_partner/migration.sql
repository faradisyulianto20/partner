-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE');

-- CreateEnum
CREATE TYPE "VerificationStatus" AS ENUM ('PENDING', 'VERIFIED', 'REJECTED');

-- CreateEnum
CREATE TYPE "VerificationDocType" AS ENUM ('KTP', 'FACE_WITH_KTP', 'STR_LICENSE');

-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('PENDING_PAYMENT', 'PAID', 'CONFIRMED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('UNPAID', 'PAID', 'FAILED');

-- CreateTable
CREATE TABLE "Psychologist" (
    "id" TEXT NOT NULL,
    "fullName" TEXT NOT NULL,
    "phoneNumber" TEXT NOT NULL,
    "gender" "Gender" NOT NULL,
    "location" TEXT NOT NULL,
    "clinicName" TEXT NOT NULL,
    "specialization" TEXT NOT NULL,
    "clientsHandled" INTEGER NOT NULL,
    "yearsExperience" INTEGER NOT NULL,
    "nik" TEXT NOT NULL,
    "strNumber" TEXT NOT NULL,
    "bio" TEXT,
    "tags" TEXT[],
    "rating" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "reviewCount" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Psychologist_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PsychologistEducation" (
    "id" TEXT NOT NULL,
    "psychologistId" TEXT NOT NULL,
    "level" TEXT NOT NULL,
    "institution" TEXT NOT NULL,
    "year" INTEGER,

    CONSTRAINT "PsychologistEducation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PsychologistReview" (
    "id" TEXT NOT NULL,
    "psychologistId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PsychologistReview_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PsychologistSchedule" (
    "id" TEXT NOT NULL,
    "psychologistId" TEXT NOT NULL,
    "dayOfWeek" INTEGER NOT NULL,
    "startTime" TEXT NOT NULL,
    "endTime" TEXT NOT NULL,
    "isAvailable" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "PsychologistSchedule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PsychologistVerificationDoc" (
    "id" TEXT NOT NULL,
    "psychologistId" TEXT NOT NULL,
    "type" "VerificationDocType" NOT NULL,
    "url" TEXT NOT NULL,
    "status" "VerificationStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PsychologistVerificationDoc_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PsychologistBooking" (
    "id" TEXT NOT NULL,
    "psychologistId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "scheduledAt" TIMESTAMP(3) NOT NULL,
    "status" "BookingStatus" NOT NULL DEFAULT 'PENDING_PAYMENT',
    "paymentStatus" "PaymentStatus" NOT NULL DEFAULT 'UNPAID',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PsychologistBooking_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Psychologist_nik_key" ON "Psychologist"("nik");

-- CreateIndex
CREATE UNIQUE INDEX "Psychologist_strNumber_key" ON "Psychologist"("strNumber");

-- AddForeignKey
ALTER TABLE "PsychologistEducation" ADD CONSTRAINT "PsychologistEducation_psychologistId_fkey" FOREIGN KEY ("psychologistId") REFERENCES "Psychologist"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PsychologistReview" ADD CONSTRAINT "PsychologistReview_psychologistId_fkey" FOREIGN KEY ("psychologistId") REFERENCES "Psychologist"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PsychologistSchedule" ADD CONSTRAINT "PsychologistSchedule_psychologistId_fkey" FOREIGN KEY ("psychologistId") REFERENCES "Psychologist"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PsychologistVerificationDoc" ADD CONSTRAINT "PsychologistVerificationDoc_psychologistId_fkey" FOREIGN KEY ("psychologistId") REFERENCES "Psychologist"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PsychologistBooking" ADD CONSTRAINT "PsychologistBooking_psychologistId_fkey" FOREIGN KEY ("psychologistId") REFERENCES "Psychologist"("id") ON DELETE CASCADE ON UPDATE CASCADE;
