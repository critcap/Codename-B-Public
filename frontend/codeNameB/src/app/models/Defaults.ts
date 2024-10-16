import { Difficulty } from './Difficulty';
import { Map } from './Map';

export class Defaults {
  constructor(
    public maps: Map[],
    public difficulties: Difficulty[],
  ) {}
}
