import { TypeOrmModule } from '@nestjs/typeorm';

export const dbModule = TypeOrmModule.forRoot({
  type: 'sqlite',
  database: ':memory:',
  autoLoadEntities: true,
  synchronize: true,
  keepConnectionAlive: true,
});
