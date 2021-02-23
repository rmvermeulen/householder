import { Test, TestingModule } from '@nestjs/testing';
import { InjectRepository, TypeOrmModule } from '@nestjs/typeorm';
import { dbModule } from '../testing/db.module';
import { User } from './user.entity';
import { UserService } from './user.service';

describe('UserService', () => {
  let service: UserService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [dbModule, TypeOrmModule.forFeature([User])],
      providers: [UserService],
    })
      .overrideProvider(InjectRepository(User))
      .useValue({
        async find() {
          return [];
        },
      })
      .compile();

    service = module.get<UserService>(UserService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('can fetch active users', () => {
    expect(service.getActiveUsers()).resolves.toStrictEqual([]);
  });
});
