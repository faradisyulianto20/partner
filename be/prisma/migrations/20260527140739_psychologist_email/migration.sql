/*
  Warnings:

  - A unique constraint covering the columns `[email]` on the table `Psychologist` will be added. If there are existing duplicate values, this will fail.

*/
-- AlterTable
ALTER TABLE "Psychologist" ADD COLUMN     "email" TEXT;

-- CreateTable
CREATE TABLE "PsychologistEmailVerification" (
    "id" TEXT NOT NULL,
    "psychologistId" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "status" "VerificationStatus" NOT NULL DEFAULT 'PENDING',
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PsychologistEmailVerification_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "PsychologistEmailVerification_token_key" ON "PsychologistEmailVerification"("token");

-- CreateIndex
CREATE UNIQUE INDEX "Psychologist_email_key" ON "Psychologist"("email");

-- AddForeignKey
ALTER TABLE "PsychologistEmailVerification" ADD CONSTRAINT "PsychologistEmailVerification_psychologistId_fkey" FOREIGN KEY ("psychologistId") REFERENCES "Psychologist"("id") ON DELETE CASCADE ON UPDATE CASCADE;
