-- CreateTable
CREATE TABLE "EmotionEntry" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "moodLabel" TEXT NOT NULL,
    "moodScore" DOUBLE PRECISION,
    "summary" TEXT,
    "recommendations" TEXT,
    "rawResponse" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EmotionEntry_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "EmotionEntry" ADD CONSTRAINT "EmotionEntry_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
