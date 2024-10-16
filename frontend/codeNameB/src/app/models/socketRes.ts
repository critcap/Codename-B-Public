import { GameStartParameters } from './GameStartParameters';

export interface socketRes {
  action?: string;
  token?: string;
  gameStartParameters?: GameStartParameters;
  fromUser?: string;
  toUser?: string;
  response?: string;
}
