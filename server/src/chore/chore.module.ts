import { Module } from '@nestjs/common';
import { ChoreService } from './chore.service';
import { ChoreController } from './chore.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Chore } from './chore.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Chore])],
  providers: [ChoreService],
  controllers: [ChoreController],
})
export class ChoreModule {}
