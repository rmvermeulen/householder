import { Controller, Get, Param } from '@nestjs/common';
import { ChoreService } from './chore.service';

@Controller(['chore', 'chores'])
export class ChoreController {
  constructor(private readonly chores: ChoreService) {}

  @Get()
  getChores() {
    return this.chores.find();
  }

  @Get(':id')
  getChore(@Param('id') id: number) {
    return this.chores.findById(id);
  }
}
