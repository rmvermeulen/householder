import { TypeOrmModule } from '@nestjs/typeorm';

export const databaseTestingModule = TypeOrmModule.forRoot({
  type: 'sqlite',
  database: ':memory:',
  autoLoadEntities: true,
  synchronize: true,
  keepConnectionAlive: true,
});
