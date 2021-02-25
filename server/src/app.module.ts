import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { User } from './user/user.entity';
import { UserModule } from './user/user.module';
import { ChoreModule } from './chore/chore.module';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: 'localhost',
      port: 5432,
      username: 'rasmus',
      database: 'householder',
      autoLoadEntities: true,
    }),
    UserModule,
    ChoreModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
