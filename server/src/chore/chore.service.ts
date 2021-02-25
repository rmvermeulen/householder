import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Chore } from './chore.entity';

@Injectable()
export class ChoreService {
  constructor(
    @InjectRepository(Chore)
    private readonly chores: Repository<Chore>,
  ) {}

  find() {
    return this.chores.find();
  }

  findById(id: number) {
    return this.chores.findOne({ id });
  }
}
