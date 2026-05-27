-- CreateEnum
CREATE TYPE "ConsultationMethod" AS ENUM ('CHAT', 'VOICE', 'VIDEO');

-- AlterTable
ALTER TABLE "PsychologistBooking" ADD COLUMN     "fullName" TEXT NOT NULL DEFAULT 'Unknown',
ADD COLUMN     "method" "ConsultationMethod" NOT NULL DEFAULT 'CHAT',
ADD COLUMN     "notes" TEXT,
ADD COLUMN     "price" INTEGER NOT NULL DEFAULT 0;
