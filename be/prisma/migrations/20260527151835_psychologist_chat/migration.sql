-- CreateEnum
CREATE TYPE "PsychologistMessageRole" AS ENUM ('USER', 'PSYCHOLOGIST');

-- CreateTable
CREATE TABLE "PsychologistMessage" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "senderRole" "PsychologistMessageRole" NOT NULL,
    "senderId" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PsychologistMessage_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "PsychologistMessage" ADD CONSTRAINT "PsychologistMessage_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "PsychologistBooking"("id") ON DELETE CASCADE ON UPDATE CASCADE;
