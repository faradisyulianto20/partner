-- CreateEnum
CREATE TYPE "WalletTransactionType" AS ENUM ('CREDIT', 'DEBIT');

-- CreateTable
CREATE TABLE "PsychologistWalletTransaction" (
    "id" TEXT NOT NULL,
    "psychologistId" TEXT NOT NULL,
    "bookingId" TEXT,
    "type" "WalletTransactionType" NOT NULL,
    "amount" INTEGER NOT NULL,
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "PsychologistWalletTransaction_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "PsychologistWalletTransaction_bookingId_key" ON "PsychologistWalletTransaction" ("bookingId");

-- AddForeignKey
ALTER TABLE "PsychologistWalletTransaction"
ADD CONSTRAINT "PsychologistWalletTransaction_psychologistId_fkey" FOREIGN KEY ("psychologistId") REFERENCES "Psychologist" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PsychologistWalletTransaction"
ADD CONSTRAINT "PsychologistWalletTransaction_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "PsychologistBooking" ("id") ON DELETE SET NULL ON UPDATE CASCADE;