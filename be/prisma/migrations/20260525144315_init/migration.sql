-- CreateTable
CREATE TABLE "Analysis" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "inputText" TEXT NOT NULL,
    "emotionLabel" TEXT NOT NULL,
    "summary" TEXT NOT NULL,
    "recommendations" JSONB,
    "rawJson" JSONB,

    CONSTRAINT "Analysis_pkey" PRIMARY KEY ("id")
);
