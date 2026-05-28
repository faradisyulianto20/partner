/*
  Warnings:

  - You are about to drop the `PsychologistWalletTransaction` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "JournalMoodCategory" AS ENUM ('POSITIVE', 'CALM', 'ANXIOUS', 'SAD', 'ANGRY', 'BURNOUT', 'NEUTRAL');

-- DropForeignKey
ALTER TABLE "PsychologistWalletTransaction" DROP CONSTRAINT "PsychologistWalletTransaction_bookingId_fkey";

-- DropForeignKey
ALTER TABLE "PsychologistWalletTransaction" DROP CONSTRAINT "PsychologistWalletTransaction_psychologistId_fkey";

-- DropTable
DROP TABLE "PsychologistWalletTransaction";

-- DropEnum
DROP TYPE "WalletTransactionType";

-- CreateTable
CREATE TABLE "Journal" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "moodLabel" TEXT NOT NULL,
    "moodCategory" "JournalMoodCategory" NOT NULL,
    "moodConfidence" DOUBLE PRECISION,
    "summary" TEXT NOT NULL,
    "rawJson" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Journal_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Journal_userId_createdAt_idx" ON "Journal"("userId", "createdAt");
