import { Test, TestingModule } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EntityManager } from 'typeorm';
import { userMatcher } from '../testing/data.matchers';
import { dbModule } from '../testing/db.module';
import { User } from './user.entity';
import { UserService } from './user.service';

describe('UserService', () => {
  let service: UserService;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [dbModule, TypeOrmModule.forFeature([User])],
      providers: [UserService],
    }).compile();

    const mgr: EntityManager = module.get(EntityManager);
    await mgr.save([
      await mgr.create(User, {
        firstName: 'test',
        lastName: 'testing',
        isActive: true,
      }),
      await mgr.create(User, {
        firstName: 'inactive',
        lastName: 'testing',
        isActive: false,
      }),
    ]);

    service = module.get<UserService>(UserService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('can fetch all users', () =>
    expect(service.getUsers()).resolves.toEqual([
      {
        id: 1,
        firstName: 'test',
        lastName: 'testing',
        isActive: true,
      },
      {
        id: 2,
        firstName: 'inactive',
        lastName: 'testing',
        isActive: false,
      },
    ]));

  it('can fetch active users', () =>
    expect(service.getActiveUsers()).resolves.toEqual([
      {
        id: 1,
        firstName: 'test',
        lastName: 'testing',
        isActive: true,
      },
    ]));

  it('can fetch a specific user', async () => {
    const user = await service.getUser(1);
    expect(user).toBeDefined();
    expect(user).toBeInstanceOf(User);
    expect(user).toEqual({
      id: 1,
      firstName: expect.any(String),
      lastName: expect.any(String),
      isActive: expect.any(Boolean),
    });
  });

  it('can create a new user', async () =>
    expect(
      service.createUser({
        firstName: 'Bob',
        lastName: 'Bobson',
      }),
    ).resolves.toEqual({
      ...userMatcher,
      firstName: 'Bob',
      lastName: 'Bobson',
    }));
});
