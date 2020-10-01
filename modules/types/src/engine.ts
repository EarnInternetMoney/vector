import { Bytes32 } from "./basic";
import { Balance, FullTransferState } from "./channel";
import { EngineParams } from "./schemas";
import { IVectorStore } from "./store";
import { WithdrawCommitmentJson } from "./transferDefinitions";
import { ChannelRpcMethod, ChannelRpcMethodsResponsesMap } from "./vectorProvider";

///////////////////////////////////
////// Engine transfer types
// Conditional transfers
export const ConditionalTransferType = {
  HashlockTransfer: "HashlockTransfer",
} as const;
export type ConditionalTransferType = typeof ConditionalTransferType[keyof typeof ConditionalTransferType];

export type ConditionalTransferResponse = {
  routingId: Bytes32;
};

///////////////////////////////////
////// Engine event types
// Emitted when transfer created
export const CONDITIONAL_TRANSFER_CREATED_EVENT = "CONDITIONAL_TRANSFER_CREATED";
export type ConditionalTransferCreatedPayload = {
  channelAddress: string;
  transfer: FullTransferState;
  channelBalance: Balance;
  conditionType: ConditionalTransferType;
};

// Emitted when transfer resolved
export const CONDITIONAL_TRANSFER_RESOLVED_EVENT = "CONDITIONAL_TRANSFER_RESOLVED";
export type ConditionalTransferResolvedPayload = ConditionalTransferCreatedPayload;

// Emitted when an onchain deposit is reconciled with offchain balance
export const DEPOSIT_RECONCILED_EVENT = "DEPOSIT_RECONCILED";
export type DepositReconciledPayload = {
  channelAddress: string;
  assetId: string;
  channelBalance: Balance;
};

// Emitted when a withdrawal transfer is created
export const WITHDRAWAL_CREATED_EVENT = "WITHDRAWAL_CREATED";
export type WithdrawalCreatedPayload = {
  channelAddress: string;
  transfer: FullTransferState;
  fee: string;
  assetId: string;
  amount: string;
  recipient: string;
  channelBalance: Balance;
};

// Emitted when a withdrawal transfer is resolved
export const WITHDRAWAL_RESOLVED_EVENT = "WITHDRAWAL_RESOLVED";
export type WithdrawalResolvedPayload = WithdrawalCreatedPayload;

// Emitted when withdrawal commitment is submitted to chain
export const WITHDRAWAL_RECONCILED_EVENT = "WITHDRAWAL_RECONCILED";
export type WithdrawalReconciledPayload = {
  channelAddress: string;
  transactionHash: string;
  transferId: string;
};

// Grouped event types
export const EngineEvents = {
  [CONDITIONAL_TRANSFER_CREATED_EVENT]: CONDITIONAL_TRANSFER_CREATED_EVENT,
  [CONDITIONAL_TRANSFER_RESOLVED_EVENT]: CONDITIONAL_TRANSFER_RESOLVED_EVENT,
  [DEPOSIT_RECONCILED_EVENT]: DEPOSIT_RECONCILED_EVENT,
  [WITHDRAWAL_CREATED_EVENT]: WITHDRAWAL_CREATED_EVENT,
  [WITHDRAWAL_RESOLVED_EVENT]: WITHDRAWAL_RESOLVED_EVENT,
  [WITHDRAWAL_RECONCILED_EVENT]: WITHDRAWAL_RECONCILED_EVENT,
} as const;
export type EngineEvent = typeof EngineEvents[keyof typeof EngineEvents];
export interface EngineEventMap {
  [CONDITIONAL_TRANSFER_CREATED_EVENT]: ConditionalTransferCreatedPayload;
  [CONDITIONAL_TRANSFER_RESOLVED_EVENT]: ConditionalTransferResolvedPayload;
  [DEPOSIT_RECONCILED_EVENT]: DepositReconciledPayload;
  [WITHDRAWAL_CREATED_EVENT]: WithdrawalCreatedPayload;
  [WITHDRAWAL_RESOLVED_EVENT]: WithdrawalResolvedPayload;
  [WITHDRAWAL_RECONCILED_EVENT]: WithdrawalReconciledPayload;
}

///////////////////////////////////
////// Core engine interfaces
export interface IVectorEngine {
  request<T extends ChannelRpcMethod>(payload: EngineParams.RpcRequest): Promise<ChannelRpcMethodsResponsesMap[T]>;
  on<T extends EngineEvent>(
    event: T,
    callback: (payload: EngineEventMap[T]) => void | Promise<void>,
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    filter: (payload: EngineEventMap[T]) => boolean,
  ): void;
  once<T extends EngineEvent>(
    event: T,
    callback: (payload: EngineEventMap[T]) => void | Promise<void>,
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    filter: (payload: EngineEventMap[T]) => boolean,
  ): void;
  off<T extends EngineEvent>(event?: T): void;
}

export interface IEngineStore extends IVectorStore {
  // Getters
  getWithdrawalCommitment(transferId: string): Promise<WithdrawCommitmentJson | undefined>;

  // NOTE: The engine does *not* care about the routingId (it is stored
  // in the meta of transfer objects), only the router module does.
  // However, because the engine fills in basic routing metas using sane
  // defaults, it should also be responsible for providing an easy-access
  // method for higher level modules
  getTransferByRoutingId(channelAddress: string, routingId: string): Promise<FullTransferState | undefined>;

  getTransfersByRoutingId(routingId: string): Promise<FullTransferState[]>;

  // Setters
  saveWithdrawalCommitment(transferId: string, withdrawCommitment: WithdrawCommitmentJson): Promise<void>;
}
