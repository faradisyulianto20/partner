-- CreateEnum
CREATE TYPE "EnergyCategory" AS ENUM ('POSITIVE', 'NEGATIVE', 'NEUTRAL');

-- AlterTable
ALTER TABLE "Analysis" ADD COLUMN     "energyCategory" "EnergyCategory",
ADD COLUMN     "userId" TEXT;

-- CreateTable
CREATE TABLE "PartnerQueue" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "energy" "EnergyCategory" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PartnerQueue_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PartnerMatch" (
    "id" TEXT NOT NULL,
    "userAId" TEXT NOT NULL,
    "userBId" TEXT NOT NULL,
    "energyA" "EnergyCategory" NOT NULL,
    "energyB" "EnergyCategory" NOT NULL,
    "status" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PartnerMatch_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PartnerMessage" (
    "id" TEXT NOT NULL,
    "matchId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PartnerMessage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PartnerFavorite" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "partnerId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PartnerFavorite_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PartnerBlock" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "blockedUserId" TEXT NOT NULL,
    "reason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PartnerBlock_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PartnerReport" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "reportedUserId" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PartnerReport_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "PartnerMessage" ADD CONSTRAINT "PartnerMessage_matchId_fkey" FOREIGN KEY ("matchId") REFERENCES "PartnerMatch"("id") ON DELETE CASCADE ON UPDATE CASCADE;
