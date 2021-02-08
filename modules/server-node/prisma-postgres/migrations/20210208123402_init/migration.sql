-- CreateTable
CREATE TABLE "balance" (
    "participant" TEXT NOT NULL,
    "assetId" TEXT NOT NULL,
    "to" TEXT NOT NULL,
    "amount" TEXT NOT NULL,
    "processedDeposit" TEXT NOT NULL,
    "defundNonce" TEXT NOT NULL,
    "channelAddress" TEXT NOT NULL,

    PRIMARY KEY ("participant","channelAddress","assetId")
);

-- CreateTable
CREATE TABLE "channel" (
    "channelAddress" TEXT NOT NULL,
    "publicIdentifierA" TEXT NOT NULL,
    "publicIdentifierB" TEXT NOT NULL,
    "participantA" TEXT NOT NULL,
    "participantB" TEXT NOT NULL,
    "assetIds" TEXT NOT NULL,
    "timeout" TEXT NOT NULL,
    "nonce" INTEGER NOT NULL,
    "merkleRoot" TEXT NOT NULL,
    "channelFactoryAddress" TEXT NOT NULL,
    "transferRegistryAddress" TEXT NOT NULL,
    "chainId" TEXT NOT NULL,
    "providerUrl" TEXT NOT NULL,
    "inDispute" BOOLEAN NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("channelAddress")
);

-- CreateTable
CREATE TABLE "update" (
    "channelAddress" TEXT,
    "channelAddressId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "fromIdentifier" TEXT NOT NULL,
    "toIdentifier" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "nonce" INTEGER NOT NULL,
    "amountA" TEXT NOT NULL,
    "amountB" TEXT NOT NULL,
    "toA" TEXT NOT NULL,
    "toB" TEXT NOT NULL,
    "assetId" TEXT NOT NULL,
    "signatureA" TEXT,
    "signatureB" TEXT,
    "totalDepositsAlice" TEXT,
    "totalDepositsBob" TEXT,
    "transferAmountA" TEXT,
    "transferAmountB" TEXT,
    "transferToA" TEXT,
    "transferToB" TEXT,
    "transferId" TEXT,
    "transferDefinition" TEXT,
    "transferTimeout" TEXT,
    "transferInitialState" TEXT,
    "transferEncodings" TEXT,
    "merkleProofData" TEXT,
    "meta" TEXT,
    "responder" TEXT,
    "transferResolver" TEXT,
    "merkleRoot" TEXT,

    PRIMARY KEY ("channelAddressId","nonce")
);

-- CreateTable
CREATE TABLE "transfer" (
    "transferId" TEXT NOT NULL,
    "routingId" TEXT NOT NULL,
    "inDispute" BOOLEAN NOT NULL,
    "channelNonce" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "amountA" TEXT NOT NULL,
    "amountB" TEXT NOT NULL,
    "toA" TEXT NOT NULL,
    "toB" TEXT NOT NULL,
    "initialStateHash" TEXT NOT NULL,
    "channelAddress" TEXT,
    "channelAddressId" TEXT NOT NULL,
    "createUpdateChannelAddressId" TEXT,
    "createUpdateNonce" INTEGER,
    "resolveUpdateChannelAddressId" TEXT,
    "resolveUpdateNonce" INTEGER,

    PRIMARY KEY ("transferId")
);

-- CreateTable
CREATE TABLE "event-subscription" (
    "id" TEXT NOT NULL,
    "event" TEXT NOT NULL,
    "publicIdentifier" TEXT NOT NULL,
    "url" TEXT NOT NULL,

    PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "onchain_transaction" (
    "transactionHash" TEXT NOT NULL,
    "to" TEXT NOT NULL,
    "from" TEXT NOT NULL,
    "data" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "chainId" TEXT NOT NULL,
    "nonce" INTEGER NOT NULL,
    "gasLimit" TEXT NOT NULL,
    "gasPrice" TEXT NOT NULL,
    "timestamp" TEXT,
    "raw" TEXT,
    "blockHash" TEXT,
    "blockNumber" INTEGER,
    "contractAddress" TEXT,
    "transactionIndex" INTEGER,
    "root" TEXT,
    "gasUsed" TEXT,
    "logsBloom" TEXT,
    "logs" TEXT,
    "cumulativeGasUsed" TEXT,
    "byzantium" BOOLEAN,
    "status" TEXT NOT NULL DEFAULT E'submitted',
    "reason" TEXT NOT NULL,
    "error" TEXT,
    "channelAddress" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("transactionHash")
);

-- CreateTable
CREATE TABLE "configuration" (
    "id" INTEGER NOT NULL,
    "mnemonic" TEXT NOT NULL,

    PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "node_index" (
    "index" INTEGER NOT NULL,
    "publicIdentifier" TEXT NOT NULL,

    PRIMARY KEY ("index")
);

-- CreateIndex
CREATE UNIQUE INDEX "channel.publicIdentifierA_publicIdentifierB_chainId_unique" ON "channel"("publicIdentifierA", "publicIdentifierB", "chainId");

-- CreateIndex
CREATE UNIQUE INDEX "channel.participantA_participantB_chainId_unique" ON "channel"("participantA", "participantB", "chainId");

-- CreateIndex
CREATE UNIQUE INDEX "update_channelAddress_unique" ON "update"("channelAddress");

-- CreateIndex
CREATE UNIQUE INDEX "transfer.routingId_channelAddressId_unique" ON "transfer"("routingId", "channelAddressId");

-- CreateIndex
CREATE UNIQUE INDEX "transfer_createUpdateChannelAddressId_createUpdateNonce_unique" ON "transfer"("createUpdateChannelAddressId", "createUpdateNonce");

-- CreateIndex
CREATE UNIQUE INDEX "transfer_resolveUpdateChannelAddressId_resolveUpdateNonce_unique" ON "transfer"("resolveUpdateChannelAddressId", "resolveUpdateNonce");

-- CreateIndex
CREATE UNIQUE INDEX "event-subscription.publicIdentifier_event_unique" ON "event-subscription"("publicIdentifier", "event");

-- CreateIndex
CREATE UNIQUE INDEX "onchain_transaction.transactionHash_chainId_unique" ON "onchain_transaction"("transactionHash", "chainId");

-- CreateIndex
CREATE UNIQUE INDEX "configuration.mnemonic_unique" ON "configuration"("mnemonic");

-- CreateIndex
CREATE UNIQUE INDEX "node_index.publicIdentifier_unique" ON "node_index"("publicIdentifier");

-- AddForeignKey
ALTER TABLE "balance" ADD FOREIGN KEY ("channelAddress") REFERENCES "channel"("channelAddress") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "update" ADD FOREIGN KEY ("channelAddress") REFERENCES "channel"("channelAddress") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transfer" ADD FOREIGN KEY ("createUpdateChannelAddressId", "createUpdateNonce") REFERENCES "update"("channelAddressId", "nonce") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transfer" ADD FOREIGN KEY ("resolveUpdateChannelAddressId", "resolveUpdateNonce") REFERENCES "update"("channelAddressId", "nonce") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transfer" ADD FOREIGN KEY ("channelAddress") REFERENCES "channel"("channelAddress") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "onchain_transaction" ADD FOREIGN KEY ("channelAddress") REFERENCES "channel"("channelAddress") ON DELETE CASCADE ON UPDATE CASCADE;
